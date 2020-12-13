
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

.model.Model:{[tb;cl;vl]
    cvl:count[vl]; 
    $[cvl>1;[rx:(cvl#enlist[tb]);rx[cl]:flip[vl];:flip rx];[r[cl]:first[vl];:tb]]
    };
