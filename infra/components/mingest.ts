
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

export interface ServantSpec {
    sId?: number,
    host?: string,
    port?: number,
    start?: number,
    end?: number
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
    public readonly conf: Array<ServantSpec>; 

    constructor(name: string,
                args: MIngestArgs,
                opts: pulumi.ComponentResourceOptions = {}) {
        super("beast:qenv:gate", name, args, opts);
            
        this.bucket = gcp.storage.Bucket.get("axiomdata", "axiomdata");
        const ts=Date.now();

        this.gateImage = new docker.Image(`${name}-gate-image`, {
            imageName: "thorad/gate:d"+ts.toString(),
            build: {
                dockerfile: "./ingest/gate.Dockerfile",
                context: "./ingest/",
            },
            skipPush: false,
        });

        this.ingestImage = new docker.Image(`${name}-ingest-image`, {
            imageName: "thorad/ingest:d"+ts.toString(),
            build: {
                dockerfile: "./ingest/ingest.Dockerfile",
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

        // listFiles(
        //     storage, 
        //     "axiomdata", 
        //     batchSize, 
        //     maxBatches).catch(console.error);

        let files = [445855, 445856, 445857];  
        let batches = _.chunk(files, batchSize);

        this.conf = [];
        this.servants = {};
        for(let i=0;i<batches.length;i++) {
            let batch = batches[i];
            let s = i.toString();
            let sname = (`ingest-${s}`);
            // let datapaths = batch.map(c => this.bucket.url+"/okex/events/"+c.toString());
            // datapaths.push(this.bucket.url+"/okex/events/ev");
            // console.log(datapaths);
            this.servants[sname] = new ingest.Ingest(sname, {
                provider: args.provider,  
                image: this.ingestImage,
                gcpBucket: this.bucket,
                dataMountPath:this.mountDataPath
            });
            this.conf.push({
                sId: i,
                host: sname,
                port: 5000,
                start: _.min(batch), 
                end: _.max(batch)
            });
        };
        console.log(JSON.stringify(this.conf));

        const appLabels = {app: "gate"};
        const gateConfig = new k8s.core.v1.ConfigMap(`${name}-gate`, {
            metadata: { labels: appLabels },
            data: { "config.json": JSON.stringify(this.conf)},
        });
        const gateConfigName = gateConfig.metadata.apply(m => m.name);

        // TODO create a gateway and register ordinal paths as a conf file
        this.deployment = new k8s.apps.v1.Deployment(`${name}-gate`, {
            spec: {
                selector: {
                    matchLabels: appLabels,
                },
                replicas: (args.replicas || 1),
                template: {
                    metadata: {labels: appLabels},
                    spec: {
                        containers: [
                            {
                                name: "gate",
                                image: this.gateImage.imageName, 
                                imagePullPolicy:(args.pullPolicy || "Always"), 
                                env: [
                                    { 
                                        name: "CONFIGPATH", 
                                        value: "/gate/config/config.json" 
                                    },
                                ],
                                ports:[
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
                                volumeMounts: [
                                    {
                                        name: "gate-configs",
                                        mountPath: "/gate/config"
                                    }
                                ],
                            },
                        ],
                        volumes: [{ name: "gate-configs", configMap: { name: gateConfigName } }],
                    },
                },
            },
        }, {provider: args.provider, parent: this});

        this.service = new k8s.core.v1.Service(`${name}-gate`, {
            metadata: {
                name: name,
                labels: this.deployment.metadata.labels,
            },
            spec: {
                ports: [{name:"kdb", port:5000, targetPort:"kdb"}], 
                selector: this.deployment.spec.template.metadata.labels,
            },
        }, { parent: this });

        this.registerOutputs();
    }
}
