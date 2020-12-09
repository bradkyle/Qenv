
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";

// Arguments for the demo app.
export interface ImpalaArgs {
    provider: k8s.Provider; // Provider resource for the target Kubernetes cluster.
    imageTag: string; // Tag for the kuard image to deploy.
}

export class Impala extends pulumi.ComponentResource {

    constructor(name: string,
                args: ImpalaArgs,
                opts: pulumi.ComponentResourceOptions = {}) {
        super("beast:impala:train", name, args, opts);

        // Create a ConfigMap to hold the MariaDB configuration.
        const impalaCM = new k8s.core.v1.ConfigMap("impala", {
            data: {
            "config.py": `
            config = {
                'experiment_name': 'Qenv',
                'master_address': 'localhost:8010',
                'env':[
                    {'host':'env1','port':5000},
                    {'host':'env2','port':5000},
                    {'host':'env3','port':5000},
                ],
                'actor_num': 2,
                'pool_size': 4,
                'num_steps':500000,
                'sample_batch_steps': 50,
                'train_batch_size': 1000,
                'sample_queue_max_size': 8,
                'gamma': 0.99,
                'lr_scheduler': [(0, 0.001), (20000, 0.0005), (40000, 0.0001)],
                'entropy_coeff_scheduler': [(0, -0.01)],
                'vf_loss_coeff': 0.5,
                'clip_rho_threshold': 1.0,
                'clip_pg_rho_threshold': 1.0,
                'get_remote_metrics_interval': 10,
                'log_metrics_interval_s': 10,
                'params_broadcast_interval': 5,
            }
            `}}, { provider: args.provider });

        // Create the kuard Deployment.
        const appLabels = {app: "impala"};
        const deployment = new k8s.apps.v1.StatefulSet(`${name}-impala`, {
            spec: {
                selector: {
                    matchLabels: appLabels,
                },
                serviceName: "impala",
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
                                                    app: "impala",
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
                                name: "impala",
                                image: `thorad/parl:${args.imageTag}`,
                                imagePullPolicy: "IfNotPresent",
                                env: [
                                    { 
                                        name: "NUM_WORKERS", 
                                        value: "2" 
                                    },
                                    { 
                                        name: "CONFIG_PATH", 
                                        value: "/impala/config.py" 
                                    }
                                ],
                                volumeMounts: [
                                    {
                                        name: "data",
                                        mountPath: "/ingest/data"
                                    },
                                    {
                                        name: "config",
                                        mountPath: "/impala/config.py",
                                        subPath: "config.py"
                                    }
                                ]
                            },
                        ],
                        volumes: [
                            {
                                name: "config",
                                configMap: {
                                    name: impalaCM.metadata.name 
                                }
                            }
                        ]
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
