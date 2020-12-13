
/ .engine.model.common.Public  :([]
 			 
/   );

/ .engine.model.commmon.Private :([]
				  
/ 	);

.engine.model.common.Get     :{[tbl;cnd]
	?[tbl;cnd;0b;()] 
	};

.engine.model.common.Update  :{[tbl;val]
	tbl upsert val;		  
	};

.engine.model.common.Delete  :{[tbl;cnd]
	![tbl;cnd;0b;`symbol$()]				  
	};

.engine.model.common.Create  :{[]
				  
	};

.model.Failure :{}
.model.Account :{}
.model.Inventory :{}
.model.Deposit :{}
.model.Withdraw :{}
.model.Funding : {}
.model.Mark:{}
.model.Settlement:{}
.model.PriceLimit :{}
.model.Level:{}
.model.Trade:{}
.model.Order:{}
.model.Instrument:{}
.model.Fill:{}
