const fs = require('fs');
const execSync = require('child_process').execSync;
import * as _ from "lodash";

function getBatches(
    bucketPath:string, 
    batchSize:number,
    maxBatches:number,
    start:number,
    end:number
  ):number[][] {
    // Lists files in the bucket
    let files:string[] = execSync("gsutil ls "+bucketPath).toString("utf8").split("\n");
    let names = files.map(f=>f.split("/"));
    let nbrs = names.map(f=>f[5]).map(Number);
    nbrs = nbrs.filter(f=>!Number.isNaN(f));
    nbrs = _.uniq(nbrs);
    nbrs = _.filter(nbrs,n=>n>start); 
    nbrs = _.filter(nbrs,n=>n<end); 
    let batches:number[][] = _.chunk(nbrs, batchSize);
    batches = _.slice(batches, 0, maxBatches);
    return batches;
}

var conf = [];
const start = 445800; 
const end = 999999; 

let batches = getBatches("gs://axiomdata/okex/events/", 48, 3, start, end);
console.log(batches);
let batch = batches[0];
let dirs = batch.map(p=>"gs://axiomdata/okex/events/"+p.toString()+","+p.toString());
dirs.push("gs://axiomdata/okex/events/ev,ev\n");
console.log(dirs);
console.log(dirs.length);
fs.writeFile('data.list', dirs.join("\n"), function (err) {
  if (err) return console.log(err);
});
