
\l require
\cd ../

\l quantest
\cd ../

.require.Require["./env/";`CODE`UNIT];

.qt.RunTests[];

// TODO run integration and benchmark test