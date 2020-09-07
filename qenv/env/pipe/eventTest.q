


test:.qt.Unit[
    ".event.ValidateEvent";
    {[c]
        p:c[`params];

        .account.ProcessDepth[p[`event]];

    };();();({};{};defaultBeforeEach;defaultAfterEach);
    "Global function for creating a new account"];
