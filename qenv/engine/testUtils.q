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

TESTKIND    :`UNIT`INTEGRATION`BENCHMARK`PROFILE;
TESTSTATE   :`PASS`FAIL`SKIP;

Test    :(
    [testId      : `long$()]
    name         : `symbol$();
    namespace    : `symbol$();
    kind         : `.testUtils.TESTKIND;
    state        : `.testUtils.TESTSTATE;
    dscr         : `char$();
    func         : ();
    params       : ();
    setup        : ();
    revert       : ();
    repeat       : `long$();
    retry        : `long$();
    start        : `datetime$();
    end          : `datetime$();
    profileRes   : ()
    );


/ mock kind enumerations
MOCKKIND    :`FAKE`SPIE`STUB`MOCK`TIMER;

Mock        :{
    [mockId      : `long$()]
    testId       : `long$();
    kind         : `.testUtils.MOCKKIND;
    returns      : ();
    throws       : ();
    rejects      : ();
    calledWith   : ();
    mocks        : ();
    replaceWith  : ();
    numCalls     : `long$()
    };

// TODO restore;

/ assertion kind enumerations
ASSERTIONKIND:  (`TRUE;      / place a new order
                `THROWS;    / modify an existing order
                `KNOWN;    / increment a given accounts balance
                `EQUALS; / decrement a given accounts balance
                `THAT /
                );

Assertion   :{
    [mockId      : `long$()]
    testId       : `long$();
    kind         : `.testUtils.ASSERTIONKIND;
    state        : `.testUtils.TESTSTATE;
    dscr         : `char$();
    subject      : ();
    object       : ();
    predicate    : ();
    start        : `datetime$();
    end          : `datetime$()
    };



// Register adds a test to the given test table.
Register    :{[kind;name;dscr;func;params;before;after]

    };

// Generates the tabular representation of 
generateReport  :{

    };

RunTests    :{[testKinds]

    };