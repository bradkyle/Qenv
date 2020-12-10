// list all local dirs
// get all dirs older than x
// system mv all dirs into gcsfuse dir

.upl.check:{[]
			dfs:system"ls ",path;
			time:7h$(`hh$.z.z);
			dfs:dfs where dfs<(time-24); 
			{system"mv ",y," ",x}[outpath]'[dfs];
			};

.z.ts:{}
