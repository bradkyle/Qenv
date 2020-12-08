
// Pass through the engine
//---------------------------------------------------------------------------------------------------. 
// ex,sym,time,intime,side,price,size 
trade:([ex:`symbol$();sym:`symbol$();tid:`symbol$()] time:`datetime$(); intime:`datetime$(); side:`long$(); price:`long$(); size:`long$());

// ex,sym,time,intime,side,price,size
depth:([ex:`symbol$();sym:`symbol$();tid:`symbol$()] time:`datetime$(); intime:`datetime$(); side:`long$(); price:`long$(); size:`long$());

// ex,sym,time,intime,markprice
markprice:([ex:`symbol$();sym:`symbol$();tid:`symbol$()] time:`datetime$(); intime:`datetime$(); markprice:`long$()); 

// ex,sym,time,intime,fundingrate
funding:([ex:`symbol$();sym:`symbol$();tid:`symbol$()] time:`datetime$(); intime:`datetime$(); fundingrate:`long$()); 

// ex,sum,time,intime,pricelimit
pricelimit:([ex:`symbol$();sym:`symbol$();tid:`symbol$()] time:`datetime$(); intime:`datetime$(); pricelimitbuy:`long$(); pricelimitsell:`long$()); 

// ex,sym,time,intime
settlement:([ex:`symbol$();sym:`symbol$();tid:`symbol$()] time:`datetime$(); intime:`datetime$()); 


// Dont pass through the engine
//---------------------------------------------------------------------------------------------------. 

// ex,sym,time,intime,side,price,size 
liquidation:([ex:`symbol$();sym:`symbol$();tid:`symbol$()] time:`datetime$(); intime:`datetime$(); side:`long$(); price:`long$(); size:`long$());

// src,tag,value
signal:([source:`symbol$();tag:`symbol$()] time:`datetime$(); intime:`datetime$(); scalar:`float$()); 


// Reference function that would use gateway in production 
//---------------------------------------------------------------------------------------------------. 
getdata:{
				h("trade";(`binance`binancefutures`bitmex`okex`huobi`huobidm);(`btcusdt`btcud`btcswapl`btcswapi);(.z.z;.z.z+`second$5));
				h("depth";(`binance`binancefutures`bitmex`okex`okexswap`huobi`huobidm);(`btcusdt`btcud`btcswapl`btcswapi);(.z.z;.z.z+`second$5));
				h("markprice";(binancefutures`bitmex`okex`huobi`huobidm);(`btcusdt`btcud`btcswapl`btcswapi);(.z.z;.z.z+`second$5));
				h("trade";(`binance`binancefutures`bitmex`okex`huobi`huobidm);(`btcusdt`btcud`btcswapl`btcswapi);(.z.z;.z.z+`second$5));
				h("signal";(`bitmex`binance`);(`btcusdt`btcud`btcswapl`btcswapi);(.z.z;.z.z+`second$5));
				}
