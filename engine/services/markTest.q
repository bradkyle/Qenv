// GetInMarketAccounts, Liquidate, UpdateAccounts, AddAccountEvent, AddMarkEvent


.qt.Unit[
    ".engine.services.mark.ProcessMarkUpdateEvents";
    {[c]
        .qt.RunUnit[c;.engine.services.mark.ProcessMarkUpdateEvents];
    };.qt.generalParams;
    (
        enlist("Process Mark Price Update one account";(
        (
          (`.engine.model.instrument.GetInstrumentByIds;{[x] 0!(count[x]#.engine.model.instrument.test.Instrument)};1b;1;enlist[1]);
          (`.engine.model.inventory.GetInMarketInventory;{[x] 0!(count[x]#.engine.model.inventory.test.Inventory)};1b;1;enlist[1]);
          (`.engine.model.account.GetAccountsById;{[x] 0!(count[x]#.engine.model.account.test.Account)};1b;1;enlist[1]);
          (`.engine.model.instrument.ValidInstrumentIds;{[x] count[x]#1b};1b;1;enlist[1]);
          (`.engine.model.account.ValidAccountIds;{[x] count[x]#1b};1b;1;enlist[1]);
          (`.engine.logic.fill.DeriveRiskTier;{[x;y] first .engine.model.instrument.test.riskTiers};1b;1;enlist[1]); // TDSO simplify
          (`.engine.model.orderbook.GetLevelsByPrice;{[x] 0!.engine.model.orderbook.test.OrderBook };1b;1;enlist[enlist 100]);
          (`.engine.model.instrument.UpdateInstruments;{[x] };1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
          (`.engine.logic.liquidation.Liquidate;{[x] };1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
          (`.engine.model.account.UpdateAccounts;{[x] 0!(count[x]#.engine.model.account.test.Account)};1b;1;enlist[1])
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ))
        /* ("Mark price increases combined long";()); */
        /* ("Mark price increases combined short";()); */
        /* ("Mark price increases hedged long";()); */
        /* ("Mark price increases hedged short";()); */
        /* ("Mark price increases hedged 75 long/ 25 short";()); */
        /* ("Mark price increases hedged 25 short/ 75 short";()); */
        /* ("Mark price decreases combined long";()); */
        /* ("Mark price decreases combined short";()); */
        /* ("Mark price decreases hedged long";()); */
        /* ("Mark price decreases hedged short";()); */
        /* ("Mark price decreases hedged 75 long/ 25 short";()); */
        /* ("Mark price decreases hedged 25 short/ 75 short";()); */
        /* ("Mark price decreases: multiple accounts";()); */
        /* ("Mark price decreases: multiple accounts";()); */
        /* ("Mark price decreases: multiple accounts";()); */
        /* ("Mark price decreases: multiple accounts";()); */
        /* ("Mark price decreases: multiple accounts";()); */
        /* ("Mark price decreases: multiple accounts";()); */
        /* ("Mark price increases multiple accounts";()); */
        /* ("Mark price increases multiple accounts";()); */
        /* ("Mark price increases multiple accounts";()); */
        /* ("Mark price increases multiple accounts";()); */
        /* ("Mark price increases multiple accounts";()); */
        /* ("Mark price increases multiple accounts";()) */
    );
    .util.testutils.defaultContractHooks;
    "Process a set of mark price update events"];
