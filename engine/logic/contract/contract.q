
//  UnrealizedPnl
/ i.UnrealizedPnl[ // TODO 
/         iv[`amt];
/         iv[`isignum];
/         iv[`avgPrice];
/         i[`markPrice];
/         i[`faceValue]];
.engine.logic.contract.ExecCost    :{[contractType;price;qty;multiplier]
    $[contractType=0;.engine.logic.contract.inverse.ExecCost[price;qty;multiplier];
      contractType=1;.engine.logic.contract.linear.ExecCost[price;qty;multiplier];
      contractType=2;.engine.logic.contract.quanto.ExecCost[price;qty;multiplier];
      'nyi]
    };

//  UnrealizedPnl
/ i.UnrealizedPnl[ // TODO 
/         iv[`amt];
/         iv[`isignum];
/         iv[`avgPrice];
/         i[`markPrice];
/         i[`faceValue]];
.engine.logic.contract.AvgPrice    :{[contractType;isignum;execCost;totalEntry;multiplier]
    $[contractType=0;.engine.logic.contract.inverse.ExecCost[isignum;execCost;totalEntry;multiplier];
      contractType=1;.engine.logic.contract.linear.ExecCost[isignum;execCost;totalEntry;multiplier];
      contractType=2;.engine.logic.contract.quanto.ExecCost[isignum;execCost;totalEntry;multiplier];
      'nyi]
    };

//  UnrealizedPnl
/ i.UnrealizedPnl[ // TODO 
/         iv[`amt];
/         iv[`isignum];
/         iv[`avgPrice];
/         i[`markPrice];
/         i[`faceValue]];
.engine.logic.contract.UnrealizedPnl    :{[contractType;markPrice;faceValue;multiplier;amt;isignum;avgPrice] 
				$[contractType=0;.engine.logic.contract.inverse.UnrealizedPnl[markPrice;faceValue;multiplier;amt;isignum;avgPrice]; 
				  contractType=1;.engine.logic.contract.linear.UnrealizedPnl[markPrice;faceValue;multiplier;amt;isignum;avgPrice];
          contractType=2;.engine.logic.contract.quanto.UnrealizedPnl[markPrice;faceValue;multiplier;amt;isignum;avgPrice];
      'nyi]
    };

//  UnrealizedPnl
/ i.UnrealizedPnl[ // TODO 
/         iv[`amt];
/         iv[`isignum];
/         iv[`avgPrice];
/         i[`markPrice];
/         i[`faceValue]];
.engine.logic.contract.RealizedPnl    :{[contractType;fillQty;fillPrice;isignum;avgPrice;faceValue;multiplier]
    $[contractType=0;.engine.logic.contract.inverse.ExecCost[fillQty;fillPrice;isignum;avgPrice;faceValue;multiplier];
      contractType=1;.engine.logic.contract.linear.ExecCost[fillQty;fillPrice;isignum;avgPrice;faceValue;multiplier];
      contractType=2;.engine.logic.contract.quanto.ExecCost[fillQty;fillPrice;isignum;avgPrice;faceValue;multiplier];
      'nyi]
    };
