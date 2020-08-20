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


setupState  :{[]


    };

// ApplyFunding
// ==================================================================================>

test:.qt.Unit[
    ".observation.getFeatureVectors";
    {[c]
        p:c[`params];
        setupState[p];

        .observation.getFeatureVectors[p[o]];
        
        // Assertions
        checkAccount[p;c];
        checkInventory[p;c];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Derives a feature vector for each account, inserts it into a feature buffer, then returns normalized vector bundle"];

deriveCaseParams :{[p]

   
    };


.qt.AddCase[test;"getFeatureVectors";deriveCaseParams[(
    
    )]];