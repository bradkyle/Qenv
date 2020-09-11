.util.Require     :{[path;reqs]
    basePath:getenv `BP;
    {
        show x;
        show y;
        show z;
        show 99#"=";
    }[basePath;path]'[reqs];
    };