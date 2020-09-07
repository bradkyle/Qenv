

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

// Flattening Utils
// ---------------------------------------------------------------------------------------->

test:.qt.Unit[
    ".state.adapter.createFlattenSideOrdersLimit";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for creating a new account"];


test:.qt.Unit[
    ".state.adapter.createFlattenAllOrdersLimit";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for creating a new account"];


test:.qt.Unit[
    ".state.adapter.createFlattenSideOrdersMarket";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for creating a new account"];


test:.qt.Unit[
    ".state.adapter.createFlattenAllOrdersMarket";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for creating a new account"];


// Macro Action Utils
// ---------------------------------------------------------------------------------------->



// General Order Placement Utilities
// ---------------------------------------------------------------------------------------->

test:.qt.Unit[
    ".state.adapter.createOrderAtPrice";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for creating a new account"];

test:.qt.Unit[
    ".state.adapter.createOrderAtLevel";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for creating a new account"];


test:.qt.Unit[
    ".state.adapter.createOrderAtBucket";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for creating a new account"];


// Aggregate order Placement utilities
// ---------------------------------------------------------------------------------------->

test:.qt.Unit[
    ".state.adapter.addDeltaOrdersByPrice";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for creating a new account"];

test:.qt.Unit[
    ".state.adapter.addDeltaOrdersByLevel";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for creating a new account"];

test:.qt.Unit[
    ".state.adapter.addDeltaOrdersByBucket";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for creating a new account"];


// Action Adapter Mapping
// ---------------------------------------------------------------------------------------->

test:.qt.Unit[
    ".state.adapter.mapping$DISCRETE";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for creating a new account"];


test:.qt.Unit[
    ".state.adapter.mapping$MARKETMAKER";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for creating a new account"];


test:.qt.Unit[
    ".state.adapter.Adapt";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for creating a new account"];