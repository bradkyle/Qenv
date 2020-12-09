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
}

export class Ingest extends pulumi.ComponentResource {

    constructor(name: string,
                args: IngestArgs,
                opts: pulumi.ComponentResourceOptions = {}) {
        super("beast:qenv:ingest", name, args, opts);
            
        const data_bucket = gcp.storage.Bucket.get("axiomdata", "axiomdata");

        const image = new docker.Image(`${name}-ingest-image`, {
            imageName: "thorad/ingest",
            build: {
                dockerfile: "./ingest/Dockerfile",
                context: "./ingest/",
            },
            skipPush: false,
        });

        // Create a Secret to hold the MariaDB credentials.
        const kdbSecret = new k8s.core.v1.Secret("ingest", {
            stringData: {
                "kdb-password": new random.RandomPassword("kdb-pw", {length: 12}).result
            }
        }, { provider: args.provider });

        // Create the kuard Deployment.
        const appLabels = {app: "ingest"};
        const deployment = new k8s.apps.v1.StatefulSet(`${name}-ingest`, {
            spec: {
                selector: {
                    matchLabels: appLabels,
                },
                serviceName: "ingest",
                updateStrategy :{
                    type: "RollingUpdate"
                },
                replicas: 1,
                template: {
                    metadata: {labels: appLabels},
                    spec: {
                        serviceAccountName: "default",
                        securityContext: {
                            fsGroup: 1001,
                            runAsUser: 1001
                        },
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
                        containers: [
                            {
                                name: "ingest",
                                image: `thorad/ingest:${args.imageTag}`,
                                imagePullPolicy: "IfNotPresent",
                                env: [
                                    { 
                                        name: "KDB_USER", 
                                        value: "ingest" 
                                    },
                                    {
                                        name: "KDB_PASS",
                                        valueFrom: {
                                            secretKeyRef: {
                                                name: kdbSecret.metadata.name,
                                                key: "kdb-password"
                                            }
                                        }
                                    },
                                    { 
                                        name: "DVC_REMOTE", 
                                        value: "/ingest/data" 
                                    },
                                    { 
                                        name: "DATA_PATH", 
                                        value: "/ingest/data" 
                                    }
                                ],
                                ports: [{containerPort: 5000, name: "kdb"}],
                                livenessProbe: {
                                    httpGet: {path: "/healthy", port: "kdb"},
                                    initialDelaySeconds: 5,
                                    timeoutSeconds: 1,
                                    periodSeconds: 10,
                                    failureThreshold: 3,
                                },
                                readinessProbe: {
                                    httpGet: {path: "/ready", port: "kdb"},
                                    initialDelaySeconds: 5,
                                    timeoutSeconds: 1,
                                    periodSeconds: 10,
                                    failureThreshold: 3,
                                },
                                volumeMounts: [
                                    {
                                        name: "data",
                                        mountPath: "/ingest/data"
                                    },
                                ]
                            },
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
                                    storage: "8Gi"
                                }
                            }
                        }
                    }
                ]
            },
        }, {provider: args.provider, parent: this});

        this.registerOutputs();
    }
}
