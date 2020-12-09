//
// Copyright 2016-2019, Pulumi Corporation.  All rights reserved.

// import * as aws from "@pulumi/aws";
// import * as gcp from "@pulumi/gcp";

// // Create an AWS resource (S3 Bucket)
// const awsBucket = new aws.s3.Bucket("my-bucket");

// // Create a GCP resource (Storage Bucket)
// const gcpBucket = new gcp.storage.Bucket("my-bucket");

// // Export the names of the buckets
// export const bucketNames = [
//     awsBucket.bucket,
//     gcpBucket.name,
// ];
//
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as ingest from "../components/ingest"
import * as qenv from "../components/qenv"
import * as impala from "../components/impala"
import * as local from "../components/lclcluster"

export interface PrdConfig {

}

export function setup(config:PrdConfig) {
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

        // Create Kubernetes clusters.
        // Note: Comment out lines for any cluster you don't want to deploy.
        // const aksCluster = new aks.AksCluster("multicloud", {});
        // const eksCluster = new eks.EksCluster("multicloud", {});
        const gkeCluster = new gke.GkeCluster("multicloud", {});

        // Create a list of named clusters where the demo app will be deployed.
        interface Cluster {
            name: string;
            provider: k8s.Provider;
            staticAppIP?: pulumi.Output<string>;
        }
        const clusters: Cluster[] = [
            // Note: Comment out lines for any cluster you don't want to deploy.
            // {name: "aks", provider: aksCluster.provider, staticAppIP: aksCluster.staticAppIP},
            // {name: "eks", provider: eksCluster.provider},
            {name: "gke", provider: gkeCluster.provider},
            {name: "local", provider: local.provider},
        ];

        // Export a list of URLs to access the demo app.
        interface AppUrl {
            name: string;
            url: pulumi.Output<string>;
        }
        export let appUrls: AppUrl[] = [];

        const kuardImageTag = "blue";
        // const kuardImageTag = "green";

        // Create the application on each of the selected clusters.
        for (const cluster of clusters) {
            const instance = new app.DemoApp(cluster.name, {
                provider: cluster.provider,
                imageTag: kuardImageTag,
                staticAppIP: cluster.staticAppIP,
            });

            const instanceUrl: AppUrl = {name: cluster.name, url: instance.appUrl};
            appUrls = appUrls.concat(instanceUrl);
        }

        const ingest_deployment = new ingest.Ingest("ingest",{
            dataMountPath: "/ingest/data",
            provider:local.provider,    
            imageTag:"latest",
        });

        const qenv_deployment = new qenv.Qenv("test",{
            provider:local.provider,    
            numEnvs:2,
            ingestHost:"",
            poolSize:2,
            port:5000,
        });


        const impala_deployment = new impala.Impala("test",{
            provider:local.provider,    
            imageTag:"latest",
        });

};
