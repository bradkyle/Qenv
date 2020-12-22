
// lng long postition
// srt short position
// wit:witdrawn
// dep:deposited
// rt: RiskTier
// ft: FeeTier
.engine.model.account.Account:([aId:`long$()] 
  iId:`.engine.model.instrument.Instrument$();
  lng:`.engine.model.inventory.Inventory$();srt:`.engine.model.inventory.Inventory$();
  rt:`.engine.model.risktier.Risktier$();ft:`.engine.model.feetier.Feetier$();
  froz:`long$();vol:`long$();dep:`long$();wit:`long$();mrgTyp:`long$();avail:`long$();
  done:`boolean$();bal:`long$();time:`datetime$());
.engine.model.account.r:.util.NullRowDict[`.engine.model.account.Account];

.engine.model.account.Create:.engine.model.common.Create[`.engine.model.account.Account];
.engine.model.account.Get:.engine.model.common.Get[`.engine.model.account.Account];
.engine.model.account.Update:.engine.model.common.Update[`.engine.model.account.Account];

.model.Account:{[cl;vl]
    //if[null cl;cl:key .fill.r]; // TODO check
    x:.model.Model[.engine.model.account.r;cl;vl];
    x[`iId]:`.engine.model.instrument.Instrument$x[`iId];
    x[`lng]:`.engine.model.inventory.Inventory$x[`lng]; 
    x[`srt]:`.engine.model.inventory.Inventory$x[`srt]; 
    / x[`rt]:`.engine.model.risktier.Risktier$x[`rt]; 
    / x[`ft]:`.engine.model.feetier.Feetier$x[`ft];  
    x
    };

.engine.model.withdraw.r:.util.NullRowDict[([] 
        time:`datetime$(); 
        aId:`.engine.model.account.Account$(); 
        iId:`.engine.model.instrument.Instrument$(); 
        wit:`long$())];

.model.Withdraw:{[cl;vl]
    //if[null cl;cl:key .fill.r]; // TODO check
    x:.model.Model[.engine.model.withdraw.r;cl;vl];
    x[`aId]:`.engine.model.account.Account$x[`aId]; 
    x[`iId]:`.engine.model.instrument.Instrument$x[`iId];
    x
    };

.engine.model.deposit.r:.util.NullRowDict[([] 
        time:`datetime$(); 
        aId:`.engine.model.account.Account$(); 
        iId:`.engine.model.instrument.Instrument$(); 
        dep:`long$())];

.model.Deposit:{[cl;vl]
    //if[null cl;cl:key .fill.r]; // TODO check
    x:.model.Model[.engine.model.deposit.r;cl;vl];
    x[`aId]:`.engine.model.account.Account$x[`aId]; 
    x[`iId]:`.engine.model.instrument.Instrument$x[`iId];
    x
    };

.engine.model.leverage.r:.util.NullRowDict[([] 
        time:`datetime$(); 
        aId:`.engine.model.account.Account$(); 
        iId:`.engine.model.instrument.Instrument$(); 
        lev:`long$())];

.model.Leverage:{[cl;vl]
    //if[null cl;cl:key .fill.r]; // TODO check
    x:.model.Model[.engine.model.leverage.r;cl;vl];
    x[`aId]:`.engine.model.account.Account$x[`aId];
    / x[`ivId]:`.engine.model.inventory.Inventory$x[`ivId]; 
    x[`iId]:`.engine.model.instrument.Instrument$x[`iId];
    x
    };


