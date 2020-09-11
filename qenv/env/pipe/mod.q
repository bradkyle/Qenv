


// Code Modules
// ----------------------------------------------------------->

.require.Mod[bp;".pipe.event";"";(
    ".util")];

.require.Mod[bp;".pipe.common";"";()];

.require.Mod[bp;".pipe.ingress";"";(
    ".pipe.event")];

.require.Mod[bp;".pipe.egress";"";(
    ".pipe.event")];

.require.Mod[bp;".pipe";"";(
    ".pipe.event";
    ".pipe.ingress";
    ".pipe.egress";
    ".util";
    ".util.cond")];


// Unit Test Modules
// ----------------------------------------------------------->


.require.UnitMod[bp;".account.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];


.require.UnitMod[bp;".account.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];

