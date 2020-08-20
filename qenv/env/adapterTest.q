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
    "Creates the event to place a new order at a given level in the orderbook"];


test:.qt.Unit[
    ".adapter.makerSide";
    {[c]
        p:c[`params];

        .qt.M[`.state.getPriceAtLevel;p[`MgetPriceAtLevel];c];
        .qt.M[`.state.getLvlOQtysByPrice;p[`MgetLvlOQtysByPrice];c];
        
        a:p[`args];
        res:.adapter.makerSide[a[0];a[1];a[2];a[3];a[4]];

        .qt.A[res;~;p[`eRes];"result";c];

    };
    {[p]:`args`MgetPriceAtLevel`MgetLvlOQtysByPrice`eDI`eRes!(p[0];p[1];p[2];p[3];p[4])};
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
    "derives the set of deltas that ameliarate the delta between the current and target dist for a given side"];


test:.qt.Unit[
    ".adapter.makerDelta";
    {[c]
        p:c[`params];

        .qt.M[`.adapter.makerSide;p[`MmakerSide];c];
        .qt.M[`.adapter.MakeActionEvent;p[`MMakeActionEvent];c];
        
        a:p[`args];
        res:.adapter.makerSide[a[0];a[1];a[2];a[3];a[4]];

        .qt.A[res;~;p[`eRes];"result";c];

    };
    {[p]:`args`MMmakerSide`MMakeActionEvent`eDI`eRes!(p[0];p[1];p[2];p[3];p[4])};
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
    "derives the set of events that ameliarate the delta between the current and target dist"];


test:.qt.Unit[
    ".adapter.createFlattenEvents";
    {[c]
        p:c[`params];

        .qt.M[`.state.getOpenPositionAmtBySide;p[`MgetOpenPositionAmtBySide];c];
        .qt.M[`.adapter.createMarketOrderEvent;p[`McreateMarketOrderEvent];c];
        
        a:p[`args];
        res:.adapter.createFlattenEvents[a[0];a[1];a[2];a[3];a[4]];

        .qt.A[res;~;p[`eRes];"result";c];

    };
    {[p]:`args`MgetOpenPositionAmtBySide`MMakeActionEvent`eRes!(p[0];p[1];p[2];p[3])};
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
    "creates the set of events that serve to flatten the inventory for the account"];


test:.qt.Unit[
    ".adapter.createOrderEventsFromDist";
    {[c]
        p:c[`params];

        .qt.M[`.state.getOpenPositionAmtBySide;p[`MgetOpenPositionAmtBySide];c];
        .qt.M[`.adapter.createMarketOrderEvent;p[`McreateMarketOrderEvent];c];
        
        a:p[`args];
        / res:.adapter.createFlattenEvents[a[0];a[1];a[2];a[3];a[4]];

        / .qt.A[res;~;p[`eRes];"result";c];

    };
    {[p]:`args`MgetOpenPositionAmtBySide`MMakeActionEvent`eRes!(p[0];p[1];p[2];p[3])};
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
    "Creates the set of order events that conforms to provided dist"];

test:.qt.Unit[
    ".adapter.createOrderEventsFromDist";
    {[c]
        p:c[`params];

        .qt.M[`.state.getOpenPositionAmtBySide;p[`MgetOpenPositionAmtBySide];c];
        .qt.M[`.adapter.createMarketOrderEvent;p[`McreateMarketOrderEvent];c];
        
        a:p[`args];
        / res:.adapter.createFlattenEvents[a[0];a[1];a[2];a[3];a[4]];

        / .qt.A[res;~;p[`eRes];"result";c];

    };
    {[p]:`args`MgetOpenPositionAmtBySide`MMakeActionEvent`eRes!(p[0];p[1];p[2];p[3])};
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
    "Creates the set of market order events that conforms to provided dist"];


test:.qt.Unit[
    ".adapter.createNaiveStopEvents";
    {[c]
        p:c[`params];

        .qt.M[`.state.getOpenPositionAmtBySide;p[`MgetOpenPositionAmtBySide];c];
        .qt.M[`.adapter.createMarketOrderEvent;p[`McreateMarketOrderEvent];c];
        
        a:p[`args];
        / res:.adapter.createFlattenEvents[a[0];a[1];a[2];a[3];a[4]];

        / .qt.A[res;~;p[`eRes];"result";c];

    };
    {[p]:`args`MgetOpenPositionAmtBySide`MMakeActionEvent`eRes!(p[0];p[1];p[2];p[3])};
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
    "Creates the set of stop market orders that serve to stop loss at a given loss fraction"];


// TODO testing Adapter FN;



test:.qt.Unit[
    ".adapter.Adapt[`DISCRETE]";
    {[c]
        p:c[`params];

        .qt.M[`.state.getOpenPositionAmtBySide;p[`MgetOpenPositionAmtBySide];c];
        .qt.M[`.adapter.createMarketOrderEvent;p[`McreateMarketOrderEvent];c];
        
        a:p[`args];
        / res:.adapter.createFlattenEvents[a[0];a[1];a[2];a[3];a[4]];

        / .qt.A[res;~;p[`eRes];"result";c];

    };
    {[p]:`args`MgetOpenPositionAmtBySide`MMakeActionEvent`eRes!(p[0];p[1];p[2];p[3])};
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
    "Creates the set of stop market orders that serve to stop loss at a given loss fraction"];




test:.qt.Unit[
    ".adapter.Adapt[`MARKETMAKER]";
    {[c]
        p:c[`params];

        .qt.M[`.state.getOpenPositionAmtBySide;p[`MgetOpenPositionAmtBySide];c];
        .qt.M[`.adapter.createMarketOrderEvent;p[`McreateMarketOrderEvent];c];
        
        a:p[`args];
        / res:.adapter.createFlattenEvents[a[0];a[1];a[2];a[3];a[4]];

        / .qt.A[res;~;p[`eRes];"result";c];

    };
    {[p]:`args`MgetOpenPositionAmtBySide`MMakeActionEvent`eRes!(p[0];p[1];p[2];p[3])};
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
    "Creates the set of stop market orders that serve to stop loss at a given loss fraction"];




.qt.RunTests[];