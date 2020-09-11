
.util.Require     :{[reqs]
    basePath:getenv `BP;
    currentPath:.z.f;
    {

    }[basePath;currentPath]'[reqs];
    };