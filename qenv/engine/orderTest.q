\l account.q
\l instrument.q
\l event.q
\l order.q
system "d .orderTest";
\l util.q
\cd ../quantest/
\l quantest.q 
\cd ../engine/

z:.z.z;


// Test order generation
// -------------------------------------------------------------->

/ nxt:update qty:qty+(first 1?til 100) from select qty:last (datum[;0][;2]) by price:datum[;0][;1] from d where[(d[`datum][;0][;0])=`BUY]
/ nxt:exec qty by price from update qty:rand qty from select qty:last (datum[;0][;2]) by price:datum[;0][;1] from d where[(d[`datum][;0][;0])=`BUY]
/ .account.NewAccount[`accountId`other!1 2;.z.z]
testOrders:{[num;oidstart;params]
    // params is a dictionary of values that are sanitized below
    :([price:`long$(num?prices); orderId:`long$(oidstart+til num)]
        accountId       : `long$(num#1);
        side            : num?(`.order.ORDERSIDE$`BUY;`.order.ORDERSIDE$`SELL);
        otype           : num#`.order.ORDERTYPE$`LIMIT;
        offset          : `long$(num?til 10000);
        timeinforce     : num#`.order.TIMEINFORCE$`NIL;
        size            : `long$(num?til 10000); / multiply by 100
        leaves          : `long$(num?til 10000);
        filled          : `long$(num?til 10000);
        limitprice      : `long$(num?til 10000); / multiply by 100
        stopprice       : `long$(num?til 10000); / multiply by 100
        status          : num#`.order.ORDERSTATUS$`NEW;
        time            : num#.z.z;
        isClose         : `boolean$(num?(1 0));
        trigger         : num#`.order.STOPTRIGGER$`NIL;
        execInst        : num#`.order.EXECINST$`NIL)
    };

// Before and after defaults
// -------------------------------------------------------------->

defaultAfterEach: {
     delete from `.account.Account;
     delete from `.account.Inventory;
     delete from `.event.Events;
     delete from `.order.Order;
     delete from `.order.OrderBook;
     .account.accountCount:0;
     .order.orderCount:0;
     .qt.RestoreMocks[];
    };

defaultBeforeEach: {
     delete from `.account.Account;
     delete from `.account.Inventory;
     delete from `.event.Events;
     delete from `.order.Order;
     delete from `.order.OrderBook;
     .account.NewAccount[`accountId`other!1 2;.z.z];
     .account.NewAccount[`accountId`other!2 2;.z.z];
    };


// Process Depth Update
// -------------------------------------------------------------->

test:.qt.Unit[
    ".order.ProcessDepthUpdate";
    {[c]
        p:c[`params];
        / show p[`event];

        .order.ProcessDepthUpdate[p[`event]];
        // Assertions
        .qt.A[.order.OrderBook;~;p[`eOB];"orderbook";c];
        / .qt.A[{x!y[x]}[cols einv;invn];~;einv;"inventory";c];

    };();({};{};defaultBeforeEach;defaultAfterEach);
    "Given a side update which consists of a table of price, time,",
    "size update the orderbook and the individual order offsets"];

deriveCaseParams    :{[params]
    e:();
    if [count[params[2]]>0;[
        d:params[2];
        if[count[d]<4;d,:enlist(count[first[d]]#.z.z)];
        // Side, Price, Size
        d:{:`time`intime`kind`cmd`datum!(x[3];x[3];`DEPTH;`UPDATE;
        ((`.order.ORDERSIDE$x[0]);x[1];x[2]))} each flip[d];
        e:flip[d];
        ]];
    
    / eOB:params[3];
    / eOB:update price:`int$price, 

    p:`cOB`cOrd`event`eOB`eOrd`eEvents!(
        params[0];
        params[1];
        e;
        params[3];
        params[4];
        params[5]
        );
    :p;
    };

// TODO test removes OB level when zero
// 

// Add time to allow for multiple simultaneous updates.
//TODO make into array and addCases
.qt.AddCase[test;"simple update no agent orders or previous depth one side";deriveCaseParams[(
    ();();
    ((10#`SELL);1000+til 10;10#1000);
    ([price:(1000+til 10)] side:(10#`.order.ORDERSIDE$`SELL);qty:(10#1000));
    ();()
    )]];

.qt.AddCase[test;"simple update no agent orders or previous depth both";deriveCaseParams[(
    ();();
    (((10#`SELL),(10#`BUY));((1000+til 10),(999-til 10));20#1000);
    ([price:(((1000+til 10),(999-til 10)))] side:(`.order.ORDERSIDE$((10#`SELL),(10#`BUY)));qty:(20#1000));
    ();()
    )]];

.qt.AddCase[test;"simple update no agent orders or previous depth both (crossing)";deriveCaseParams[(
    ();();
    ((10#`SELL);1000+til 10;10#1000);
    ([price:(1000+til 10)] side:(10#`.order.ORDERSIDE$`SELL);qty:(10#1000));
    ();()
    )]];

.qt.AddCase[test;"simple update no agent orders or previous depth both; Multi temporal";deriveCaseParams[(
    ();();
    ((10#`SELL);(raze flip 2#{(1000+x;1000+x)}til 5);10#1000 100;(10#z,(z+`second$5)));
    ([price:(1000+til 5)] side:(5#`.order.ORDERSIDE$`SELL);qty:(5#100));
    ();()
    )]];

/ .qt.AddCase[test;"1 order at 1 level, previous depth";deriveCaseParams[(
/     ();();
/     ((10#`SELL);(raze flip 2#{(1000+x;1000+x)}til 5);10#1000;(10#z,(z+`second$5)));
/     ([price:((1000+til 5))] side:(5#`.order.ORDERSIDE$`SELL);qty:(5#1000));
/     ();()
/     )]];

/ .qt.AddCase[test;"single agent ask decreasing (delta less than offset) (single update)";deriveCaseParams[(
/     (); // currentOB
/     genTestOrders[]; // current Orders
/     `price`qty!(`s#993150 993250i;2689711 2689711i);
/     `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
/     ()
/     )]];

/ .qt.AddCase[test;"1 order at 1 level (single update)";deriveCaseParams[(
/     ();
/     genTestOrders[];
/     `SELL;
/     `price`qty!(`s#993150 993250i;2689711 2689711i);
/     `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
/     ()
/     )]];

/ .qt.AddCase[test;"3 orders at 1 level (single update)";deriveCaseParams[(
/     ();
/     genTestOrders[];
/     `SELL;
/     `price`qty!(`s#993150 993250i;2689711 2689711i);
/     `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
/     ()
/     )]];

/ .qt.AddCase[test;"1 order at 3 different levels and differing offsets (single update)";deriveCaseParams[(
/     ();
/     genTestOrders[];
/     `SELL;
/     `price`qty!(`s#993150 993250i;2689711 2689711i);
/     `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
/     ()
/     )]];

/ .qt.AddCase[test;"3 orders of different quantities at 3 different levels and differing offsets (single update)";deriveCaseParams[(
/     ();
/     genTestOrders[];
/     `SELL;
/     `price`qty!(`s#993150 993250i;2689711 2689711i);
/     `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
/     ()
/     )]];

/ .qt.AddCase[test;"mixed orders of different quantities at 3 different levels and differing offsets (single update)";deriveCaseParams[(
/     ();
/     genTestOrders[];
/     `SELL;
/     `price`qty!(`s#993150 993250i;2689711 2689711i);
/     `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
/     ()
/     )]];

/ .qt.AddCase[test;"mixed orders of different quantities at 3 different levels and differing offsets: There are no non agent orders left (single update)";
/     deriveCaseParams[(
/     ();
/     genTestOrders[];
/     `SELL;
/     `price`qty!(`s#993150 993250i;2689711 2689711i);
/     `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
/     ()
/     )]];


/ .qt.AddCase[test;"depth update overlaps with current depth of opposing side (single update)";
/     deriveCaseParams[(
/     ();
/     genTestOrders[];
/     `SELL;
/     `price`qty!(`s#993150 993250i;2689711 2689711i);
/     `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
/     ()
/     )]];


/ .qt.AddCase[test;"depth update does not conform to tick size (single update)";
/     deriveCaseParams[(
/     ();
/     genTestOrders[];
/     `SELL;
/     `price`qty!(`s#993150 993250i;2689711 2689711i);
/     `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
/     ()
/     )]];

/ .qt.AddCase[test;"depth update does not conform to lot size (single update)";
/     deriveCaseParams[(
/     ();
/     genTestOrders[];
/     `SELL;
/     `price`qty!(`s#993150 993250i;2689711 2689711i);
/     `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
/     ()
/     )]];


/ .qt.AddCase[test;"agent offsets are zero and update is less than agent order size (single update)";
/     deriveCaseParams[(
/     ();
/     genTestOrders[];
/     `SELL;
/     `price`qty!(`s#993150 993250i;2689711 2689711i);
/     `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
/     ()
/     )]];


/ .qt.AddCase[test;"depth update contains depth for which the next value is zero (single update)";
/     deriveCaseParams[(
/     ();
/     genTestOrders[];
/     `SELL;
/     `price`qty!(`s#993150 993250i;2689711 2689711i);
/     `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
/     ()
/     )]];

/ .qt.AddCase[test;"check that best ask, best bid, is liquid variables are updated (single update)";
/     deriveCaseParams[(
/     ();
/     genTestOrders[];
/     `SELL;
/     `price`qty!(`s#993150 993250i;2689711 2689711i);
/     `price`qty`side!(`s#993150 993250i;2689711 2689711i;`.order.ORDERSIDE$`SELL`SELL);
/     ()
/     )]];


// New Order Tests
// -------------------------------------------------------------->

oBeforeAll :{
    .instrument.NewInstrument[
        `instrumentId`tickSize`maxPrice`minPrice`maxOrderSize`minOrderSize`priceMultiplier!
        (1;0.5;1e5f;0f;1e7f;0f;1);
        1b;.z.z];
    };

oAfterAll :{
    delete from `.instrument.Instrument;
    };

BING:();

test:.qt.Unit[
    ".order.NewOrder";
    {[c]
        p:c[`params]; 
        if[count[p[`cOB]]>0;.order.ProcessDepthUpdate[p[`cOB]]];
  

        // instantiate mock for processCross
        mck: .qt.M[`.order.processCross;p[`mFn];c];

        o:p[`order];
        / show .instrument.Instrument;
        res:.order.NewOrder[o;.z.z];

        // Assertions
        k:key p[`eOrd]; 
        o1:first (0!select from .order.Order where orderId=1);
        .qt.A[o1[k];~;p[`eOrd][k];"order";c];

    };();(oBeforeAll;oAfterAll;defaultBeforeEach;defaultAfterEach);
    "Global function for processing new orders"];

deriveCaseParams    :{[params]
    ob:();
    if [count[params[0]]>0;[
        d:params[0];
        if[count[d]<4;d,:enlist(count[first[d]]#.z.z)];
        // Side, Price, Size
        d:{:`time`intime`kind`cmd`datum!(x[3];x[3];`DEPTH;`UPDATE;
        ((`.order.ORDERSIDE$x[0]);x[1];x[2]))} each flip[d];
        ob:flip[d];
        ]];
    
    p:`cOB`cOrd`order`eOB`eOrd`eEvents!(
        ob;
        params[1];
        params[2];
        params[3];
        params[4];
        params[5]
        );
    :p;
    };

.qt.AddCase[test;"New limit order no previous depth or orders should update";
    deriveCaseParams[(
    ((10#`SELL);1000+til 10;10#1000);();
    `accountId`instrumentId`side`otype`price`size!(1;1;`SELL;`LIMIT;1000;1000);
    ([price:(1000+til 10)] side:(10#`.order.ORDERSIDE$`SELL);qty:(10#1000));
    (`price`offset!(1000;1000));
    ()
    )]];

.qt.AddCase[test;"New limit order participate don't initiate not triggered, calls processCross";
    deriveCaseParams[(
    ((10#`SELL);1000+til 10;10#1000);();
    `accountId`instrumentId`side`otype`price`size!(1;1;`SELL;`LIMIT;1000;1000);
    ([price:(1000+til 10)] side:(10#`.order.ORDERSIDE$`SELL);qty:(10#1000));
    (`price`offset!(1000;1000));
    ()
    )]];


/ .qt.AddCase[test;"New simple market order";
/     deriveCaseParams[ ]];

/ .qt.AddCase[test;"New simple stop market order";
/     deriveCaseParams[ ]];

/ .qt.AddCase[test;"New simple stop limit order";
/     deriveCaseParams[ ]];

/ .qt.AddCase[test;"Trash fields present";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Invalid Account Id (form)";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Invalid Order side";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Invalid Order type";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Invalid time in force";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Invalid Exec inst";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Invalid price tick size";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"order price>max price";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"order price<min price";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"order size>max order size";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"order price<min order size";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Account id not found";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Duplicate clOrdId";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Duplicate orderId";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Not enough margin to execute order";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Accounts do not match";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Invalid stopPrice for order type";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Invalid order type for exec inst";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Account id not found";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Order placed in book offset = offset at depth price";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Order placed in book offset when no depth orders exist";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Participate dont initiate cross throws error";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Dont participate dont initiate cross calls/places market order";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Order placed in book";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Incorrect time format for event";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Close order larger than inventory";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Close order with no inventory";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"multiple close orders (of STOP_LIMIT, STOP_MARKET, LIMIT), collectively than inventory";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Invalid stop order price for trigger";
/     deriveCaseParams[]];



// Fill Trade tests
// -------------------------------------------------------------->

// TODO better (more consice/shorter test)
test:.qt.Unit[
    ".order.fillTrade";
    {[c]
        p:c[`params];
        if[count[p[`cOB]]>0;.order.ProcessDepthUpdate[p[`cOB]]];

        // instantiate mock for ApplyFill
        mck1: .qt.M[`.account.ApplyFill;{[a;b;c;d;e;f;g;h]};c];
        mck2: .qt.M[`.order.AddTradeEvent;{[a;b]};c];

        t:p[`trade];
        res:.order.fillTrade[t[`iId];t[`side];t[`qty];t[`isClose];t[`isAgent];t[`accountId];t[`time]];
        

        mck:.qt.Mock@mck1;
        .qt.A[mck[`called];=;p[`eApplyFill][`called];c];
        .qt.A[mck[`numCalls];=;p[`eApplyFill][`numCalls];c];
        if[mck[`called]; [
            i:.qt.Invocation@(mck1;1);
            .qt.A[(i[`invokedWith]);~;(p[`eAddTradeEvent][`calledWith]);"numCalls";c];
            ]];

        / show mck[`called];
        mck:.qt.Mock@mck2;

        .qt.A[(mck[`called]);=;(p[`eAddTradeEvent][`called]);"called";c];
        .qt.A[(mck[`numCalls]);=;(p[`eAddTradeEvent][`numCalls]);"numCalls";c];
        if[mck[`called]; [
            i:.qt.Invocation@(mck2;1);
            .qt.A[(i[`invokedWith]);~;(p[`eAddTradeEvent][`calledWith]);"numCalls";c];
            ]];
        
    };();({};{};defaultBeforeEach;defaultAfterEach);
    "process trades from the historical data or agent orders"];

deriveCaseParams    :{[params]
    ob:();
    if [count[params[0]]>0;[
        d:params[0];
        if[count[d]<4;d,:enlist(count[first[d]]#.z.z)];
        // Side, Price, Size
        d:{:`time`intime`kind`cmd`datum!(x[3];x[3];`DEPTH;`UPDATE;
        ((`.order.ORDERSIDE$x[0]);x[1];x[2]))} each flip[d];
        ob:flip[d];
        ]];

    t:`iId`side`qty`isClose`isAgent`accountId`time!params[2];
    t[`side]:`.order.ORDERSIDE$t[`side];

    mCols:`called`numCalls`calledWith;
    
    p:`cOB`cOrd`trade`eOB`eOrd`eAddTradeEvent`eApplyFill!(
        ob;
        params[1];
        t;
        params[3];
        params[4];
        mCols!params[5];
        mCols!params[6]
        );
    :p;
    };

// TODO no liquidity
cTime:.z.z;

.qt.AddCase[test;"orderbook does not have agent orders, trade was not made by an agent";
    deriveCaseParams[(
        ((10#`BUY);1000+til 10;10#1000);();
        (1;`SELL;100;0b;0b;1;cTime);();();(1b;1;((`.order.ORDERSIDE$`SELL;100;1000);cTime));(0b;0;())
    )]];

/ .qt.AddCase[test;"orderbook does not have agent orders, trade was made by an agent, trade is larger than best qty";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"orderbook does not have agent orders, trade was made by an agent, trade is smaller than best qty";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"orderbook does not have agent orders, trade was not made by an agent, trade is larger than best qty";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"orderbook does not have agent orders, trade was not made by an agent, trade is smaller than best qty";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"orderbook has agent orders, trade doesn't fill agent order, trade execution > agent order offset, fill is agent";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"orderbook has agent orders, trade fills agent order, trade execution < agent order offset, fill is agent";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"orderbook has agent orders, trade doesn't fill agent order, trade execution > agent order offset, fill is not agent";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"orderbook has agent orders, trade fills agent order, trade execution < agent order offset, fill is not agent";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"agent order fills another agents order";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"agent fills its own limit order";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"agent order fills another agents order";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"no liquidity";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"should update instrument etc. last price";
/     deriveCaseParams[]];

/ / .qt.AddCase[test;"should update open interest, open value etc.";
/     / deriveCaseParams[]];

/ test:.qt.Unit[
/     ".order.processCross";
/     {[c]
/         p:c[`params];
/         time:.z.z;
/         eacc:p[`eaccount];
/         einv:p[`einventory];
/         ecols:p[`ecols];

/         account:Sanitize[p[`account];.account.defaults[];.account.allCols];        
/         inventory:Sanitize[p[`inventory];.account.defaults[];.account.allCols];

/         // Execute tested function
/         x:p[`params];
/         .account.execFill[account;inventory;x[`fillQty];x[`price];x[`fee]];

/         // 
/         acc:exec from .account.Account where accountId=account[`accountId];
/         invn:exec from .account.Inventory where accountId=inventory[`accountId], side=inventory[`side];

/         // Assertions
/         .qt.A[{x!y[x]}[cols eacc;acc];~;eacc;"account";c];
/         .qt.A[{x!y[x]}[cols einv;invn];~;einv;"inventory";c];

/     };();({};{};defaultBeforeEach;defaultAfterEach);
/     "Global function for processing new orders"];


/ test:.qt.Unit[
/     ".order.ProcessTrade";
/     {[c]
/         p:c[`params];
/         time:.z.z;
/         eacc:p[`eaccount];
/         einv:p[`einventory];
/         ecols:p[`ecols];

/         account:Sanitize[p[`account];.account.defaults[];.account.allCols];        
/         inventory:Sanitize[p[`inventory];.account.defaults[];.account.allCols];

/         // Execute tested function
/         x:p[`params];
/         .account.execFill[account;inventory;x[`fillQty];x[`price];x[`fee]];

/         // 
/         acc:exec from .account.Account where accountId=account[`accountId];
/         invn:exec from .account.Inventory where accountId=inventory[`accountId], side=inventory[`side];

/         // Assertions
/         .qt.A[{x!y[x]}[cols eacc;acc];~;eacc;"account";c];
/         .qt.A[{x!y[x]}[cols einv;invn];~;einv;"inventory";c];

/     };();({};{};defaultBeforeEach;defaultAfterEach);
/     "Global function for processing new orders"];


// Update Mark Price
// -------------------------------------------------------------->

/ test:.qt.Unit[
/     ".order.UpdateMarkPrice";
/     {[c]
/         p:c[`params];
        
/         res: .order.UpdateMarkPrice[p[`markPrice];1;.z.z];

/     };();({};{};defaultBeforeEach;defaultAfterEach);
/     "Global function for processing new orders"];

/ .qt.AddCase[test;"Should update markprice for instrument, account inventory etc.";
/     deriveCaseParams[(
/         ();();96000;
/     )]];

/ .qt.AddCase[test;"Should update the cumulative unrealized pnl, available balance, margin, orders etc.";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Should liquidate relevant inventory/accounts depending on the configuration";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Should trigger triggerable stop limit orders";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Should not trigger non-triggerable stop limit orders";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Should trigger triggerable stop market orders";
/     deriveCaseParams[]];

/ .qt.AddCase[test;"Should not trigger non-triggerable stop market orders";
/     deriveCaseParams[]];

.qt.RunTests[];