
\cd valid 
\l account.q 
\l order.q 

.valid.loadTests:{
    system[sv["";("l ";x;"/orderTest.q")]];
		system[sv["";("l ";x;"/accountTest.q")]];
    };

\cd ../
