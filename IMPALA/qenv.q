\p 5000
.env.obs:{s:(4 42 42);(sum[s]?255)};
.env.Step:{[actions] show actions; (.env.obs[];rand 1f;0b;())}
.env.Reset:{show "reset"; .env.obs[]}
