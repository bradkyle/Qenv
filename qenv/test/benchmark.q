

hrdata:{count select from x where time within (min[time];(min[time]+(`minute$y)))};

bench:.qt.Bench[
    ".engine.ProcessEvents";
    {[c]
    
    };
    {[p]

    };
    ("Benchmarks the processing speed of the",
     "engine with differing configuration")];