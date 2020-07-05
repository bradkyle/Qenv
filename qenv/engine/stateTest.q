system "d .stateTest";
\l qunit.q
\l state.q


// Singleton State and Lookback Buffers
// =====================================================================================>

testInsertResultantEvents   :{

    };


// Adapters
// =====================================================================================>

// Event Creation Utilities
// --------------------------------------------------->

testGetPriceAtLevel :{

    };

testGetOpenPositions  :{

    };

testGetCurrentOrderLvlDist  :{

    };

testCreateOrderEventsAtLevel  :{

    };

testCreateOrderEventsByTargetDist   :{

    };

testCreateOrderEventsByLevelDeltas  :{

    };

testCreateMarketOrderEvent  :{

    };

testCreateFlattenEvents     :{

    };

testCreateCancelAllOrdersEvent  :{

    };

testCreateOrderEventsFromDist   :{

    };

testCreateDepositEvent          :{

    };

testCreateWithdrawEvent         :{

    };

testCreateNaiveStopEvents       :{

    };

// Action Adapters
// --------------------------------------------------->

testDiscrete    :{

    };

testSimpleBox   :{

    };

testDualBox     :{

    };

testLvlDeltas   :{

    };

testMarketMakerAdapter  :{

    };

testAdapt   :{

    };

// Exposed State Logic
// =====================================================================================>


// Agent specific obs/reward functions
// --------------------------------------------------->

testGetFeatureVectors   :{

    };

testGetResultantRewards :{

    };

// Secondary state functions
// --------------------------------------------------->

testNextEvents :{

    };

testDerive  :{

    };

testAdvance :{

    };

// Main Callable functions
// --------------------------------------------------->