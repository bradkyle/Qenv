
.util.batch.sanitize     :{[events]
    if[type[events]=0h; events:raze[events]]; // TODO convert to table
    if[(type[events]=99h) and (count[first events]=1);events:enlist events];
    if[type[events]=99h;events:flip events];
    events
    };

// takes a batch of events with their respective time and 
// makes fails
// then invokes the given callback resfn
// TODO add err msg to datum
.util.batch.PurgeFails           :{[resfn;events;errkind;errmsg] 
    $[count[events]>0;[
        events:.util.batch.sanitize[events];
        if[not all[`eid`kind`time`datum in cols[events]];'INVALID_EVENT_SCHEMA];
        events[`datum]:flip events[`kind`datum];
        events[`kind]:16;
        events[`cmd]:0;
        resfn[events];
        ];'EMPTY_BATCH]
    };
  
// Removes events that conform to a provided conditional
// if it fails, it removes the event and inserts it as a failure in the return
// /egress buffer/pipe.
// todo ensure cond is boolean
.util.batch.Purge               :{[resfn;events;cond;errkind;errmsg]
    /* if[(count[cond]<=1) and (type[cond] in (1 -1h));cond:enlist cond]; */
    /* .test.cond:cond; */
    /* .test.events:events; */
    $[(count[events]>0) and (count[where[cond]]>0);[
        events:.util.batch.sanitize[events];
        ok: events where[not[cond]];
        if[count[where cond]>0;.util.batch.PurgeFails[resfn;events where cond;errkind;errmsg]];
        $[count[ok]>0;ok;'NONE_OK]
        ];events]
    };


// Attempts to apply a given function to an events batch and returns
// all errorts/failures to the resfn callback
// TODO incorperate failure cause into purge
.util.batch.TPurge              :{[resfn;events;fn;errkind;errmsg]  
    $[count[events]>0;[
        events:.util.batch.sanitize[events];
        res:{@[{(1b;x[y])}[x];y;{(0b;y;x)}[y]]}[fn]'[events];
        fails:res[;2] where[not[res[;0]]];
        if[count[fails]>0;.util.batch.PurgeFails[resfn;fails;errkind;errmsg]];
        res[;1] where[res[;0]]
      ];events]
    };

// The parse function attempts to parse the given set of datums 
// and will subsequently purge the events that do not conform to the schema
// in addition it will also infill the defualt values as provided by the schema
// schema is a reference to a table that contains the defaults to be overwritten
.util.batch.Parse     :{[resfn;events;schema;errkind;errmsg]
    $[count[events]>0;[
            .util.batch.TPurge[resfn;events;{[x;y]x,:y;x}[schema];errkind;errmsg]
    ];events]
    };

// Branches the given events based upon the given conditions 
// events that meet the conditions are fed to the afn and the 
// rest are returned to the bfn (if specified) else are returned
// as a variable
// returns a tuple of res and events
.util.batch.Branch              :{[resfn;events;fn;cond;errkind;errmsg]  
    $[count[events]>0;[
        if[(count[cond]=1) and (type[cond]=0h);cond:raze cond];
        if[count[cond]=1;cond:enlist cond];
        events:.util.batch.sanitize[events];
        res:(();());
        if[count[where cond]>0;res[0]:.util.batch.TPurge[resfn;events where cond;fn;errkind;errmsg]];
        if[count[where not cond]>0;res[1]:events where not cond];
        res
        ];events]
    };

// Generates a boolean vector equal to num (the number of events)
// that is derived as the probability of the selection being 0 
// in the vector space 
.util.batch.genDropouts :{[probs;num]
    if[probs>1;'INVALID_DROPOUT_PROBABILITY];
    (num?(7h$(1%probs))=0)
    };

// Wherever the given condition is not met the function attempts to
// set the given type to the defaults
.util.batch.RowDropout      :{[resfn;events;probs;errkind;errmsg]  
    $[count[events]>0;[
        events:.util.batch.sanitize[events];
        dropout:.util.batch.genDropouts[probs;count first[events]];
        .util.batch.PurgeFails[resfn;events where dropout;errkind;errmsg];
        events where not[dropout]
        ];events]
    };

// Wherever the given condition is not met the function attempts to
// set the given type to the defaults
// probs k should be a table with cols `kind`probs
.util.batch.RowDropoutK     :{[resfn;events;probsk;errkind;errmsg]  
    if[any[cols[k]<>`kind`probs];'INVALID_PROBSK];
    if[any[probsk[`probs]>1];'INVALID_DROPOUT];
    events:.util.batch.sanitize[events];
    events:update dropout:rand'[7h$(1%probs)]=0 from ej[enlist[`kind];raze events;probsk];
    .util.batch.PurgeFails[resfn;?[events;enlist(`dropout);0b;.common.event.DCOLS];errkind;errmsg];
    ?[events;enlist(not;`dropout);0b;.common.event.DCOLS]
    };

// Branches the given events based upon the given conditions 
// events that meet the conditions are fed to the afn and the 
// rest are returned to the bfn (if specified) else are returned
// as a variable
.util.batch.TimeOffset          :{[events;t]  
    if[any[type[t]<>15h];'INVALID_DELAY];
    events:.util.batch.sanitize[events];
    events[`time]+:t;
    events
    };

// Sets the default values provided where the given column/row 
// meets the condition providedfunctionName
.util.batch.TimeOffsetK         :{[events;tk]  
    if[any[cols[k]<>`kind`delay];'INVALID_TK];
    if[any[type[tk[`delay]]<>15h];'INVALID_DELAY];
    events:.util.batch.sanitize[events];
    :enlist[`delay] _ (update time:time+delay from ej[enlist[`kind];raze events;tk]);
    };


// Branches the given events based upon the given conditions 
// events that meet the conditions are fed to the afn and the 
// rest are returned to the bfn (if specified) else are returned
// as a variable
// mu and sigma should both be of type timespan
// TODO check that mu and sigma are both of time kind
.util.batch.GausTimeOffset          :{[events;mu;sigma]  
    if[any[(mu>1)];'INVALID_MU];
    if[any[(sigma>1)];'INVALID_SIGMA];
    events:.util.batch.sanitize[events];
    update time:time+.util.np.randomTimespan[mu;sigma] from events
    };

// Sets the default values provided where the given column/row 
// meets the condition providedfunctionName
// TODO check that mu and sigma are both of type timespan
.util.batch.GausTimeOffsetK         :{[events;normk]  
    if[any[cols[k]<>`kind`mu`sigma];'INVALID_NORMK];
    if[any[rnorm[`mu]>1];'INVALID_MU];
    if[any[rnorm[`sigma]>1];'INVALID_SIGMA];
    events:.util.batch.sanitize[events];
    update time:time+.util.np.randomTimespan[mu;sigma] from ej[enlist[`kind];events;normk]
    };

