import * as pulumi from "@pulumi/pulumi";
import * as random from "@pulumi/random";
import * as k8s from "@pulumi/kubernetes";
import * as kx from "@pulumi/kubernetesx";

// Arguments for the demo app.
export interface KafkaTopicArgs {
    
}


// Arguments for the demo app.
export interface KafkaArgs {
    provider: k8s.Provider; // Provider resource for the target Kubernetes cluster.
    imageTag: string; // Tag for the kuard image to deploy.
}

export class KafkaOperator extends pulumi.ComponentResource {

    constructor(name: string,
                args: KafkaArgs,
                opts: pulumi.ComponentResourceOptions = {}) {
        super("beast:sensor:sensor", name, args, opts);

        // Deploy the bitnami/wordpress chart.
        const prometheus = new k8s.helm.v3.Chart("prometheus", {
            chart: "kube-prometheus-stack",
            fetchOpts: {
                repo: "https://prometheus-community.github.io/helm-charts",
            },
        });

        // Deploy the bitnami/wordpress chart.
        const strimzi = new k8s.helm.v3.Chart("strimzi", {
            chart: "strimzi-kafka-operator",
            fetchOpts: {
                repo: "https://strimzi.io/charts/",
            },
        });

        const kafka = new k8s.apiextensions.CustomResource(
            "kafka", 
            {
                apiVersion: "kafka.strimzi.io/v1beta1",
                kind: "Kafka",
                metadata: {
                    name: "strimzi-cluster"
                },
                spec: {
                      entityOperator: {
                        topicOperator: {},
                        userOperator: {}
                      },
                      zookeeper: {
                        readinessProbe: {
                          initialDelaySeconds: 15,
                          timeoutSeconds: 5
                        },
                        metrics: {
                          rules: [
                            {
                              pattern: 'org.apache.ZooKeeperService<name0=ReplicatedServer_id(\\d+)><>(\\w+)',
                              type: 'GAUGE',
                              name: 'zookeeper_$2'
                            },
                            {
                              pattern: 'org.apache.ZooKeeperService<name0=ReplicatedServer_id(\\d+), name1=replica.(\\d+)><>(\\w+)',
                              labels: {
                                replicaId: '$2'
                              },
                              type: 'GAUGE',
                              name: 'zookeeper_$3'
                            },
                            {
                              pattern: 'org.apache.ZooKeeperService<name0=ReplicatedServer_id(\\d+), name1=replica.(\\d+), name2=(\\w+)><>(Packets.*)',
                              labels: {
                                replicaId: '$2',
                                memberType: '$3'
                              },
                              type: 'COUNTER',
                              name: 'zookeeper_$4'
                            },
                            {
                              pattern: 'org.apache.ZooKeeperService<name0=ReplicatedServer_id(\\d+), name1=replica.(\\d+), name2=(\\w+)><>(\\w+)',
                              labels: {
                                replicaId: '$2',
                                memberType: '$3'
                              },
                              type: 'GAUGE',
                              name: 'zookeeper_$4'
                            },
                            {
                              pattern: 'org.apache.ZooKeeperService<name0=ReplicatedServer_id(\\d+), name1=replica.(\\d+), name2=(\\w+), name3=(\\w+)><>(\\w+)',
                              labels: {
                                replicaId: '$2',
                                memberType: '$3'
                              },
                              type: 'GAUGE',
                              name: 'zookeeper_$4_$5'
                            },
                            {
                              pattern: 'org.apache.ZooKeeperService<name0=StandaloneServer_port(\\d+)><>(\\w+)',
                              type: 'GAUGE',
                              name: 'zookeeper_$2'
                            },
                            {
                              pattern: 'org.apache.ZooKeeperService<name0=StandaloneServer_port(\\d+), name1=InMemoryDataTree><>(\\w+)',
                              type: 'GAUGE',
                              name: 'zookeeper_$2'
                            }
                          ],
                          lowercaseOutputName: true
                        },
                        livenessProbe: {
                          initialDelaySeconds: 15,
                          timeoutSeconds: 5
                        },
                        storage: {
                          deleteClaim: false,
                          type: 'persistent-claim',
                          size: '1Gi'
                        },
                        replicas: 3
                      },
                      kafkaExporter: {
                        topicRegex: '.*',
                        groupRegex: '.*'
                      },
                      kafka: {
                        metrics: {
                          rules: [
                            {
                              pattern: 'kafka.server<type=(.+), name=(.+), clientId=(.+), topic=(.+), partition=(.*)><>Value',
                              labels: {
                                topic: '$4',
                                partition: '$5',
                                clientId: '$3'
                              },
                              type: 'GAUGE',
                              name: 'kafka_server_$1_$2'
                            },
                            {
                              pattern: 'kafka.server<type=(.+), name=(.+), clientId=(.+), brokerHost=(.+), brokerPort=(.+)><>Value',
                              labels: {
                                broker: '$4:$5',
                                clientId: '$3'
                              },
                              type: 'GAUGE',
                              name: 'kafka_server_$1_$2'
                            },
                            {
                              pattern: 'kafka.(\\w+)<type=(.+), name=(.+)Percent\\w*><>MeanRate',
                              type: 'GAUGE',
                              name: 'kafka_$1_$2_$3_percent'
                            },
                            {
                              pattern: 'kafka.(\\w+)<type=(.+), name=(.+)Percent\\w*><>Value',
                              type: 'GAUGE',
                              name: 'kafka_$1_$2_$3_percent'
                            },
                            {
                              pattern: 'kafka.(\\w+)<type=(.+), name=(.+)Percent\\w*, (.+)=(.+)><>Value',
                              labels: {
                                $4: '$5'
                              },
                              type: 'GAUGE',
                              name: 'kafka_$1_$2_$3_percent'
                            },
                            {
                              pattern: 'kafka.(\\w+)<type=(.+), name=(.+)PerSec\\w*, (.+)=(.+), (.+)=(.+)><>Count',
                              labels: {
                                $6: '$7',
                                $4: '$5'
                              },
                              type: 'COUNTER',
                              name: 'kafka_$1_$2_$3_total'
                            },
                            {
                              pattern: 'kafka.(\\w+)<type=(.+), name=(.+)PerSec\\w*, (.+)=(.+)><>Count',
                              labels: {
                                $4: '$5'
                              },
                              type: 'COUNTER',
                              name: 'kafka_$1_$2_$3_total'
                            },
                            {
                              pattern: 'kafka.(\\w+)<type=(.+), name=(.+)PerSec\\w*><>Count',
                              type: 'COUNTER',
                              name: 'kafka_$1_$2_$3_total'
                            },
                            {
                              pattern: 'kafka.(\\w+)<type=(.+), name=(.+), (.+)=(.+), (.+)=(.+)><>Value',
                              labels: {
                                $6: '$7',
                                $4: '$5'
                              },
                              type: 'GAUGE',
                              name: 'kafka_$1_$2_$3'
                            },
                            {
                              pattern: 'kafka.(\\w+)<type=(.+), name=(.+), (.+)=(.+)><>Value',
                              labels: {
                                $4: '$5'
                              },
                              type: 'GAUGE',
                              name: 'kafka_$1_$2_$3'
                            },
                            {
                              pattern: 'kafka.(\\w+)<type=(.+), name=(.+)><>Value',
                              type: 'GAUGE',
                              name: 'kafka_$1_$2_$3'
                            },
                            {
                              pattern: 'kafka.(\\w+)<type=(.+), name=(.+), (.+)=(.+), (.+)=(.+)><>Count',
                              labels: {
                                $6: '$7',
                                $4: '$5'
                              },
                              type: 'COUNTER',
                              name: 'kafka_$1_$2_$3_count'
                            },
                            {
                              pattern: 'kafka.(\\w+)<type=(.+), name=(.+), (.+)=(.*), (.+)=(.+)><>(\\d+)thPercentile',
                              labels: {
                                $6: '$7',
                                $4: '$5',
                                quantile: '0.$8'
                              },
                              type: 'GAUGE',
                              name: 'kafka_$1_$2_$3'
                            },
                            {
                              pattern: 'kafka.(\\w+)<type=(.+), name=(.+), (.+)=(.+)><>Count',
                              labels: {
                                $4: '$5'
                              },
                              type: 'COUNTER',
                              name: 'kafka_$1_$2_$3_count'
                            },
                            {
                              pattern: 'kafka.(\\w+)<type=(.+), name=(.+), (.+)=(.*)><>(\\d+)thPercentile',
                              labels: {
                                $4: '$5',
                                quantile: '0.$6'
                              },
                              type: 'GAUGE',
                              name: 'kafka_$1_$2_$3'
                            },
                            {
                              pattern: 'kafka.(\\w+)<type=(.+), name=(.+)><>Count',
                              type: 'COUNTER',
                              name: 'kafka_$1_$2_$3_count'
                            },
                            {
                              pattern: 'kafka.(\\w+)<type=(.+), name=(.+)><>(\\d+)thPercentile',
                              labels: {
                                quantile: '0.$4'
                              },
                              type: 'GAUGE',
                              name: 'kafka_$1_$2_$3'
                            }
                          ],
                          lowercaseOutputName: true
                        },
                        listeners: {
                          tls: {},
                          plain: {}
                        },
                        version: '2.6.0',
                        replicas: 3,
                        readinessProbe: {
                          initialDelaySeconds: 15,
                          timeoutSeconds: 5
                        },
                        storage: {
                          type: 'jbod',
                          volumes: [
                            {
                              deleteClaim: false,
                              type: 'persistent-claim',
                              id: 0,
                              size: '5Gi'
                            }
                          ]
                        },
                        config: {
                          'log.message.format.version': '2.4',
                          'transaction.state.log.min.isr': 2,
                          'transaction.state.log.replication.factor': 3,
                          'offsets.topic.replication.factor': 3
                        },
                        livenessProbe: {
                          initialDelaySeconds: 15,
                          timeoutSeconds: 5
                        }
                      }
                },
        });
    }


    addTopic(name:string, args:KafkaTopicArgs) {

    }


}








