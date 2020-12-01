
\l init.q
\l ingest/client.q
/ \l okexswap.q
/ \l data/okex

\d .policy

Act: {[obs;nactions] rand nactions };

\d .

// Reset the environment
// and get the first observations
obs:.env.Reset[];

// Take 100000 steps
do[100;{
				// pass observations to the agent
				actions:.policy.Act[obs;27];
				res:.env.Step[actions];
				obs:res[0];
				rwd:res[1];
				dns:res[2];

				}[]];
