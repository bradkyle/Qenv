import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";

// Minikube does not implement services of type `LoadBalancer`; require the user to specify if we're
// running on minikube, and if so, create only services of type ClusterIP.
const config = new pulumi.Config();
const isMinikube = config.require("isMinikube");

// nginx container, replicated 1 time.
const appName = "nginx";
const appLabels = { app: appName };
const nginx = new k8s.apps.v1.Deployment(appName, {
    spec: {
        selector: { matchLabels: appLabels },
        replicas: 1,
        template: {
            metadata: { labels: appLabels },
            spec: { containers: [{ name: appName, image: "nginx:1.15-alpine" }] },
        },
    },
});
// Copyright 2016-2018, Pulumi Corporation.  All rights reserved.

import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";

const config = new pulumi.Config();

const nginxLabels = { app: "nginx" };
const nginxDeployment = new k8s.apps.v1.Deployment("nginx-deployment", {
    spec: {
        selector: { matchLabels: nginxLabels },
        replicas: config.getNumber("replicas") || 2,
        template: {
            metadata: { labels: nginxLabels },
            spec: {
                containers: [{
                    name: "nginx",
                    image: "nginx:1.7.9",
                    ports: [{ containerPort: 80 }],
                }],
            },
        },
    },
});

export const nginx = nginxDeployment.metadata.name;

// Allocate an IP to the nginx Deployment.
const frontend = new k8s.core.v1.Service(appName, {
    metadata: { labels: nginx.spec.template.metadata.labels },
    spec: {
        type: isMinikube === "true" ? "ClusterIP" : "LoadBalancer",
        ports: [{ port: 80, targetPort: 80, protocol: "TCP" }],
        selector: appLabels,
    },
});
