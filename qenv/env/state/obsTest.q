



test:.qt.Unit[
    ".obs.derive";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for creating a new account"];


test:.qt.Unit[
    ".obs.GetObs";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for creating a new account"];
