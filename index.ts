import * as pulumi from "@pulumi/pulumi";
import * as dev from "./infra/stacks/development";
import * as prd from "./infra/stacks/production";
import * as stg from "./infra/stacks/staging";
import * as tst from "./infra/stacks/testing";
import * as local from "./infra/components/lclcluster"
import * as gke from "./infra/components/gkecluster"

let config = new pulumi.Config();
const isMinikube = config.require("isMinikube");

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
if (gke_config.active && !isMinikube) {
	 const cluster = new gke.GKECluster("",{});			
	 let provider = cluster.provider;
} else {
	 let provider = local; 
} 

let ingest_config = config.requireObject("ingest");
console.log(ingest_config);
if (ingest_config.active) {

} else {

}

let gate = config.requireObject("gate");
console.log(gate);

let qenv = config.requireObject("ingest");
console.log(qenv);

let impala = config.requireObject("impala");
console.log(impala);
