import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";

// Minikube does not implement services of type `LoadBalancer`; require the user to specify if we're
// running on minikube, and if so, create only services of type ClusterIP.
const config = new pulumi.Config();
const isMinikube = config.require("isMinikube");

// nginx container, replicated 1 time.
const appName = "nginx";

// Arguments for the demo app.
export interface DemoAppArgs {
    provider: k8s.Provider; // Provider resource for the target Kubernetes cluster.
    imageTag: string; // Tag for the kuard image to deploy.
    staticAppIP?: pulumi.Input<string>; // Optional static IP to use for the service. (Required for AKS).
}

export class DemoApp extends pulumi.ComponentResource {
    public appUrl: pulumi.Output<string>;

    constructor(name: string,
                args: DemoAppArgs,
                opts: pulumi.ComponentResourceOptions = {}) {
        super("qenv:kubernetes-ts-multicloud:demo-app", name, args, opts);

        // Create the kuard Deployment.
        const appLabels = {app: "qenv"}; // TODO change to statefulset
        const qenv = new k8s.apps.v1.Deployment(`${name}-qenv`, {
            spec: {
                selector: {matchLabels: appLabels},
                replicas: 1,
                template: {
                    metadata: {labels: appLabels},
                    spec: {
                        containers: [
                            {
                                name: "qenv",
                                image: `thorad/qenv:${args.imageTag}`,
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

        // Allocate an IP to the nginx Deployment.
        const frontend = new k8s.core.v1.Service(appName, {
            metadata: { labels: qenv.spec.template.metadata.labels },
            spec: {
                type: isMinikube === "true" ? "ClusterIP" : "LoadBalancer",
                ports: [{ port: 80, targetPort: 80, protocol: "TCP" }],
                selector: appLabels,
            },
        });

        // The address appears in different places depending on the Kubernetes service provider.
        // let address = service.status.loadBalancer.ingress[0].hostname;
        // if (name === "gke" || name === "aks") {
        //     address = service.status.loadBalancer.ingress[0].ip;
        // }

        // this.appUrl = pulumi.interpolate`http://${address}:${service.spec.ports[0].port}`;

        this.registerOutputs();
    }
}
