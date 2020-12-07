


\cd valid 
\l account.q 
\l order.q 

.logic.loadTests   :{
    system[sv["";("l ";x;"/orderTest.q")]];
		system[sv["";("l ";x;"/accountTest.q")]];
    };

\cd ../
