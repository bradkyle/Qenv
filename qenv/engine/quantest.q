\l qunit.q
system "d .quantest";


// Forms a message pertaining to form
// of a test case. 
FailedMsg :{[dscr;expected;result]:(dscr," | expected:",string[expected]," - got:",string[result])};

/ simple profiler for functions
/ does not support projection
/ does not really work if functions defined using \d
/ does not work for f . a, use f a for monadic or f[a;a0] etc
/ in .p namespace for ease of use
/ any issues let me know
/ example
/ q)f
/ {[x;y]
/   x+y;
/   {x;y;z}[5+33;x;];
/   :x+y;
/  }
/ q)p)f[1;2]
/ fn                      time         pct
/ ----------------------------------------
/ "{[x;y]\n  x+y;"        00:00:00.000 50
/ "\n  {x;y;z}[5+33;x;];" 00:00:00.000 25
/ "\n  :x+y;"             00:00:00.000 25
/ "\n }"                  00:00:00.000 0
/ q)p){1+2;til 100;til 2000}`
/ fn         time         pct
/ --------------------------------
/ "{1+2;"    00:00:00.000 11.11111
/ "til 100;" 00:00:00.000 16.66667
/ "til 2000" 00:00:00.000 72.22222
/ ,"}"       00:00:00.000 0
/ q)p){system"sleep 1";x+'til 1000;x+y+123}[1;2]
/ fn                    time         pct
/ -----------------------------------------------
/ "{system\"sleep 1\";" 00:00:01.002 99.99132
/ "x+'til 1000;"        00:00:00.000 0.008581704
/ "x+y+123"             00:00:00.000 9.978725e-05
/ ,"}"                  00:00:00.000 0
e:{profile[first x;eval each 1_x:parse x]}

profile:{[f;a]
  f:$[-11h=type f;get f;f];
  if[100h<>type f;'"profiler nyi"];
  f:@[tag;f;{'"profiler failed to tag:",x}];
  t:run[f;a];
  :disp[f;t];
 };

stub:";.p.time,:.z.p;"; / append this for timing

tag:{[f]
  f:-4!string f;
  i:min 2 1 1>f{sums(-). x~\:/:1#'y}/:("{}";"[]";"()"); / indices to ignore brackets
  f:raze f@[;;,;stub]/where i&f~\:1#";";                / append timing stub
  if[$[null i:last count[stub]+f ss stub;1;not all(-1_i _f)in" \t\n"];
    f:(-1_f),stub,"}"];                                / handle ...} without ;
  :get f;
 };

run:{[f;a]
  .p.time:1#.z.p;
  f . a;
  :.p.time,.z.p;
 };

disp:{[f;t]
  r:update time:1_deltas t til 1+count fn from([]fn:stub vs string f);
  r:update time:0D from r where all each fn in\:"\t\n }";      / handle "empty" lines
  :update trim fn,`time$0^time,pct:0^100*time%sum time from r; / time easier to read?
 };

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

test[`UNIT] :   {[tester]
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

mock[`FAKE] :   {[mocker]
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

assert[`TRUE] :   {[assertion]
    :0N;
    };

// Case
// ======================================================================>

Case    :(
    [caseId      : `long$()]
    testId       : `long$();
    state        : `.quantest.TESTSTATE$();
    dscr         : `char$();
    func         : ();
    params       : ();
    before        : ();
    after       : ();
    repeat       : `long$();
    retry        : `long$();
    start        : `datetime$();
    end          : `datetime$();
    profileRes   : ()
    );

// Main (Callable) Functions.
// ======================================================================>

// Register adds a test to the given test table.
Register    :{[kind;dscr;func;params;before;after]

    };

// todo Unit, Integration, Benchmark, Profile, T

AddCase     :{[]

    };

// Generates the tabular representation of 
generateReport  :{

    };

formatTable     :{

    };

RunTests    :{[test;filter;only]
    
    };

ResetTest   :{

    }