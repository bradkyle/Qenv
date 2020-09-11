


// Code Modules
// ----------------------------------------------------------->

.util.Mod[bp;".pipe.event";"";(
    ".util")];

.util.Mod[bp;".pipe.common";"";()];

.util.Mod[bp;".pipe.ingress";"";(
    ".pipe.event")];

.util.Mod[bp;".pipe.egress";"";(
    ".pipe.event")];

.util.Mod[bp;".pipe";"";(
    ".pipe.event";
    ".pipe.ingress";
    ".pipe.egress";
    ".util";
    ".util.cond")];


// Unit Test Modules
// ----------------------------------------------------------->


.util.UnitMod[bp;".account.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];


.util.UnitMod[bp;".account.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];

