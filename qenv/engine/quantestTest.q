
\d .external
externalFn  :{[a;b;c]
    show a b c;
    }
\d .

testFn  :{[params;test]
    
    };

beforeAll  :{[]

    };

afterAll   :{[]

    };

beforeEach  :{[]

    };

afterEach   :{[]

    };

test :.quantest.UNIT["testing this register function";testFn;before;after;beforeEach;afterEach];

//TODO make into array and addCases
.quantest.AddCase[test;"hedged:";()];
.quantest.AddCase[test;"hedged:";()];
.quantest.AddCase[test;"hedged:";()];
.quantest.AddCase[test;"hedged:";()];
.quantest.AddCase[test;"hedged:";()];
.quantest.AddCase[test;"hedged:";()];
.quantest.AddCase[test;"hedged:";()];
.quantest.AddCase[test;"hedged:";()];

.quantest.RunTest[test];