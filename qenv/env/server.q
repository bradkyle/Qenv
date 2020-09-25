

\p 5050

.server.episode_step:0;

.server.DumRes           :{[actions]
        .episode_step+:1;
        ({(
            x[0];
            ({rand 255f}'[til 256]);
            rand 1f;
            (1?(01b))[0];
            .server.episode_step;
            rand[1f]*.server.episode_step
        )}'[actions])
    };

.server.DumResT          :{[actions]
    (`agentId`observation`reward`done`episode_step`episode_return!flip[.server.DumRes[actions]])
    };

// TODO ACTIONS should be a tuple/vector of (agentId, action)
.server.DumStep         :{[actions;k]
        :$[k=0;
            .server.DumResT[actions];
          k=1;
            .server.DumRes[actions];
            .server.DumRes[actions]];  
    };