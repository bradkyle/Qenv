




.qt.Unit[
    ".pipe.getCurriculumIngressBatch";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };
    {[p]
    
    };
    ();
    .util.testutils.defaultPipeHooks;
    "Global function for creating a new account"];


.qt.Unit[
    ".pipe.getChronologicalIngressBatch";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };
    {[p]
    
    };
    ();
    .util.testutils.defaultPipeHooks;
    "Global function for creating a new account"];

.qt.Unit[
    ".pipe.getRandomIngressBatch";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };
    {[p]
    
    };
    ();
    .util.testutils.defaultPipeHooks;
    "Global function for creating a new account"];


.qt.Unit[
    ".pipe.Reset";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };
    {[p]
    
    };
    ();
    .util.testutils.defaultPipeHooks;
    "Global function for creating a new account"];


.qt.Unit[
    ".pipe.GetIngressEvents";
    {[c]
        p:c[`params];

        a:p`args;
        res:.pipe._GetIngressEvents[a[0];a[1]];

    };
    {[p]
    
    };
    (
        ("GetIngressEvents: windowkind 1, ");
        ();
        ();
        ()
    );
    .util.testutils.defaultPipeHooks;
    "Global function for creating a new account"];


.qt.Unit[
    ".pipe.GetEgressEvents";
    {[c]
        p:c[`params];
        .util.testutils.setupEvents[0^p`cEvents];

        .pipe.CONF:p`pipeConf;



        a:p`args;
        res:.pipe._GetEgressEvents[a[0];a[1]];


        .pipe.CONF:();
    };
    {[p]
        :`events`
    };
    (
        ();
        ();
        ();
        ()
    );
    .util.testutils.defaultPipeHooks;
    "Global function for creating a new account"];