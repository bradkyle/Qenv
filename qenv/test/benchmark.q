

hrdata:{count select from x where time within (min[time];(min[time]+(`minute$y)))};

bench:.qt.Bench[
    ".engine.ProcessEvents";
    {

    };

    ("Benchmarks the processing speed of the ",
     "engine with differing configuration")];