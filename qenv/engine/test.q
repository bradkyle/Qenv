\c 500 550
\l qunit.q
\l accountTest.q 
\l orderTest.q 
/ \l utilTest.q
\l inventoryTest.q
/ .qunit.runTests `.accountTest;
/ .qunit.runTests `.utilTest
/ .qunit.runTests `.inventoryTest;
.qunit.runTests `.orderbookTest;