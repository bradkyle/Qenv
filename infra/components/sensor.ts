import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as random from "@pulumi/random";
import * as kafka from "./kafka"
// import * as dkr from "./docker"

// Arguments for the demo app.
export interface SensorArgs {
    provider: k8s.Provider; // Provider resource for the target Kubernetes cluster.
    kafka:kafka.KafkaOperator,
    imageTag: string; // Tag for the kuard image to deploy.
}

export class Sensor extends pulumi.ComponentResource {

    constructor(name: string,
                args: SensorArgs,
                opts: pulumi.ComponentResourceOptions = {}) {
        super("beast:sensor:sensor", name, args, opts);

        const kafkaTopic = args.kafka.addTopic("",{}); 

        //
        // Create a Secret to hold the MariaDB credentials.
        const kdbSecret = new k8s.core.v1.Secret("kdb", {
            stringData: {
                "kdb-password": new random.RandomPassword("mariadb-pw", {length: 12}).result
            }
        }, { provider: args.provider });


        // Create the kuard Deployment.
        const sensorLabels = {app: "sensor"}; // TODO change to statefulset
        const sensor = new k8s.apps.v1.Deployment(`${name}-sensor`, {
            spec: {
                selector: {matchLabels: sensorLabels},
                replicas: 1,
                template: {
                    metadata: {labels: sensorLabels},
                    spec: {
                        containers: [
                            {
                                name: "sensor",
                                image: `thorad/sensor:${args.imageTag}`,
                                ports: [{containerPort: 8080, name: "kdb"}],
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
                            },
                        ],
                    },
                },
            },
        }, {provider: args.provider, parent: this});

        // args.monitoring.addMonitor();

        // Create the persist Deployment.
        const persistLabels = {app: "persist"}; // TODO change to statefulset
        const persist = new k8s.apps.v1.Deployment(`${name}-persist`, {
            spec: {
                selector: {matchLabels: persistLabels },
                replicas: 1,
                template: {
                    metadata: {labels: persistLabels},
                    spec: {
                        containers: [
                            {
                                name: "persist",
                                image: `thorad/persist:${args.imageTag}`,
                                ports: [{containerPort: 8080, name: "kdb"}],
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
                                        name: "KAFKA_HOST", 
                                        value: "/ingest/data" 
                                    },
                                    { 
                                        name: "KAFKA_PORT", 
                                        value: "/ingest/data" 
                                    },
                                    { 
                                        name: "KAFKA_TOPIC", 
                                        value: "/ingest/data" 
                                    },
                                    { 
                                        name: "KAFKA_GROUP", 
                                        value: "/ingest/data" 
                                    }
                                ],
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

            },
        }, {provider: args.provider, parent: this});


        this.registerOutputs();
    }
}
