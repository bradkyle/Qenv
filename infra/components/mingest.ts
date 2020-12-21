
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as random from "@pulumi/random";
import * as gcp from "@pulumi/gcp";
import * as docker from "@pulumi/docker";
import * as ingest from "./ingest";
import * as _ from "lodash";
const execSync = require('child_process').execSync;

// Arguments for the demo app.
export interface MIngestArgs {
    provider: k8s.Provider; // Provider resource for the target Kubernetes cluster.
    staticAppIP?: pulumi.Input<string>; // Optional static IP to use for the service. (Required for AKS).
    isMinikube?: boolean;
    replicas?: number;
    gcpBucket?:gcp.storage.Bucket;
    dataMountPath:string;
    pullPolicy?:string
    allocateIpAddress?: boolean;
    skipPush?: boolean;
    start:number;
    end:number;
    batchSize:number;
    maxBatches:number;
}

export interface ServantSpec {
    sId?: number,
    host?: string,
    port?: number,
    start?: number,
    end?: number
}

function getBatches(
    bucketPath:string, 
    batchSize:number,
    maxBatches:number,
    start:number,
    end:number
  ):number[][] {
    // Lists files in the bucket
    let files:string[] = execSync("gsutil ls "+bucketPath).toString("utf8").split("\n");
    let names = files.map(f=>f.split("/"));
    let nbrs = names.map(f=>f[5]).map(Number);
    nbrs = nbrs.filter(f=>!Number.isNaN(f));
    nbrs = _.uniq(nbrs);
    nbrs = _.filter(nbrs,n=>n>start); 
    nbrs = _.filter(nbrs,n=>n<end); 
    let batches:number[][] = _.chunk(nbrs, batchSize);
    batches = _.slice(batches, 0, maxBatches);
    return batches;
}

export class MIngest extends pulumi.ComponentResource {
    public readonly bucket: gcp.storage.Bucket; 
    // public readonly gcssecret: k8s.core.v1.Secret; 
    public deployment: k8s.apps.v1.Deployment; 
    public service: k8s.core.v1.Service;
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
            imageName: "thorad/gate",
            build: {
                dockerfile: "./ingest/gate.Dockerfile",
                context: "./ingest/",
            },
            skipPush:false
        });

        this.ingestImage = new docker.Image(`${name}-ingest-image`, {
            imageName: "thorad/ingest",
            build: {
                dockerfile: "./ingest/ingest.Dockerfile",
                context: "./ingest/",
            },
            skipPush:false,
        });

        this.keyfilepath = "/var/secrets/google/key.json";
        this.testDataPath = "/ingest/testdata/events"
        this.mountDataPath = args.dataMountPath + "/events"

        const start = args.start;
        const end = args.end;
        const batchSize = args.batchSize;
        const maxBatches = args.maxBatches;

        this.conf = [];
        this.servants = {};
        let batches = getBatches("gs://axiomdata/okex/events/", batchSize, maxBatches, start, end);

        if (batches && batches.length>0){
            for(let i=0;i<batches.length;i++) {
                let batch = batches[i];
                let dirs = batch.map(p=>"gs://axiomdata/okex/events/"+p.toString()+","+p.toString());
                dirs.push("gs://axiomdata/okex/events/ev,ev\n");
                let s = i.toString();
                let sname = (`ingest-${s}`);
                console.log(dirs);
                this.servants[sname] = new ingest.Ingest(sname, {
                    provider: args.provider,  
                    isMinikube:args.isMinikube,
                    image: this.ingestImage,
                    gcpBucket: this.bucket,
                    dataMountPath:this.mountDataPath,
                    datapaths: dirs
                });
                this.conf.push({
                    sId: i,
                    host: sname,
                    port: 5000,
                    start: _.min(batch), 
                    end: _.max(batch)
                });
            };
        };

        const appLabels = {app: "gate"};
        const gateConfig = new k8s.core.v1.ConfigMap(`${name}-gate`, {
            metadata: { labels: appLabels },
            data: { "config.json": JSON.stringify(this.conf)},
        }, {provider: args.provider, parent: this});
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
                                image:this.gateImage.imageName, 
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
                name: "gate",
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
