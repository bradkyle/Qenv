  
// TODO join fea set

 
// GetObs derives a feature vector from the current state which it
// then fills and removes inf etc from.
// it then checks if the state Feature Buffer has been initialized
// with the respective feature columns, or else it initializes it.
// when the feature buffer is set up it will proceed to upsert the 
// features into the Feature buffer. It then calls .ml.minmax scaler
// to normalize the given features (FOR EACH ACCOUNT) such that the
// observations can be passed back to the agents etc.
/  @param step     (Long) The current environment step
/  @param aIds     (Long) The accountIds for which to get observations.
/  @return         (List) The normalized observation vector for each 
/                         account
/ cols[fea] except `accountId // TODO make more efficient, move to C etc
.state.obs.GetObs :{[step;lookback;aIds]
    fea:.state.obs.derive[step;aIds];
    if[((step=0) or (count[.state.FeatureBuffer]<count[aIds]));[
            // If the env is on the first step then generate 
            // a lookback buffer (TODO with decreasing noise?)
            // backwards (randomized fill of buffer)
            {x[`step]-:y;x:`accountId`step xkey x;x:0f^`float$(x);.state.FeatureBuffer,:{x+:x*rand 0.001;x}x}[fea]'[til[lookback]];
    ]];
    fea:`accountId`step xkey fea;
    fea:0f^`float$(fea);
    .state.FeatureBuffer,:fea;
   :last'[flip'[.ml.minmaxscaler'[{raze'[x]}'[`accountId xgroup (enlist[`step] _ (`step xasc 0!.state.FeatureBuffer))]]]]
    / :last'[flip'[{raze'[x]}'[`accountId xgroup (enlist[`step] _ (`step xasc 0!.state.FeatureBuffer))]]]
    };

