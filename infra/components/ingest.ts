import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as random from "@pulumi/random";
import * as gcp from "@pulumi/gcp";
import * as docker from "@pulumi/docker";

// Arguments for the demo app.
export interface IngestArgs {
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

export class Ingest extends pulumi.ComponentResource {
    public readonly bucket: gcp.storage.Bucket; 
    public readonly image: docker.Image; 
    public readonly kdbsecret: k8s.core.v1.Secret; 
    // public readonly gcssecret: k8s.core.v1.Secret; 
    public readonly deployment: k8s.apps.v1.Deployment; 
    public readonly service: k8s.core.v1.Service;
    public readonly ipAddress?: pulumi.Output<string>;

    constructor(name: string,
                args: IngestArgs,
                opts: pulumi.ComponentResourceOptions = {}) {
        super("beast:qenv:ingest", name, args, opts);
            
        this.bucket = gcp.storage.Bucket.get("axiommulti", "axiommulti");

        this.image = new docker.Image(`${name}-ingest-image`, {
            imageName: "thorad/ingest",
            build: {
                dockerfile: "./ingest/Dockerfile",
                context: "./ingest/",
            },
            skipPush: false,
        });

        // Create a Secret to hold the MariaDB credentials.
        this.kdbsecret = new k8s.core.v1.Secret("ingest", {
            stringData: {
                "kdb-password": new random.RandomPassword("kdb-pw", {length: 12}).result
            }
        }, { provider: args.provider });

        // Create the kuard Deployment.
        const appLabels = {app: "ingest"};
        this.deployment = new k8s.apps.v1.Deployment(`${name}-ingest`, {
            spec: {
                selector: {
                    matchLabels: appLabels,
                },
                replicas: args.replicas,
                template: {
                    metadata: {labels: appLabels},
                    spec: {
                        affinity: {
                            podAntiAffinity: {
                                preferredDuringSchedulingIgnoredDuringExecution: [
                                    {
                                        weight: 1,
                                        podAffinityTerm: {
                                            topologyKey: "kubernetes.io/hostname",
                                            labelSelector: {
                                                matchLabels: {
                                                    app: "ingest",
                                                    release: "example"
                                                }
                                            }
                                        }
                                    }
                                ]
                            }
                        },
                        // volumes :[
                        //     {
                        //         name: "google-cloud-key",
                        //         secret : {

                        //         }
                        //     }
                        // ],
                        containers: [
                            {
                                name: "ingest",
                                image: `thorad/ingest:${args.imageTag}`,
                                imagePullPolicy:(args.pullPolicy || "Always"), 
                                env: [
                                    { 
                                        name: "KDB_USER", 
                                        value: "ingest" 
                                    },
                                    {
                                        name: "KDB_PASS",
                                        valueFrom: {
                                            secretKeyRef: {
                                                name: this.kdbsecret.metadata.name,
                                                key: "kdb-password"
                                            }
                                        }
                                    },
                                    { 
                                        name: "DVC_REMOTE", 
                                        value: "/ingest/data" 
                                    },
                                    { 
                                        name: "GOOGLE_APPLICATION_CREDENTIALS", 
                                        value: "/var/secrets/google/key.json" 
                                    },
                                    { 
                                        name: "DATA_PATH", 
                                        value: args.dataMountPath 
                                    }
                                ],
                                ports: [{containerPort: 5000, name: "kdb"}],
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
                                lifecycle:{
                                    postStart :{
                                        exec : {
                                            command: [
                                                "gcsfuse", 
                                                "--implicit-dirs", 
                                                "-o", 
                                                "nonempty", 
                                                this.bucket.name, 
                                                args.dataMountPath
                                            ]
                                        }
                                    },
                                    preStop:{
                                        exec : {
                                            command: [
                                                "fusermount", 
                                                "-u", 
                                                args.dataMountPath 
                                            ]
                                        }
                                    }
                                }
                            },
                        ],
                    },
                },
            },
        }, {provider: args.provider, parent: this});


        this.service = new k8s.core.v1.Service(name, {
            metadata: {
                name: name,
                labels: this.deployment.metadata.labels,
            },
            spec: {
                ports: args.ports && args.ports.map(p => ({ port: p, targetPort: p })),
                selector: this.deployment.spec.template.metadata.labels,
                // Minikube does not implement services of type `LoadBalancer`; require the user to specify if we're
                // running on minikube, and if so, create only services of type ClusterIP.
                type: args.allocateIpAddress ? (args.isMinikube ? "ClusterIP" : "LoadBalancer") : undefined,
            },
        }, { parent: this });

        this.registerOutputs();
    }
}
