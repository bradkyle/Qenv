\l global.q

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
MakeAction   : {[accountId;action;]
        if[not (type time)=-15h; :`]; //TODO fix
        if[not (cmd in EVENTCMD); ];
        if[not (kind in EVENTKIND); ];
        if[not] //validate datum 
        :`time`cmd`kind`datum!(time;cmd;kind;datum);
        };

// Creates an action i.e. a mapping between
// a agent/account Id and its respective
// vector target distribution and/or adapter
// that conforms to a generaliseable dictionary
MakeFailure   : {[time;cmd;kind;datum]
        if[not (type time)=-15h; :`]; //TODO fix
        if[not (cmd in EVENTCMD); ];
        if[not (kind in EVENTKIND); ];
        if[not] //validate datum 
        :`time`cmd`kind`datum!(time;cmd;kind;datum);
        };


// Feature construction utils
//----------------------------------------------------->