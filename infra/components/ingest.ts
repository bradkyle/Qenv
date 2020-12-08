import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";

// Arguments for the demo app.
export interface IngestArgs {
    provider: k8s.Provider; // Provider resource for the target Kubernetes cluster.
    imageTag: string; // Tag for the kuard image to deploy.
    staticAppIP?: pulumi.Input<string>; // Optional static IP to use for the service. (Required for AKS).
}

export class Ingest extends pulumi.ComponentResource {
    public appUrl: pulumi.Output<string>;

    constructor(name: string,
                args: IngestArgs,
                opts: pulumi.ComponentResourceOptions = {}) {
        super("examples:kubernetes-ts-multicloud:demo-app", name, args, opts);

        // Create the kuard Deployment.
        const appLabels = {app: "ingest"};
        const deployment = new k8s.apps.v1.Deployment(`${name}-ingest`, {
            spec: {
                selector: {matchLabels: appLabels},
                replicas: 1,
                template: {
                    metadata: {labels: appLabels},
                    spec: {
                        containers: [
                            {
                                name: "ingest",
                                image: `thorad/ingest:${args.imageTag}`,
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
                            },
                        ],
                    },
                },
            },
        }, {provider: args.provider, parent: this});

        // Create a LoadBalancer Service to expose the kuard Deployment.
        const service = new k8s.core.v1.Service(`${name}-ingest`, {
            spec: {
                loadBalancerIP: args.staticAppIP, // Required for AKS - automatic LoadBalancer still in preview.
                selector: appLabels,
                ports: [{port: 80, targetPort: 5000}],
                type: "LoadBalancer",
            },
        }, {provider: args.provider, parent: this});

        // The address appears in different places depending on the Kubernetes service provider.
        let address = service.status.loadBalancer.ingress[0].hostname;
        if (name === "gke" || name === "aks") {
            address = service.status.loadBalancer.ingress[0].ip;
        }

        this.appUrl = pulumi.interpolate`http://${address}:${service.spec.ports[0].port}`;

        this.registerOutputs();
    }
}
