\l qunit.q
system "d .qt";
\c 4000 4000

line: {show 99#"-"};
dline: {show 99#"="};
hline: {show 99#"#"}
uline: {line[];}

lg:{a:string[.z.t],$[type[x]=98h; "\r\n"; "  "],$[type[x] in 10 -10h; x; .Q.s x],"\r\n"; l::l,enlist a; 1 a; x};

// Forms a message pertaining to form
// of a test case. 
FailedMsg :{[dscr;expected;result]:(dscr," | expected:",string[expected]," - got:",string[result])};

// Generates the tabular representation of 
generateReport  :{

    };

formatTable     :{

    };

// Test
// ======================================================================>

TESTKIND    :`UNIT`INTEGRATION`BENCHMARK`PROFILE;
TESTSTATE   :`READY`PASS`FAIL`SKIP`ERROR;
SETUPSTATE  :`SETUP`MOCK`TESTING;

testId:-1;
Test    :(
    [testId      : `long$()]
    name         : `symbol$();
    kind         : `.qt.TESTKIND$();
    state        : `.qt.TESTSTATE$();
    dscr         : `symbol$();
    func         : {};
    repeat       : `long$();
    retry        : `long$();
    beforeAll    : {};
    afterAll     : {};
    beforeEach   : {};
    afterEach    : {};
    start        : `datetime$();
    end          : `datetime$();
    sourceFile   : `symbol$()
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
    $[not null[`$name];name:`$name;name:`$""];
    $[not null[`$dscr];dscr:`$dscr;dscr:`$""];
    / validHook:{:$[100h~type vFn:value x; $[1~count (value vFn) 1; 1b; 0b]; 0b];};
    / if[not all[validHook each hooks]; :(0b;0b;"invalid hooks specified")];
    / validFn:$[100h~type vFn:value replacement; $[1~count (value vFn) 1; 1b; 0b]; 0b];
    / if[not validFn; :(0b;0b;"testFn should be dual arg function [p;c]")];

    test:cols[.qt.Test]!((testId+:1);name;`UNIT;`READY;dscr;testFn;0;0;hooks[0];hooks[1];hooks[2];hooks[3];.z.z;.z.z;.z.f);
    `.qt.Test upsert test;

    if[count[cases]>0;.qt.AddCase[test] each cases];

    :test
    };

Integration    :{[]

    }


// Main (Callable) Functions.
// ======================================================================>

pntAssertion :{[assertion]
    show 50#"-";
    show "" sv string[assertion[`msg], " not (",assertion[`relation],")"];
    show flip exec actual, expected from assertion;
    };

pntFailCase     :{[case]
    .qt.pntAssertion each select from 0!.qt.Assertion where (state in `FAIL`ERROR), caseId=case[`caseId];
    };

pntCase     :{[case]
    show " ";
    show case[`dscr];
    show case[`state];
    show 50#"-";
    show case[`params];
    .qt.pntAssertion each select from 0!.qt.Assertion where caseId=case[`caseId];
    };

showCase    :{[cId]
    c:exec from 0!.qt.Case where caseId=cId;
    .qt.pntCase[c];
    };

nxtFailCase :{[]
    c:first select from 0!.qt.Case where state in `FAIL`ERROR;
    .qt.pntCase[c];
    :c;
    };

pntTest      :{[test]
    show 99#"-";
    show ("" sv string[test[`name], " (",test[`kind],") :", test[`state]]);
    show test[`dscr];
    show 99#"-";
    show select caseId,state,dscr from .qt.Case where testId=test[`testId];
    }

// TODO protected execution
runCase :{[test; case] 
    test[`beforeEach][]; 
    res:(@[test[`func];case;{show 99#"#";show "Error occurred in test:", x;show 99#"#"; :`ERROR}]);
   show res;
    $[(`$string[res])=`ERROR; 
        [update state:`.qt.TESTSTATE$`ERROR from `.qt.Case where caseId=case[`caseId]];
      exec any state=`FAIL from .qt.Assertion where caseId=case[`caseId];
        [update state:`.qt.TESTSTATE$`FAIL from `.qt.Case where caseId=case[`caseId]];
        [update state:`.qt.TESTSTATE$`PASS from `.qt.Case where caseId=case[`caseId]]];
    test[`afterEach][];
    };

runCaseOnly :{[case]
    t:exec from 0!.qt.Test where testId=case[`testId];
    runCase[t;case];
    };

// TODO runs all tests and then gets next fail
runNxtFail  :{
    c:.qt.nxtFailCase[];
    .qt.runCaseOnly[c];
    }

runTest         :{[test]
    cases:select from 0!.qt.Case where state=`READY, testId=test[`testId];
    test[`beforeAll][];
    test[`start]:.z.z;
    {runCase[x[0];x[1]]} each flip[(count[cases]#enlist test;cases)]; // TODO fix messy
    test[`end]:.z.z;
    test[`afterAll][];
    `qt.Test upsert test;
    };

showFailedTests :{[]
    .qt.pntTest each (select from 0!.qt.Test where state=`FAIL);
    };

RunTests :{
    runTest each select from 0!.qt.Test where state=`READY;
    show 99#"=";show (45#" "),"TEST";show 99#"=";
    .qt.pntTest each 0!.qt.Test;
    };

RunNsTests    :{[nsList;filter;only]
    dline["RUNNING TESTS"];
    nsl:$[11h~abs type nsList; nsList; `$".",/:string a where (lower a:key `) like "*test"];     
    / a:raze prepareTests each (),nsl;
    / lg $[count a; a; 'noTestsFound];
    if[count[cases]>0;runTest each (select from 0!.qt.Test where state=`READY)];
    
    / test[`beforeAll][];
    / dline[test[`name]];
    / uline[test[`dscr]];
    };

RNxt :{
    .qt.Revert[];
    .qt.RunTests[];
    .qt.nxtFailCase[];
    };

// Case
// ======================================================================>

caseId:-1;
Case    :(
    [caseId      : `long$()]
    testId       : `.qt.Test$();
    state        : `.qt.TESTSTATE$();
    dscr         : `symbol$();
    msg          : `symbol$();
    params       : {};
    repeat       : `long$();
    retry        : `long$();
    start        : `datetime$();
    end          : `datetime$()
    );


// Adds a specific case to a test with assertions and mocks included.
// @param ref is either a table or a id
// @param dscr Description of this test or related message
// @param params are the specific case params that are to be passed 
// to the testFn on execution of the test.
// @return case
AddCase     :{[test;dscr;params]
    $[not null[`$dscr];dscr:`$dscr;dscr:`$""];
    if[not((type[test] in 98 99h) and (test[`testId] in key[.qt.Test]));show "error"]; // TODO better error
    if[not(type[params] in 98 99h);0N]; // TODO better error
    case:cols[.qt.Case]!((caseId+:1);test[`testId];`READY;dscr;(`$"");params;0;0;.z.z;.z.z);
    `.qt.Case upsert case;
    };


/ SkipCase    :{[tid] update state:`SKIP from `.test.Test where testId=tid;};

// Mock
// ======================================================================>
// Mocks serve to replace a given function or variable (entity) with
// a given replacement such that tests can be performed in an idempotent
// manner.

/ mock kind enumerations
MOCKKIND    :`FAKE`SPIE`STUB`MOCK`TIMER;

mockId:-1;
Mock        :(
    [mockId      : `long$()]
    testId       : `.qt.Test$();
    caseId       : `.qt.Case$();
    kind         : `.qt.MOCKKIND$();
    namespace    : `symbol$(); 
    target       : {};
    replacement  : {};
    doWait       : `boolean$();
    waitBefore   : `long$();
    waitAfter    : `long$();
    called       : `boolean$();
    numCalls     : `long$()
    );

invokeId:-1;
Invocation :(
    [invokeId      : `long$()]
    mockId       : `.qt.Mock$();
    invokedWith  : ()
    );

// Wraps a given rep function with common logic
// @param repFn function that replaces the given target
repFn :{[replacement;mId;params] // creates lambda function to be used later
    `.qt.Invocation insert ((invokeId+:1);mId;params);
    update called:1b, numCalls:numCalls+1 from `.qt.Mock where mockId=mId;
    :replacement[params];
    };

// Replace a given variable/table/reference etc. with another
// @param target is the function that is to be replaced.
// @param expected An object representing the expected value
// @param msg Description of this test or related message
// @return reference to mock object which can be used to 
// make assertions on behavior of function.
M   :{[target;replacement;name;case]
    r:@[{(1b;value x)}; name;00b];
    / if variable has an existing value
    $[(not name in unsetMocks) and first r;
        [if[not name in key mocks; mocks[name]:r 1]]; / store original value 
        unsetMocks,:name];
    
    / make sure func declared in same ns as any existing function        
    if[100h~type fn:mocks name;
        lg "isFunc";
        ns:string first (value fn) 3;
        lg "ns = ",ns;
        v:string $[ns~"";name;last ` vs name];
        lg "v = ",v;
        runInNs[ns; v,":",string replacement];
        :name];

    // TODO check target, replacement, tags, name
    // TODO create mockid etc.
    // Initialize representation in mock table.
    // TODO check that target and replacement have the same number of params if function 
    / $[ns~`.; target; `${"." sv x} each string ns,/:fl];
    .qt.mockId+:1;
    `.qt.Mock insert (.qt.mockId;case[`testId];case[`caseId];`MOCK;`.extern;target;replacement;0b;0;0;0b;0); 
    // Replace target with mock replacement
    target set repFn[replacement;.qt.mockId];
    };

RestoreMocks    :{[]

    };

// Get Mocks by tags
// Get Mocks by name
// TODO skip
/ SkipMock    :{[]};

// TODO Watch
// ======================================================================>

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

P        :{

    };


// BenchMark
// ======================================================================>


/ // Errors TODO
/ // ======================================================================>


/ // Assert
/ // ======================================================================>

/ assertion kind enumerations
ASSERTIONKIND:  (`TRUE;      / place a new order
                `THROWS;    / modify an existing order
                `KNOWN;    / increment a given accounts balance
                `EQUALS; / decrement a given accounts balance
                `THAT /
                );

