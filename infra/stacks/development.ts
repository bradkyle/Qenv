
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as ingest from "../components/ingest"
import * as qenv from "../components/qenv"
import * as impala from "../components/impala"

// Arguments for the demo app.
export interface DevStackArgs {
    provider: k8s.Provider; // Provider resource for the target Kubernetes cluster.
    imageTag: string; // Tag for the kuard image to deploy.
    staticAppIP?: pulumi.Input<string>; // Optional static IP to use for the service. (Required for AKS).
}

export class DevStack extends pulumi.ComponentResource {
    constructor(name: string,
                args: DevStackArgs,
                opts: pulumi.ComponentResourceOptions = {}) {
        super("examples:kubernetes-ts-multicloud:demo-app", name, args, opts);

    }
}
//
// deploy impala, qenv, ingest
