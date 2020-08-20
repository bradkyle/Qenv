\l adapter.q
\l state.q
system "d .adapterTest";
\cd ../quantest/
\l quantest.q 
\cd ../engine/


defaultAfterEach: {
     
     .qt.RestoreMocks[];
    };

defaultBeforeEach: {
     
    };

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


.qt.RunTests[];