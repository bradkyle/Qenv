\p 5000 
// TODO make parameterizeable
\l /ingest/testdata/events/ev
\l /ingest/testdata/events

hrs:system"ls /ingest/testdata/events"
/ @[]

.ingest.ordinalStart: min hrs;
.ingest.ordinalEnd: max hrs;
.ingest.numOrdinals: count distinct hrs;
.ingest.ordinalLength:.ingest.ordinalEnd-.ingest.ordinalStart;
if[.ingest.numOrdinals<>.ingest.ordinalLength;show "Missing ordinals"];

// TODO register with gateway

.ingest.e:();
show "depth: ", string count depth;
show "trade: ", string count trades;
show "settlement: ", string count settlement;
show "pricerange: ", string count pricerange;
show "mark: ", string count mark;
show "funding: ", string count funding;

.ingest.Ingest:{
	.ingest.e:select from depth;
	.ingest.e,:select from trades;
	.ingest.e,:select from settlement;
	.ingest.e,:select from pricerange;
	.ingest.e,:select from mark;
	.ingest.e,:select from funding;
	.ingest.e: select time, kind, datum from .ingest.e;
	.ingest.e:`time xasc .ingest.e;
	};

.ingest.Ingest[];
.ingest.Reset: 		{:.ingest.e};

.ingest.GetBatch: {[hdl;i]
	tbls:`depth`trade`settlement`pricerange`mark`funding;
	.ingest.
	e:`time xasc raze{?[x;enlist(=;`hr;x);0b;`time`kind`datum!`time`kind`datum]}[chr]'[tbls];
	/ hdl();
	show count e;
	.Q.gc[];
	};

.ingest
