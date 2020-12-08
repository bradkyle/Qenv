

.engine.logic.contract.PricePerContract :{[contractType;price;faceValue]
  ($[contractType=0;faceValue%price;
      contractType=1;.engine.logic.contract.linear.ExecCost[price;qty;multiplier];
      contractType=2;.engine.logic.contract.quanto.ExecCost[price;qty;multiplier];
      'nyi] | 0)
    }; 

//  UnrealizedPnl
/ i.UnrealizedPnl[ // TODO 
/         iv[`amt];
/         iv[`isignum];
/         iv[`avgPrice];
/         i[`markPrice];
/         i[`faceValue]];
.engine.logic.contract.ExecCost    :{[contractType;price;qty;multiplier]
    7h$($[contractType=0;.engine.logic.contract.inverse.ExecCost[price;qty;multiplier];
      contractType=1;.engine.logic.contract.linear.ExecCost[price;qty;multiplier];
      contractType=2;.engine.logic.contract.quanto.ExecCost[price;qty;multiplier];
      'nyi] | 0)
    };

//  UnrealizedPnl
/ i.UnrealizedPnl[ // TODO 
/         iv[`amt];
/         iv[`isignum];
/         iv[`avgPrice];
/         i[`markPrice];
/         i[`faceValue]];
.engine.logic.contract.AvgPrice    :{[contractType;isignum;execCost;totalEntry;multiplier]
    7h$($[contractType=0;.engine.logic.contract.inverse.AvgPrice[isignum;execCost;totalEntry;multiplier];
      contractType=1;.engine.logic.contract.linear.AvgPrice[isignum;execCost;totalEntry;multiplier];
      contractType=2;.engine.logic.contract.quanto.AvgPrice[isignum;execCost;totalEntry;multiplier];
      'nyi] | 0)
    };

//  UnrealizedPnl
/ i.UnrealizedPnl[ // TODO 
/         iv[`amt];
/         iv[`isignum];
/         iv[`avgPrice];
/         i[`markPrice];
/         i[`faceValue]];
.engine.logic.contract.UnrealizedPnl    :{[contractType;markPrice;faceValue;multiplier;amt;isignum;avgPrice] 
      7h$($[contractType=0;.engine.logic.contract.inverse.UnrealizedPnl[amt;isignum;avgPrice;markPrice;faceValue;multiplier]; 
				  contractType=0;.engine.logic.contract.inverse.UnrealizedPnl[amt;isignum;avgPrice;markPrice;faceValue;multiplier]; 
          contractType=0;.engine.logic.contract.inverse.UnrealizedPnl[amt;isignum;avgPrice;markPrice;faceValue;multiplier]; 
      'nyi] | 0)
    };

//  UnrealizedPnl
/ i.UnrealizedPnl[ // TODO 
/         iv[`amt];
/         iv[`isignum];
/         iv[`avgPrice];
/         i[`markPrice];
/         i[`faceValue]];
.engine.logic.contract.RealizedPnl    :{[contractType;fillQty;fillPrice;isignum;avgPrice;faceValue;multiplier]
    7h$($[contractType=0;.engine.logic.contract.inverse.RealizedPnl[fillQty;fillPrice;isignum;avgPrice;faceValue;multiplier];
      contractType=1;.engine.logic.contract.linear.RealizedPnl[fillQty;fillPrice;isignum;avgPrice;faceValue;multiplier];
      contractType=2;.engine.logic.contract.quanto.RealizedPnl[fillQty;fillPrice;isignum;avgPrice;faceValue;multiplier];
      'nyi] | 0)
    };
