
getdata:{select from x where time within (min[time];(min[time]+(`minute$y)))};

// ENGINE BENCHMARKS
// ============================================================================>

bench:.qt.Bench[
    ".engine.ProcessEvents";
    {[c]
        p:c[`params];

        .qt.BM[.engine.ProcessEvents;getdata[];".engine.ProcessEvents";];

    };
    {[p]

    };
    (
        ("Benchmark an hours worth of depth updates";(

        ));
        ("Bencmark an hours worth of non agent trades";(

        ))
    );
    ("Benchmarks the processing speed of the .engine.ProcessEvents",
     "function with differing configuration")];


// STATE BENCHMARKS
// ============================================================================>