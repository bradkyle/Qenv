
// Code Modules
// ---------------------------------------------------------------------------------------->

.util.Mod[bp;".state";"";( 
    ".util";
    ".util.cond";
    ".util.table")];

.util.Mod[bp;".state.obs";"";( 
    ".state";
    ".util";
    ".util.indicators";
    ".util.cond")];

.util.Mod[bp;".state.rew";"";( 
    ".state";
    ".util";
    ".util.cond")];

.util.Mod[bp;".state.adapter";"";( 
    ".state";
    ".util";
    ".util.cond")];


// TestModules
// ---------------------------------------------------------------------------------------->

.util.UnitMod[bp;".state.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];


.util.UnitMod[bp;".state.obs.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];

.util.UnitMod[bp;".state.rew.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];


.util.UnitMod[bp;".state.adapter.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];


