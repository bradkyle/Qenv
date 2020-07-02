/*******************************************************
/ adapter enumerations
ADAPTERTYPE :   (`MARKETMAKER;        
                `DUALBOX;          
                `SIMPLEBOX;    
                `DISCRETE);   


AccountEventHistory: ();
InventoryEventHistory: ();
OrderEventHistory: ();
DepthEventHistory: ();
TradeEventHistory: ();

// Maintains a lookback buffer of 
// aggregations of state including
// state that has not been modified 
// by the engine per accountId
// sorted by time for which normalization
// and feature scaling that requires more
// than a single row can be done. 
FeatureBuffer: (

);