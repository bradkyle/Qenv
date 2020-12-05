\p 5000

.env.s:(84 84 1);

.env.robs :{.env.s#(sum[.env.s]?255f)}

.env.Step :{[actions]
				show actions; 
				:(.env.robs[], rand 1f, 0b, ())				  
				};

.env.Reset:{[]
				show "reset";
				:.env.robs[]				  
				};
