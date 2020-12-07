

.qt.Unit[
    ".engine.logic.fill.InitMarginReq";
    {[c]
        p:c[`params];

        res:.engine.logic.fill.InitMarginReq[];
        .qt.A[res;~;p[`eRes];"avgPrice";c];
    };
    {[p]
    
    };
    (
        ("Minimum tier position size init margin req";((0 0 0 0 0 0);0));
        ("Maximum tier position size init margin req";((0 0 0 0 0 0);0));
        ("Minimum tier effective leverage init margin req";((0 0 0 0 0 0);0));
        ("Maximum tier effective leverage init margin req";((0 0 0 0 0 0);0))
    );
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];

.qt.Unit[
    ".engine.logic.fill.MaintMarginReq";
    {[c]
        p:c[`params];

        res:.engine.logic.fill.MaintMarginReq[];
        .qt.A[res;~;p[`eRes];"avgPrice";c];
    };
    {[p]
    
    };
    (
        ("Minimum tier position size maint margin req";((0 0 0 0 0 0);0));
        ("Maximum tier position size maint margin req";((0 0 0 0 0 0);0));
        ("Minimum tier effective leverage maint margin req";((0 0 0 0 0 0);0));
        ("Maximum tier effective leverage maint margin req";((0 0 0 0 0 0);0))
    );
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];

.qt.Unit[
    ".engine.logic.fill.MaintMargin";
    {[c]
        p:c[`params];

        res:.engine.logic.fill.MaintMargin[];
        .qt.A[res;~;p[`eRes];"avgPrice";c];
    };
    {[p]
    
    };
    ();
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];


