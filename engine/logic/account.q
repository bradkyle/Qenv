

.order.Fill :{[i;a;f]
				iv:?[`inventory;enlist();0b;()];
				iv[`ordQty]-:0;
				iv[`ordVal]:0;
				iv[`ordLoss]:0;
				iv[`amt]:0;
				iv[`posQty]:0;
				iv[totalEntry]+:qty;

				// Calc
				iv[`execCost]+: .engine.logic.contract.ExecCost[
						i[`cntTyp];
						price;
						dlt]; 

				/ Calculates the average price of entry for 
				/ the current postion, used in calculating 
				/ realized and unrealized pnl.
				iv[`avgPrice]: .engine.logic.contract.AvgPrice[
						i[`cntTyp];
						iv[`isig];
						iv[`execCost];
						iv[`totalEntry]];

				/ If the fill reduces the position, calculate the 
				/ resultant pnl 
				iv[`rpnl]+:.engine.logic.contract.RealizedPnl[
						i[`cntTyp];
						dlt;
						price;
						iv[`isig];
						iv[`avgPrice];
						i[`faceValue]];
    		if[abs[iv[`posQty]]=0;iv[`avgPrice`execCost`totalEntry]:0];

				/ If the position is changed, calculate the resultant
				/ unrealized pnl
				iv[`upnl]:.engine.logic.contract.UnrealizedPnl[ // TODO
						i[`cntTyp]; 
						iv[`posQty];
						iv[`isig];
						iv[`avgPrice];
						i[`markPrice];
						i[`faceValue]];

				iv[`posVal]:0;
				a[`mmr]:0;
				a[`imr]:0;
				a[`feeTier]:0;

				account,:();
				inventory,:();


				};


.account.Withdraw:{[i;a;w]
				a:?[`account;enlist();0b;()];
				if[a[`bal]<=0;[0;"Order account has no balance"]];
				if[a[`available]<=0;[0;"Order account has insufficient available balance"]];
				if[a[`state]=1;[0;"Account has been disabled"]];
				if[a[`state]=2;[0;"Account has been locked for liquidation"]];
				a[`widdraw]+:withdrawn;
				a[`imr]:0;
				a[`mmr]:0;

				// pos order margin
				a[`avail]:()
				.account.account,:a;
				// TODO add events
				};

.account.Deposit:{[i;a;d]
				a:?[`account;enlist();0b;()];
				if[a[`state]=1;[0;"Account has been disabled"]];
				a[`deposited]+:deposited;
				a[`imr]:0;
				a[`mmr]:0;

				// pos order margin
				a[`avail]:()
				.account.account,:a;
				//TODO add events	

				};

.account.Leverage:{[i;a;l]
				a:?[`account;enlist();0b;()];
				if[a[`bal]<=0;[0;"Order account has no balance"]];
				if[a[`available]<=0;[0;"Order account has insufficient available balance"]];
				if[a[`state]=1;[0;"Account has been disabled"]];
				if[a[`state]=2;[0;"Account has been locked for liquidation"]];
				a[`leverage]:leverage;
				a[`imr]:0;
				a[`mmr]:0;

				// pos order margin
				a[`avail]:()
				.account.account,:a;
				// TODO add events
				};











