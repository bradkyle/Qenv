\l qunit.q
system "d .quantest";


// Forms a message pertaining to form
// of a test case. 
FailedMsg :{[dscr;expected;result]:(dscr," | expected:",string[expected]," - got:",string[result])};

// Test
// ======================================================================>

TESTKIND    :`UNIT`INTEGRATION`BENCHMARK`PROFILE;
TESTSTATE   :`PASS`FAIL`SKIP;
SETUPSTATE  :`SETUP`MOCK`TESTING;

Test    :(
    [testId      : `long$()]
    name         : `symbol$();
    namespace    : `symbol$();
    kind         : `.quantest.TESTKIND$();
    state        : `.quantest.TESTSTATE$();
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

test : (`.quantest.TESTKIND$())!(); // TODO change to subset of supported types.

test[`UNIT] :   {[params]
    :0N;
    };

// Mock
// ======================================================================>

/ mock kind enumerations
MOCKKIND    :`FAKE`SPIE`STUB`MOCK`TIMER;

Mock        :(
    [mockId      : `long$()]
    testId       : `long$();
    kind         : `.quantest.MOCKKIND$();
    returns      : ();
    throws       : ();
    rejects      : ();
    calledWith   : ();
    mocks        : ();
    replaceWith  : ();
    numCalls     : `long$()
    );

// TODO restore;
mock : (`.quantest.MOCKKIND$())!(); // TODO change to subset of supported types.

mock[`FAKE] :   {[params]
    :0N;
    };

/ // Assert
/ // ======================================================================>

/ assertion kind enumerations
ASSERTIONKIND:  (`TRUE;      / place a new order
                `THROWS;    / modify an existing order
                `KNOWN;    / increment a given accounts balance
                `EQUALS; / decrement a given accounts balance
                `THAT /
                );

Assertion   :(
    [assertId      : `long$()]
    testId       : `long$();
    kind         : `.quantest.ASSERTIONKIND;
    state        : `.quantest.TESTSTATE;
    dscr         : `char$();
    subject      : ();
    object       : ();
    predicate    : ();
    start        : `datetime$();
    end          : `datetime$()
    );

assert : (`.quantest.ASSERTIONKIND$())!(); // TODO change to subset of supported types.

assert[`TRUE] :   {[params]
    :0N;
    };

// Main (Callable) Functions.
// ======================================================================>

// Register adds a test to the given test table.
Register    :{[kind;name;dscr;func;params;before;after]

    };

// Generates the tabular representation of 
generateReport  :{

    };

formatTable     :{

    };

RunTests    :{[testKinds]
    
    };