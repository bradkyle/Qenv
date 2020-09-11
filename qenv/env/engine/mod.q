
// Code Modules
// ----------------------------------------------------------->

.rq.M[".instrument";"";(
    ".util")];

.rq.M[".account";"";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];

.rq.M[".order";"";(
    ".account";
    ".instrument";
    ".util";
    ".util.cond";
    ".pipe.ingress";
    ".pipe.egress")];

.rq.M[".liquidation";"";(
    ".account";
    ".instrument";
    ".order";
    ".util";
    ".util.cond";
    ".pipe.egress")];

.rq.M[".engine";"";(
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

.rq.UM[".instrument.test";"instrumentTest.q";(
    ".util")];

.rq.UM[".account.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];

.rq.UM[".order.test";"orderTest.q";(
    ".account";
    ".instrument";
    ".util";
    ".util.cond";
    ".pipe.ingress";
    ".pipe.egress")];

.rq.UM[".liquidation.test";"liquidationTest.q";(
    ".account";
    ".instrument";
    ".order";
    ".util";
    ".util.cond";
    ".pipe.egress")];

.rq.UM[".engine.test";"engineTest.q";(
    ".account";
    ".instrument";
    ".liquidation";
    ".order";
    ".util";
    ".util.cond";
    ".util.table";
    ".pipe.ingress";
    ".pipe.egress")];
