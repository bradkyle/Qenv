\p 5000 
\l /home/ingest/data/okextest/events/ev
\l /home/ingest/data/okextest/events

.ingest.e:();
show "depth: ", string count depth;
show "trade: ", string count trades;
show "settlement: ", string count settlement;
show "pricerange: ", string count pricerange;
show "mark: ", string count mark;

.ingest.Ingest:{[frm;to;cache]
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
show count .ingest.e;

.ingest.Reset: {:.ingest.e};
