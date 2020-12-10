
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as random from "@pulumi/random";
import * as gcp from "@pulumi/gcp";
import * as docker from "@pulumi/docker";
import * as gcs from "@google-cloud/storage";
import * as ingest from "./ingest";
import * as _ from "lodash";

// Arguments for the demo app.
export interface MIngestArgs {
    provider: k8s.Provider; // Provider resource for the target Kubernetes cluster.
    imageTag: string; // Tag for the kuard image to deploy.
    staticAppIP?: pulumi.Input<string>; // Optional static IP to use for the service. (Required for AKS).
    isMinikube?: boolean;
    replicas?: number;
    gcpBucket?:gcp.storage.Bucket;
    dataMountPath:string;
    pullPolicy?:string
    ports?: number[];
    allocateIpAddress?: boolean;
}

async function listFiles(
    storage:gcs.Storage, 
    bucketName:string, 
    episodeLength:number, 
    maxEpisodes:number
  ):Promise<string[]> {
    let outs:string[] = []; 
    // Lists files in the bucket
    const [files] = await storage.bucket(bucketName).getFiles();

    console.log('Files:');
    files.forEach(file => {
        outs.push(file.name);
    });
    return outs;
}

export class MIngest extends pulumi.ComponentResource {
    public readonly bucket: gcp.storage.Bucket; 
    // public readonly gcssecret: k8s.core.v1.Secret; 
    public readonly deployment: k8s.apps.v1.Deployment; 
    public readonly service: k8s.core.v1.Service;
    public readonly ipAddress?: pulumi.Output<string>;
    public readonly keyfilepath: string;
    public readonly mountDataPath: string;
    public readonly testDataPath: string;
    public readonly gateImage: docker.Image; 
    public readonly ingestImage: docker.Image; 
    public readonly servants: Record<string, ingest.Ingest>; 

    constructor(name: string,
                args: MIngestArgs,
                opts: pulumi.ComponentResourceOptions = {}) {
        super("beast:qenv:ingest", name, args, opts);
            
        this.bucket = gcp.storage.Bucket.get("axiomdata", "axiomdata");

        this.gateImage = new docker.Image(`${name}-gate-image`, {
            imageName: "thorad/ingest",
            build: {
                dockerfile: "./ingest/Dockerfile",
                context: "./ingest/",
            },
            skipPush: false,
        });

        this.ingestImage = new docker.Image(`${name}-ingest-image`, {
            imageName: "thorad/ingest",
            build: {
                dockerfile: "./ingest/Dockerfile",
                context: "./ingest/",
            },
            skipPush: false,
        });

        this.keyfilepath = "/var/secrets/google/key.json";
        this.testDataPath = "/ingest/testdata/events"
        this.mountDataPath = args.dataMountPath + "/events"

        const batchSize = 2;
        const maxBatches = 5;

        const storage = new gcs.Storage();

        listFiles(
            storage, 
            "axiomdata", 
            batchSize, 
            maxBatches).catch(console.error);


        let files = [445855, 445856, 445857];  
        let batches = _.chunk(files, batchSize);
        console.log(batches)

        this.servants = {};
        for(let i=0;i<batches.length;i++) {
            let batch = batches[i];
            console.log(batch);
            let name = 'ingest-${i}';
            let conf = {
                sId: i,
                host: name,
                port: 5000,
                start: _.max(batch), 
                end: _.min(batch)
            };
            console.log(conf);
            
            this.servants[name] = new ingest.Ingest(name, {
                provider: args.provider,  
                image: this.ingestImage,
                dataMountPath:this.mountDataPath
            });
        };

        // TODO create a gateway and register ordinal paths as a conf file
        const gatewayLabels = {app: "ingest"};
        this.deployment = new k8s.apps.v1.Deployment(`${name}-ingest`, {
            spec: {
                selector: {
                    matchLabels: gatewayLabels,
                },
                replicas: (args.replicas || 1),
                template: {
                    metadata: {labels: gatewayLabels},
                    spec: {
                        containers: [
                            {
                                name: "ingest",
                                image: `thorad/ingest:${args.imageTag}`,
                                imagePullPolicy:(args.pullPolicy || "Always"), 
                                env: [
                                    { 
                                        name: "GOOGLE_APPLICATION_CREDENTIALS", 
                                        value: this.keyfilepath 
                                    },
                                    { 
                                        name: "DATA_PATH", 
                                        value: args.dataMountPath 
                                    }
                                ],
                                ports: [
                                      {containerPort: 5000, name: "kdb"}
                                ],
                                // livenessProbe: {
                                //     httpGet: {path: "/healthy", port: "kdb"},
                                //     initialDelaySeconds: 5,
                                //     timeoutSeconds: 1,
                                //     periodSeconds: 10,
                                //     failureThreshold: 3,
                                // },
                                // readinessProbe: {
                                //     httpGet: {path: "/ready", port: "kdb"},
                                //     initialDelaySeconds: 5,
                                //     timeoutSeconds: 1,
                                //     periodSeconds: 10,
                                //     failureThreshold: 3,
                                // },
                                // volumeMounts: [
                                //     {
                                //         name: "google-cloud-key",
                                //         mountPath: "/var/secrets/google"
                                //     }
                                // ],
                            },
                        ],
                    },
                },
            },
        }, {provider: args.provider, parent: this});

        this.service = new k8s.core.v1.Service(`${name}-gateway`, {
            metadata: {
                name: name,
                labels: this.deployment.metadata.labels,
            },
            spec: {
                ports: args.ports && args.ports.map(p => ({ port: p, targetPort: p })),
                selector: this.deployment.spec.template.metadata.labels,
            },
        }, { parent: this });

        this.registerOutputs();
    }
}
