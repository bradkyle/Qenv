

test:.qt.Unit[
    ".engine.UpdateEngineProbs";
    {[c]
        p:c[`params];
        
    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".engine.ResetEngine";
    {[c]
        p:c[`params];

    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".engine.prepareIngress";
    {[c]
        p:c[`params];

    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".engine.prepareIngress";
    {[c]
        p:c[`params];

    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".engine.prepareEgress";
    {[c]
        p:c[`params];

    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".engine.ProcessEvents";
    {[c]
        p:c[`params];

    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];



test:.qt.Unit[
    ".engine.Setup";
    {[c]
        p:c[`params];
    
    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];

// TODO engine integration tests i.e. on real data
// TODO test that live data generates same state