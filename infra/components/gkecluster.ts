// Copyright 2016-2019, Pulumi Corporation.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import * as gcp from "@pulumi/gcp";
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as random from "@pulumi/random";

export interface GkeClusterArgs {
}

export class GKECluster extends pulumi.ComponentResource {
    public cluster: gcp.container.Cluster;
    public provider: k8s.Provider;

    constructor(name: string,
                args: GkeClusterArgs,
                opts: pulumi.ComponentResourceOptions = {}) {
        super("examples:kubernetes-ts-multicloud:GkeCluster", name, {}, opts);

        gcp.container.getEngineVersions().then(it => it.latestMasterVersion);

        // Create a GKE cluster
        const engineVersion = gcp.container.getEngineVersions().then(v => v.latestMasterVersion);
        this.cluster = new gcp.container.Cluster(name, {
            initialNodeCount: 2,
            minMasterVersion: engineVersion,
            nodeVersion: engineVersion,
            nodeConfig: {
                machineType: "n1-standard-4",
                oauthScopes: [
                    "https://www.googleapis.com/auth/cloud-platform",
                    "https://www.googleapis.com/auth/compute",
                    "https://www.googleapis.com/auth/servicecontrol",
                    "https://www.googleapis.com/auth/service.management.readonly",
                    "https://www.googleapis.com/auth/devstorage.read_only",
                    "https://www.googleapis.com/auth/logging.write",
                    "https://www.googleapis.com/auth/monitoring"
                ],
            },
        });

        // const my_repo = new gcp.artifactregistry.Repository("my-repo", {
        //     location: "us-central1",
        //     repositoryId: "my-repository",
        //     description: "example docker repository",
        //     format: "DOCKER",
        // }, {
        //     provider: google_beta,
        // });

        // Export the Cluster name
        const clusterName = this.cluster.name;

        // Manufacture a GKE-style kubeconfig. Note that this is slightly "different"
        // because of the way GKE requires gcloud to be in the picture for cluster
        // authentication (rather than using the client cert/key directly).
        const kubeconfig = pulumi.
            all([ this.cluster.name, this.cluster.endpoint, this.cluster.masterAuth ]).
            apply(([ name, endpoint, masterAuth ]) => {
                const context = `${gcp.config.project}_${gcp.config.zone}_${name}`;
                return `apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${masterAuth.clusterCaCertificate}
    server: https://${endpoint}
  name: ${context}
contexts:
- context:
    cluster: ${context}
    user: ${context}
  name: ${context}
current-context: ${context}
kind: Config
preferences: {}
users:
- name: ${context}
  user:
    auth-provider:
      config:
        cmd-args: config config-helper --format=json
        cmd-path: gcloud
        expiry-key: '{.credential.token_expiry}'
        token-key: '{.credential.access_token}'
      name: gcp
`;
        });

        // Create a Kubernetes provider instance that uses our cluster from above.
        this.provider = new k8s.Provider(name, {
            kubeconfig: kubeconfig,
        });

    }
}
