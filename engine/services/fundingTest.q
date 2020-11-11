.qt.Unit[
    ".engine.services.funding.ProcessFundingEvents";
    {[c]
        .qt.RunUnit[c;.engine.services.funding.ProcessFundingEvents];
    };.qt.generalParams;
    (
        ("No inventory, no funding occurs hedged";(
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
        ));
        ("No inventory, no funding occurs combined";(
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
        ));
        ("Positive Funding occurs hedged long position";(
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
        ));
        ("Negative Funding occurs hedged long position";(
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
        ));
        ("Positive Funding occurs hedged short position";(
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
        ));
        ("Negative Funding occurs hedged short position";());
        ("Negative Funding occurs with split hedged short(0.50)/long(0.50) position";());
        ("Positive Funding occurs with split hedged long(0.50)/short(0.50) position";());
        ("Negative Funding occurs with split hedged short(0.75)/long(0.25) position";());
        ("Negative Funding occurs with split hedged long(0.25)/short(0.75) position";());
        ("Positive Funding occurs with split hedged short(0.75)/long(0.25) position";());
        ("Positive Funding occurs with split hedged long(0.25)/short(0.75) position";());
        ("Negative Funding occurs combined short position";());
        ("Positive Funding occurs combined short position";());
        ("Negative Funding occurs combined long position";());
        ("Positive Funding occurs combined long position";())
    );
    .util.testutils.defaultContractHooks;
    "Process a set of funding events"];