assertId:-1;
Assertion   :(
    [assertId      : `long$()]
    testId         : `.qt.Test$();
    caseId         : `.qt.Case$();
    kind           : `.qt.ASSERTIONKIND;
    state          : `.qt.TESTSTATE;
    msg            : `symbol$();
    actual         : ();
    relation       : `symbol$();
    expected       : ()
    );

// Assert that the relation between expected and actual value holds
// @param actual An object representing the actual result value
// @param expected An object representing the expected value
// @param msg Description of this test or related message
// @param case the case to which this assertion belongs.
// @return actual object
A   :{[actual;relation;expected;msg;case]
    $[not null[`$msg];msg:`$msg;msg:`$""];
    failFlag::not .[relation; (actual; expected); 0b];
    state:$[failFlag;`FAIL;`PASS];
    ass:cols[.qt.Assertion]!((assertId+:1);case[`testId];case[`caseId];`THAT;state;msg;actual;(`$string[relation]);expected);
    `.qt.Assertion upsert ass;
    }


/ // Reset
/ // ======================================================================>

Reset   :{
    .qt.assertId:.qt.mockId:.qt.testId:.qt.invokeId:.qt.caseId:-1;
    delete from `.qt.Assertion;
    delete from `.qt.Invocation;
    delete from `.qt.Mock;
    delete from `.qt.Case;
    delete from `.qt.Test;
    };

Revert  :{
    .qt.assertId:.qt.mockId:.qt.invokeId:-1;
    delete from `.qt.Assertion;
    delete from `.qt.Invocation;
    delete from `.qt.Mock;
    };