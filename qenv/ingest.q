hour:{`int$sum 24 1*@[;0;-;1970.01.01] `date`hh$x};

// TODO better connection handling

.ingest.h:hopen`:gate:5000
.ingest.watermark:0n;
.ingest.Reset 	 :{.ingest.h"reset[]"}; // TODO change watermark
.ingest.GetFirst :{.ingest.h"getfirst[]"};
.ingest.GetLast  :{.ingest.h"getlast[]"};
.ingest.Advance  :{hr:hour x;$[(hr>(.ingest.watermark-1));
																[
																e:.ingest.h"request[",string[hr+1],"]";
																.ingest.watermark:hour[max e`time];
																];()]};
