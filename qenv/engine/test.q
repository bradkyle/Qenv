\c 500 550
\l qunit.q
\l accountTest.q 
\l orderTest.q 
\l utilTest.q
\l inventoryTest.q
\l stateTest.q 
\l engineTest.q
\l instrumentTest.q
.qunit.runTests `.utilTest
.qunit.runTests `.instrumentTest;
.qunit.runTests `.accountTest;
.qunit.runTests `.inventoryTest;
.qunit.runTests `.orderTest;
.qunit.runTests `.engineTest;
.qunit.runTests `.stateTest;