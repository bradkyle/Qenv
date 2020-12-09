
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as random from "@pulumi/random";

// Arguments for the demo app.
export interface InferenceArgs {
    provider: k8s.Provider; // Provider resource for the target Kubernetes cluster.
    imageTag: string; // Tag for the kuard image to deploy.
    staticAppIP?: pulumi.Input<string>; // Optional static IP to use for the service. (Required for AKS).
}

export class Inference extends pulumi.ComponentResource {

    constructor(name: string,
                args: InferenceArgs,
                opts: pulumi.ComponentResourceOptions = {}) {
        super("examples:kubernetes-ts-multicloud:demo-app", name, args, opts);
        //
        // Create a Secret to hold the MariaDB credentials.
        const kdbSecret = new k8s.core.v1.Secret("mariadb", {
            stringData: {
                "kdb-root-password": new random.RandomPassword("mariadb-root-pw", {
                    length: 12}).result,
                "kdb-password": new random.RandomPassword("mariadb-pw", {
                    length: 12}).result
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
                                        name: "KDB_ROOT_PASSWORD",
                                        valueFrom: {
                                            secretKeyRef: {
                                                name: kdbSecret.metadata.name,
                                                key: "kdb-root-password"
                                            }
                                        }
                                    },
                                    { name: "MARIADB_USER", value: "bn_wordpress" },
                                    {
                                        name: "KDB_PASSWORD",
                                        valueFrom: {
                                            secretKeyRef: {
                                                name: kdbSecret.metadata.name,
                                                key: "kdb-password"
                                            }
                                        }
                                    },
                                    { name: "MARIADB_DATABASE", value: "bitnami_wordpress" }
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
                                        mountPath: "/bitnami/mariadb"
                                    },
                                    {
                                        name: "config",
                                        mountPath: "/opt/bitnami/mariadb/conf/my.cnf",
                                        subPath: "my.cnf"
                                    }
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