.qt.Unit[
    ".engine.logic.fill.InitMargin";
    {[c]
        p:c[`params];

        res:.engine.logic.fill.InitMargin[];
        .qt.A[res;~;p[`eRes];"avgPrice";c];
    };
    {[p]
    
    };
    ();
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];
// TODO add different contract types?
// TODO add upnl?
// TODO change params
.qt.Unit[
    ".engine.logic.fill.incFill";
    {[c]
        .qt.RunUnit[c;.engine.logic.fill.incFill];
    };.qt.generalParams;
    (
				("hedged:long_to_longer";(
        (
          (`.engine.logic.contract.AvgPrice;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
					(`.engine.logic.contract.ExecCost;{[x] 100};1b;1;enlist[1])
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ));
				("hedged:short_to_shorter";(
        (
          (`.engine.logic.contract.AvgPrice;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
					(`.engine.logic.contract.ExecCost;{[x] 100};1b;1;enlist[1])
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ));
				("combined:long_to_longer";(
        (
          (`.engine.logic.contract.AvgPrice;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
					(`.engine.logic.contract.ExecCost;{[x] 100};1b;1;enlist[1])
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ));
				("combined:short_to_shorter";(
        (
          (`.engine.logic.contract.AvgPrice;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
					(`.engine.logic.contract.ExecCost;{[x] 100};1b;1;enlist[1])
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ))
    );
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];


.qt.Unit[
    ".engine.logic.fill.redFill";
    {[c]
        .qt.RunUnit[c;.engine.logic.fill.redFill];
    };.qt.generalParams;
    (
        ("hedged:longer_to_long";(
        (
          enlist(`.engine.logic.contract.RealizedPnl;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)) 
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ));
        ("hedged:shorter_to_short";(
        (
          enlist(`.engine.logic.contract.RealizedPnl;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)) 
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ));
        ("hedged:longer_to_long rpl + 0.25";(
        (
          enlist(`.engine.logic.contract.RealizedPnl;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)) 
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ));
        ("hedged:shorter_to_short rpl + 0.25";(
        (
          enlist(`.engine.logic.contract.RealizedPnl;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)) 
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ));
        ("hedged:longer_to_long rpl - 0.25";(
        (
          enlist(`.engine.logic.contract.RealizedPnl;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)) 
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ));
        ("hedged:shorter_to_short rpl - 0.25";(
        (
          enlist(`.engine.logic.contract.RealizedPnl;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)) 
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ));
        ("combined:longer_to_long";(
        (
          enlist(`.engine.logic.contract.RealizedPnl;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)) 
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ));
        ("combined:shorter_to_short";(
        (
          enlist(`.engine.logic.contract.RealizedPnl;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)) 
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ));
        ("combined:longer_to_long rpl + 0.25";(
        (
          enlist(`.engine.logic.contract.RealizedPnl;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)) 
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ));
        ("combined:shorter_to_short rpl + 0.25";(
        (
          enlist(`.engine.logic.contract.RealizedPnl;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)) 
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ));
        ("combined:longer_to_long rpl - 0.25";(
        (
          enlist(`.engine.logic.contract.RealizedPnl;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)) 
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ));
        ("combined:shorter_to_short rpl - 0.25";(
        (
          enlist(`.engine.logic.contract.RealizedPnl;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)) 
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ))
    );
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];


.qt.Unit[
    ".engine.logic.fill.crsFill";
    {[c]
        .qt.RunUnit[c;.engine.logic.fill.crsFill];
    };.qt.generalParams;
    (
        ("combined:longer_to_short";(
        (
          (`.engine.logic.contract.AvgPrice;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
          (`.engine.logic.contract.ExecCost;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
					(`.engine.logic.contract.RealizedPnl;{[x] 100};1b;1;enlist[1])
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ));
        ("combined:shorter_to_long";(
        (
          (`.engine.logic.contract.AvgPrice;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
          (`.engine.logic.contract.ExecCost;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
					(`.engine.logic.contract.RealizedPnl;{[x] 100};1b;1;enlist[1])
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ));
        ("combined:shorter_to_longer";(
        (
          (`.engine.logic.contract.AvgPrice;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
          (`.engine.logic.contract.ExecCost;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
					(`.engine.logic.contract.RealizedPnl;{[x] 100};1b;1;enlist[1])
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ));
        ("combined:longer_to_shorter";(
        (
          (`.engine.logic.contract.AvgPrice;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
          (`.engine.logic.contract.ExecCost;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
					(`.engine.logic.contract.RealizedPnl;{[x] 100};1b;1;enlist[1])
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ));
        ("combined:longer_to_short rpl + 0.25";(
        (
          (`.engine.logic.contract.AvgPrice;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
          (`.engine.logic.contract.ExecCost;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
					(`.engine.logic.contract.RealizedPnl;{[x] 100};1b;1;enlist[1])
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ));
        ("combined:shorter_to_long rpl + 0.25";(
        (
          (`.engine.logic.contract.AvgPrice;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
          (`.engine.logic.contract.ExecCost;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
					(`.engine.logic.contract.RealizedPnl;{[x] 100};1b;1;enlist[1])
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ));
        ("combined:longer_to_short rpl - 0.25";(
        (
          (`.engine.logic.contract.AvgPrice;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
          (`.engine.logic.contract.ExecCost;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
					(`.engine.logic.contract.RealizedPnl;{[x] 100};1b;1;enlist[1])
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ));
        ("combined:shorter_to_long rpl - 0.25";(
        (
          (`.engine.logic.contract.AvgPrice;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
          (`.engine.logic.contract.ExecCost;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
					(`.engine.logic.contract.RealizedPnl;{[x] 100};1b;1;enlist[1])
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ));
        ("combined:longer_to_shorter rpl + 0.25";(
        (
          (`.engine.logic.contract.AvgPrice;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
          (`.engine.logic.contract.ExecCost;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
					(`.engine.logic.contract.RealizedPnl;{[x] 100};1b;1;enlist[1])
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ));
        ("combined:shorter_to_longer rpl + 0.25";(
        (
          (`.engine.logic.contract.AvgPrice;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
          (`.engine.logic.contract.ExecCost;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
					(`.engine.logic.contract.RealizedPnl;{[x] 100};1b;1;enlist[1])
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ));
        ("combined:longer_to_shorter rpl - 0.25";(
        (
          (`.engine.logic.contract.AvgPrice;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
          (`.engine.logic.contract.ExecCost;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
					(`.engine.logic.contract.RealizedPnl;{[x] 100};1b;1;enlist[1])
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ));
        ("combined:shorter_to_longer rpl - 0.25";(
        (
          (`.engine.logic.contract.AvgPrice;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
          (`.engine.logic.contract.ExecCost;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
					(`.engine.logic.contract.RealizedPnl;{[x] 100};1b;1;enlist[1])
          );    
          `eid`time`cmd`kind`datum!(0;z;0;8;`instrument`fundingRate`nextFundingTime!(0;0.1;z));
          ();()
        ))
        // TODO integration
    );
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];




.qt.Unit[
    ".engine.logic.fill.ApplyFills";
    {[c]
        .qt.RunUnit[c;.engine.logic.fill.ApplyFills];
    };.qt.generalParams;
    (
        ("hedged:long_to_longer";(
            ( // Mocks
            (`.engine.model.account.UpdateAccount;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)); 
            (`.engine.model.inventory.UpdateInventory;{[x] 100};1b;1;enlist enlist `price`side`qty`hqty`iqty`vqty!(0;0;0;0;0;1)) 
            );
            `eid`time`cmd`kind`datum!(0;z;0;8;
            `instrument`account`side`price`size`reduce`time!(0;0;1;100;100;0b;z));
            (); // Eres
            () // Err
        ));
        ("hedged:longer_to_long";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("hedged:long_to_flat";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("hedged:longer_to_flat";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("hedged:short_to_shorter";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("hedged:shorter_to_short";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("hedged:shorter_to_flat";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:long_to_longer";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:longer_to_long";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:long_to_flat";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:longer_to_short";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:long_to_shorter";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:short_to_shorter";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:shorter_to_short";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:short_to_long";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:short_to_longer";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:short_to_flat_rpl_-50";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("hedged:long_to_flat_rpl_50";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("hedged:short_to_flat_rpl_50";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("hedged:long_to_flat_rpl_-50";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:long_to_flat_rpl_50";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:long_to_flat_rpl_-50";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:long_to_short_rpl_-50";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:long_to_short_rpl_50";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:short_to_flat_rpl_50";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:short_to_long_rpl_50";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:short_to_long_rpl_-50";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:short_to_flat_rpl_-50";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:long_to_flat_rpl_50";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:long_to_flat_rpl_-50";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:short_to_flat_rpl_50";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ));
        ("combined:short_to_flat_rpl_-50";(
            ( // Mocks
            );
            (); // Fill
            (); // Eres
            () // Err
        ))
    );
    .util.testutils.defaultContractHooks;
    "Function for deriving the exec cost from the qty and the price"];
