TESTING:1b;
BASE:system["pwd"][0];
args:.Q.opt[.z.x];
TESTSET:first args[`ts];
show TESTSET;
 
getFn :{[path]  
    {x,".",y}[path]'[string[system("f ",path)]]
    };

.Q.trp[{
    // Load common dependencies
    system"l quantest/init.q";
    system"l common/init.q";
    system"l util/init.q";

    // Load unit tests
    / \l config/init.q
    system"l engine/init.q";
    system"l state/init.q";
    system"l env.q";
    system"l envTest.q";
    /:args `ag be_true -l`/ Load integration and 
    // benchmark tests
    
    system"l test/init.q"

    if[not[null[`$TESTSET]];.qt.ShowOnly[(getFn[TESTSET])]];
   // .qt.ShowOnly[(
       //         /* getFn[".engine.model.instrument"] */
    /     / ".engine.logic.trade.ProcessAgentTrades"
    /     ".engine.model.account.NewAccounts";
    /     ".engine.model.account.UpdateAccounts";
    /     ".engine.model.account.GetAccountsById";
    /     ".engine.model.account.GetInMarketAccounts";
    /     ".engine.model.account.GetAllInsolvent";
    /     ".engine.model.account.GetAllUnsettled";
    /     ".engine.model.account.ValidAccountIds";
    //)];
    /* .qt.SkpBes[669]; */
    /* .qt.SkpAft[38]; */
    //.qt.SkpBesTest[73];

    .qt.RunTests[];
    };();{
        system[("cd ",BASE)];
        show `$x;
        show `$.Q.sbt[y];
    }];
 
rl:{
    system[("l ",BASE,"/test.q")]
    RT x
    };
