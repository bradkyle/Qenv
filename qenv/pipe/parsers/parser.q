\d .parser

persist:    {[events; dest]
    events:`utc_day xgroup update utc_day:`date$time from events;
    {[dest;events]
        path:`$("/" sv (dest;string[first events[`utc_day]];"events/")); 
        events:flip[enlist[`utc_day] _ events];
        path upsert .Q.en[`:db;] events;
    }[dest] each 0!events;
    };

Parse   :{[table;dest;parsefn;split]
    ct:count table;
    idx:1_((,) prior ((split*til `long$floor[ct%split]), ct));
    {[p;t;d;s;i] 
        show s;
        z:i[1]+s;
        show z;
        persist[p[.Q.ind[t;z]]; d]
    }[parsefn;table;dest;til[split]] peach idx;
    };

/ .parser.Parse[trade;":./data/bitmex";.bitmex.tradeParser;10000];