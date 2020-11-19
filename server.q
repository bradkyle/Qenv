system"l common/init.q";
system"l util/init.q";

// Load unit tests
/ \l config/init.q
system"l binance.q";
system"l engine/init.q";
system"l state/init.q";
system"l env.q";
system"l server.q";
system"l envTest.q";
system"l serverTest.q";


/ \p 5050
// todo https://github.com/AquaQAnalytics/TorQ/blob/master/torq.q copy
