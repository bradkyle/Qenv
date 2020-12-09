
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as ingest from "../components/ingest"
import * as qenv from "../components/qenv"
import * as impala from "../components/impala"
import * as local from "../components/lclcluster"

export function setup() {

        const ingest_deployment = new ingest.Ingest("ingest",{
            provider:local.provider,    
            imageTag:"latest",
        });

        const qenv_deployment = new qenv.Qenv("test",true,{
            provider:local.provider,    
            imageTag:"latest",
            numEnvs:2,
            ingestHost:"",
            poolSize:2
        });


        const impala_deployment = new impala.Impala("test",{
            provider:local.provider,    
            imageTag:"latest",
        });

};
