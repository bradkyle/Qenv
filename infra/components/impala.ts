
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";

// Arguments for the demo app.
export interface ImpalaArgs {
    provider: k8s.Provider; // Provider resource for the target Kubernetes cluster.
    imageTag: string; // Tag for the kuard image to deploy.
    staticAppIP?: pulumi.Input<string>; // Optional static IP to use for the service. (Required for AKS).
}

export class DemoApp extends pulumi.ComponentResource {
    public appUrl: pulumi.Output<string>;

    constructor(name: string,
                args: ImpalaArgs,
                opts: pulumi.ComponentResourceOptions = {}) {
        super("examples:kubernetes-ts-multicloud:demo-app", name, args, opts);

        // Create the kuard Deployment.
        const appLabels = {app: "qenv"};
        const deployment = new k8s.apps.v1.Deployment(`${name}-parl-impala`, {
            spec: {
                selector: {matchLabels: appLabels},
                replicas: 1,
                template: {
                    metadata: {labels: appLabels},
                    spec: {
                        containers: [
                            {
                                name: "impala",
                                image: `thorad/parl:${args.imageTag}`,
                                ports: [{containerPort: 8080, name: "http"}],
                                livenessProbe: {
                                    httpGet: {path: "/healthy", port: "http"},
                                    initialDelaySeconds: 5,
                                    timeoutSeconds: 1,
                                    periodSeconds: 10,
                                    failureThreshold: 3,
                                },
                                readinessProbe: {
                                    httpGet: {path: "/ready", port: "http"},
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


        this.registerOutputs();
    }
}
