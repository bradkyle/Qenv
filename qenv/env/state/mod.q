
// Code Modules
// ---------------------------------------------------------------------------------------->

.rq.M[".state";"";( 
    ".util";
    ".util.cond";
    ".util.table")];

.rq.M[".state.obs";"";( 
    ".state";
    ".util";
    ".util.indicators";
    ".util.cond")];

.rq.M[".state.rew";"";( 
    ".state";
    ".util";
    ".util.cond")];

.rq.M[".state.adapter";"";( 
    ".state";
    ".util";
    ".util.cond")];


// TestModules
// ---------------------------------------------------------------------------------------->

.rq.UM[".state.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];


.rq.UM[".state.obs.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];

.rq.UM[".state.rew.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];


.rq.UM[".state.adapter.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];


