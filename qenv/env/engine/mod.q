
// Code Modules
// ----------------------------------------------------------->

.rq.M[bp;".instrument";"";(
    ".util")];

.rq.M[bp;".account";"";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];

.rq.M[bp;".order";"";(
    ".account";
    ".instrument";
    ".util";
    ".util.cond";
    ".pipe.ingress";
    ".pipe.egress")];

.rq.M[bp;".liquidation";"";(
    ".account";
    ".instrument";
    ".order";
    ".util";
    ".util.cond";
    ".pipe.egress")];

.rq.M[bp;".engine";"";(
    ".account";
    ".instrument";
    ".liquidation";
    ".order";
    ".util";
    ".util.cond";
    ".util.table";
    ".pipe.ingress";
    ".pipe.egress")];

// Unit Test Modules
// ----------------------------------------------------------->

.rq.UM[bp;".instrument.test";"instrumentTest.q";(
    ".util")];

.rq.UM[bp;".account.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];

.rq.UM[bp;".order.test";"orderTest.q";(
    ".account";
    ".instrument";
    ".util";
    ".util.cond";
    ".pipe.ingress";
    ".pipe.egress")];

.rq.UM[bp;".liquidation.test";"liquidationTest.q";(
    ".account";
    ".instrument";
    ".order";
    ".util";
    ".util.cond";
    ".pipe.egress")];

.rq.UM[bp;".engine.test";"engineTest.q";(
    ".account";
    ".instrument";
    ".liquidation";
    ".order";
    ".util";
    ".util.cond";
    ".util.table";
    ".pipe.ingress";
    ".pipe.egress")];
