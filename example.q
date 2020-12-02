
\c 5000 5000
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
.env.step:0;
.env.start:.z.P;

// Take 100000 steps
do[1000;{
				// pass observations to the agent
				show .env.step;
				show `second$(.z.P - .env.start);
				actions:.policy.Act[.env.obs;21];
				res:.env.Step[actions];
				.env.obs:res[0];
				show .env.obs;
				rwd:res[1];
				dns:res[2];
				.env.step+:1;

				}[]];
