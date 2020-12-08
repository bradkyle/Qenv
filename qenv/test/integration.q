

.qt.Integration[
    (".ingest";".engine");
    {[c]
         
    };
    {};
    ()];

.qt.Integration[
    (".pipe";".engine");
    {[c]
         

    };
    {};
    ()];

.qt.Integration[
    (".adapter";".engine");
    {[c]
        
    };
    {};
    ()];

// Tests that events generated from the 
// adapter and ingest are pushed to the pipe
// and invoke the correct functionality when
// being processed.
.qt.Integration[
    (".adapter";".pipe";".ingest";".engine");
    {[c]
         
    };
    {};
    ()];

// Tests that events returning from the 
// engine will be processed correctly
.qt.Integration[
    (".engine";".state");
    {[c]
      
        
    };
    {};
    ()];

.qt.Integration[
    (".state";".state.obs");
    {[c]
        
    };
    {};
    ()];

.qt.Integration[
    (".env";".state");
    {[c]
        
    };
    {};
    ()];