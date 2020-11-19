

.qt.Unit[
    ".engine.model.order.NewOrders";
    {[c]
        p:c[`params];
        .util.testutils.revertOrders[];

        res:.util.testutils.checkErr[
            .engine.model.account.NewOrders;
            p`args;
            p`err;
            c];

        .util.testutils.checkOrders[p`eRes;c;cols[p`eRes]];
        .qt.A[res;~;p[`eRes];"res";c];
        .util.testutils.revertOrders[];
    };
    {`args`err`eRes!x};
    (
        ("Single NewOrders (1) no error, success";(
             
        ));
        ("Single NewOrders (1) error, fail";(

        ));
        ("Single NewOrders (list) (1) error, fail";(

        ));
        ("Single NewOrders (dict) error, fail";(

        ));
        ("Batch NewOrders (4) no errors, all succeed";(
            
        ));
        ("Batch NewOrders (4) errors, none succeed";(

        ));
        ("Batch NewOrders (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account inventorys"];
    
.qt.Unit[
    ".engine.model.order.UpdateOrders";
    {[c]
        p:c[`params];
        .util.testutils.revertOrders[];
        .engine.model.account.NewOrders[p`cOrd];

        res:.util.testutils.checkErr[
            .engine.model.account.UpdateOrders;
            p`args;
            p`err;
            c];

        .util.testutils.checkOrders[p`eRes;c;cols[p`eRes]];
        .qt.A[res;~;p[`eRes];"res";c];
        .util.testutils.revertOrders[];
    };
    {`cOrd`args`err`eRes!x};
    (
        ("Single UpdateOrders (1) no error, success";(

        ));
        ("Single UpdateOrders (1) error, fail";(

        ));
        ("Single UpdateOrders (list) (1) error, fail";(

        ));
        ("Single UpdateOrders (dict) error, fail";(

        ));
        ("Batch UpdateOrders (4) no errors, all succeed";(

        ));
        ("Batch UpdateOrders (4) errors, none succeed";(

        ));
        ("Batch UpdateOrders (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];

.qt.Unit[
    ".engine.model.order.ValidOrderIds";
    {[c]
        p:c[`params];
        .util.testutils.revertOrders[];
        .engine.model.account.NewOrders[p`cOrd];

        res:.util.testutils.checkErr[
            .engine.model.account.ValidOrderIds;
            p`args;
            p`err;
            c];

        .qt.A[res;~;p[`eRes];"res";c];
        .util.testutils.revertOrders[];
    };
    {`cOrd`args`err`eRes!x};
    (
        ("Single ValidOrderIds (1) no error, success";(

        ));
        ("Single ValidOrderIds (1) error, fail";(

        ));
        ("Single ValidOrderIds (list) (1) error, fail";(

        ));
        ("Single ValidOrderIds (dict) error, fail";(

        ));
        ("Batch ValidOrderIds (4) no errors, all succeed";(

        ));
        ("Batch ValidOrderIds (4) errors, none succeed";(

        ));
        ("Batch ValidOrderIds (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];

.qt.Unit[
    ".engine.model.order.GetOrdersById";
    {[c]
        p:c[`params];
        .util.testutils.revertOrders[];
        .engine.model.account.NewOrders[p`cOrd];

        res:.util.testutils.checkErr[
            .engine.model.account.GetOrdersById;
            p`args;
            p`err;
            c];

        .qt.A[res;~;p[`eRes];"res";c];
        .util.testutils.revertOrders[];
    };
    {`cOrd`args`err`eRes!x};
    (
        ("Single GetOrdersById (1) no error, success";(

        ));
        ("Single GetOrdersById (1) error, fail";(

        ));
        ("Single GetOrdersById (list) (1) error, fail";(

        ));
        ("Single GetOrdersById (dict) error, fail";(

        ));
        ("Batch GetOrdersById (4) no errors, all succeed";(

        ));
        ("Batch GetOrdersById (4) errors, none succeed";(

        ));
        ("Batch GetOrdersById (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.model.order.ValidClientOrderIds";
    {[c]
        p:c[`params];
        .util.testutils.revertOrders[];
        .engine.model.account.NewOrders[p`cOrd];

        res:.util.testutils.checkErr[
            .engine.model.account.ValidClientOrderIds;
            p`args;
            p`err;
            c];

        .qt.A[res;~;p[`eRes];"res";c];
        .util.testutils.revertOrders[];
    };
    {`cOrd`args`err`eRes!x};
    (
        ("Single ValidClientOrderIds (1) no error, success";(

        ));
        ("Single ValidClientOrderIds (1) error, fail";(

        ));
        ("Single ValidClientOrderIds (list) (1) error, fail";(

        ));
        ("Single ValidClientOrderIds (dict) error, fail";(

        ));
        ("Batch ValidClientOrderIds (4) no errors, all succeed";(

        ));
        ("Batch ValidClientOrderIds (4) errors, none succeed";(

        ));
        ("Batch ValidClientOrderIds (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];

.qt.Unit[
    ".engine.model.order.GetOrdersByClientId";
    {[c]
        p:c[`params];
        .util.testutils.revertOrders[];
        .engine.model.account.NewOrders[p`cOrd];

        res:.util.testutils.checkErr[
            .engine.model.account.GetOrdersByClientId;
            p`args;
            p`err;
            c];

        .qt.A[res;~;p[`eRes];"res";c];
        .util.testutils.revertOrders[];
    };
    {`cOrd`args`err`eRes!x};
    (
        ("Single GetOrdersByClientId (1) no error, success";(

        ));
        ("Single GetOrdersByClientId (1) error, fail";(

        ));
        ("Single GetOrdersByClientId (list) (1) error, fail";(

        ));
        ("Single GetOrdersByClientId (dict) error, fail";(

        ));
        ("Batch GetOrdersByClientId (4) no errors, all succeed";(

        ));
        ("Batch GetOrdersByClientId (4) errors, none succeed";(

        ));
        ("Batch GetOrdersByClientId (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];

.qt.Unit[
    ".engine.model.order.GetOrdersByPrice";
    {[c]
        p:c[`params];
        .util.testutils.revertOrders[];
        .engine.model.account.NewOrders[p`cOrd];

        res:.util.testutils.checkErr[
            .engine.model.account.GetOrdersByPrice;
            p`args;
            p`err;
            c];

        .qt.A[res;~;p[`eRes];"res";c];
        .util.testutils.revertOrders[];
    };
    {`cOrd`args`err`eRes!x};
    (
        ("Single GetOrdersByPrice (1) no error, success";(

        ));
        ("Single GetOrdersByPrice (1) error, fail";(

        ));
        ("Single GetOrdersByPrice (list) (1) error, fail";(

        ));
        ("Single GetOrdersByPrice (dict) error, fail";(

        ));
        ("Batch GetOrdersByPrice (4) no errors, all succeed";(

        ));
        ("Batch GetOrdersByPrice (4) errors, none succeed";(

        ));
        ("Batch GetOrdersByPrice (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];

.qt.Unit[
    ".engine.model.order.GetOrdersBySide";
    {[c]
        p:c[`params];
        .util.testutils.revertOrders[];
        .engine.model.account.NewOrders[p`cOrd];

        res:.util.testutils.checkErr[
            .engine.model.account.GetOrdersBySide;
            p`args;
            p`err;
            c];

        .qt.A[res;~;p[`eRes];"res";c];
        .util.testutils.revertOrders[];
    };
    {`cOrd`args`err`eRes!x};
    (
        ("Single GetOrdersBySide (1) no error, success";(

        ));
        ("Single GetOrdersBySide (1) error, fail";(

        ));
        ("Single GetOrdersBySide (list) (1) error, fail";(

        ));
        ("Single GetOrdersBySide (dict) error, fail";(

        ));
        ("Batch GetOrdersBySide (4) no errors, all succeed";(

        ));
        ("Batch GetOrdersBySide (4) errors, none succeed";(

        ));
        ("Batch GetOrdersBySide (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.model.order.GetOrdersByAccountId";
    {[c]
        p:c[`params];
        .util.testutils.revertOrders[];
        .engine.model.account.NewOrders[p`cOrd];

        res:.util.testutils.checkErr[
            .engine.model.account.GetOrdersByAccountId;
            p`args;
            p`err;
            c];

        .qt.A[res;~;p[`eRes];"res";c];
        .util.testutils.revertOrders[];
    };
    {`cOrd`args`err`eRes!x};
    (
        ("Single GetOrdersByAccountId (1) no error, success";(

        ));
        ("Single GetOrdersByAccountId (1) error, fail";(

        ));
        ("Single GetOrdersByAccountId (list) (1) error, fail";(

        ));
        ("Single GetOrdersByAccountId (dict) error, fail";(

        ));
        ("Batch GetOrdersByAccountId (4) no errors, all succeed";(

        ));
        ("Batch GetOrdersByAccountId (4) errors, none succeed";(

        ));
        ("Batch GetOrdersByAccountId (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.model.order.GetInstrumentOrdersByAccountId";
    {[c]
        p:c[`params];
        .util.testutils.revertOrders[];
        .engine.model.account.NewOrders[p`cOrd];

        res:.util.testutils.checkErr[
            .engine.model.account.GetInstrumentOrdersByAccountId;
            p`args;
            p`err;
            c];

        .qt.A[res;~;p[`eRes];"res";c];
        .util.testutils.revertOrders[];
    };
    {`cOrd`args`err`eRes!x};
    (
        ("Single GetInstrumentOrdersByAccountId (1) no error, success";(

        ));
        ("Single GetInstrumentOrdersByAccountId (1) error, fail";(

        ));
        ("Single GetInstrumentOrdersByAccountId (list) (1) error, fail";(

        ));
        ("Single GetInstrumentOrdersByAccountId (dict) error, fail";(

        ));
        ("Batch GetInstrumentOrdersByAccountId (4) no errors, all succeed";(

        ));
        ("Batch GetInstrumentOrdersByAccountId (4) errors, none succeed";(

        ));
        ("Batch GetInstrumentOrdersByAccountId (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.model.order.RemoveOrdersByAccountId";
    {[c]
        p:c[`params];
        .util.testutils.revertOrders[];
        .engine.model.account.NewOrders[p`cOrd];

        res:.util.testutils.checkErr[
            .engine.model.account.RemoveOrdersByAccountId;
            p`args;
            p`err;
            c];
        
        .util.testutils.checkOrders[p`eRes;c;cols[p`eRes]];
        .qt.A[res;~;p[`eRes];"res";c];
        .util.testutils.revertOrders[];

    };
    {`cOrd`args`err`eRes!x};
    (
        ("Single RemoveOrdersByAccountId (1) no error, success";(

        ));
        ("Single RemoveOrdersByAccountId (1) error, fail";(

        ));
        ("Single RemoveOrdersByAccountId (list) (1) error, fail";(

        ));
        ("Single RemoveOrdersByAccountId (dict) error, fail";(

        ));
        ("Batch RemoveOrdersByAccountId (4) no errors, all succeed";(

        ));
        ("Batch RemoveOrdersByAccountId (4) errors, none succeed";(

        ));
        ("Batch RemoveOrdersByAccountId (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.model.order.RemoveInstrumentOrdersByAccountId";
    {[c]
        p:c[`params];
        .util.testutils.revertOrders[];
        .engine.model.account.NewOrders[p`cOrd];

        res:.util.testutils.checkErr[
            .engine.model.account.RemoveInstrumentOrdersByAccountId;
            p`args;
            p`err;
            c];
        
        .util.testutils.checkOrders[p`eRes;c;cols[p`eRes]];
        .qt.A[res;~;p[`eRes];"res";c];
        .util.testutils.revertOrders[];
    };
    {`cOrd`args`err`eRes!x};
    (
        ("Single RemoveInstrumentOrdersByAccountId (1) no error, success";(

        ));
        ("Single RemoveInstrumentOrdersByAccountId (1) error, fail";(

        ));
        ("Single RemoveInstrumentOrdersByAccountId (list) (1) error, fail";(

        ));
        ("Single RemoveInstrumentOrdersByAccountId (dict) error, fail";(

        ));
        ("Batch RemoveInstrumentOrdersByAccountId (4) no errors, all succeed";(

        ));
        ("Batch RemoveInstrumentOrdersByAccountId (4) errors, none succeed";(

        ));
        ("Batch RemoveInstrumentOrdersByAccountId (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.model.order.RemoveOrdersById";
    {[c]
        p:c[`params];
        .util.testutils.revertOrders[];
        .engine.model.account.NewOrders[p`cOrd];

        res:.util.testutils.checkErr[
            .engine.model.account.RemoveOrdersById;
            p`args;
            p`err;
            c];
        
        .util.testutils.checkOrders[p`eRes;c;cols[p`eRes]];
        .qt.A[res;~;p[`eRes];"res";c];
        .util.testutils.revertOrders[];
    };
    {`cOrd`args`err`eRes!x};
    (
        ("Single RemoveOrdersById (1) no error, success";(

        ));
        ("Single RemoveOrdersById (1) error, fail";(

        ));
        ("Single RemoveOrdersById (list) (1) error, fail";(

        ));
        ("Single RemoveOrdersById (dict) error, fail";(

        ));
        ("Batch RemoveOrdersById (4) no errors, all succeed";(

        ));
        ("Batch RemoveOrdersById (4) errors, none succeed";(

        ));
        ("Batch RemoveOrdersById (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.model.order.RemoveOrdersByClientId";
    {[c]
        p:c[`params];
        .util.testutils.revertOrders[];
        .engine.model.account.NewOrders[p`cOrd];

        res:.util.testutils.checkErr[
            .engine.model.account.RemoveOrdersByClientId;
            p`args;
            p`err;
            c];
        
        .util.testutils.checkOrders[p`eRes;c;cols[p`eRes]];
        .qt.A[res;~;p[`eRes];"res";c];
        .util.testutils.revertOrders[];
    };
    {`cOrd`args`err`eRes!x};
    (
        ("Single RemoveOrdersByClientId (1) no error, success";(

        ));
        ("Single RemoveOrdersByClientId (1) error, fail";(

        ));
        ("Single RemoveOrdersByClientId (list) (1) error, fail";(

        ));
        ("Single RemoveOrdersByClientId (dict) error, fail";(

        ));
        ("Batch RemoveOrdersByClientId (4) no errors, all succeed";(

        ));
        ("Batch RemoveOrdersByClientId (4) errors, none succeed";(

        ));
        ("Batch RemoveOrdersByClientId (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.model.order.PruneOrders";
    {[c]
        p:c[`params];
        .util.testutils.revertOrders[];
        .engine.model.account.NewOrders[p`cOrd];

        res:.util.testutils.checkErr[
            .engine.model.account.PruneOrders;
            p`args;
            p`err;
            c];
        
        .util.testutils.checkOrders[p`eRes;c;cols[p`eRes]];
        .qt.A[res;~;p[`eRes];"res";c];
        .util.testutils.revertOrders[];
    };
    {`cOrd`args`err`eRes!x};
    (
        ("Single PruneOrders (1) no error, success";(

        ));
        ("Single PruneOrders (1) error, fail";(

        ));
        ("Single PruneOrders (list) (1) error, fail";(

        ));
        ("Single PruneOrders (dict) error, fail";(

        ));
        ("Batch PruneOrders (4) no errors, all succeed";(

        ));
        ("Batch PruneOrders (4) errors, none succeed";(

        ));
        ("Batch PruneOrders (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.model.order.GetActiveLimitOrders";
    {[c]
        p:c[`params];
        .util.testutils.revertOrders[];
        .engine.model.account.NewOrders[p`cOrd];

        res:.util.testutils.checkErr[
            .engine.model.account.GetActiveLimitOrders;
            p`args;
            p`err;
            c];
        
        .qt.A[res;~;p[`eRes];"res";c];
        .util.testutils.revertOrders[];
    };
    {`cOrd`args`err`eRes!x};
    (
        ("Single GetActiveLimitOrders (1) no error, success";(

        ));
        ("Single GetActiveLimitOrders (1) error, fail";(

        ));
        ("Single GetActiveLimitOrders (list) (1) error, fail";(

        ));
        ("Single GetActiveLimitOrders (dict) error, fail";(

        ));
        ("Batch GetActiveLimitOrders (4) no errors, all succeed";(

        ));
        ("Batch GetActiveLimitOrders (4) errors, none succeed";(

        ));
        ("Batch GetActiveLimitOrders (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];


.qt.Unit[
    ".engine.model.order.GetActiveLimitOrdersBySide";
    {[c]
        p:c[`params];
        .util.testutils.revertOrders[];
        .engine.model.account.NewOrders[p`cOrd];

        res:.util.testutils.checkErr[
            .engine.model.account.GetActiveLimitOrdersBySide;
            p`args;
            p`err;
            c];
        
        .qt.A[res;~;p[`eRes];"res";c];
        .util.testutils.revertOrders[];
    };
    {`cOrd`args`err`eRes!x};
    (
        ("Single GetActiveLimitOrdersBySide (1) no error, success";(

        ));
        ("Single GetActiveLimitOrdersBySide (1) error, fail";(

        ));
        ("Single GetActiveLimitOrdersBySide (list) (1) error, fail";(

        ));
        ("Single GetActiveLimitOrdersBySide (dict) error, fail";(

        ));
        ("Batch GetActiveLimitOrdersBySide (4) no errors, all succeed";(

        ));
        ("Batch GetActiveLimitOrdersBySide (4) errors, none succeed";(

        ));
        ("Batch GetActiveLimitOrdersBySide (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];

.qt.Unit[
    ".engine.model.order.GetFilledOrders";
    {[c]
        p:c[`params];
        .util.testutils.revertOrders[];
        .engine.model.account.NewOrders[p`cOrd];

        res:.util.testutils.checkErr[
            .engine.model.account.GetFilledOrders;
            p`args;
            p`err;
            c];
        
        .qt.A[res;~;p[`eRes];"res";c];
        .util.testutils.revertOrders[];
    };
    {`cOrd`args`err`eRes!x};
    (
        ("Single GetFilledOrders (1) no error, success";(

        ));
        ("Single GetFilledOrders (1) error, fail";(

        ));
        ("Single GetFilledOrders (list) (1) error, fail";(

        ));
        ("Single GetFilledOrders (dict) error, fail";(

        ));
        ("Batch GetFilledOrders (4) no errors, all succeed";(

        ));
        ("Batch GetFilledOrders (4) errors, none succeed";(

        ));
        ("Batch GetFilledOrders (2) errors, (2) succeed";(

        ))
    );
    ({};{};{};{});
    "Global function for creating a new account"];
