

.qt.Unit[
    ".engine.model.instrument.NewInstrument";
    {[c]
        p:c[`params];
        .util.testutils.revertInstrument[];
        .qt.RunUnit[c;.engine.services.account.NewAccounts];
        .util.testutils.checkInstrument[p`eRes;c;cols[p`eRes]];
        .util.testutils.revertInstrument[];
    };
    {`args`err`eRes`mocks!x};
    (
        ("Single NewInstruent (1) no error, success";(

        ));
        ("Single NewInstruent (1) error, fail";(

        ));
        ("Single NewInstruent (list) (1) error, fail";(

        ));
        ("Single NewInstruent (dict) error, fail";(

        ));
        ("Batch NewInstruent (4) no errors, all succeed";(

        ));
        ("Batch NewInstruent (4) errors, none succeed";(

        ));
        ("Batch NewInstruent (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a NewInstruent"];

.qt.Unit[
    ".engine.model.instrument.UpdateInstrument";
    {[c]
        p:c[`params];
        p:c[`params];
        .util.testutils.revertInstrument[];
        .engine.model.instrument.NewInstruent[p`cIns];
        .qt.RunUnit[c;.engine.services.account.NewAccounts];
        .util.testutils.checkInstrument[p`eRes;c;cols[p`eRes]];
        .util.testutils.revertInstrument[];
    };
    {};
    (
        ("Single UpdateInstrument (1) no error, success";(

        ));
        ("Single UpdateInstrument (1) error, fail";(

        ));
        ("Single UpdateInstrument (list) (1) error, fail";(

        ));
        ("Single UpdateInstrument (dict) error, fail";(

        ));
        ("Batch UpdateInstrument (4) no errors, all succeed";(

        ));
        ("Batch UpdateInstrument (4) errors, none succeed";(

        ));
        ("Batch UpdateInstrument (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a UpdateInstrument"];


.qt.Unit[
    ".engine.model.instrument.ValidInstrumentIds";
    {[c]
        p:c[`params];
        .util.testutils.revertInstrument[];
        .engine.model.instrument.NewInstruent[p`cIns];
        .qt.RunUnit[c;.engine.services.account.NewAccounts];
        .util.testutils.revertInstrument[];
    };
    {};
    (
        ("Single ValidInstrumentIds (1) no error, success";(

        ));
        ("Single ValidInstrumentIds (1) error, fail";(

        ));
        ("Single ValidInstrumentIds (list) (1) error, fail";(

        ));
        ("Single ValidInstrumentIds (dict) error, fail";(

        ));
        ("Batch ValidInstrumentIds (4) no errors, all succeed";(

        ));
        ("Batch ValidInstrumentIds (4) errors, none succeed";(

        ));
        ("Batch ValidInstrumentIds (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.model.instrument.GetInstrumentByIds";
    {[c]
        p:c[`params];
        .util.testutils.revertInstrument[];
        .engine.model.instrument.NewInstruent[p`cIns];
        .qt.RunUnit[c;.engine.services.account.NewAccounts];
        .util.testutils.revertInstrument[];
    };
    {};
    (
        ("Single GetInstrumentById (1) no error, success";(

        ));
        ("Single GetInstrumentById (1) error, fail";(

        ));
        ("Single GetInstrumentById (list) (1) error, fail";(

        ));
        ("Single GetInstrumentById (dict) error, fail";(

        ));
        ("Batch GetInstrumentById (4) no errors, all succeed";(

        ));
        ("Batch GetInstrumentById (4) errors, none succeed";(

        ));
        ("Batch GetInstrumentById (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for GetInstrumentById"];
