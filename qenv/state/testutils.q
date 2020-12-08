.util.testutils.defaultStateHooks               :({};{};{};{});

// Make Test Data Utils
// -------------------------------------------------------------->

// TODO make default Events

// The following function takes a reference to a table,
// and a set of columns (cl) and values (vl).
// It generates a null row, if the value count is greater
// than 1 it repeats the row x times and fills the respective
// columns provided by cl with the respective values provided
// by vl
/  @param ref (Symbol) The symbol reference to the table
/  @param cl (List[Symbol]) The list of symbols indicating columns
/  @param vl (List[List[Any]]) The list of lists to populate with. 
.util.testutils.makeDefaultsRecords  :{[ref;cl;vl] // TODO inter with actual cols
    r:.util.NullRowDict[ref];
    cvl:count[vl]; 
    :$[cvl>1;[rx:(cvl#enlist[r]);rx[cl]:flip[vl];:rx];[r[cl]:first[vl];:r]]};



// Random State Generation
// -------------------------------------------------------------->

// TODO make defaults to events
.util.testutils.setUniformState      :{
    .state.CurrentAccount,:.util.testutils.makeDefaultsRecords[
        `.state.CurrentAccount;
        `accountId`time`balance`available;
        {(x;.tu.z;10;10)}'[til 5]];
    .state.CurrentInventory,:.util.testutils.makeDefaultsRecords[
        `.state.CurrentInventory;
        `accountId`side`amt`realizedPnl`avgPrice`unrealizedPnl;
        {((x mod 5);(x mod 3);0;0;0;0)}'[til 15]];
    .state.CurrentOrders,:.util.testutils.makeDefaultsRecords[
         `.state.CurrentOrders;
         `orderId`accountId`side`otype`price`leaves`status`reduce;
        {(x;(x mod 5);$[(x<250);-1;1];1;floor[1000-(x%10)];100;0;(1h$first[1?(1 0)]))}'[til 500]];
    .state.CurrentDepth,:.util.testutils.makeDefaultsRecords[
         `.state.CurrentDepth;
         `price`time`side`size;
        {(floor[1000-(x%2)];.tu.z;$[(x<50);-1;1];100)}'[til 100]];
    .state.TradeEventHistory,:.util.testutils.makeDefaultsRecords[
         `.state.TradeEventHistory;
         `tid`time`size`price`side;
        {(x;(.tu.snz rand 10000);100;floor[1000-(rand 50)];$[(x<5000);-1;1])}'[til 10000]];
    .state.MarkEventHistory,:.util.testutils.makeDefaultsRecords[
         `.state.MarkEventHistory;
         `time`markprice;
        {(snz rand 10000;floor[1000-(x%2)])}'[til 1000]];
    .state.FundingEventHistory,:.util.testutils.makeDefaultsRecords[
         `.state.FundingEventHistory;
         `time`fundingrate`fundingtime;
        {((snz rand 10000);first[1?0.001 0.002 0.003];(snz rand 1000))}'[til 50]];
    .state.LiquidationEventHistory,:.util.testutils.makeDefaultsRecords[
         `.state.LiquidationEventHistory;
         `liqid`time`size`price`side;
        {(x;(snz rand 1000);first[1?100 200 300];floor[1000-(rand 50)];$[(x<250);-1;1])}'[til 500]];
    .state.SignalEventHistory,:.util.testutils.makeDefaultsRecords[
         `.state.SignalEventHistory;
         `sigid`time`sigvalue;
        {(rand 50;(snz rand 5000);rand 1f)}'[til 5000]];
    };


.util.testutils.genRandomStateH      :{
    .util.testutils.makeDefaultsRecords[`.state.AccountEventHistory;cl;vl]
    };