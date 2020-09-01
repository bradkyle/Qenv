

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
.util.cond.isActiveLimit:{:(
                (=;`side;x);
                (=;`otype;1);
                (in;`status;(0 1));
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
.util.cond.isActiveLimitB:{:(
                (=;`otype;1);
                (in;`status;(0 1));
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
.util.cond.depthBounds:{:((>;`netLongPosition;0);
                   (>;`netShortPosition;0); // TODO CONDITIONAL
                   (>;`openBuyQty;0); // TODO CONDITIONAL
                   (>;`openSellQty;0))};

