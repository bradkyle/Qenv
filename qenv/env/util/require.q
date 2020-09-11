.util.Require     :{[reqs]
    basePath:getenv `BP;
    {
        show x;
        show string[y];
        show 99#"=";
    }[basePath]'[reqs];
    };