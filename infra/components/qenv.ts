import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as docker from "@pulumi/docker";
import * as k8stypes from "@pulumi/kubernetes/types/input";

// Arguments for the demo app.
export interface QenvArgs {
    provider: k8s.Provider; // Provider resource for the target Kubernetes cluster.
    ingestHost: string;
    numEnvs?: number; 
    port?: number; 
    poolSize?:number;
    allocateIpAddress?: boolean;
    resources?: k8stypes.core.v1.ResourceRequirements;
    isMinikube?: boolean;
    replicas?: number;
}

export class Qenv extends pulumi.ComponentResource {
    public readonly deployment: k8s.apps.v1.Deployment;
    public readonly service: k8s.core.v1.Service;
    public readonly image: docker.Image;
    public readonly ipAddress?: pulumi.Output<string>;
    public readonly port: number;

    constructor(name: string,
                args: QenvArgs,
                opts: pulumi.ComponentResourceOptions = {}) {
        super("beast:qenv:qenv", name, args, opts);

        this.port = args.port || 5000;
        this.image = new docker.Image(`${name}-qenv-image`, {
            imageName: "thorad/qenv",
            build: {
                dockerfile: "./qenv/Dockerfile",
                context: "./qenv/",
            },
            skipPush: false,
        });

        // Create a ConfigMap to hold the MariaDB configuration.
        const qenvCM = new k8s.core.v1.ConfigMap("qenv", {
            data: {
            "my.cnf": `
            [mysqld]
            skip-name-resolve
            explicit_defaults_for_timestamp
            basedir=/opt/bitnami/mariadb
            port=3306
            socket=/opt/bitnami/mariadb/tmp/mysql.sock
            tmpdir=/opt/bitnami/mariadb/tmp
            max_allowed_packet=16M
            bind-address=0.0.0.0
            pid-file=/opt/bitnami/mariadb/tmp/mysqld.pid
            log-error=/opt/bitnami/mariadb/logs/mysqld.log
            character-set-server=UTF8
            collation-server=utf8_general_ci
            [client]
            port=3306
            socket=/opt/bitnami/mariadb/tmp/mysql.sock
            default-character-set=UTF8
            [manager]
            port=3306
            socket=/opt/bitnami/mariadb/tmp/mysql.sock
            pid-file=/opt/bitnami/mariadb/tmp/mysqld.pid
            `}}, { provider: args.provider });


        // TODO change to statefulset
        // Create the kuard Deployment.
        const appLabels = {app: "qenv"}; // TODO change to statefulset
        this.deployment = new k8s.apps.v1.Deployment(`${name}-qenv`, {
            spec: {
                selector: {matchLabels: appLabels},
                replicas: args.replicas || 1,
                template: {
                    metadata: {labels: appLabels},
                    spec: {
                        containers: [
                            {
                                name: "qenv",
                                image: this.image.imageName, 
                                ports: [{containerPort: this.port, name: "kdb"}],
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
                                resources: args.resources || { requests: { cpu: "100m", memory: "100Mi" } },
                            },
                        ],
                    },
                },
            },
        }, {provider: args.provider, parent: this});

        // Allocate an IP to the nginx Deployment.
        this.service = new k8s.core.v1.Service(name, {
            metadata: { labels: this.deployment.spec.template.metadata.labels },
            spec: {
                type: args.isMinikube ? "ClusterIP" : "LoadBalancer",
                ports: [{ port: this.port, targetPort: this.port, protocol: "TCP" }],
                selector: appLabels,
            },
        });

        if (args.allocateIpAddress) {
            this.ipAddress = args.isMinikube ?
                this.service.spec.clusterIP :
                this.service.status.loadBalancer.ingress[0].ip;
        }

        // this.appUrl = pulumi.interpolate`http://${address}:${service.spec.ports[0].port}`;

        this.registerOutputs();
    }
}
