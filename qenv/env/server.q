

\p 5050

.server.DumStep         :{[actions]
        // ACTIONS should be a tuple/vector of (agentId, action)
        {(x[0];({rand 255}'[til 256]))}'[actions]
    };