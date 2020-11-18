
inventory:([ivId:`long$()] ordQty:`long$();ordVal:`long$();ordLoss:`long$();posQty:`long$();posValue:`long$();rpnl:`long$();
avgPrice:`long$();execCost:`long$();upnl:`long$();lev:`long$(););

// wit:witdrawn
// dep:deposited
account:([aId:`long$()] lng:`inventory$();srt:`inventory$();mrg:`long$();dep:`long$();wit:`long$();mmr:`long$();imr:`long$();
posTyp:`long$(); feeTier:`long$());
