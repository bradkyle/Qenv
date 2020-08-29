
getdata:{select from x where time within (min[time];(min[time]+(`minute$y)))};

// ENGINE BENCHMARKS
// ============================================================================>

bench:.qt.Bench[
    ".engine.ProcessEvents";
    {[c]
        p:c[`params];

        .qt.BM[.engine.ProcessEvents;p[`datafn][];p[`repeats];".engine.ProcessEvents";c];

    };
    {[p]

    };
    (
        ("Benchmark an hours worth of depth updates";(

        ));
        ("Bencmark an hours worth of non agent trades";(

        ));
        ("Bencmark an hours worth of mark price updates";(

        ));
        ("Bencmark an hours worth of combined events";(

        ));
        ("Bencmark an hours worth of place order events (1 agent)";(

        ));
        ("Bencmark an hours worth of place order events (5 agents)";(

        ));
        ("Bencmark an hours worth of place order events (10 agents)";(

        ));
        ("Bencmark an hours worth of cancel order events (1 agent)";(

        ));
        ("Bencmark an hours worth of cancel order events (5 agents)";(

        ));
        ("Bencmark an hours worth of cancel order events (10 agents)";(

        ));
        ("Bencmark an hours worth of amend order events (1 agent)";(

        ));
        ("Bencmark an hours worth of amend order events (5 agents)";(

        ));
        ("Bencmark an hours worth of amend order events (10 agents)";(

        ));
        ("Bencmark an hours worth of combined events (1 agent)";(

        ));
        ("Bencmark an hours worth of combined events (5 agents)";(

        ));
        ("Bencmark an hours worth of combined events (10 agents)";(

        ))
    );
    ("Benchmarks the processing speed of the .engine.ProcessEvents",
     "function with differing configuration")];


// STATE BENCHMARKS : InsertResultantEvents
// ============================================================================>


bench:.qt.Bench[
    ".state.InsertResultantEvents";
    {[c]
        p:c[`params];

        .qt.BM[.engine.ProcessEvents;p[`datafn][];p[`repeats];".engine.ProcessEvents";c];

    };
    {[p]

    };
    (
        ("Benchmark an hours worth of depth updates";(

        ));
        ("Bencmark an hours worth of non agent trades";(

        ));
        ("Bencmark an hours worth of mark price updates";(

        ));
        ("Bencmark an hours worth of combined events";(

        ));
        ("Bencmark an hours worth of place order events (1 agent)";(

        ));
        ("Bencmark an hours worth of place order events (5 agents)";(

        ));
        ("Bencmark an hours worth of place order events (10 agents)";(

        ));
        ("Bencmark an hours worth of cancel order events (1 agent)";(

        ));
        ("Bencmark an hours worth of cancel order events (5 agents)";(

        ));
        ("Bencmark an hours worth of cancel order events (10 agents)";(

        ));
        ("Bencmark an hours worth of amend order events (1 agent)";(

        ));
        ("Bencmark an hours worth of amend order events (5 agents)";(

        ));
        ("Bencmark an hours worth of amend order events (10 agents)";(

        ));
        ("Bencmark an hours worth of combined events (1 agent)";(

        ));
        ("Bencmark an hours worth of combined events (5 agents)";(

        ));
        ("Bencmark an hours worth of combined events (10 agents)";(

        ))
    );
    ("Benchmarks the processing speed of the .engine.ProcessEvents",
     "function with differing configuration")];



// STATE BENCHMARKS : GetObservations
// ============================================================================>

bench:.qt.Bench[
    ".state.GetObservations";
    {[c]
        p:c[`params];

        .qt.BM[.engine.ProcessEvents;p[`datafn][];p[`repeats];".engine.ProcessEvents";c];

    };
    {[p]

    };
    (
        ("Benchmark ohlc only observations (1 second step; 30 windowsize)";(

        ));
        ("Bencmark depth only observations (1 second step; 30 windowsize)";(

        ));
        ("Bencmark depth and ohlc observations (1 second step; 30 windowsize)";(

        ));
        ("Bencmark depth and ohlc observations (1 second step; 30 windowsize)";(

        ));
    );
    ("Benchmarks the processing speed of the .engine.ProcessEvents",
     "function with differing configuration")];

// STATE BENCHMARKS : GetRewards
// ============================================================================>

bench:.qt.Bench[
    ".state.GetRewards";
    {[c]
        p:c[`params];

        .qt.BM[.engine.ProcessEvents;p[`datafn][];p[`repeats];".engine.ProcessEvents";c];

    };
    {[p]

    };
    (
        ("Benchmark ohlc only observations";(

        ));
        ("Bencmark depth only observations";(

        ));
        ("Bencmark depth and ohlc observations";(

        ));
        ("Bencmark depth and ohlc observations";(

        ))
    );
    ("Benchmarks the processing speed of the .engine.ProcessEvents",
     "function with differing configuration")];


// Run benchmarks and output results to the results dir
.qt.RunBenchmarks["results"];