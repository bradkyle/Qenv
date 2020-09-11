
// Code Modules
// ---------------------------------------------------------------------------------------->

.require.M[bp;".state";"";( 
    ".util";
    ".util.cond";
    ".util.table")];

.require.M[bp;".state.obs";"";( 
    ".state";
    ".util";
    ".util.indicators";
    ".util.cond")];

.require.M[bp;".state.rew";"";( 
    ".state";
    ".util";
    ".util.cond")];

.require.M[bp;".state.adapter";"";( 
    ".state";
    ".util";
    ".util.cond")];


// TestModules
// ---------------------------------------------------------------------------------------->

.require.UM[bp;".state.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];


.require.UM[bp;".state.obs.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];

.require.UM[bp;".state.rew.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];


.require.UM[bp;".state.adapter.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];


