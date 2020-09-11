
.util.Require     :{[path;reqs]
    {
        ns:"";
        $[not[ns in key[`]]];[
            filePath:raze[(system["pwd"]),(enlist x),(enlist y[0])];
            $[;
                system ("l ", filePath);
                show ("Successfully loaded ",filePath," ...");
            ];
        ];
        [
            show ("Namespace ", ns, " already loaded ...");
        ]];
 
    }[path]'[reqs];
    };