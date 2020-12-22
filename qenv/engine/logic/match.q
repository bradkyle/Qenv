
.engine.logic.newstate:{[state;offset;rp;lqty]
    rp:first rp;
    ?[((offset<=rp)and((lqty+offset)<=rp));1;?[(sums[offset]<=rp);2;state]]};

// recieves trade as type
.engine.logic.match.Trade: {
        // Get all the levels that would encounter a  
        // fill, limit the price level selection to 
        // TODO add limit to match
        l:0!?[`.engine.model.orderbook.Orderbook;(
            (in;`side;x`side);
            (>;(+;`qty;(+;`hqty;(+;`iqty;`vqty)));0);
            (|;(<;(+\;`qty);sum[x`qty]);
            (=;`i;(*:;`i))));0b;()];
          
        $[count[l]>0;[
            aqty:sum[l[`qty`iqty`hqty`vqty]];
            thresh:sums[aqty];
            rp:min[(sum x`oqty;first[aqty])]^((thresh-prev[thresh])-(thresh-sum x`oqty));

            // Get all the orders that are to be filled
            o:?[`.engine.model.order.Order;(
                (=;`okind;1);
                (in;`price;l[`price] where (rp>0));
                (in;`state;(0 1));(>;`oqty;0));0b;()];

            if[count[o]>0;[

                    // Create a state table
                    s:0!((`price`side`iId xkey l) lj (`price`side`iId xgroup o));
                    so:ungroup s;

                    // Update Orders
                    // Derive the new orders from the ungrouped state.
                    no:![?[so;();0b;
                        `iId`oId`time`aId`side`okind`price`dqty`state`reduce`lqty`offset`shft!(
                        `iId;`oId;`time;`aId;`side;`okind;`price;`dqty;`state;`reduce;
                        (max;(enlist;(?;(>;`rp;`lqty);(-;(+;`lqty;`offset);`rp);`lqty);0)); // lqty
                        (.util.Clip;(-;`offset;`rp)); // offset
                        (.util.Clip;(+;(-;`offset;`rp);`lqty)) // shft // todo test
                    )];();0b;`dqty`shft`state!(
                        (.util.Clip;(?;(&;(<;`dqty;`lqty);(>;`lqty;0));`dqty;`lqty));
                        (+;`lqty;`offset);
                        (.engine.logic.match;`state;`offset;`rp;`lqty) // TODO update state
                    )];
                    .engine.model.order.Update[no];
                    .engine.Emit .event.Order[no];

                    // Update Orderbook
                    nl:?[];

                    // Execute Book Fills 
                    f:?[no;();0b;`time`price`qty`reduce`ismaker`side`iId`oId`ivId`aId!(
                        `time;`price;so[`lqty] - no[`lqty];`reduce;
                         (=;`okind;1);`side;`iId;`oId;`ivId;`aId)]

                    // Create New Trades
            
        ]];
      ]];
    
    };

.engine.logic.match.Match: {
        // Get all the levels that would encounter a  
        // fill, limit the price level selection to 
        // TODO add limit to match
        l:0!?[`.engine.model.orderbook.Orderbook;(
            (in;`side;x`side);
            (>;(+;`qty;(+;`hqty;(+;`iqty;`vqty)));0);
            (|;(<;(+\;`qty);sum[x`oqty]);
            (=;`i;(*:;`i))));0b;()];
          
        if[count[l]>0;[
            aqty:sum[l[`qty`iqty`hqty`vqty]];
            thresh:sums[aqty];
            rp:min[(sum x`oqty;first[aqty])]^((thresh-prev[thresh])-(thresh-sum x`oqty));

            // Get all the orders that are to be filled
            o:?[`.engine.model.order.Order;(
                (=;`okind;1);
                (in;`price;l[`price] where (rp>0));
                (in;`state;(0 1));(>;`oqty;0));0b;()];

            // Create a state table
            s:0!((`price`side`iId xkey l) lj (`price`side`iId xgroup o));
            so:ungroup s;

            if[count[so]>0;[
                // Update Orders
                // Derive the new orders from the ungrouped state.
                no:![?[so;();0b;
                    `iId`oId`time`aId`side`okind`price`dqty`state`reduce`lqty`offset`shft!(
                    `iId;`oId;`time;`aId;`side;`okind;`price;`dqty;`state;`reduce;
                    (max;(enlist;(?;(>;`rp;`lqty);(-;(+;`lqty;`offset);`rp);`lqty);0)); // lqty
                    (.util.Clip;(-;`offset;`rp)); // offset
                    (.util.Clip;(+;(-;`offset;`rp);`lqty)) // shft // todo test
                )];();0b;`dqty`shft`state!(
                    (.util.Clip;(?;(&;(<;`dqty;`lqty);(>;`lqty;0));`dqty;`lqty));
                    (+;`lqty;`offset);
                    (.engine.logic.match;`state;`offset;`rp;`lqty) // TODO update state
                )];
                .engine.model.order.Update[no];
                .engine.Emit .event.Order[no];

                // Update Orderbook
                nl:?[s ij (`price`side xgroup no);();0b;`price`side`hqty`iqty`vqty`qty`time!(
                    `price;`side;
                    (.util.Clip;(-;`hqty;`rp));
                    ((';sum);(-;`lqty;`dqty));
                    ((';sum);`lqty);
                    (.util.Clip;(-;(-;`qty;`rp);(sum;(-;so[`lqty];no[`lqty])))); // TODO
                    (max;x`time)
                    )];
                .engine.model.orderbook.Update[nl];
                .engine.Emit .event.Level[nl];

                // Derive Actor Fills
                f:?[x;();0b;`time`price`qty`reduce`ismaker`side`iId`oId`ivId`aId!(
                    `time;`price;so[`lqty] - no[`lqty];`reduce;
                    (=;`okind;1);`side;`iId;`oId;`ivId;`aId)];

                // Derive Book Fills 
                f,:?[no;();0b;`time`price`qty`reduce`ismaker`side`iId`oId`ivId`aId!(
                    `time;`price;so[`lqty] - no[`lqty];`reduce;
                     (=;`okind;1);`side;`iId;`oId;`ivId;`aId)];
                .engine.logic.fill.Fill[f];

                // Create New Trades
                t:();
                .engine.Emit .event.Trade[t];
            ]];


            // TODO insert unmatched orders if condition stipulates


            ]];
      
    };











