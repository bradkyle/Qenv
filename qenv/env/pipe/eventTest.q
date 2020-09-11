
.util.Require["/env/pipe/";(
    ("pipe.q";".pipe"); 
    ("event.q";".pipe.event"); 
    ("ingress.q";".pipe.ingress");
    ("egress.q";".pipe.egress")
    )]; 

.qt.Unit[
    ".event.ValidateEvent";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();.util.testutils.defaultPipeHooks;
    "Global function for creating a new account"];
