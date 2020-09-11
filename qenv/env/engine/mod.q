
.util.Mod[bp;".instrument";"";()];

.util.Mod[bp;".account";"";(
    ".instrument";    
    ".inverse.account";
    ".linear.account";
    ".quanto.account";
    ".pipe.egress"
)];

.util.Mod[bp;".order";"";(
    ".account";
    ".instrument";
    ".util";
    ".util.cond";
    ".pipe.ingress";
    ".pipe.egress"
)];

.util.Mod[bp;".liquidation";"";(
    ".account";
    ".instrument";
    ".order";
    ".util";
    ".util.cond";
    ".pipe.egress"
)];

.util.Mod[bp;".engine";"";(
    ".account";
    ".instrument";
    ".liquidation";
    ".order";
    ".util";
    ".util.cond";
    ".pipe.ingress";
    ".pipe.egress"
)];