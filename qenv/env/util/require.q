
.util.Require     :{[reqs]
    basePath:getenv `BP;
    currentPath:.z.f;
    {
        show x;
        show string[y];
        show z;
        show 99#"=";
    }[basePath;currentPath]'[reqs];
    };