\c 500 550
\l account.q
\l qunit.q
\l accountTest.q 
/ \l utilTest.q
\l inventoryTest.q
.qunit.runTests `.accountTest;
/ .qunit.runTests `.utilTest
/ .qunit.runTests `.inventoryTest;