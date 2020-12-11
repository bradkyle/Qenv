
import * as k8s from "@pulumi/kubernetes";
import * as pulumi from "@pulumi/pulumi";
import * as docker from "@pulumi/docker";
import * as k8stypes from "@pulumi/kubernetes/types/input";
import * as qenv from "./qenv"

// Arguments for the demo app.
export interface MQenvArgs {
    provider: k8s.Provider; // Provider resource for the target Kubernetes cluster.
    ingestService: pulumi.Output<string>;
    numEnvs?: number; 
    port?: number; 
    allocateIpAddress?: boolean;
    resources?: k8stypes.core.v1.ResourceRequirements;
    isMinikube?: boolean;
    replicas?: number;
    skipPush?: boolean;
}

export class MQenv extends pulumi.ComponentResource {
    public readonly qenvs: Record<string, qenv.Qenv>; 
    public readonly qenvImage: docker.Image;
    public readonly ipAddress?: pulumi.Output<string>;
    public readonly port: number;

    constructor(name: string,
                args: MQenvArgs,
                opts: pulumi.ComponentResourceOptions = {}) {
        super("beast:qenv:qenv", name, args, opts);

        this.port = args.port || 5000;
        this.qenvImage = new docker.Image(`${name}-qenv-image`, {
            imageName: "gcr.io/beast-298015/qenv:latest",
            build: {
                dockerfile: "./qenv/Dockerfile",
                context: "./qenv/",
            },
            skipPush:(args.skipPush || true),
        });

        console.log(this.qenvImage.imageName);
        console.log(args.skipPush);
        console.log('-----------------------------------');

        this.qenvs = {};
        for(let i=0;i<(args.numEnvs || 1);i++) {
            let s = i.toString();
            let sname = (`qenv-${s}`);
            // let datapaths = batch.map(c => this.bucket.url+"/okex/events/"+c.toString());
            // datapaths.push(this.bucket.url+"/okex/events/ev");
            // console.log(datapaths);
            this.qenvs[sname] = new qenv.Qenv(sname, {
                provider: args.provider,  
                ingestService:args.ingestService,
                image: this.qenvImage,
            });
            // this.conf.push({
            //     sId: i,
            //     host: sname,
            //     port: 5000,
            //     start: _.min(batch), 
            //     end: _.max(batch)
            // });
        };

        this.registerOutputs();
    }
}


