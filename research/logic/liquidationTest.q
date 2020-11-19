



.qt.Unit[
    ".engine.logic.liquidation.ForceCancel";
    {[c]
        .qt.RunUnit[c;.engine.services.mark.ProcessMarkUpdateEvents];
    };.qt.generalParams;
    (
        ("Single ForceCancel (1) no error, success";(
                    ();();();()
        ));
        ("Single ForceCancel (1) error, fail";(
                    ();();();()
        ));
        ("Single ForceCancel (list) (1) error, fail";(
                    ();();();()
        ));
        ("Single ForceCancel (dict) error, fail";(
                    ();();();()
        ));
        ("Batch ForceCancel (4) no errors, all succeed";(
                    ();();();()
        ));
        ("Batch ForceCancel (4) errors, none succeed";(
                    ();();();()
        ));
        ("Batch ForceCancel (2) errors, (2) succeed";(
                    ();();();()
        ))
    );
    ({};{};{};{});
    "Global function for creating a new account inventorys"];



.qt.Unit[
    ".engine.logic.liquidation.SelfTrade";
    {[c]
        .qt.RunUnit[c;.engine.services.mark.ProcessMarkUpdateEvents];
    };.qt.generalParams;
    (
        ("Single ForceCancel (1) no error, success";(
                    ();();();()
        ));
        ("Single ForceCancel (1) error, fail";(
                    ();();();()
        ));
        ("Single ForceCancel (list) (1) error, fail";(
                    ();();();()
        ));
        ("Single ForceCancel (dict) error, fail";(
                    ();();();()
        ));
        ("Batch ForceCancel (4) no errors, all succeed";(
                    ();();();()
        ));
        ("Batch ForceCancel (4) errors, none succeed";(
                    ();();();()
        ));
        ("Batch ForceCancel (2) errors, (2) succeed";(
                    ();();();()
        ))
    );
    ({};{};{};{});
    "Global function for creating a new account inventorys"];
    

.qt.Unit[
    ".engine.logic.liquidation.IsAccountInsolvent";
    {[c]
        .qt.RunUnit[c;.engine.services.mark.ProcessMarkUpdateEvents];
    };.qt.generalParams;
    (
        ("Single ForceCancel (1) no error, success";(
                    ();();();()
        ));
        ("Single ForceCancel (1) error, fail";(
                    ();();();()
        ));
        ("Single ForceCancel (list) (1) error, fail";(
                    ();();();()
        ));
        ("Single ForceCancel (dict) error, fail";(
                    ();();();()
        ));
        ("Batch ForceCancel (4) no errors, all succeed";(
                    ();();();()
        ));
        ("Batch ForceCancel (4) errors, none succeed";(
                    ();();();()
        ));
        ("Batch ForceCancel (2) errors, (2) succeed";(
                    ();();();()
        ))
    );
    ({};{};{};{});
    "Global function for creating a new account inventorys"];
