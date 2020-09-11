

// Code Modules
// ---------------------------------------------------------------------------------------->

.require.M[bp;".config";"";(

    )];

.require.M[bp;".env";"env.q";(
    ".state";
    ".adapter";
    ".state.obs";
    ".state.rew";
    ".state.dns";
    ".pipe";
    ".engine";
    ".config")];


// TestModules
// ---------------------------------------------------------------------------------------->

.require.UM[bp;".config.test";"configTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];


.require.UM[bp;".env.test";"envTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];