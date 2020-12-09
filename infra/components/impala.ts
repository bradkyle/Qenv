
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";

// Arguments for the demo app.
export interface ImpalaArgs {
    provider: k8s.Provider; // Provider resource for the target Kubernetes cluster.
    imageTag: string; // Tag for the kuard image to deploy.
}

export class Impala extends pulumi.ComponentResource {

    constructor(name: string,
                args: ImpalaArgs,
                opts: pulumi.ComponentResourceOptions = {}) {
        super("beast:impala:train", name, args, opts);

        // Create a ConfigMap to hold the MariaDB configuration.
        const impalaCM = new k8s.core.v1.ConfigMap("impala", {
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

        // Create the kuard Deployment.
        const appLabels = {app: "impala"};
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
