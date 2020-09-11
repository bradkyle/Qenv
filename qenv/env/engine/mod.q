
// Code Modules
// ----------------------------------------------------------->

.util.Mod[bp;".instrument";"";(
    ".util")];

.util.Mod[bp;".account";"";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];

.util.Mod[bp;".order";"";(
    ".account";
    ".instrument";
    ".util";
    ".util.cond";
    ".pipe.ingress";
    ".pipe.egress")];

.util.Mod[bp;".liquidation";"";(
    ".account";
    ".instrument";
    ".order";
    ".util";
    ".util.cond";
    ".pipe.egress")];

.util.Mod[bp;".engine";"";(
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

.util.UnitMod[bp;".instrument.test";"instrumentTest.q";(
    ".util")];

.util.UnitMod[bp;".account.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];

.util.UnitMod[bp;".order.test";"orderTest.q";(
    ".account";
    ".instrument";
    ".util";
    ".util.cond";
    ".pipe.ingress";
    ".pipe.egress")];

.util.UnitMod[bp;".liquidation.test";"liquidationTest.q";(
    ".account";
    ".instrument";
    ".order";
    ".util";
    ".util.cond";
    ".pipe.egress")];

.util.UnitMod[bp;".engine.test";"engineTest.q";(
    ".account";
    ".instrument";
    ".liquidation";
    ".order";
    ".util";
    ".util.cond";
    ".util.table";
    ".pipe.ingress";
    ".pipe.egress")];
