\p 5000 
\l /home/ingest/data/okextest/events/ev
\l /home/ingest/data/okextest/events

.ingest.e:();

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
