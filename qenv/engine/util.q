\l logger.q 

// Shortened enlist
E:{[x] :enlist[x]};

// Sets all values to 0 in list or matrix
// where value is less than zero (negative)
Clip :{[x](x>0)*abs x};  

// Converts a list of lists into a equidimensional
// i.e. equal dimensional matrix that can be used
// in matrix calculations 
PadM  :{[x]:x,'(max[c]-c:count each x)#'0};

// Returns the opposite side to the side provided as an
// argument
NegSide :{[side]$[side=`SELL;:`BUY;:`SELL]};

// If the value of key(f) of the datum/dict (d) is null then
// set the value equal to the provided value (v) and return
// the datum/dictionary (d)
// if the fields provided are iterable set all given names
// in fields to value given
Default	:{[d;f;a;v] 
	$[(count f)=1;f:enlist f;0N];
	/ d[f[where[d[f]=0N]]]:v;
	d[where[null d[a]] inter f]:v; 
	:d;
	};

// TODO make better implementation, perhaps with type checking
// sanitize constructs valid input with the correct types and
// is a useful utility for low 
Sanitize  :{[i;d;a]
	i:i[a];
	idx:where[not[null i]];
	if[(count idx)>0;d[idx]:i[idx]];
	:a!d;
	};

// TODO 
MandCols :{[m]
	if[all null inventory[mandCols];
		[
			.logger.Err[]
		]
	];
	};

// Converts a given amount of contracts into their
// equivalent value in the given margin currency
CntToMrg    : {[qty;price;faceValue;doAbs]
        $[price>0 & doAbs;
        :(faceValue%price)* abs[qty];
        doAbs;
        :(faceValue%price)*qty;
        :0];
        };


// Feature construction utils
//----------------------------------------------------->



