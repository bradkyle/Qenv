\p 5000 
// TODO make parameterizeable
// ingest/testdata/events/
master: `$getenv[`MASTER];
host: getenv[`HOSTNAME];
path: getenv[`DATAPATH];
system["l ",path,"/ev"];
system["l ",path];

hrs:system["ls ",path];
hrs:raze{@["I"$;x;show]}'[hrs];
hrs:hrs where not null hrs;

.ingest.ordinals:distinct hrs;
.ingest.start: min hrs;
.ingest.end: max hrs;
.ingest.ordinalNum: count distinct hrs;
.ingest.ordinalLength:.ingest.end-.ingest.start;

// TODO try until done
.ingest.h:neg hopen `:gate:5000;
/ .ingest.h(`register;(host;5000;.ingest.start;.ingest.end));

.ingest.state:((!) . flip(
	(`ordinalStart; .ingest.start);
	(`ordinalEnd; .ingest.end);
	(`ordinalNum; .ingest.ordinalNum);
	(`ordinalLength; .ingest.ordinalLength)));
show .ingest.state;

.ingest.e:();
show "depth: ", string count depth;
show "trade: ", string count trades;
show "settlement: ", string count settlement;
show "pricerange: ", string count pricerange;
show "mark: ", string count mark;
show "funding: ", string count funding;


.ingest.GetBatch			:{[qid;i]
	tbls:`depth`trades`settlement`pricerange`mark`funding;
	/ chr:.ingest.ordinals[i];
	e:`time xasc raze{?[y;enlist(=;`hr;x);0b;`time`kind`datum!`time`kind`datum]}[i]'[tbls];
	.ingest.h(qid;e);
	show count e;
	.Q.gc[];

	};

