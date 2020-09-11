
// Basal Engine Unit Tests
\l ./env/engine/instrumentTest.q
\l ./env/engine/accountTest.q
\l ./env/engine/orderTest.q
\l ./env/engine/liquidationTest.q
\l ./env/engine/engineTest.q

// Contract Specific Unit Tests
\l ./env/engine/contract/inverse/accountTest.q
\l ./env/engine/contract/linear/accountTest.q

// Pipe Unit Tests
\l ./env/pipe/eventTest.q
\l ./env/pipe/pipeTest.q

// State Unit Tests
\l ./env/state/stateTest.q
\l ./env/state/adapterTest.q
\l ./env/state/obsTest.q
\l ./env/state/rewTest.q

// Basal Env Tests
\l ./env/configTest.q
\l ./env/envTest.q

// Integration Tests
\l ./test/integration.q 

// Benchmark Tests
\l ./test/benchmark.q

.qt.RunTests[];

// TODO run integration and benchmark test