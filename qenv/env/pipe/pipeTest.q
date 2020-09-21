


.qt.Unit[
    ".pipe.getFirstIngressBatch";
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
    (
        ("";(

        ));
        ("";(

        ))
    );
    .util.testutils.defaultPipeHooks;
    "Global function for creating a new account"];


.qt.Unit[
    ".pipe.GetIngressEvents";
    {[c]
        p:c[`params];
        .pipe.ingress.AddBatch[`time`cmd`kind`datum!p[`events]];

        .pipe.CONF:p`pipeConf;

        res:.pipe._GetIngressEvents[p[`step];p[`windowkind]];

        .qt.A[res;~;p[`eRes];"res";case];
        .qt.A[.pipe.ingress.Event;~;p[`eEvents];"ingress events";case];
        .pipe.CONF:();
    };
    {[p]
        :`events`pipeConf`step`windowkind`eRes`eEvents!(

        );
    };
    (
        (("Get all events within the current step time and 5 seconds in the future",
         "1 event outside of window");(
            (
                ();
                ();
                ();
                ();
                ();
                ()
            );
            ();
            1;
            0;
            ();
            ()
        ));
        (("Get all events within the current step time and 5 events in the future",
         "1 event outside of window");(
            (
                ();
                ();
                ();
                ();
                ();
                ()
            );
            ();
            1;
            1;
            ();
            ()
        ));
        (("Get all events within the current step event count and 20 event count window,",
         "max 5 seconds:(no events after window thresh step event count)");(
            (
                ();
                ();
                ();
                ();
                ();
                ()
            );
            ();
            1;
            2;
            ();
            ()
        ));
        (("Get all events within the current step event count and 20 event count window,",
         "max 5 seconds:(1 event after window thresh step event count)");(
            (
                ();
                ();
                ();
                ();
                ();
                ()
            );
            ();
            1;
            2;
            ();
            ()
        ))
    );
    .util.testutils.defaultPipeHooks;
    "Global function for creating a new account"];


.qt.Unit[
    ".pipe.GetEgressEvents";
    {[c]
        p:c[`params];
        .pipe.egress.AddBatch[`time`cmd`kind`datum!p[`events]];

        .pipe.CONF:p`pipeConf;

        res:.pipe._GetEgressEvents[p[`step];p[`windowkind]];

        .qt.A[res;~;p[`eRes];"res";case];
        .qt.A[.pipe.egress.Event;~;p[`eEvents];"egress events";case];
        .pipe.CONF:();
    };
    {[p]
        :`events`pipeConf`step`windowkind!(

        );
    };
    (
        ("Get all events that have passed";(
             (
                ();
                ();
                ();
                ();
                ();
                ()
            );
            ();
            1;
            0;
            ();
            ()
        ));
        ("";(
             (
                ();
                ();
                ();
                ();
                ();
                ()
            );
            ();
            1;
            0;
            ();
            ()
        ))
    );
    .util.testutils.defaultPipeHooks;
    "Global function for creating a new account"];