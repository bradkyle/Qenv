


.qt.Unit[
    ".engine.services.settlement.ParseSettlementEvents";
    {[c]
        p:c[`params];


    };();();({};{};{};{});
    "Global function for creating a new account"];

.qt.Unit[
    ".engine.services.settlement.ProcessSettlementEvents";
    {[c]
        .qt.RunUnit[c;.engine.services.funding.ProcessFundingEvents];
    };.qt.generalParams;
    (
        enlist("Settlement occurs";(
        (
          (`.engine.model.instrument.GetInstrumentByIds;{[x] 0!(count[x]#.engine.model.instrument.test.Instrument)};1b;1;enlist[1]);
          (`.engine.model.account.GetAllUnsettled;{[x] 0!(count[x]#.engine.model.instrument.test.Instrument)};1b;1;enlist[1]);
          (`.engine.model.inventory.GetInventoryOfAccounts;{[x] 0!(count[x]#.engine.model.instrument.test.Instrument)};1b;1;enlist[1]);
          (`.engine.model.instrument.ValidInstrumentIds;{[x] count[x]#1b};1b;1;enlist[1]);
          (`.engine.logic.fill.DeriveRiskTier;{[x;y] first .engine.model.instrument.test.riskTiers};1b;1;enlist[1]); // TDSO simplify
          (`.engine.model.instrument.UpdateInstruments;{[x] };1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
          (`.engine.model.account.UpdateAccounts;{[x] 0!(count[x]#.engine.model.account.test.Account)};1b;1;enlist[1]);
          (`.engine.model.inventory.UpdateInventory;{[x] 0!(count[x]#.engine.model.account.test.Account)};1b;1;enlist[1])
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ))
    );
    .util.testutils.defaultContractHooks;
    "Process a set of mark price update events"];

