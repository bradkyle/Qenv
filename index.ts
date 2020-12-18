import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as dev from "./infra/stacks/development";
import * as prd from "./infra/stacks/production";
import * as stg from "./infra/stacks/staging";
import * as tst from "./infra/stacks/testing";
import * as local from "./infra/components/lclcluster"
import * as gke from "./infra/components/gkecluster"
import * as mingest from "./infra/components/mingest"
import * as gcp from "@pulumi/gcp";
import * as docker from "@pulumi/docker";

let config = new pulumi.Config();
const isMinikube = config.require("isMinikube");

const registry = new gcp.container.Registry("beast");
const registryUrl = registry.id.apply(_ =>
    gcp.container.getRegistryRepository().then(reg => reg.repositoryUrl));

const imageName = registryUrl.apply(url => `${url}/myapp`);
const registryInfo = undefined; // use gcloud for authentication.

const image = new docker.Image('push-ingest-image', {
	imageName: "thorad/ingest:bambam",
	build: {
			dockerfile: "./ingest/ingest.Dockerfile",
			context: "./ingest/",
	},
	registry: registryInfo,
	skipPush:false
});

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
if (ingest_config.active) {
			const ingest = new mingest.MIngest("ingest",{
					dataMountPath: "/ingest/data",
					provider: provider,    
					imageTag:"latest",
					ports:[5000],
					isMinikube:false,
					skipPush:false,
					replicas:1
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

let qenv = config.requireObject<QenvConfig>("ingest");
console.log(qenv);

interface ImpalaConfig {
	active:boolean;
	name:string;
	xparlPort:number;
	xparlCpus:number;
	numActors:number;
	logInterval:number;
}

let impala = config.requireObject<ImpalaConfig>("impala");
console.log(impala);
