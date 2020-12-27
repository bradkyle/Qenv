"use strict";
exports.__esModule = true;
var fs = require('fs');
var execSync = require('child_process').execSync;
var _ = require("lodash");
function getBatches(bucketPath, batchSize, maxBatches, start, end) {
    // Lists files in the bucket
    var files = execSync("gsutil ls " + bucketPath).toString("utf8").split("\n");
    var names = files.map(function (f) { return f.split("/"); });
    var nbrs = names.map(function (f) { return f[5]; }).map(Number);
    nbrs = nbrs.filter(function (f) { return !Number.isNaN(f); });
    nbrs = _.uniq(nbrs);
    nbrs = _.filter(nbrs, function (n) { return n > start; });
    nbrs = _.filter(nbrs, function (n) { return n < end; });
    var batches = _.chunk(nbrs, batchSize);
    batches = _.slice(batches, 0, maxBatches);
    return batches;
}
var conf = [];
var start = 445800;
var end = 999999;
var batches = getBatches("gs://axiomdata/okex/events/", 48, 3, start, end);
console.log(batches);
var batch = batches[0];
var dirs = batch.map(function (p) { return "gs://axiomdata/okex/events/" + p.toString() + "," + p.toString(); });
dirs.push("gs://axiomdata/okex/events/ev,ev\n");
console.log(dirs);
console.log(dirs.length);
fs.writeFile('data.list', dirs.join("\n"), function (err) {
    if (err)
        return console.log(err);
});
