
\cd config
\l config.q
\l binance_train.q
if[getenv[`TESTING]="YES";\l configTest.q];
\cd ../
