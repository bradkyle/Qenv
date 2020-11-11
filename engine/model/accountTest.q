

// Accounts of an Instrument
// ---------------------------------------------------------------------------->
.qt.Unit[
    ".engine.model.account.NewAccounts";
    {[c]
        p:c[`params];
        .util.testutils.revertAccount[];
        .qt.RunUnit[c;.engine.services.account.NewAccounts];
        .util.testutils.checkAccount[p`eRes;c;cols[p`eRes]];
        .util.testutils.revertAccount[];
    };
    {`args`err`eRes`mocks!x};
    (
        ("Single New Account dict (1) no error, success";(
            `accountId`depositAmount`marginType`positionType!(0;0;0;0); / .util.testutils.makeAccounts[`accountId`marginType`positionType;()];
            ();
            (); / .util.testutils.makeAccounts[];
            ()
        ));
        ("Single New Account table (1) no error, success";(
            flip[enlist[`accountId`depositAmount`marginType`positionType!(0;0;0;0)]]; 
            ();
            (); / .util.testutils.makeAccounts[];
            ()
        ));
        ("Single New Account (1) error, fail";(
            (); / .util.testutils.makeAccounts[`accountId`marginType`positionType;()];
            ();
            (); / .util.testutils.makeAccounts[];
            ()
        ));
        ("Single New Account (list) (1) error, fail";(

            (); / .util.testutils.makeAccounts[`accountId`marginType`positionType;()];
            ();
            (); / .util.testutils.makeAccounts[];
            ()
        ));
        ("Single New Account (dict) error, fail";(

            (); / .util.testutils.makeAccounts[`accountId`marginType`positionType;()];
            ();
            (); / .util.testutils.makeAccounts[];
            ()
        ));
        ("Batch New Account (4) no errors, all succeed";(

            (); / .util.testutils.makeAccounts[`accountId`marginType`positionType;()];
            ();
            (); / .util.testutils.makeAccounts[];
            ()
        ));
        ("Batch New Account (4) errors, none succeed";(

            (); / .util.testutils.makeAccounts[`accountId`marginType`positionType;()];
            ();
            (); / .util.testutils.makeAccounts[];
            ()
        ));
        ("Batch New Account (2) errors, (2) succeed";(

            (); / .util.testutils.makeAccounts[`accountId`marginType`positionType;()];
            ();
            (); / .util.testutils.makeAccounts[];
            ()
        ));
        ("Batch New Account different schema";(

            (); / .util.testutils.makeAccounts[`accountId`marginType`positionType;()];
            ();
            (); / .util.testutils.makeAccounts[];
            ()
        ))
    );
    ({};{};{};{});
    "Recieves a table/dictionary or list of accounts"];

.qt.Unit[
    ".engine.model.account.UpdateAccounts";
    {[c]
        p:c[`params];
        .util.testutils.revertAccount[];
        .engine.model.account.NewAccounts[p`cAcc];
        .qt.RunUnit[c;.engine.services.account.NewAccounts];
        .util.testutils.checkAccount[p`eRes;c;cols[p`eRes]];
        .util.testutils.revertAccount[];
    };
    {`cAcc`args`err`eRes`mocks!x};
    (
        ("Single Update Account (1) no error, success";(

        ));
        ("Single Update Account (1) error, fail";(

        ));
        ("Single Update Account (list) (1) error, fail";(

        ));
        ("Single Update Account (dict) error, fail";(

        ));
        ("Batch Update Account (4) no errors, all succeed";(

        ));
        ("Batch Update Account (4) errors, none succeed";(

        ));
        ("Batch Update Account (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];

.qt.Unit[
    ".engine.model.account.GetAccountsById";
    {[c]
        p:c[`params];
        .util.testutils.revertAccount[];
        .engine.model.account.NewAccounts[p`cAcc];
        .qt.RunUnit[c;.engine.services.account.NewAccounts];
        .util.testutils.revertAccount[];
    };
    {`cAcc`args`err`eRes`mocks!x};
    (
        ("Single GetAccountsById (1) no error, success";(

        ));
        ("Single GetAccountsById (1) error, fail";(

        ));
        ("Single GetAccountsById (list) (1) error, fail";(

        ));
        ("Single GetAccountsById (dict) error, fail";(

        ));
        ("Batch GetAccountsById (4) no errors, all succeed";(

        ));
        ("Batch GetAccountsById (4) errors, none succeed";(

        ));
        ("Batch GetAccountsById (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];

.qt.Unit[
    ".engine.model.account.GetInMarketAccounts";
    {[c]
        p:c[`params]; 
        .util.testutils.revertAccount[];
        .engine.model.account.NewAccounts[p`cAcc];
        .qt.RunUnit[c;.engine.services.account.NewAccounts];
        .util.testutils.revertAccount[];
    };
    {`cAcc`args`err`eRes`mocks!x};
    (
        ("Single GetInMarketAccounts (1) no error, success";(

        ));
        ("Single GetInMarketAccounts (1) error, fail";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.model.account.GetAllInsolvent";
    {[c]
        p:c[`params]; 
        .util.testutils.revertAccount[];
        .engine.model.account.NewAccounts[p`cAcc];
        .qt.RunUnit[c;.engine.services.account.NewAccounts];
        .util.testutils.revertAccount[];
    };
    {`cAcc`args`err`eRes`mocks!x};
    (
        ("Single GetInMarketAccounts (1) no error, success";(

        ));
        ("Single GetInMarketAccounts (1) error, fail";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];

.qt.Unit[
    ".engine.model.account.GetAllUnsettled";
    {[c]
        p:c[`params];
        .util.testutils.revertAccount[];
        .engine.model.account.NewAccounts[p`cAcc];
        .qt.RunUnit[c;.engine.services.account.NewAccounts];
        .util.testutils.revertAccount[];
    };
    {`cAcc`args`err`eRes`mocks!x};
    (
        ("Single GetInMarketAccounts (1) no error, success";(

        ));
        ("Single GetInMarketAccounts (1) error, fail";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];

.qt.Unit[
    ".engine.model.account.ValidAccountIds";
    {[c]
        p:c[`params];
        .util.testutils.revertAccount[];
        .engine.model.account.NewAccounts[p`cAcc];
        .qt.RunUnit[c;.engine.services.account.NewAccounts];
        .util.testutils.revertAccount[];
    };
    {`cAcc`args`err`eRes`mocks!x};
    (
        ("Single ValidAccountIds (1) no error, success";(

        ));
        ("Single ValidAccountIds (1) error, fail";(

        ));
        ("Single ValidAccountIds (list) (1) error, fail";(

        ));
        ("Single ValidAccountIds (dict) error, fail";(

        ));
        ("Batch ValidAccountIds (4) no errors, all succeed";(

        ));
        ("Batch ValidAccountIds (4) errors, none succeed";(

        ));
        ("Batch ValidAccountIds (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];

.qt.Unit[
    ".engine.model.account.IncSelfFill";
    {[c]
        p:c[`params];
        .util.testutils.revertAccount[];
        .engine.model.account.NewAccounts[p`cAcc];
        .qt.RunUnit[c;.engine.services.account.NewAccounts];
        .util.testutils.checkAccount[p`eRes;c;cols[p`eRes]];
        .util.testutils.revertAccount[];
    };
    {`cAcc`args`err`eRes`mocks!x};
    (
        ("Single IncSelfFill (1) no error, success";(

        ));
        ("Single IncSelfFill (1) error, fail";(

        ));
        ("Single IncSelfFill (list) (1) error, fail";(

        ));
        ("Single IncSelfFill (dict) error, fail";(

        ));
        ("Batch IncSelfFill (4) no errors, all succeed";(

        ));
        ("Batch IncSelfFill (4) errors, none succeed";(

        ));
        ("Batch IncSelfFill (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];

.qt.Unit[
    ".engine.model.account.SetAccountStateLiquidating";
    {[c]
        p:c[`params];
        .util.testutils.revertAccount[];
        .engine.model.account.NewAccounts[p`cAcc];
        .qt.RunUnit[c;.engine.services.account.NewAccounts];
        .util.testutils.checkAccount[p`eRes;c;cols[p`eRes]];
        .util.testutils.revertAccount[];
    };
    {`cAcc`args`err`eRes`mocks!x};
    (
        ("Single SetAccountStateLiquidating (1) no error, success";(

        ));
        ("Single SetAccountStateLiquidating (1) error, fail";(

        ));
        ("Single SetAccountStateLiquidating (list) (1) error, fail";(

        ));
        ("Single SetAccountStateLiquidating (dict) error, fail";(

        ));
        ("Batch SetAccountStateLiquidating (4) no errors, all succeed";(

        ));
        ("Batch SetAccountStateLiquidating (4) errors, none succeed";(

        ));
        ("Batch SetAccountStateLiquidating (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];

.qt.Unit[
    ".engine.model.account.SetAccountStateActive";
    {[c]
        p:c[`params];
        .util.testutils.revertAccount[];
        .engine.model.account.NewAccounts[p`cAcc];
        .qt.RunUnit[c;.engine.services.account.NewAccounts];
        .util.testutils.checkAccount[p`eRes;c;cols[p`eRes]];
        .util.testutils.revertAccount[];
    };
    {`cAcc`args`err`eRes`mocks!x};
    (
        ("Single SetAccountStateActive (1) no error, success";(

        ));
        ("Single SetAccountStateActive (1) error, fail";(

        ));
        ("Single SetAccountStateActive (list) (1) error, fail";(

        ));
        ("Single SetAccountStateActive (dict) error, fail";(

        ));
        ("Batch SetAccountStateActive (4) no errors, all succeed";(

        ));
        ("Batch SetAccountStateActive (4) errors, none succeed";(

        ));
        ("Batch SetAccountStateActive (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];
 
