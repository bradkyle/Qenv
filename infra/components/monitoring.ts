
import * as pulumi from "@pulumi/pulumi";
import * as random from "@pulumi/random";
import * as k8s from "@pulumi/kubernetes";
import * as kx from "@pulumi/kubernetesx";

// Arguments for the demo app.
export interface MonitorArgs {

}

// Arguments for the demo app.
export interface ThanosArgs {
    provider: k8s.Provider; // Provider resource for the target Kubernetes cluster.
    imageTag: string; // Tag for the kuard image to deploy.
}

export class ThanosOperator extends pulumi.ComponentResource {

    constructor(name: string,
                args: ThanosArgs,
                opts: pulumi.ComponentResourceOptions = {}) {
        super("beast:sensor:sensor", name, args, opts);

        // Deploy the bitnami/wordpress chart.
        const thanos = new k8s.helm.v3.Chart("thanos", {
            chart: "kube-prometheus-stack",
            fetchOpts: {
                repo: "https://prometheus-community.github.io/helm-charts",
            },
        });




    }


    addMonitor(name:string, args:MonitorArgs) {

    }


}








