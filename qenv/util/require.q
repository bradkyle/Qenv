
.util.PathExists  :{[path]
    $[type[path]=10h;(count[key hsym[` $path]]>0);'PATH_SHOULD_BE_STRING]
    };

.util.Require     :{[path;reqs]
    {   
        ns:`$(last("." vs y[1]));
        $[not[ns in key[`]];[
            filePath:raze[(system["pwd"]),(enlist x),(enlist y[0])];
            $[.util.PathExists[filePath];[
                system ("l ", filePath);
                show ("Successfully loaded ",filePath," ...");
            ];[
                show ("Path ",filePath," is invalid ...");
                'INVALID_PATH
            ]];
        ];
        [
            show ("Namespace ", string[ns], " already loaded ...");
        ]];
 
    }[path]'[reqs];
    };