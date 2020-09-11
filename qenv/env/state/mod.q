
// Code Modules
// ---------------------------------------------------------------------------------------->

.require.Mod[bp;".state";"";( 
    ".util";
    ".util.cond";
    ".util.table")];

.require.Mod[bp;".state.obs";"";( 
    ".state";
    ".util";
    ".util.indicators";
    ".util.cond")];

.require.Mod[bp;".state.rew";"";( 
    ".state";
    ".util";
    ".util.cond")];

.require.Mod[bp;".state.adapter";"";( 
    ".state";
    ".util";
    ".util.cond")];


// TestModules
// ---------------------------------------------------------------------------------------->

.require.UnitMod[bp;".state.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];


.require.UnitMod[bp;".state.obs.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];

.require.UnitMod[bp;".state.rew.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];


.require.UnitMod[bp;".state.adapter.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];


