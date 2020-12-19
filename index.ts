import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as local from "./infra/components/lclcluster"
import * as gke from "./infra/components/gkecluster"
import * as mingest from "./infra/components/mingest"
import * as gcp from "@pulumi/gcp";
import * as docker from "@pulumi/docker";
import * as mqenv from "./infra/components/mqenv";
import * as impala from "./infra/components/impala";

let config = new pulumi.Config();
const isMinikube = (config.require("isMinikube") == "true");

// const env = pulumi.getStack();
// const infra = new pulumi.StackReference(`acmecorp/infra/${env}`);
//
// dev.setup({})
// stg.setup({})
interface GKEConfig {
	active: boolean;
	name: string;
	initialNodeCount: number;
	machineType: string
}
let gke_config = config.requireObject<GKEConfig>("gke");
console.log(gke_config);

var provider: k8s.Provider;
if (gke_config.active && !isMinikube) {
	 const cluster = new gke.GKECluster("beast",{});			
	 provider = cluster.provider;
} else {
	 provider = local.provider; 
} 

interface IngestConfig {
	active: boolean;
	name: string;
	port: number;
	numWorkers: number;
	dataBucket: string;
	bucketPath: string;
	bucketProvider: string;
	pullData:false;
	dataPath: string;
	replicas: number;
	batchSize: number;
	maxBatches: number;
	skipBuild: boolean;
	skipPush: boolean;
}

interface GateConfig {
	active:boolean;
	name:string;
	port:number;
	replicas:number;
	skipBuild:boolean;
	skipPush:boolean;
	configPath:string;
}

let ingest_config = config.requireObject<IngestConfig>("ingest");
let gate = config.requireObject<GateConfig>("gate");
console.log(ingest_config);
console.log(gate);
var ingest: mingest.MIngest;
if (ingest_config.active) {
			ingest = new mingest.MIngest("ingest",{
					dataMountPath:ingest_config.dataPath, 
					provider: provider,    
					isMinikube:isMinikube,
					skipPush:ingest_config.skipPush,
					replicas:ingest_config.replicas
			});
}

interface QenvConfig {
	active:boolean;
	name:string;
	port:number;
	numWorkers:number;
	gateHost:string;
	gatePort:number;
	skipBuild:boolean;
	skipPush:boolean;
}

let qenv_config = config.requireObject<QenvConfig>("ingest");
console.log(qenv_config);
if (qenv_config.active){
	const qenv = new mqenv.MQenv("qenv",{
		provider:provider,
		ingestService:"gate",
		numEnvs:2,
		isMinikube:isMinikube,
		replicas:1,
		skipPush:false,
	})
}

interface ImpalaConfig {
	active:boolean;
	name:string;
	xparlPort:number;
	xparlCpus:number;
	numActors:number;
	logInterval:number;
}

let impala_config = config.requireObject<ImpalaConfig>("impala");
console.log(impala_config);
if (impala_config.active){
	const i = new impala.Impala("impala",{
		provider:provider,
		skipPush:false,
	})
}












