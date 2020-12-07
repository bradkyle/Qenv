
.engine.model.common.Public  :([]
  
  );

.engine.model.commmon.Private :([]
				  
	);

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
