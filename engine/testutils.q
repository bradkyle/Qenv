l: `long$
z:.z.z;
sc:{x+(`second$y)};
sn:{x-(`second$y)};
sz:sc[z];
snz:sn[z];
dts:{(`date$x)+(`second$x)};
dtz:{dts[sc[x;y]]}[z]
doz:`date$z;
dozc:{x+y}[doz];


// TODO fix comments
// TODO pipe utils, ingress, egress etc.

// Error checking utils
// -------------------------------------------------------------->

.util.testutils.checkErr            :{[fn;args;err;case]
        $[count[err]>0;[
            .qt.AT[fn; args; err; ""; case];
        ];[
            :fn[args];
        ]];
    };

// Mock generation and checking utils
// -------------------------------------------------------------->

// Checks that the .engine.model.order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.makeMockParams     :{[ref;args]
    
    };       


// TODO add additional logic
// Checks that the .engine.model.order.Order table matches the orders
// that are provided.
/  @param x (Order/List) The orders that are to be checked
/  @param y (Case) The case that the assertions belong to
/  @param z (List[String]) The params that are being checked 
.util.testutils.checkMock           :{[x;y;z]
        .qt.MA[x;y[0];y[1];y[2];z];
    };

