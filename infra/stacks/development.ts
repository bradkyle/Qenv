
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as ingest from "../components/mingest"
import * as qenv from "../components/mqenv"
import * as impala from "../components/impala"
import * as local from "../components/lclcluster"

export interface DevConfig {

}

export function setup(config:DevConfig) {

        const i = new ingest.MIngest("ingest",{
            dataMountPath: "/ingest/testdata",
            provider:local.provider,    
            imageTag:"latest",
            ports:[5000],
            isMinikube:true,
            replicas:1
        });

        const q = new qenv.MQenv("test",{
            provider:local.provider,    
            numEnvs:2,
            ingestService:i.service.metadata.name,
        });

        // const b = new impala.Impala("test",{
        //     provider:local.provider,    
        //     imageTag:"latest",
        // });

};
