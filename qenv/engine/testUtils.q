\l qunit.q

// Forms a message pertaining to form
// of a test case. 
FailedMsg :{[dscr;expected;result]:(dscr," | expected:",string[expected]," got:",string[result])};

// TODO
AssertEquals: {[]

    };
    
RevertALL   :{[]

    };

TESTKIND    :`UNIT`INTEGRATION`BENCHMARK;

Register    :{[kind;name;dscr;func;params;setup;revert]

    };