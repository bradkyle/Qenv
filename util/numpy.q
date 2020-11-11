
/* This is a file for defining utilities derived from numpy */


.util.np.randomTimespan :{[mu;sigma]
	`timespan$(first[np[`:random.normal;mu;sigma;1]`])
	};



