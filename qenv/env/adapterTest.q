\l adapter.q
\l state.q
system "d .adapterTest";
\cd ../quantest/
\l quantest.q 
\cd ../env/

z:.z.z;

defaultAfterEach: {
     
     .qt.RestoreMocks[];
    };

defaultBeforeEach: {
     
    };

test:.qt.Unit[
    ".adapter.createOrderAtLevel";
    {[c]
        p:c[`params];

        .state.DefaultInstrumentId:p[`eDI];
        .qt.M[`.state.getPriceAtLevel;p[`MgetPriceAtLevel];c];
        .qt.M[`.state.genNextClOrdId;p[`MgenNextClOrdId];c];
        
        a:p[`args];
        res:.adapter.createOrderAtLevel[a[0];a[1];a[2];a[3]];

        .qt.A[res;~;p[`eRes];"result";c];

    };
    {[p]:`args`MgetPriceAtLevel`MgenNextClOrdId`eDI`eRes!(p[0];p[1];p[2];p[3];p[4])};
    (
        ("Given correct params should return correct";(
            (1;`SELL;100;1;0b;z);
            {[l;s] :100};
            {0};
            0;0));
        ("Given correct params should return correct";(
            (1;`SELL;100;1;0b;z);
            {[l;s] :100};
            {0};
            0;0))
    );
    .qt.sBlk;
    "Global function for processing new orders"];

/ .qt.SkpAft[0];

test:.qt.Unit[
    ".adapter.createOrderEventsByTargetDist";
    {[c]
        p:c[`params];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".adapter.createOrderEventsByLevelDeltas";
    {[c]
        p:c[`params];
        
    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".adapter.createMarketOrderEvent";
    {[c]
        p:c[`params];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".adapter.createFlattenEvents";
    {[c]
        p:c[`params];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".adapter.createCancelAllOrdersEvent";
    {[c]
        p:c[`params];
        
    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".adapter.createOrderEventsFromDist";
    {[c]
        p:c[`params];
        
    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".adapter.createMarketOrderEventsFromDist";
    {[c]
        p:c[`params];
        time:.z.z;

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".adapter.createDepositEvent";
    {[c]

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".adapter.createOrderEventsByTargetDist";
    {[c]
        
    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


test:.qt.Unit[
    ".adapter.createNaiveStopEvents";
    {[c]
        
    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];

test:.qt.Unit[
    ".adapter.ADAPTERTYPE$`DISCRETE adapter";
    {[c]
        
    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];

test:.qt.Unit[
    ".adapter.ADAPTERTYPE$`MARKETMAKER adapter";
    {[c]
        
    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];

test:.qt.Unit[
    ".adapter.Adapt";
    {[c]
        
    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];


.qt.RunTests[];