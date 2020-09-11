

// Code Modules
// ---------------------------------------------------------------------------------------->

.util.Mod[bp;".config";"";(

    )];

.util.Mod[bp;".env";"env.q";(
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

.util.UnitMod[bp;".config.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];


.util.UnitMod[bp;".env.test";"accountTest.q";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress")];