
 

.qt.Unit[
    ".engine.logic.account.Withdraw";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        mck1: .qt.M[`.engine.model.account.Update;{[a;b]};c];
        mck2: .qt.M[`.engine.Emit;{[a;b;c]};c];

				res:.engine.logic.account.Withdraw[a];

        .qt.CheckMock[mck1;m[0];c];
        .qt.CheckMock[mck2;m[1];c];
    };
    {[p] :`args`eRes`mocks`err!p};
    (
        ("Withdraw no balance:should fail";(
            .util.testutils.makeWithdraw[`aId`iId`withdraw;enlist(0;0;0)];
            (); // res 
            (enlist(1b;1;();.util.testutils.makeAccount[])); // mocks 
            () // err 
        ));
        ("Withdraw insufficient balance:should fail";(
            .util.testutils.makeWithdraw[`aId`iId`withdraw;enlist(0;0;0)];
            (); // res 
            (enlist(1b;1;();.util.testutils.makeAccount[])); // mocks 
            () // err 
        ));
        ("Withdraw Account disabled:should fail";(
            .util.testutils.makeWithdraw[`aId`iId`withdraw;enlist(0;0;0)];
            (); // res 
            (enlist(1b;1;();.util.testutils.makeAccount[])); // mocks 
            () // err 
        ));
        ("Withdraw Account locked:should fail";(
            .util.testutils.makeWithdraw[`aId`iId`withdraw;enlist(0;0;0)];
            (); // res 
            (enlist(1b;1;();.util.testutils.makeAccount[])); // mocks 
            () // err 
        ));
        ("Withdraw Success: Update fee tier, risk tier, apply withdraw fee, avail";(
            .util.testutils.makeWithdraw[`aId`iId`withdraw;enlist(0;0;0)];
            (); // res 
            (enlist(1b;1;();.util.testutils.makeAccount[])); // mocks 
            () // err 
        ))
    );
    ({};{};{};{});
    "Process a batch of signal events"];

.qt.Unit[
    ".engine.logic.account.Deposit";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        mck1: .qt.M[`.engine.model.account.Get;{[a;b] a}[m[0][3]];c];
        mck2: .qt.M[`.engine.model.account.Update;{[a;b]};c];
        mck3: .qt.M[`.engine.Emit;{[a;b;c]};c];

				res:.engine.valid.account.Deposit[a];

        .qt.CheckMock[mck1;m[0];c];
        .qt.CheckMock[mck2;m[1];c];
        .qt.CheckMock[mck3;m[2];c];
    };
    {[p] :`args`eRes`mocks`err!p};
    (
        ("Deposit Account disabled:should fail";(
            .util.testutils.makeDeposit[`aId`iId`withdraw;enlist(0;0;0)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeAccount[]); // Update Account
                (1b;1;.util.testutils.makeAccount[];()); // Update Account
                (1b;1;.util.testutils.makeEvent[];()) // Update Account
            ); // mocks 
            () // err 
        ));
        ("Deposit Account locked:should fail";(
            .util.testutils.makeDeposit[`aId`iId`withdraw;enlist(0;0;0)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeAccount[]); // Update Account
                (1b;1;.util.testutils.makeAccount[];()); // Update Account
                (1b;1;.util.testutils.makeEvent[];()) // Update Account
            ); // mocks 
            () // err 
        ));
        ("Deposit Success: Update fee tier, risk tier, avail";(
            .util.testutils.makeDeposit[`aId`iId`withdraw;enlist(0;0;0)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeAccount[]); // Update Account
                (1b;1;.util.testutils.makeAccount[];()); // Update Account
                (1b;1;.util.testutils.makeEvent[];()) // Update Account
            ); // mocks 
            () // err 
        ))
    );
    ({};{};{};{});
    "Process a batch of signal events"];


.qt.Unit[
    ".engine.logic.account.Leverage";
    {[c]
        p:c[`params];
        a:p`args;
        m:p[`mocks];

        mck1: .qt.M[`.engine.model.account.Get;{[a;b] a}[m[0][3]];c];
        mck2: .qt.M[`.engine.model.account.Update;{[a;b]};c];
        mck3: .qt.M[`.engine.Emit;{[a;b;c]};c];

				res:.engine.valid.account.Leverage[a 0;a 1;a 2];

        .qt.CheckMock[mck1;m[0];c];
        .qt.CheckMock[mck2;m[1];c];
        .qt.CheckMock[mck3;m[2];c];
    };
    {[p] :`args`eRes`mocks`err!p};
    (
        ("Leverage no balance:should fail";(
            .util.testutils.makeLeverage[`aId`iId`withdraw;enlist(0;0;0)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeAccount[]); // Update Account
                (1b;1;.util.testutils.makeAccount[];()); // Update Account
                (1b;1;.util.testutils.makeEvent[];()) // Update Account
            ); // mocks 
            () // err 
        ));
        ("Leverage insufficient balance:should fail";(
            .util.testutils.makeLeverage[`aId`iId`withdraw;enlist(0;0;0)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeAccount[]); // Update Account
                (1b;1;.util.testutils.makeAccount[];()); // Update Account
                (1b;1;.util.testutils.makeEvent[];()) // Update Account
            ); // mocks 
            () // err 
        ));
        ("Leverage Account disabled:should fail";(
            .util.testutils.makeLeverage[`aId`iId`withdraw;enlist(0;0;0)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeAccount[]); // Update Account
                (1b;1;.util.testutils.makeAccount[];()); // Update Account
                (1b;1;.util.testutils.makeEvent[];()) // Update Account
            ); // mocks 
            () // err 
        ));
        ("Leverage Account locked:should fail";(
            .util.testutils.makeLeverage[`aId`iId`withdraw;enlist(0;0;0)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeAccount[]); // Update Account
                (1b;1;.util.testutils.makeAccount[];()); // Update Account
                (1b;1;.util.testutils.makeEvent[];()) // Update Account
            ); // mocks 
            () // err 
        ));
        ("Leverage Success: Update fee tier, risk tier, apply withdraw fee, avail";(
            .util.testutils.makeLeverage[`aId`iId`leverage;enlist(0;0;0)];
            (); // res 
            (
                (1b;1;();.util.testutils.makeAccount[]); // Update Account
                (1b;1;.util.testutils.makeAccount[];()); // Update Account
                (1b;1;.util.testutils.makeEvent[];()) // Update Account
            ); // mocks 
            () // err 
        ))
    );
    "Global function for creating a new account"];
 

