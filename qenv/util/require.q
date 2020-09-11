
.util.Require     :{[path;reqs]
    {
        filePath:raze[(system["pwd"]),(enlist x),(enlist y[0])];
        show filePath;
        show 99#"=";
    }[path]'[reqs];
    };