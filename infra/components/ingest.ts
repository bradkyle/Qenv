import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as random from "@pulumi/random";
import * as gcp from "@pulumi/gcp";
import * as docker from "@pulumi/docker";
import * as gcs from "@google-cloud/storage";

const fs = require('fs');

// Arguments for the demo app.
export interface IngestArgs {
    provider: k8s.Provider; // Provider resource for the target Kubernetes cluster.
    image?: docker.Image; // Tag for the kuard image to deploy.
    staticAppIP?: pulumi.Input<string>; // Optional static IP to use for the service. (Required for AKS).
    isMinikube?: boolean;
    replicas?: number;
    gcpBucket?:gcp.storage.Bucket;
    dataMountPath?:string;
    pullPolicy?:string
    ports?: number[];
    datapaths?:string[];
    allocateIpAddress?: boolean;
    testing?: boolean;
    skipPush?: boolean;
    gcpDataPath?: string
}

export class Ingest extends pulumi.ComponentResource {
    public readonly bucket: gcp.storage.Bucket; 
    public readonly image: docker.Image; 
    // public readonly gcssecret: k8s.core.v1.Secret; 
    public readonly deployment: k8s.apps.v1.StatefulSet; 
    public readonly service: k8s.core.v1.Service;
    public readonly ipAddress?: pulumi.Output<string>;
    public readonly keyfilepath: string;
    public readonly datapaths: string[];

    constructor(name: string,
                args: IngestArgs,
                opts: pulumi.ComponentResourceOptions = {}) {
        super("beast:qenv:ingest", name, args, opts);
            
        if (args.gcpBucket) {
            this.bucket = args.gcpBucket;
        } else {
            this.bucket = gcp.storage.Bucket.get("axiomdata", "axiomdata");
        }
        const ts = Date.now();

        if(args.image){
            console.log("Using cached image");
            this.image = args.image;
        } else {
            this.image = new docker.Image(`${name}-ingest-image`, {
                imageName: "thorad/ingest:latest",
                build: {
                    dockerfile: "./ingest/Dockerfile",
                    context: "./ingest/",
                },
                skipPush:(args.skipPush || true),
            });
        };

        this.keyfilepath = "/var/secrets/google/key.json";

        // TODO create a gateway and register ordinal paths as a conf file
        // for (i of)
        const appLabels = {app: "ingest"};
        this.datapaths = (args.datapaths || []);
        
        fs.writeFile('./ingest/data.txt', this.datapaths.join("\n"), (err:any) => {
            // throws an error, you could also catch it here
            if (err) throw err;
        });

        // const gcloudKey = new k8s.core.v1.ConfigMap(`${name}-gcloud-key`, {
        //     metadata: { labels: appLabels },
        //     data: { "data.list": JSON.stringify(this.datapaths)},
        // });
        // const gcloudKeyName = gcloudKey.metadata.apply(m => m.name);

        // gsutil -m cp -r data.list
        const ingestConfig = new k8s.core.v1.ConfigMap(`${name}-ingest`, {
            metadata: { labels: appLabels },
            data: { "data.list": this.datapaths.join("\n")},
        }, {provider: args.provider, parent: this});
        const ingestConfigName = ingestConfig.metadata.apply(m => m.name);

        const datapath = (args.dataMountPath || "/ingest/testdata/events");
        this.deployment = new k8s.apps.v1.StatefulSet(`${name}-ingest`, {
            spec: {
                selector: {
                    matchLabels: appLabels,
                },
                serviceName: "ingest",
                updateStrategy :{
                    // type: "RollingUpdate"
                },
                replicas: 1,
                template: {
                    metadata: {labels: appLabels},
                    spec: {
                        serviceAccountName: "default",
                        containers: [
                            {
                                name: "ingest",
                                image: this.image.imageName,
                                imagePullPolicy:(args.pullPolicy || "Always"), 
                                env: [
                                    { 
                                        name: "GOOGLE_APPLICATION_CREDENTIALS", 
                                        value: this.keyfilepath 
                                    },
                                    { 
                                        name: "CONFIG_PATH", 
                                        value: this.keyfilepath 
                                    },
                                    { 
                                        name: "DATA_PATH", 
                                        value: "/ingest/data/events" 
                                    }
                                ],
                                volumeMounts: [
                                    {
                                        name: "data-list",
                                        mountPath: "/ingest/config/datalist"
                                    },
                                    (!args.isMinikube ? {
                                        name:"data",
                                        mountPath:datapath
                                    }:{name:"data",mountPath:"/data"}),
                                ],
                                ports: [
                                      {containerPort: 5000, name: "kdb"}
                                ],
                                lifecycle:{
                                    postStart :(args.isMinikube ? {
                                        exec :{
                                            command :["ls"]
                                        }
                                    }:{
                                        exec : {
                                            command: [
                                                "/bin/sh",
                                                "./getdata.sh", 
                                                "/ingest/config/datalist/data.list",
                                                datapath
                                            ]
                                        }
                                    }),
                                    // preStop:{
                                    //     exec : {
                                    //         command: [
                                    //             "fusermount", 
                                    //             "-u", 
                                    //             args.stateMountPath
                                    //         ]
                                    //     }
                                    // }
                                }

                            },
                        ],
                        volumes :[
                            // {
                            //     name: "google-cloud-key",
                            //     secret : {}
                            // },
                            {
                                name: "data-list",
                                configMap: {
                                    name: ingestConfigName
                                }
                            }
                        ],
                    },
                },
                volumeClaimTemplates: [
                    { 
                        metadata: {
                            name: "data",
                            labels: {
                                app: "ingest",
                                component: "master",
                                release: "example",
                            }
                        },
                        spec: {
                            accessModes: [
                                "ReadWriteOnce"
                            ],
                            resources: {
                                requests: {
                                    storage: "5Gi"
                                }
                            }
                        }
                    }
                ]
            },
        }, {provider: args.provider, parent: this});


        this.service = new k8s.core.v1.Service(`${name}-ingest`, {
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
