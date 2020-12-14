

.qt.Unit[
    ".engine.logic.account.Liquidate";
    {[c]
        mck1: .qt.M[`.engine.model.account.Update;{[a;b]};c];
        mck2: .qt.M[`.engine.model.liquidation.Create;{[a;b;c]};c];
        mck1: .qt.M[`.engine.logic.order.New;{[a;b]};c];

        res:.engine.logic.account.Remargin[a 0;a 1;a 2];

        .qt.CheckMock[mck1;m[0];c];
        .qt.CheckMock[mck2;m[1];c];
    };
    {[p] :`args`eRes`mocks`err!p};
    (
        ("Liquidation of > tier 3 account";(
            (`aId`iId`withdraw;enlist(0;0;0));
            (); // res 
            (
                (1b;1;.util.testutils.makeAccount[];()); // Update Account
                (1b;1;.util.testutils.makeLiquidation[];()); // Update Account
                (1b;1;.util.testutils.makeOrder[];()) // Update Account
            ); // mocks 
            () // err 
        ));
        ("Liquidation of < tier 3 account";(
            (`aId`iId`withdraw;enlist(0;0;0));
            (); // res 
            (
                (1b;1;.util.testutils.makeAccount[];()); // Update Account
                (1b;1;.util.testutils.makeLiquidation[];()); // Update Account
                (1b;1;.util.testutils.makeOrder[];()) // Update Account
            ); // mocks 
            () // err 
        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];


/ .qt.SkpBesTest[25];
.qt.Unit[
    ".engine.logic.account.Withdraw";
    {[c]
        p:c[`params];
        s:p[`setup];
        m:p[`mocks];
        a:p[`args];

        .util.table.dropAll[(
          `.engine.model.inventory.Inventory,
          `.engine.model.risktier.RiskTier,
          `.engine.model.feetier.Feetier
        )];

        a:.model.Withdraw . p`args;
        res:.engine.logic.account.Withdraw[p`args];

        .qt.CheckMock[mck1;m[0];c];
        .qt.CheckMock[mck2;m[1];c];
    };
    {[p] :`setup`args`eRes`mocks`err!p};
    (
       enlist("Withdraw no balance:should fail";(
            ((!) . flip(
                (`inventory;(`aId`side`mm`upnl`ordQty`ordLoss`amt;flip(0 0;-1 1;0 0;0 0;0 0;0 0;10 10))); 
                (`feetier;(`ftId`vol`bal`ref;flip(0 1;0 0;0 0;0 0))); // Update Account
                (`risktier;(`rtId`amt`lev;flip(0 1;50000 250000;125 100))) // Update Account
            ));
            (`aId`iId`wit;enlist(0;0;0));
            (); // res 
            (
                (1b;1;();()); // Update Account
                (1b;1;();()) // Update Account
            ); // mocks 
            () // err 
        ))
        / ("Withdraw insufficient balance:should fail";(
        /     .util.testutils.makeWithdraw[`aId`iId`withdraw;enlist(0;0;0)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeAccount[]); // Update Account
        /         (1b;1;.util.testutils.makeAccount[];()); // Update Account
        /         (1b;1;.util.testutils.makeEvent[];()) // Update Account
        /     ); // mocks 
        /     () // err 
        / ));
        / ("Withdraw Account disabled:should fail";(
        /     .util.testutils.makeWithdraw[`aId`iId`withdraw;enlist(0;0;0)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeAccount[]); // Update Account
        /         (1b;1;.util.testutils.makeAccount[];()); // Update Account
        /         (1b;1;.util.testutils.makeEvent[];()) // Update Account
        /     ); // mocks 
        /     (

        /     ) // err 
        / ));
        / ("Withdraw Account locked:should fail";(
        /     .util.testutils.makeWithdraw[`aId`iId`withdraw;enlist(0;0;0)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeAccount[]); // Update Account
        /         (1b;1;.util.testutils.makeAccount[];()); // Update Account
        /         (1b;1;.util.testutils.makeEvent[];()) // Update Account
        /     ); // mocks 
        /     () // err 
        / ));
        / ("Withdraw Success: Update fee tier, risk tier, apply withdraw fee, avail";(
        /     .util.testutils.makeWithdraw[`aId`iId`withdraw;enlist(0;0;0)];
        /     (); // res 
        /     (
        /         (1b;1;();.util.testutils.makeAccount[]); // Update Account
        /         (1b;1;.util.testutils.makeAccount[];()); // Update Account
        /         (1b;1;.util.testutils.makeEvent[];()) // Update Account
        /     ); // mocks 
        /     () // err 
        / ))
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

        res:.engine.logic.account.Deposit[a 0;a 1;a 2];

        .qt.CheckMock[mck1;m[0];c];
        .qt.CheckMock[mck2;m[1];c];
        .qt.CheckMock[mck3;m[2];c];
    };
    {[p] :`args`eRes`mocks`err!p};
    (
        ("Deposit Account disabled:should fail";(
            (`aId`iId`withdraw;enlist(0;0;0));
            (); // res 
            (
                (1b;1;();()); // Update Account
                (1b;1;();()) // Update Account
            ); // mocks 
            () // err 
        ));
        ("Deposit Account locked:should fail";(
            (`aId`iId`withdraw;enlist(0;0;0));
            (); // res 
            (
                (1b;1;();()); // Update Account
                (1b;1;();()) // Update Account
            ); // mocks 
            () // err 
        ));
        ("Deposit Success: Update fee tier, risk tier, avail";(
            (`aId`iId`withdraw;enlist(0;0;0));
            (); // res 
            (
                (1b;1;();()); // Update Account
                (1b;1;();()) // Update Account
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

        res:.engine.logic.account.Leverage[a 0;a 1;a 2];

        .qt.CheckMock[mck1;m[0];c];
        .qt.CheckMock[mck2;m[1];c];
        .qt.CheckMock[mck3;m[2];c];
    };
    {[p] :`args`eRes`mocks`err!p};
    (
        ("Leverage no balance:should fail";(
            (`aId`iId`withdraw;enlist(0;0;0));
            (); // res 
            (
                (1b;1;();()); // Update Account
                (1b;1;();()) // Update Account
            ); // mocks 
            () // err 
        ));
        ("Leverage insufficient balance:should fail";(
            (`aId`iId`withdraw;enlist(0;0;0));
            (); // res 
            (
                (1b;1;.model.Account[];()); // Update Account
                (1b;1;.event.Account[];()) // Update Account
            ); // mocks 
            () // err 
        ));
        ("Leverage Account disabled:should fail";(
            (`aId`iId`withdraw;enlist(0;0;0));
            (); // res 
            (
                (1b;1;.model.Account[];()); // Update Account
                (1b;1;.event.Account[];()) // Update Account
            ); // mocks 
            () // err 
        ));
        ("Leverage Account locked:should fail";(
            (`aId`iId`withdraw;enlist(0;0;0));
            (); // res 
            (
                (1b;1;.model.Account[];()); // Update Account
                (1b;1;.event.Account[];()) // Update Account
            ); // mocks 
            () // err 
        ));
        ("Leverage Success: Update fee tier, risk tier, apply withdraw fee, avail";(
            (`aId`iId`withdraw;enlist(0;0;0));
            (); // res 
            (
                (1b;1;.model.Account[];()); // Update Account
                (1b;1;.event.Account[];()) // Update Account
            ); // mocks 
            () // err 
        ))
    );
    "Global function for creating a new account"];
 

