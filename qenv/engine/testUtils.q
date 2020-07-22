\l qunit.q
\d .testUtils

// Forms a message pertaining to form
// of a test case. 
FailedMsg :{[dscr;expected;result]:(dscr," | expected:",string[expected]," got:",string[result])};

// TODO
AssertEquals: {[]

    };
    
RevertALL   :{[]

    };

TESTKIND    :`UNIT`INTEGRATION`BENCHMARK;
TESTSTATE   :`PASS`FAIL`SKIP;

Test    :(
    [testId      : `long$()]
    name         : `symbol$();
    kind         : `.testUtils.TESTKIND;
    state        : `.testUtils.TESTSTATE;
    dscr         : `char$();
    func         : ();
    params       : ();
    setup        : ();
    revert       : ()
    );

Register    :{[kind;name;dscr;func;params;setup;revert]

    };

// Generates the tabular representation of 
generateReport  :{

    };

RunTests    :{[testKinds]

    };