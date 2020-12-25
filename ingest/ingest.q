\p 5000 
// TODO make parameterizeable
// ingest/testdata/events/
path: getenv[`DATA_PATH];
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

.ingest.state:((!) . flip(
	(`ordinalStart; .ingest.start);
	(`ordinalEnd; .ingest.end);
	(`ordinalNum; .ingest.ordinalNum);
	(`ordinalLength; .ingest.ordinalLength)));

.ingest.e:();
show "depth: ", string count depth;
show "trade: ", string count trades;
show "settlement: ", string count settlement;
show "pricerange: ", string count pricerange;
show "mark: ", string count mark;
show "funding: ", string count funding;

.ingest.prep: {update datum:{[kind;datum;time]$[
    kind=`pricerange;`highest`lowest!datum;
    kind=`depth;`side`price`size!datum;
    kind=`mark;enlist[`mkprice]!datum;
    kind=`trade;`side`price`size!datum;
    kind=`funding;enlist[`fundingrate]!datum;
    kind=`settlement;enlist[`lastsettled]!time;
    datum]}'[kind;datum;time] from x
    };

.ingest.GetBatch			:{[i]
	tbls:`depth`trades`settlement`pricerange`mark`funding;
	/ chr:.ingest.ordinals[i];
  .ingest.prep xasc[`time;raze{?[y;enlist(=;`hr;x);0b;`time`kind`datum!`time`kind`datum]}[i]'[tbls]]
	};

if[not system"t";system"t 30"];
.z.ts:{.Q.gc[]}
