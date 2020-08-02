\d .logger

/**********************************************************

/ log information in the console 
Debug : {[msg; arg]
        1 "DEBUG:[" , (string .z.Z) , "] ";
        $[100=type arg; 
            [show msg; show value arg];
            [show msg; show arg]
        ];
    }

/ log information in the console 
Info : {[msg; arg]
        1 "INFO:[" , (string .z.Z) , "] ";
        $[100=type arg; 
            [show msg; show value arg];
            [show msg; show arg]
        ];
    }

/ log error in the console 
Err : {[msg; arg]
        1 "ERROR:[" , (string .z.Z) , "] ";
        $[100=type arg; 
            [show msg; show value arg];
            [show msg; show arg]
        ];
    }
