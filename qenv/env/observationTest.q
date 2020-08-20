\l observation.q
\l state.q
system "d .observationTest";
\cd ../quantest/
\l quantest.q 
\cd ../env/

z:.z.z;

defaultAfterEach: {
     
     .qt.RestoreMocks[];
    };

defaultBeforeEach: {
     
    };


setupState  :{[p]
    show p[`cEvents];

    };

// ApplyFunding
// ==================================================================================>


test:.qt.Unit[
    ".adapter.Adapt[`MARKETMAKER]";
    {[c]
        p:c[`params];
        setupState[p];

        res:.observation.getFeatureVectors[p[`aids]];
        
        // Assertions
        checkFeatureBuffer[p;c];
        .qt.A[res;~;p[`eRes]];

    };
    {[p]:`aids`cEvents`eFea`eRes!(p[0];p[1];p[2];p[3])};
    (
        ("Should return normalized feature buffer for 1 account";(
            (til 3);
            ();
            ()));
        ("Should fill in resultant nulls with 0 and upsert where neccessary";(
            (til 4);
            ();
            ();
            ()))
    );
    .qt.sBlk;
    ("Derives a feature vector for each account, inserts it into a feature buffer ",
    "then returns normalized (min max) vector bundle for each account.")];



.qt.RunTests[];

