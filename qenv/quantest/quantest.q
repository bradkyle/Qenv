\l qunit.q
system "d .qt";


line: {show 99#"-"};
dline: {show 99#"="};
hline: {show 99#"#"}
uline: {line[];}

lg:{a:string[.z.t],$[type[x]=98h; "\r\n"; "  "],$[type[x] in 10 -10h; x; .Q.s x],"\r\n"; l::l,enlist a; 1 a; x};

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
TESTSTATE   :`READY`PASS`FAIL`SKIP;
SETUPSTATE  :`SETUP`MOCK`TESTING;

Test    :(
    [testId      : `long$()]
    name         : `symbol$();
    namespace    : `symbol$();
    kind         : `.qt.TESTKIND$();
    state        : `.qt.TESTSTATE$();
    dscr         : `symbol$();
    func         : {};
    repeat       : `long$();
    retry        : `long$();
    beforeEach   : {};
    afterEach    : {};
    beforeAll    : {};
    afterAll     : {};
    start        : `datetime$();
    end          : `datetime$()
    );

SkipTest    :{
    update state:`SKIP from `.test.Test where testId=tid;
    };

// Main (Callable) Test Functions
// ======================================================================>

fnhooknames: `beforeTest`afterTest`beforeEach`afterEach
allhooknames: `beforeNamespaces`afterNamespaces`beforeNamespace`afterNamespace,fnhooknames;

// todo Unit, Integration, Benchmark, Profile, T
Unit        :{[name;testFn;cases;hooks;dscr]
    beforeTest:hooks[0];
    afterTest:hook[1];
    beforeEach:hook[2];
    afterEach:hook[3]

    `.qt.Test upsert cols[.qt.Test]!(1;name;ns;`UNIT;`READY;dscr;testFn;0;0;beforeTest;afterTest;beforeEach;afterEach;.z.z;.z.z);
    };

Integration    :{[]

    }

Benchmark     :{[name;target;iterations]

    };

Profile        :{

    };


// Main (Callable) Functions.
// ======================================================================>

// Generates the tabular representation of 
generateReport  :{

    };

formatTable     :{

    };

/ find functions with a certain name pattern within the selected namespace
/ @logEmpty If set to true write to log that no funcs found otherwise stay silent
findFuncs   :{ [ns; pattern; logEmpty]
        fl:{x where x like y}[system "f ",string ns; pattern];
        if[logEmpty or 0<count fl; lg pattern," found: `","`" sv string fl];
        $[ns~`.; fl; `${"." sv x} each string ns,/:fl]};

prepareNsTest   :{[ns]
    if[not (ns~`.) or (`$1_string ns) in key `; 'nsNoExist]; // can't find namespace
    currentNamespaceBeingTested::{$["."=first a:string x; `$1 _ a; x]} ns;
    ff:findFuncs[ns;;1b];

    };


ResetTest   :{

    };

testFnWrapper   :{[testFn]

    };

// TODO protected execution
runTestCase     :{[test; case]
    test[`beforeEach][];
    test[`func][case[`params];case]
    test[`afterEach][];
    };

runTest         :{[test]
    cases:select from `.qt.Case where state=`READY;
    test[`start]:.z.z;
    runTestCase each (test;cases);
    test[`end]:.z.z;
    test[`afterAll][];
    `qt.Test upsert test;
    };

RunTests    :{[nsList;filter;only]
    dline["RUNNING TESTS"];
    nsl:$[11h~abs type nsList; nsList; `$".",/:string a where (lower a:key `) like "*test"];     
    / a:raze prepareTests each (),nsl;
    / lg $[count a; a; 'noTestsFound];
    if[count[cases]>0;runTestCase each cases]
    
    / test[`beforeAll][];
    / dline[test[`name]];
    / uline[test[`dscr]];
    };

// Case
// ======================================================================>

Case    :(
    [caseId      : `long$()]
    testId       : `.qt.Test$();
    state        : `.qt.TESTSTATE$();
    dscr         : `symbol$();
    params       : ();
    repeat       : `long$();
    retry        : `long$();
    start        : `datetime$();
    end          : `datetime$();
    );


// Adds a specific case to a test with assertions and mocks included.
// @param ref is either a table or a id
// @param dscr Description of this test or related message
// @param params are the specific case params that are to be passed 
// to the testFn on execution of the test.
// @return case
AddCase     :{[ref;dscr;params]
    `.qt.Test upsert cols[.qt.Case]!(1;1;`READY;dscr;params;0;0;.z.z;.z.z);

    };


SkipCase    :{[]
    update state:`SKIP from `.test.Test where testId=tid;
    };

// Mock
// ======================================================================>
// Mocks serve to replace a given function or variable (entity) with
// a given replacement such that tests can be performed in an idempotent
// manner.

/ mock kind enumerations
MOCKKIND    :`FAKE`SPIE`STUB`MOCK`TIMER;

Mock        :(
    [mockId      : `long$()]
    testId       : `.qt.Test$();
    kind         : `.qt.MOCKKIND$();
    namespace    : `symbol$();
    tags         : ();
    returns      : ();
    throws       : ();
    rejects      : ();
    target       : ();
    replacement  : ();
    doWait       : `boolean$();
    waitBefore   : `second$();
    waitAfter    : `second$();
    called       : `boolean$();
    numCalls     : `long$()
    );

Invocations :(
    [invokeId      : `long$()]
    mockId       : `.qt.Mock$();
    invokedWith  : ()
    );

// TODO restore;
mock : (`.qt.MOCKKIND$())!(); // TODO change to subset of supported types.

mock[`FAKE] :   {[mocker]
    :0N;
    };

// Wraps a given rep function with common logic
// @param repFn function that replaces the given target
repFn :{[replacement;params] // creates lambda function to be used later
    `.qt.Invocations insert ();
    :replacement[params];
    };

// Replace a given variable/table/reference etc. with another
// @param target is the function that is to be replaced.
// @param expected An object representing the expected value
// @param msg Description of this test or related message
// @return reference to mock object which can be used to 
// make assertions on behavior of function.
M   :{[target;replacement;name;case]
    // TODO check target, replacement, tags, name
    // TODO create mockid etc.
    // Initialize representation in mock table.
    `.qt.Mock insert (); 
    // Replace target with mock replacement
    target:repFn[replacement];
    };

// Get Mocks by tags
// Get Mocks by name
// TODO skip
SkipMock    :{[]
    
    };

// Profile
// ======================================================================>

/ Profile   :(
/     [profileId      : `long$()]
/     testId         : `.qt.Test$();
/     caseId         : `.qt.Case$();
/     kind           : `.qt.ASSERTIONKIND;
/     state          : `.qt.TESTSTATE;
/     dscr           : `char$();
/     actual         : ();
/     relation       : ();
/     expected       : ()
/     );
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
    testId         : `.qt.Test$();
    caseId         : `.qt.Case$();
    kind           : `.qt.ASSERTIONKIND;
    state          : `.qt.TESTSTATE;
    dscr           : `char$();
    actual         : ();
    relation       : ();
    expected       : ()
    );

// Assert that the relation between expected and actual value holds
// @param actual An object representing the actual result value
// @param expected An object representing the expected value
// @param msg Description of this test or related message
// @return actual object
A   :{[actual;relation;expected;msg;case]
    failFlag::not .[relation; (actual; expected); 0b];
    if[failFlag;
        lg "expected = ",-3!expected;
        lg "actual = ",-3!actual;];
    ar::`actual`expected`msg!(actual;expected;msg);
    if[failFlag; 'assertThatFAIL];
    }

SkipAssertion   :{[]
    // TODO
    };
