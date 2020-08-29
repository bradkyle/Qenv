

hrdata:{count select from x where time within (min[time];(min[time]+(`minute$y)))};

bench:.qt.Bench[
    ".engine.ProcessEvents";
    {[c]
    
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