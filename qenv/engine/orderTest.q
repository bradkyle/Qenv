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
    :([price:`int$(num?prices); orderId:`int$(oidstart+til num)]
        accountId       : `int$(num#1);
        side            : num?(`.order.ORDERSIDE$`BUY;`.order.ORDERSIDE$`SELL);
        otype           : num#`.order.ORDERTYPE$`LIMIT;
        offset          : `int$(num?til 10000);
        timeinforce     : num#`.order.TIMEINFORCE$`NIL;
        size            : `int$(num?til 10000); / multiply by 100
        leaves          : `int$(num?til 10000);
        filled          : `int$(num?til 10000);
        limitprice      : `int$(num?til 10000); / multiply by 100
        stopprice       : `int$(num?til 10000); / multiply by 100
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
     .instrument.NewInstrument[enlist[`instrumentId]!enlist[1];1b;.z.z];
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
    ((10#`SELL);`int$(1000+til 10);`int$(10#1000));
    ([price:(`int$(1000+til 10))] side:(10#`.order.ORDERSIDE$`SELL);qty:(10#1000i));
    ();()
    )]];

.qt.AddCase[test;"simple update no agent orders or previous depth both";deriveCaseParams[(
    ();();
    (((10#`SELL),(10#`BUY));`int$((1000+til 10),(999-til 10));`int$(20#1000));
    ([price:(`int$((1000+til 10),(999-til 10)))] side:(`.order.ORDERSIDE$((10#`SELL),(10#`BUY)));qty:(20#1000i));
    ();()
    )]];

.qt.AddCase[test;"simple update no agent orders or previous depth both (crossing)";deriveCaseParams[(
    ();();
    ((10#`SELL);`int$(1000+til 10);`int$(10#1000));
    ([price:(`int$(1000+til 10))] side:(10#`.order.ORDERSIDE$`SELL);qty:(10#1000i));
    ();()
    )]];

.qt.AddCase[test;"simple update no agent orders or previous depth both; Multi temporal";deriveCaseParams[(
    ();();
    ((10#`SELL);`int$(raze flip 2#{(1000+x;1000+x)}til 5);`int$(10#1000 100);(10#z,(z+`second$5)));
    ([price:(`int$(1000+til 5))] side:(5#`.order.ORDERSIDE$`SELL);qty:(5#100i));
    ();()
    )]];

/ .qt.AddCase[test;"1 order at 1 level, previous depth";deriveCaseParams[(
/     ();();
/     ((10#`SELL);`int$(raze flip 2#{(1000+x;1000+x)}til 5);`int$(10#1000);(10#z,(z+`second$5)));
/     ([price:(`int$(1000+til 5))] side:(5#`.order.ORDERSIDE$`SELL);qty:(5#1000i));
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

test:.qt.Unit[
    ".order.NewOrder";
    {[c]
        p:c[`params]; 
        if[count[p[`cOB]]>0;.order.ProcessDepthUpdate[p[`cOB]]];
  
        o:p[`order];
        res:.order.NewOrder[o;.z.z];
        show res;
        // Assertions
        show .order.Order;
        .qt.A[.order.Order@(o[`price];o[`orderId]);~;p[`eOrd];"order";c];

    };();({};{};defaultBeforeEach;defaultAfterEach);
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

/ `.state.OrderEventHistory upsert (
/     []orderId:til 10;
/     accountId:10#1;
/     side:(5#`SELL),(5#`BUY);
/     price:(1000+til 5),(999-til 5);
/     otype:10#`LIMIT;
/     leaves:10#1000;
/     filled:10#1000;
/     limitprice:10#0;
/     stopprice:10#0;
/     status:10#`NEW;
/     time:10#.z.z;
/     isClose:10#0b;
/     trigger:10#`NIL);


.qt.AddCase[test;"New simple ask limit order no previous depth or orders should update";
    deriveCaseParams[(
    ((10#`SELL);`int$(1000+til 10);`int$(10#1000));();
    `accountId`instrumentId`side`otype`price!(1;1;`SELL;`LIMIT;1000);
    ([price:(`int$(1000+til 10))] side:(10#`.order.ORDERSIDE$`SELL);qty:(10#1000i));
    ();
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

/ test:.qt.Unit[
/     ".order.fillTrade";
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

/ .qt.AddCase[test;"orderbook does not have agent orders, trade was not made by an agent";
/     deriveCaseParams[]];

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

/ .qt.AddCase[test;"Should update markprice for instrument, account inventory etc.";
/     deriveCaseParams[]];

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