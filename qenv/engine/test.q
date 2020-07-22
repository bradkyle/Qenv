\c 500 550
\l qunit.q

/ \l utilTest.q
/ .qunit.runTests `.utilTest

\l instrumentTest.q
.qunit.runTests `.instrumentTest;

\l accountTest.q 
.qunit.runTests `.accountTest;

\l inventoryTest.q
.qunit.runTests `.inventoryTest;

\l orderTest.q 
.qunit.runTests `.orderTest;

/ \l engineTest.q
/ .qunit.runTests `.engineTest;

/ \l stateTest.q 
/ .qunit.runTests `.stateTest;