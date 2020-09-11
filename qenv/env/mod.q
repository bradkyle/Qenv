

// Code Modules
// ---------------------------------------------------------------------------------------->

.require.Mod[bp;".config";"";(

    )];

.require.Mod[bp;".env";"env.q";(
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

.require.UnitMod[bp;".config.test";"configTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];


.require.UnitMod[bp;".env.test";"envTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];