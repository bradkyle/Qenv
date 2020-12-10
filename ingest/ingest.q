\p 5000 
show system "pwd";
\l /home/ingest/testdata/events/ev
\l /home/ingest/testdata/events

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
.ingest.GetBatch: {};
