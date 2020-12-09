
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


    }


    addTopic(name:string, args:KafkaTopicArgs) {

    }


}








