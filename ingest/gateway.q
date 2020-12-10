\p 5000
confpath: getenv[`CONFIGPATH];
show system"ls";
show system"pwd";
show configpath;
// Load config and try to make connections to 
// slave processes.
// ------------------------------------------------>
slave:(
	[sId: `long$()]
	host:`symbol$();
	port: `long$();
	start:`long$();
	end:`long$());

conf:.j.k raze read0 (`$confpath); 
lf:`sId`port`start`end;
conf[lf]:7h$conf[lf];
conf[`host]:`$conf[`host];
slave,:conf;

mkurl:{[host;port] `$sv[":";("";string[host];string[port])]}
gethost:{first value raze (select first mkurl'[host;port] from slave where x within(start;end))}

request :{
	slv:gethost[7h$x];
	req:".ingest.GetBatch[",string[x],"]";
	h:hopen slv;
	h req
	};

