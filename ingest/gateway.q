
// Load config and try to make connections to 
// slave processes.
// ------------------------------------------------>
servers :(
	[serverId: `long$()]
	serverHost:`symbol$();
	serverPort: `long$();
	ordinalStart:`long$();
	ordinalEnd:`long$());

configure :{[]
	confpath: getenv[`CONFIGPATH];
	conf:.j.k raze read0 (`$confpath); 
	lf:`serverId`serverPort`ordinalStart`ordinalEnd;
	conf[lf]:7h$conf[lf];
	conf[`serverHost]:`$conf[`serverHost];
	servers,:conf;
	};

register :{[]

	};

// Allow for queries to be made via gateway
// ------------------------------------------------>

h!:()
.z.pg:{:"SEND MESSAGE ASYNCH!"};

queries:([qid:`u#`int$()]
		query:();
		client_handle:`int$();
		client_callback_function:();
		time_received:`time$();
		time_returned:`time$();
		slave_handle:`int$();
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


.z.ps:{[x]
	$[not(w:neg .z.w)in key h;
	/request
	[
	/x@0 - request
	/x@1 - callback_function
	new_qid:1^1+exec last qid from queries; /assign id to new query
	`queries upsert (new_qid;first x;(neg .z.w);last x;.z.T;0Nt;0N;`master);
	/check for a free slave.If one exists,send oldest query to that slave
	check[];
	];
	/response
	[
	/x@0 - query id
	/x@1 - result
	qid:first x;
	result:last x;
	/try to send result back to client
	.[send_result;
		(qid;result);
		{[qid;error]queries[qid;`location`time_returned]:(`client_failure;.z.T)}[qid]
	 ];
	/drop the first query id from the slave list in dict h
	h[w]:1_h[w];
	/send oldest unsent query to slave
	send_query[w];
	]];	
 };


/Change location of queries outstanding on the dead servant to master
.z.pc:{
	update location:`master from `queries where qid in h@neg x; /reassign lost queries to master process (for subsequent re-assignment)
	h::h _ (neg x); /remove dead servant handle from h
	check[];
	/if client handle went down, remove outstanding queries
	delete from `queries where location=`master,client_handle=neg x;
 };
