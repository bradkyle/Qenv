
\l require
\cd ../

\l quantest
\cd ../

.rq.Require["./env/";`CODE`UNIT];

.qt.RunTests[];

// TODO run integration and benchmark test