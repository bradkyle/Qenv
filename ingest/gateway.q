\p 5000
// Load config and try to make connections to 
// slave processes.
// ------------------------------------------------>
slave:(
	[sId: `long$()]
	host:`symbol$();
	port: `long$();
	start:`long$();
	end:`long$());

confpath: getenv[`CONFIGPATH];
conf:.j.k raze read0 (`$confpath); 
lf:`sId`port`start`end;
conf[lf]:7h$conf[lf];
conf[`host]:`$conf[`host];
slave,:conf;

// Allow for queries to be made via gateway
// ------------------------------------------------>
.z.pg:{:"SEND MESSAGE ASYNCH!"};

queries:([qid:`u#`int$()]
		query:();
		client_handle:`int$();
		client_callback_function:();
		time_received:`time$();
		time_returned:`time$();
		slave_handle:`int$();
		slave:`symbol$();
		location:`symbol$()
		);

send_query:{[hdl]
	qid:exec first qid from queries where location=`master;
	/if there is an outstanding query to be sent, try to send it
	if[not null qid;
	query:queries[qid;`query];
	h[hdl],:qid;
	queries[qid;`slave_handle]:hdl;
	queries[qid;`location]:`slave;
	hdl({[qid;query](neg .z.w)(qid;@[value;query;`error])};qid;query)
	];
 };

send_result:{[qid;result]
	query:queries[qid;`query];
	client_handle:queries[qid;`client_handle];
	client_callback_function:queries[qid;`client_callback_function];
	client_handle(client_callback_function;qid;query;result);
	/break[];
	queries[qid;`location`time_returned]:(`client;.z.T);
	 }; 

mkurl:{[host;port] `$sv[":";("";string[host];string[port])]}
gethost:{first value raze (select first mkurl'[host;port] from slave where x within(start;end))}

request :{
	slv:gethost[7h$x[1]];
	new_qid:1^1+exec last qid from queries; /assign id to new query
	req:".ingest.GetBatch[",string[new_qid],";",string[x[1]],"]";
	`queries upsert (new_qid;req;(neg .z.w);x[2];.z.T;0Nt;0N;slv;`master);
	h:neg[hopen slv];
	h req;
	};

response :{
		qid:x[0];
		result:x[1];
		//try to send result back to client
		.[send_result;
			(qid;result);
			{[qid;error]queries[qid;`location`time_returned]:(`client_failure;.z.T)}[qid]
		 ];
		/ h[w]:1_h[w];
		/drop the first query id from the slave list in dict h
		/send oldest unsent query to slave
		/ send_query[w];
	};

.z.ps:{[x]
	dst:x[0];	
	$[dst=`req;request[x];
		dst=`res;response[x[1]];
		'INVALID_DEST];
 };


/Change location of queries outstanding on the dead servant to master
.z.pc:{
	update location:`master from `queries where qid in h@neg x; /reassign lost queries to master process (for subsequent re-assignment)
	h::h _ (neg x); /remove dead servant handle from h
	check[];
	/if client handle went down, remove outstanding queries
	delete from `queries where location=`master,client_handle=neg x;
 };
