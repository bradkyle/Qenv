
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as docker from "@pulumi/docker";
import * as gcp from "@pulumi/gcp";

// Arguments for the demo app.
export interface ImpalaArgs {
    provider: k8s.Provider; // Provider resource for the target Kubernetes cluster.
    imageTag: string; // Tag for the kuard image to deploy.
    skipPush?: boolean;
}

export class Impala extends pulumi.ComponentResource {
    public readonly image: docker.Image; 
    // public readonly nodepool: gcp.container.Nodepool;

    constructor(name: string,
                args: ImpalaArgs,
                opts: pulumi.ComponentResourceOptions = {}) {
        super("beast:impala:train", name, args, opts);

        this.image = new docker.Image(`${name}-impala-image`, {
            imageName: "gcr.io/beast-298015/impala:latest",
            build: {
                dockerfile: "./impala/Dockerfile",
                context: "./impala/",
            },
            skipPush:(args.skipPush || true),
        });
    
        const envs = {};

        // this.nodepool = new gcp.container.NodePool("", {
        //     cluster:args.cluster.name,
        //     version:"",
        //     initialNodeCount:1,
        //     nodeConfig: {
        //         machineType: "",
        //         oauthScopes: [
        //             "https://www.googleapis.com/auth/compute",
        //             "https://www.googleapis.com/auth/devstorage.read_only",
        //             "https://www.googleapis.com/auth/logging.write",
        //             "https://www.googleapis.com/auth/monitoring",
        //         ],
        //         guestAccelerators: [{
                    // type: "nvidia-tesla-k80",
                    // count: 1,
                // }],
        //         labels: {"instanceType": "n1-standard-1"},
        //     }
        // });

        // Create a ConfigMap to hold the MariaDB configuration.
        const impalaCM = new k8s.core.v1.ConfigMap("impala", {
            data: {
            "config.py": `
            config = {
                'experiment_name': 'Qenv',
                'master_address': 'localhost:8010',
                'env':[
                    {'host':'qenv-0-qenv','port':5000},
                    {'host':'qenv-1-qenv','port':5000},
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
            }`}}, { provider: args.provider });

        // TODO create node pool here
        // TODO convert this to job?
        // xparl start --port 8010 --cpu_num ${NUM_WORKERS}


        // Create the kuard Deployment.
        const appLabels = {app: "impala"};
        const deployment = new k8s.apps.v1.StatefulSet(`${name}-impala`, {
            spec: {
                selector: {
                    matchLabels: appLabels,
                },
                serviceName: "impala",
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
                                name: "impala",
                                image: this.image.imageName,
                                imagePullPolicy: "IfNotPresent",
                                env: [
                                    { 
                                        name: "NUM_WORKERS", 
                                        value: "2" 
                                    },
                                    { 
                                        name: "LOG_PATH", 
                                        value: "/impala/data/log" 
                                    },
                                    { 
                                        name: "CKP_PATH", 
                                        value: "/impala/data/ckp" 
                                    },
                                    { 
                                        name: "CONFIG_PATH", 
                                        value: "/impala/config/config.py" 
                                    }
                                ],
                                volumeMounts: [
                                    {
                                        name: "data",
                                        mountPath: "/impala/data"
                                    },
                                    {
                                        name: "config",
                                        mountPath: "/impala/config",
                                        // subPath: "config.py"
                                    }
                                ],
                                // lifecycle:{
                                //     postStart :{
                                //         exec : {
                                //             command: [
                                //                 "gcsfuse", 
                                //                 "--implicit-dirs", 
                                //                 "-o", 
                                //                 "nonempty", 
                                //                 this.bucket.name, 
                                //                 args.stateMountPath
                                //             ]
                                //         }
                                //     },
                                //     preStop:{
                                //         exec : {
                                //             command: [
                                //                 "fusermount", 
                                //                 "-u", 
                                //                 args.stateMountPath
                                //             ]
                                //         }
                                //     }
                                // }

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
                                app: "impala",
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
