
// Code Modules
// ----------------------------------------------------------->

.require.M[bp;".instrument";"";(
    ".util")];

.require.M[bp;".account";"";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];

.require.M[bp;".order";"";(
    ".account";
    ".instrument";
    ".util";
    ".util.cond";
    ".pipe.ingress";
    ".pipe.egress")];

.require.M[bp;".liquidation";"";(
    ".account";
    ".instrument";
    ".order";
    ".util";
    ".util.cond";
    ".pipe.egress")];

.require.M[bp;".engine";"";(
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

.require.UM[bp;".instrument.test";"instrumentTest.q";(
    ".util")];

.require.UM[bp;".account.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];

.require.UM[bp;".order.test";"orderTest.q";(
    ".account";
    ".instrument";
    ".util";
    ".util.cond";
    ".pipe.ingress";
    ".pipe.egress")];

.require.UM[bp;".liquidation.test";"liquidationTest.q";(
    ".account";
    ".instrument";
    ".order";
    ".util";
    ".util.cond";
    ".pipe.egress")];

.require.UM[bp;".engine.test";"engineTest.q";(
    ".account";
    ".instrument";
    ".liquidation";
    ".order";
    ".util";
    ".util.cond";
    ".util.table";
    ".pipe.ingress";
    ".pipe.egress")];
