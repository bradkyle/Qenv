

// Bucketed Limit Order Creation
// ---------------------------------------------------------------------------------------->

test:.qt.Unit[
    ".adapter.uniBucketOrders";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for creating a new account"];


test:.qt.Unit[
    ".adapter.expBucketOrders";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for creating a new account"];


test:.qt.Unit[
    ".adapter.logBucketOrders";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for creating a new account"];


// Stop Creation
// ---------------------------------------------------------------------------------------->

test:.qt.Unit[
    ".adapter.naiveStops";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for creating a new account"];


test:.qt.Unit[
    ".adapter.uniStops";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for creating a new account"];


test:.qt.Unit[
    ".adapter.expStops";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for creating a new account"];


test:.qt.Unit[
    ".adapter.logStops";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for creating a new account"];


// Stop Creation
// ---------------------------------------------------------------------------------------->

test:.qt.Unit[
    ".state.adapter.createUniTemporalOrders";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for creating a new account"];


test:.qt.Unit[
    ".state.adapter.createRandTemporalOrders";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for creating a new account"];