


test:.qt.Unit[
    ".adapter.getPriceAtLevel";
    {[c]
        p:c[`params];

    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


.qt.AddCase[test;"hedged:long_to_longer";()];

test:.qt.Unit[
    ".adapter.getOpenPositions";
    {[c]
        p:c[`params];

    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".adapter.getCurrentOrderLvlDist";
    {[c]
        p:c[`params];

    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".adapter.createOrderEventsAtLevel";
    {[c]
        p:c[`params];

    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".adapter.createOrderEventsByTargetDist";
    {[c]
        p:c[`params];

    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".adapter.createOrderEventsByLevelDeltas";
    {[c]
        p:c[`params];
        
    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".adapter.createMarketOrderEvent";
    {[c]
        p:c[`params];

    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".adapter.createFlattenEvents";
    {[c]
        p:c[`params];

    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".adapter.createCancelAllOrdersEvent";
    {[c]
        p:c[`params];
        
    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".adapter.createOrderEventsFromDist";
    {[c]
        p:c[`params];
        
    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".adapter.createMarketOrderEventsFromDist";
    {[c]
        p:c[`params];
        time:.z.z;

    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".adapter.createDepositEvent";
    {[c]

    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".adapter.createOrderEventsByTargetDist";
    {[c]
        
    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".adapter.createNaiveStopEvents";
    {[c]
        
    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];

test:.qt.Unit[
    ".adapter.ADAPTERTYPE$`DISCRETE adapter";
    {[c]
        
    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];

test:.qt.Unit[
    ".adapter.ADAPTERTYPE$`MARKETMAKER adapter";
    {[c]
        
    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];

test:.qt.Unit[
    ".adapter.Adapt";
    {[c]
        
    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];