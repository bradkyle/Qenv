system "d .instrumentTest";
\l qunit.q
\l instrument.q

revert:   {
            delete from `.instrument.Instrument;
            .instrument.instrumentCount:0;
            .inventory.activeInstrumentId:0;
    };

// TODO more cases i.e. with agent orders etc.
/ testProcessSideUpdate   :{ 
/         runCase: {[dscr; case]
/             $[count[case[`qtys]]>0;.order.updateQtys[case[`side];case[`qtys]];0N];
/             / $[count[case[`orders]]>0;.order.updateOrders[case[`side];case[`orders]];0N];
/             $[count[case[`offsets]]>0;.order.updateOffsets[case[`side];case[`offsets]];0N];
/             $[count[case[`sizes]]>0;.order.updateSizes[case[`sizes];case[`sizes]];0N];

/             res:.order.processSideUpdate[case[`side];case[`updates]];
/             / .qunit.assertEquals[res; 1b; "Should return true"]; // TODO use caseid etc
/             .qunit.assertEquals[.order.getQtys[case[`side]]; case[`eqtys]; "qtys expected"];
/             .qunit.assertEquals[.order.getOffsets[case[`side]]; case[`eoffsets]; "offsets expected"];
/             .qunit.assertEquals[.order.getSizes[case[`side]]; case[`esizes]; "sizes expected"];
/         };
/         caseCols:`side`updates`qtys`orders`offsets`sizes`eqtys`eorders`eoffsets`esizes`eresnum;
        
/         runCase["case1";caseCols!(`BUY;((100 100.5!100 100));();();();();(100 100.5!100 100);();();();0)];
/         runCase["case2";caseCols!(`SELL;((100 100.5!100 100));();();();();(100 100.5!100 100);();();();0)];
/     };

// Instrument CRUD Logic
// -------------------------------------------------------------->
testNewInstrument : {
    runCase: {[dscr; instrument; einstrument; expects] 
            res:();
            // Execute tested function
            res,:.instrument.NewInstrument[instrument; 1b; .z.z];
            // Run tests on state
            ins:select from .instrument.Instrument;
            .qunit.assertEquals[count ins; expects[`instrumentCount]; "instrumentCount"];      

            // Tear Down 
            / revert[];
    }; 

    instrumentCols: `some`other;
    expectedCols: `instrumentCount`shouldError;

    runCase["simple instrument creation";
        instrumentCols!(0N;0N);
        instrumentCols!();
        expectedCols!(1;0b)];

    };
 
testGetInstrument  :{
    runCase: {[dscr; instrumentId; einstrument; expects] 
            res:();
            // Execute tested function
            res,:.instrument.NewInstrument[instrument; 1b; .z.z];
            // Run tests on state
            ins:select from .instrument.Instrument;
            .qunit.assertEquals[count ins; expects[`instrumentCount]; "instrumentCount"];      

            // Tear Down 
            / revert[];
    }; 
 
    expectedCols: `instrumentCount`shouldError;

    runCase["simple instrument creation";
        instrumentId;
        instrumentCols!();
        expectedCols!(1;0b)];
    };

// TODO test active instrument doesnt exist, exists etc.
testGetActiveInstrument :{
    runCase: {[dscr; instrumentId; einstrument; expects] 
            res:();
            // Execute tested function
            res,:.instrument.NewInstrument[instrument; 1b; .z.z];
            // Run tests on state
            ins:select from .instrument.Instrument;
            .qunit.assertEquals[count ins; expects[`instrumentCount]; "instrumentCount"];      

            // Tear Down 
            / revert[];
    }; 
 
    expectedCols: `instrumentCount`shouldError;

    runCase["simple instrument creation";
        instrumentId;
        instrumentCols!();
        expectedCols!(1;0b)];

    };

testUpdateInstrument     :{
    runCase: {[dscr; instrumentId; einstrument; expects] 
            res:();
            // Execute tested function
            res,:.instrument.NewInstrument[instrument; 1b; .z.z];
            // Run tests on state
            ins:select from .instrument.Instrument;
            .qunit.assertEquals[count ins; expects[`instrumentCount]; "instrumentCount"];      

            // Tear Down 
            / revert[];
    }; 
 
    expectedCols: `instrumentCount`shouldError;

    runCase["simple instrument creation";
        instrumentId;
        instrumentCols!();
        expectedCols!(1;0b)];
    
    };

testUpdateActiveInstrument  :{
    runCase: {[dscr; instrumentId; einstrument; expects] 
            res:();
            // Execute tested function
            res,:.instrument.NewInstrument[instrument; 1b; .z.z];
            // Run tests on state
            ins:select from .instrument.Instrument;
            .qunit.assertEquals[count ins; expects[`instrumentCount]; "instrumentCount"];      

            // Tear Down 
            / revert[];
    }; 
 
    expectedCols: `instrumentCount`shouldError;

    runCase["simple instrument creation";
        instrumentId;
        instrumentCols!();
        expectedCols!(1;0b)];
    
    };