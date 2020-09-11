


// Code Modules
// ----------------------------------------------------------->

.rq.M[".pipe.event";"";(
    ".util")];

.rq.M[".pipe.common";"";()];

.rq.M[".pipe.ingress";"";(
    ".pipe.event")];

.rq.M[".pipe.egress";"";(
    ".pipe.event")];

.rq.M[".pipe";"";(
    ".pipe.event";
    ".pipe.ingress";
    ".pipe.egress";
    ".util";
    ".util.cond")];


// Unit Test Modules
// ----------------------------------------------------------->


.rq.UM[".account.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];


.rq.UM[".account.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];

