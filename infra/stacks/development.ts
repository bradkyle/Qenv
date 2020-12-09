
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as ingest from "../components/ingest"
import * as qenv from "../components/qenv"
import * as impala from "../components/impala"
import * as local from "../components/lclcluster"

export interface DevConfig {

}

export function setup(config:DevConfig) {

        const ingest_deployment = new ingest.Ingest("ingest",{
            dataMountPath: "/ingest/data",
            provider:local.provider,    
            imageTag:"latest",
            ports:[5000],
            isMinikube:true,
            replicas:1
        });

        // const qenv_deployment = new qenv.Qenv("test",{
        //     provider:local.provider,    
        //     numEnvs:2,
        //     ingestHost:"",
        //     poolSize:2,
        //     port:5000,
        // });


        // const impala_deployment = new impala.Impala("test",{
        //     provider:local.provider,    
        //     imageTag:"latest",
        // });

};
