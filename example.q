
\c 500 500
\l init.q
\l ingest/client.q
/ \l okexswap.q
/ \l data/okex

\d .policy

Act: {[obs;nactions] enlist(0;rand nactions) };

\d .

// Reset the environment
// and get the first observations
.env.obs:.env.Reset[];

// Take 100000 steps
do[100;{
				// pass observations to the agent
				actions:.policy.Act[.env.obs;27];
				res:.env.Step[actions];
				.env.obs:res[0];
				rwd:res[1];
				dns:res[2];

				}[]];
