
getdata:{select from x where time within (min[time];(min[time]+(`minute$y)))};

// binance-futures-agent-76b96d48cd-xzrth
// TODO process trade vs process depth benchmark

// ENGINE BENCHMARKS
// ============================================================================>

bench:.qt.Bench[
    ".engine.ProcessEvents";
    {[c]
        p:c[`params];

        .qt.BM[.engine.ProcessEvents;p[`datafn][];p[`repeats];".engine.ProcessEvents";c];


        .qt.P[];
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

        .qt.BM[.state.InsertResultantEvents;p[`datafn][];p[`repeats];".state.InsertResultantEvents";c];

        .qt.P[];
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

// TODO benchmark getObservations with features
bench:.qt.Bench[
    ".state.GetObservations";
    {[c]
        p:c[`params];

        .qt.BM[.state.GetObservations;p[`datafn][];p[`repeats];".state.GetObservations";c];

        .qt.P[];
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
        ("Benchmark ohlc only observations (30 second step; 30 windowsize)";(

        ));
        ("Bencmark depth only observations (30 second step; 30 windowsize)";(

        ));
        ("Bencmark depth and ohlc observations (30 second step; 30 windowsize)";(

        ));
        ("Bencmark depth and ohlc observations (30 second step; 30 windowsize)";(

        ));
        ("Benchmark ohlc only observations (1 second step; 100 windowsize)";(

        ));
        ("Bencmark depth only observations (1 second step; 100 windowsize)";(

        ));
        ("Bencmark depth and ohlc observations (1 second step; 100 windowsize)";(

        ));
        ("Bencmark depth and ohlc observations (1 second step; 100 windowsize)";(

        ));
        ("Benchmark ohlc only observations (30 second step; 100 windowsize)";(

        ));
        ("Bencmark depth only observations (30 second step; 100 windowsize)";(

        ));
        ("Bencmark depth and ohlc observations (30 second step; 100 windowsize)";(

        ));
        ("Bencmark depth and ohlc observations (30 second step; 100 windowsize)";(

        ))
    );
    ("Benchmarks the processing speed of the .state.GetObservations",
     "function with differing configuration")];

// STATE BENCHMARKS : GetRewards
// ============================================================================>

bench:.qt.Bench[
    ".state.GetRewards";
    {[c]
        p:c[`params];

        .qt.BM[.state.GetRewards;p[`datafn][];p[`repeats];".state.GetRewards";c];

        .qt.P[];
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
    ("Benchmarks the processing speed of the .state.GetRewards",
     "function with differing configuration")];


// FULL ENV STEP BENCHMARKS
// ============================================================================>


// Run benchmarks and output results to the results dir
.qt.RunBenchmarks["results"];