


// Code Modules
// ----------------------------------------------------------->

.rq.M[bp;".pipe.event";"";(
    ".util")];

.rq.M[bp;".pipe.common";"";()];

.rq.M[bp;".pipe.ingress";"";(
    ".pipe.event")];

.rq.M[bp;".pipe.egress";"";(
    ".pipe.event")];

.rq.M[bp;".pipe";"";(
    ".pipe.event";
    ".pipe.ingress";
    ".pipe.egress";
    ".util";
    ".util.cond")];


// Unit Test Modules
// ----------------------------------------------------------->


.rq.UM[bp;".account.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];


.rq.UM[bp;".account.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];

