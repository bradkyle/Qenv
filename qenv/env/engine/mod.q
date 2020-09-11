
// Code Modules
// ----------------------------------------------------------->

.require.Mod[bp;".instrument";"";(
    ".util")];

.require.Mod[bp;".account";"";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];

.require.Mod[bp;".order";"";(
    ".account";
    ".instrument";
    ".util";
    ".util.cond";
    ".pipe.ingress";
    ".pipe.egress")];

.require.Mod[bp;".liquidation";"";(
    ".account";
    ".instrument";
    ".order";
    ".util";
    ".util.cond";
    ".pipe.egress")];

.require.Mod[bp;".engine";"";(
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

.require.UnitMod[bp;".instrument.test";"instrumentTest.q";(
    ".util")];

.require.UnitMod[bp;".account.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];

.require.UnitMod[bp;".order.test";"orderTest.q";(
    ".account";
    ".instrument";
    ".util";
    ".util.cond";
    ".pipe.ingress";
    ".pipe.egress")];

.require.UnitMod[bp;".liquidation.test";"liquidationTest.q";(
    ".account";
    ".instrument";
    ".order";
    ".util";
    ".util.cond";
    ".pipe.egress")];

.require.UnitMod[bp;".engine.test";"engineTest.q";(
    ".account";
    ".instrument";
    ".liquidation";
    ".order";
    ".util";
    ".util.cond";
    ".util.table";
    ".pipe.ingress";
    ".pipe.egress")];
