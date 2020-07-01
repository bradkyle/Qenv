


// Processing Logic
// --------------------------------------------------->

forceOrderCancellations :{[]

};

liquidateAccount   :{[account]

};

liquidatePosition   :{[position]

};

CheckByMarkPrice    :{[markPrice;time]
    liquidateAccount each select from .schema.Account where liquidationPrice=markPrice;
    liquidatePosition each select from .schema.Inventory where liquidationPrice=markPrice;
};


