
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as ingest from "../components/mingest"
import * as qenv from "../components/mqenv"
import * as impala from "../components/impala"
import * as cluster from "../components/gkecluster"
import * as gcp from "@pulumi/gcp";
import { Config } from "@pulumi/pulumi";
import * as random from "@pulumi/random";


export interface StgConfig {

}

export function setup(conf:StgConfig) {

        gcp.container.getEngineVersions().then(it => it.latestMasterVersion);

        const name = "helloworld";

        // Create a GKE cluster
        const engineVersion = gcp.container.getEngineVersions().then(v => v.latestMasterVersion);
        const cluster = new gcp.container.Cluster(name, {
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
        const clusterName = cluster.name;

        // Manufacture a GKE-style kubeconfig. Note that this is slightly "different"
        // because of the way GKE requires gcloud to be in the picture for cluster
        // authentication (rather than using the client cert/key directly).
        const kubeconfig = pulumi.
            all([ cluster.name, cluster.endpoint, cluster.masterAuth ]).
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
        const provider = new k8s.Provider(name, {
            kubeconfig: kubeconfig,
        });

        const i = new ingest.MIngest("ingest",{
            dataMountPath: "/ingest/data",
            provider:provider,    
            imageTag:"latest",
            ports:[5000],
            isMinikube:false,
            skipPush:false,
            replicas:1
        });

        const q = new qenv.MQenv("test",{
            provider:provider,    
            numEnvs:2,
            skipPush:false,
            ingestService:i.service.metadata.name,
        });

        const b = new impala.Impala("test",{
            provider:provider,    
            skipPush:false,
            imageTag:"latest",
        });

};
