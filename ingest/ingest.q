\p 5000 
// TODO make parameterizeable
// ingest/testdata/events/
master: `$getenv[`MASTER];
path: getenv[`DATAPATH];
system["l ",path,"/ev"];
system["l ",path];

hrs:system["ls ",path];
hrs:raze{@["I"$;x;show]}'[hrs];
hrs:hrs where not null hrs;

.ingest.ordinals:distinct hrs;
.ingest.ordinalStart: min hrs;
.ingest.ordinalEnd: max hrs;
.ingest.ordinalNum: count distinct hrs;
.ingest.ordinalLength:.ingest.ordinalEnd-.ingest.ordinalStart;

.ingest.state:((!) . flip(
	(`ordinalStart; .ingest.ordinalStart);
	(`ordinalEnd; .ingest.ordinalEnd);
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


.ingest.GetBatch			:{[hdl;i]
	tbls:`depth`trades`settlement`pricerange`mark`funding;
	chr:.ingest.ordinals[i];
	e:`time xasc raze{?[y;enlist(=;`hr;x);0b;`time`kind`datum!`time`kind`datum]}[chr]'[tbls];
	/ hdl();
	show count e;
	.Q.gc[];
	};

