\l global.q


// Converts a given amount of contracts into their
// equivalent value in the given margin currency
CntToMrg    : {[qty;price;faceValue;doAbs]
        $[price>0 & doAbs;
        :(faceValue%price)* abs[qty];
        doAbs;
        :(faceValue%price)*qty;
        :0];
        };

// Event/Action/Failure construction utils
//----------------------------------------------------->

// Todo move to schema/event
MakeEvent   : {[time;cmd;kind;datum]
        if[not (type time)=-15h; :0b]; //
        if[not (cmd in EVENTCMD); :0b];
        if[not (kind in EVENTKIND); :0b];
        if[not (type datum)=99h; :0b]; // should error if not dictionary
        / if[not] //validate datum 
        :`time`cmd`kind`datum!(time;cmd;kind;datum);
        };

// Creates an action i.e. a mapping between
// a agent/account Id and its respective
// vector target distribution and/or adapter
// that conforms to a generaliseable dictionary
MakeAction   : {[accountId;action]
        // TODO check 
        :`time`cmd`kind`datum!(time;cmd;kind;datum);
        };

// Creates an action i.e. a mapping between
// a agent/account Id and its respective
// vector target distribution and/or adapter
// that conforms to a generaliseable dictionary
MakeFailure   : {[time;cmd;kind;datum]
        if[not (type time)=-15h; :0b]; //TODO fix
        if[not (cmd in EVENTCMD); :0b];
        if[not (kind in EVENTKIND); :0b];
        :`time`cmd`kind`datum!(time;cmd;kind;datum);
        };


// Feature construction utils
//----------------------------------------------------->