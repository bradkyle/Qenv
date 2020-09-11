
// Code Modules
// ---------------------------------------------------------------------------------------->

.rq.M[bp;".state";"";( 
    ".util";
    ".util.cond";
    ".util.table")];

.rq.M[bp;".state.obs";"";( 
    ".state";
    ".util";
    ".util.indicators";
    ".util.cond")];

.rq.M[bp;".state.rew";"";( 
    ".state";
    ".util";
    ".util.cond")];

.rq.M[bp;".state.adapter";"";( 
    ".state";
    ".util";
    ".util.cond")];


// TestModules
// ---------------------------------------------------------------------------------------->

.rq.UM[bp;".state.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];


.rq.UM[bp;".state.obs.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];

.rq.UM[bp;".state.rew.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];


.rq.UM[bp;".state.adapter.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];


