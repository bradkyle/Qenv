
// TODO commenting

// Order Conditionals
// -------------------------------------------------------------->

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.util.cond.isActiveAccLimit:{:(
                (=;`side;x);
                (=;`otype;1);
                (in;`status;(0 1));
                (in;`price;y); 
                (in;`accountId;z); 
                (>;`leaves;0))}; // TODO improve performance


// Determines if 
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.util.cond.isActiveAccLimitB:{:(
                (=;`otype;1); // is Limit order
                (in;`status;(0 1)); // is New or partially filled
                (in;`accountId;z); // 
                (in;`price;y); 
                (>;`leaves;0))}; // TODO improve performance


// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.util.cond.isActiveLimit:{:(
                (=;`side;x);
                (=;`otype;1);
                (in;`status;(0 1));
                (in;`price;y); 
                (>;`leaves;0))}; // TODO improve performance

// Efficiently collects the set of orders that conform to the given 
// conditionals, used to get all active orders on both sides of the 
// orderbook.
/  @param x (List(Long)) list of prices to which the order must conform
.util.cond.isActiveLimitB:{:(
                (=;`otype;1);
                (in;`status;(0 1));  // is New or partially filled
                (in;`price;x);  // is in price levels
                (>;`leaves;0))}; // TODO improve performance

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.util.cond.isActiveStop:{:((>;`size;0);
               (in;`status;enlist[`NEW`PARTIALFILLED]);
               (in;`price;x); // TODO CONDITIONAL
               (in;`side;y); // TODO CONDITIONAL
               (in;`otype;enlist[`STOP_MARKET`STOP_LIMIT]))};


// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.util.cond.isActiveAccountOrder:{:((>;`size;0);
               (in;`status;enlist[`NEW`PARTIALFILLED]);
               (in;`price;x); // TODO CONDITIONAL
               (in;`side;y); // TODO CONDITIONAL
               (in;`otype;enlist[`STOP_MARKET`STOP_LIMIT]))};


// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.util.cond.AccountHasId:{:((>;`size;0);
               (in;`status;enlist[`NEW`PARTIALFILLED]);
               (in;`price;x); // TODO CONDITIONAL
               (in;`side;y); // TODO CONDITIONAL
               (in;`otype;enlist[`STOP_MARKET`STOP_LIMIT]))};


// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.util.cond.EnginePruneOrd:{:((>;`size;0);
               (in;`status;enlist[`NEW`PARTIALFILLED]);
               (in;`price;x); // TODO CONDITIONAL
               (in;`side;y); // TODO CONDITIONAL
               (in;`otype;enlist[`STOP_MARKET`STOP_LIMIT]))};


// Account Conditionals
// -------------------------------------------------------------->

// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.util.cond.hasOpenPosition:{:((>;`netLongPosition;0);
                   (>;`netShortPosition;0); // TODO CONDITIONAL
                   (>;`openBuyQty;0); // TODO CONDITIONAL
                   (>;`openSellQty;0))};


// Inc Fill is used when the fill is to be added to the given inventory
// inc fill would AdjustOrderMargin if the order when the order was a limit
// order.
/  @param price     (Long) The price at which the fill is occuring
/  @param qty       (Long) The quantity that is being filled.
/  @param account   (Account) The account to which the inventory belongs.
/  @param inventory (Inventory) The inventory that is going to be added to.
/  @return (Inventory) The new updated inventory
.util.cond.isInsolvent:{:((<;`available;`maintMarginReq))};


// OrderBook Conditionals
// -------------------------------------------------------------->

// 
/  @param price     :
/  @return (Inventory) The new updated inventory
.util.cond.bookUpdBounds:{:((>;`qty;0);(>=;`vqty;0))}; // TODO update this 


// TODO update this 
/  @param price     :
/  @return (Inventory) The new updated inventory
.util.cond.bookPrune:{:((<=;`vqty;0);
                   (<=;`hqty;0))}; // COnd based upon max bid price, max ask price