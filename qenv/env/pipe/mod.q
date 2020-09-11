


// Code Modules
// ----------------------------------------------------------->

.require.M[bp;".pipe.event";"";(
    ".util")];

.require.M[bp;".pipe.common";"";()];

.require.M[bp;".pipe.ingress";"";(
    ".pipe.event")];

.require.M[bp;".pipe.egress";"";(
    ".pipe.event")];

.require.M[bp;".pipe";"";(
    ".pipe.event";
    ".pipe.ingress";
    ".pipe.egress";
    ".util";
    ".util.cond")];


// Unit Test Modules
// ----------------------------------------------------------->


.require.UM[bp;".account.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];


.require.UM[bp;".account.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];

