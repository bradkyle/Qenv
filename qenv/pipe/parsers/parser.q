\d .parser

// TODO documentation and annotation

persist:    {[events; dest]
    events:`utc_day xgroup update utc_day:`date$time from events;
    {[dest;events]
        path:`$("/" sv (dest;string[first events[`utc_day]];"events/")); 
        events:flip[enlist[`utc_day] _ events];
        show meta events;
        show first events;
        path upsert .Q.en[`:/home/kx/qenv/lcl/ev;] events;
        show path;
    }[dest] each 0!events;
    };

Parse   :{[table;dest;parsefn;split]
    ct:count table;
    idx:1_((,) prior ((split*til `long$floor[ct%split]), ct));
    {[p;t;d;s;i] 
        z:i[1]+s;
        persist[p[.Q.ind[t;z]]; d]
    }[parsefn;table;dest;til[split]] peach idx;
    };

/ .parser.Parse[trade;":./data/bitmex";.bitmex.tradeParser;10000];