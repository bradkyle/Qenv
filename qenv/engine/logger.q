\d .logger

/**********************************************************
/ log information in the console 
Info : {[msg; arg]
        1 "[" , (string .z.Z) , "] ";
        $[100=type arg; 
            [show msg; show value arg];
            [show msg; show arg]
        ];
    }
