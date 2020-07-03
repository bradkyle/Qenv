\c 500 550
\l qunit.q
\l accountTest.q 
\l orderbookTest.q 
/ \l utilTest.q
\l inventoryTest.q
/ .qunit.runTests `.accountTest;
/ .qunit.runTests `.utilTest
/ .qunit.runTests `.inventoryTest;
.qunit.runTests `.orderbookTest;