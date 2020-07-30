
// TODO trap load errors and specify path
.global.Require :{[paths]
    $[getenv[`RDIR]~"";'`RDIR_UNSPECIFIED;rdir:getenv[`RDIR]];
    toload:(count[paths]#`$rdir;`$paths);
    {path:`$(":","" sv string x);show path;$[() ~ key path; '`$("NOT_FOUND:",path); system "l ",string path]} each flip[toload];
    };
