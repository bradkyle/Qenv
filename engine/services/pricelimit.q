
// Services
// ------------------------------------------------------->
.engine.services.pricelimit.ProcessNewPriceLimitEvents :{
    if[not[first .engine.model.instrument.ValidInstrumentIds[x[`instrument]]];[0;"instrument does not exist"]];
    i:first .engine.model.instrument.GetInstrumentByIds[x[`instrument]];

    i[`upricelimit]:last[e`upricelimit];
    i[`lpricelimit]:last[e`lpricelimit];

    .engine.model.instrument.UpdateInstruments[i]; // TODO
    // TODO emit price limit events
    };
