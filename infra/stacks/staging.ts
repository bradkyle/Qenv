
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

        const c = new cluster.GkeCluster("gke",{

        }); 

        const i = new ingest.MIngest("ingest",{
            dataMountPath: "/ingest/testdata",
            provider:c.provider,    
            imageTag:"latest",
            ports:[5000],
            isMinikube:false,
            skipPush:true,
            replicas:1
        });

        const q = new qenv.MQenv("test",{
            provider:c.provider,    
            numEnvs:2,
            skipPush:true,
            ingestService:i.service.metadata.name,
        });

        const b = new impala.Impala("test",{
            provider:c.provider,    
            skipPush:true,
            imageTag:"latest",
        });

};
