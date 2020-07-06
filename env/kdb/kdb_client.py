import pyarrow as pa 
import pyarrow.parquet as pq 
import pandas as pd 
import time 
from qpython import qconnection
import json
import math
import logging
from itertools import groupby
import numpy as np

def _p(e):
    if len(e)>1: return "[]" 
    else: return ""

def _t(a):
    return list(map(list, zip(*a)))

class QueryConstructor():
    """
    This class is used to construct insert queries from
    grouped events either recieved from the engine 
    and its resultant events or a pipeline
    """
    def __init__(self, *args, **kwargs):
        self.qrys = []

    def __str__(self):
        seperation = """

        """
        return seperation.join(self.qrys)

    def _add(self, qry):
        self.qrys.append(qry)

    def add_depths(self, events):
        try:
            _t = lambda e: np.array(['"'+str(e.time)+'"'])
            # logging.error(list(e.datum.asks.items()))
            _a = lambda e: np.array([[str(i[0]), str(i[1])] for i in sorted(e.datum.asks.items(), key=lambda e: e[0])]).flatten()
            _b = lambda e: np.array([[str(i[0]), str(i[1])] for i in sorted(e.datum.bids.items(), key=lambda e: e[0], reverse=True)]).flatten()
            ev = np.array([np.concatenate([_t(e), _a(e), _b(e)]) for e in events]).transpose() 
            qry = "`depth insert("+"".join([
                _p(events)+'time:"Z"$('+"; ".join(ev[0]) + ");",
                "ask0_price:"+" ".join(ev[1]) + "f;",
                "ask1_price:"+" ".join(ev[2]) + "f;",
                "ask2_price:"+" ".join(ev[3]) + "f;",
                "ask3_price:"+" ".join(ev[4]) + "f;",
                "ask4_price:"+" ".join(ev[5]) + "f;",
                "ask5_price:"+" ".join(ev[6]) + "f;",
                "ask6_price:"+" ".join(ev[7]) + "f;",
                "ask7_price:"+" ".join(ev[8]) + "f;",
                "ask8_price:"+" ".join(ev[9]) + "f;",
                "ask9_price:"+" ".join(ev[10]) + "f;",
                "ask0_size:"+" ".join(ev[11]) + "f;",
                "ask1_size:"+" ".join(ev[12]) + "f;",
                "ask2_size:"+" ".join(ev[13]) + "f;",
                "ask3_size:"+" ".join(ev[14]) + "f;",
                "ask4_size:"+" ".join(ev[15]) + "f;",
                "ask5_size:"+" ".join(ev[16]) + "f;",
                "ask6_size:"+" ".join(ev[17]) + "f;",
                "ask7_size:"+" ".join(ev[18]) + "f;",
                "ask8_size:"+" ".join(ev[19]) + "f;",
                "ask9_size:"+" ".join(ev[20]) + "f;",
                "bid0_price:"+" ".join(ev[21]) + "f;",
                "bid1_price:"+" ".join(ev[22]) + "f;",
                "bid2_price:"+" ".join(ev[23]) + "f;",
                "bid3_price:"+" ".join(ev[24]) + "f;",
                "bid4_price:"+" ".join(ev[25]) + "f;",
                "bid5_price:"+" ".join(ev[26]) + "f;",
                "bid6_price:"+" ".join(ev[27]) + "f;",
                "bid7_price:"+" ".join(ev[28]) + "f;",
                "bid8_price:"+" ".join(ev[29]) + "f;",
                "bid9_price:"+" ".join(ev[30]) + "f;",
                "bid0_size:"+" ".join(ev[31]) + "f;",
                "bid1_size:"+" ".join(ev[32]) + "f;",
                "bid2_size:"+" ".join(ev[33]) + "f;",
                "bid3_size:"+" ".join(ev[34]) + "f;",
                "bid4_size:"+" ".join(ev[35]) + "f;",
                "bid5_size:"+" ".join(ev[36]) + "f;",
                "bid6_size:"+" ".join(ev[37]) + "f;",
                "bid7_size:"+" ".join(ev[38]) + "f;",
                "bid8_size:"+" ".join(ev[39]) + "f;",
                "bid9_size:"+" ".join(ev[40]) + "f",
                ]) + ");"

            logging.error(qry)
            self._add(qry)
        except Exception as e:
            logging.error(e)
            logging.exception(e)
            logging.error([e for e in events[0].datum.asks.items()])

    def add_trades(self, events): 
        ev = _t([[
           '"'+str(e.time)+'"', 
            '`'+str(e.datum.side), 
            str(float(e.datum.size)), 
            str(float(e.datum.price))
        ] for e in events])
        self._add("`trades insert("+"".join([
        _p(events)+'time:"Z"$('+"; ".join(ev[0]) + ");",
        "side:"+"".join(ev[1]) + ";",
        "size:"+" ".join(ev[2]) + "f;",
        "price:"+" ".join(ev[3]) + "f"
        ]) + ");")

    def add_fundings(self, events):
        ev = _t([[
            '"'+str(e.time)+'"', 
            str(e.datum.funding_rate), 
            '"'+str(e.datum.next_funding_time)+'"'
        ] for e in events])
        self._add("`funding insert("+"".join([
        _p(events)+'time:"Z"$('+"; ".join(ev[0]) + ");",
        "funding_rate:"+"".join(ev[1])+"f;",
        'next_funding_time:"Z"$('+"; ".join(ev[2]) + ")",
        ]) + ");")

    def add_marks(self, events):
        ev = _t([[
            '"'+str(e.time)+'"', 
            str(e.datum.mark_price)
        ] for e in events])
        self._add("`mark insert("+"".join([
        _p(events)+'time:"Z"$('+"; ".join(ev[0]) + ");",
        "mark_price:"+"".join(ev[1])+"f",
        ]) + ");")

    # TODO format resp
    def add_orders(self, events):
        ev = _t([[
            '"'+str(e.time)+'"', 
            '`'+str(e.datum.side), 
            str(e.datum.size),
            str(e.datum.price) if hasattr(e, "price") else "0",
            str(e.datum.stop_price) if hasattr(e, "stop_price") else "0",
            str(e.datum.limit_price) if hasattr(e, "limit_price") else "0",
            str(e.datum.leaves) if hasattr(e, "limit_price") else "0",
            str(e.datum.filled) if hasattr(e, "limit_price") else "0",
            '`'+(str(e.datum.trigger) if hasattr(e, "trigger") else "none"),
            '`'+str(e.datum.typ),
            '`'+str(e.datum.status),
            '`'+str(e.datum.id), 
        ] for e in events])
        self._add("`orders insert("+"".join([
            _p(events)+'time:"Z"$('+"; ".join(ev[0]) + ");",
            "order_id:"+"".join(ev[9]) + ";",
            "side:"+"".join(ev[1]) + ";",
            "size:"+"".join(ev[2])+"f;",
            "price:"+"".join(ev[3])+"f;",
            "stop_price:"+"".join(ev[4])+"f;",
            "limit_price:"+"".join(ev[5])+"f;",
            "leaves:"+"".join(ev[6])+"f;",
            "filled:"+"".join(ev[7])+"f;",
            "trigger:"+"".join(ev[8]) + ";",
            "ordtyp:"+"".join(ev[9]) + ";",
            "status:"+"".join(ev[10]),
        ]) + ");")

    def add_positions(self, events):
        ev = _t([[
            '"'+str(e.time)+'"', 
            '`'+str(e.datum.side),
            str(e.datum.amount),
            str(e.datum.average_entry_price),
            str(e.datum.leverage),
            str(e.datum.realized_pnl),
            str(e.datum.unrealized_pnl)
        ] for e in events])
        self._add("`positions insert("+"".join([
        _p(events)+'time:"Z"$('+"; ".join(ev[0]) + ");",
        "side:"+"".join(ev[1]) + ";",
        "amount:"+" ".join(ev[2]) + "f;",
        "average_entry_price:"+" ".join(ev[3]) + "f;",
        "leverage:"+" ".join(ev[4]) + "f;",
        "realized_pnl:"+" ".join(ev[5]) + "f;",
        "unrealized_pnl:"+" ".join(ev[6]) + "f",
        ]) + ");")

    def add_accounts(self, events):
        ev = _t([[
            '"'+str(e.time)+'"', 
            str(e.datum.balance),
            str(e.datum.frozen),
            str(e.datum.maint_margin),
            str(e.datum.available_balance)
        ] for e in events])
        self._add("`account insert("+"".join([
        _p(events)+'time:"Z"$('+"; ".join(ev[0]) + ");",
        "balance:"+"".join(ev[1]) + "f;",
        "frozen:"+" ".join(ev[2]) + "f;",
        "maint_margin:"+" ".join(ev[3]) + "f;",
        "available_balance:"+" ".join(ev[4]) + "f"
        ]) + ");")

    def add_instruments(self, events):
        raise NotImplementedError

    def add_features(self, events):
        ev = _t([[
            '"'+str(e.time)+'"', 
            '`'+str(e.datum.fid),
            str(e.datum.value), 
        ] for e in events])
        self._add("`features insert("+"".join([
        _p(events)+'time:"Z"$('+"; ".join(ev[0]) + ");",
        "fid:"+"".join(ev[1]) + ";",
        "val:"+" ".join(ev[2]) + "f"
        ]) + ");")


class KDBClient():
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.host = kwargs.get('host', "localhost")
        self.port = kwargs.get('port', 5050)

    def _exec(self, qry, pandas=True):
        with qconnection.QConnection(host = self.host, port=self.port, pandas=pandas, numpy_temporals = True) as q:
            data = q.sendSync(qry)
            return data

    # TODO parser
    def exec(self, qry, parse_events=False, parser=None, pandas=True):
        data = self._exec(qry, pandas=pandas)
        if parser is not None and not parse_events:
            pass

        elif parse_events:
            pass

        return data

    def init(self):
        create_str = ""
        seperation = """

        """
        qry = seperation.join([
            """depth:(
                []time:`datetime$();
                ask0_price:`float$();
                ask0_size:`float$();
                ask1_price:`float$();
                ask1_size:`float$();
                ask2_price:`float$();
                ask2_size:`float$();
                ask3_price:`float$();
                ask3_size:`float$();
                ask4_price:`float$();
                ask4_size:`float$();
                ask5_price:`float$();
                ask5_size:`float$();
                ask6_price:`float$();
                ask6_size:`float$();
                ask7_price:`float$();
                ask7_size:`float$();
                ask8_price:`float$();
                ask8_size:`float$();
                ask9_price:`float$();
                ask9_size:`float$();
                bid0_price:`float$();
                bid0_size:`float$();
                bid1_price:`float$();
                bid1_size:`float$();
                bid2_price:`float$();
                bid2_size:`float$();
                bid3_price:`float$();
                bid3_size:`float$();
                bid4_price:`float$();
                bid4_size:`float$();
                bid5_price:`float$();
                bid5_size:`float$();
                bid6_price:`float$();
                bid6_size:`float$();
                bid7_price:`float$();
                bid7_size:`float$();
                bid8_price:`float$();
                bid8_size:`float$();
                bid9_price:`float$();
                bid9_size:`float$()
            );""",
            """trades:(
                []time:`datetime$();
                side:`symbol$();
                size:`float$();
                price:`float$()
            );""",
            """funding:(
                []time:`datetime$();
                funding_rate:`float$();
                next_funding_time:`datetime$()
            );""",
            """mark:(
                []time:`datetime$();
                mark_price:`float$()
            );""",
            """positions:(
                []time:`datetime$();
                side:`symbol$();
                amount:`float$();
                average_entry_price:`float$();
                leverage:`float$();
                realized_pnl:`float$();
                unrealized_pnl:`float$() 
            );""",
            """account:(
                []time:`datetime$();
                balance:`float$();
                frozen:`float$();
                maint_margin:`float$();
                available_balance:`float$()
            );""",
            """orders:(
                []time:`datetime$();
                order_id:`symbol$();
                side:`symbol$();
                size:`float$();
                price:`float$();
                stop_price:`float$();
                limit_price:`float$();
                leaves:`float$();
                filled:`float$();
                trigger:`symbol$();
                ordtyp:`symbol$();
                status:`symbol$()
            );""",
            """features:(
                []time:`datetime$();
                fid:`symbol$();
                val:`float$()
            );""",
        ])
        self._exec(qry)
        
    def destruct(self):
        qry = """

        """
        self._exec(qry)

    def new_qry(self):
        return QueryConstructor()

    def insert_events(self, events, raise_errors=True):
        grouped_events = {k:list(it) for k, it in groupby(
            events, 
            lambda e: e.typ
        )}
        qry = self.new_qry()
        for k, e in grouped_events.items():
            try:
                if k.is_depth: qry.add_depths(e)
                elif k.is_trade: qry.add_trades(e) 
                elif k.is_funding: qry.add_fundings(e)
                elif k.is_mark: qry.add_marks(e)
                elif k.is_order_update: qry.add_orders(e)
                elif k.is_position_update: qry.add_positions(e)
                elif k.is_account_update: qry.add_accounts(e)
                elif k.is_instrument_update: qry.add_instruments(e)
                elif k.is_feature: qry.add_features(e)
            except Exception as e:
                logging.error(k)
                logging.error(e)
                logging.error(e)
                logging.exception(e)
                if raise_errors:raise e

        try:
            qry = str(qry)
            self.exec(qry)
        except Exception as e:
            logging.error(k)
            logging.error(e)
            logging.error(e)
            logging.exception(e)
            if raise_errors:raise e

    # State based requesting
    # ======================================================================>

    def _position_from_data(self, data):
        """
        Formats the data recieved from a query into it's associated
        representation class.
        """
        return PositionR(
            side=PositionSide.from_str(data[1].decode("utf-8")),
            amount=data[2],
            average_entry_price=data[3],
            leverage=data[4],
            realized_pnl=data[5],
            unrealized_pnl=data[6]
        )

    # 
    # TODO cache
    def get_long_position(self):
        data = self.exec("select by time from positions where side=`long")   
        data = data.to_records()
        if len(data)>0:
            return self._position_from_data(data[0]), True
        else:
            return None, False

    # TODO cache
    def get_short_position(self):
        data = self.exec("select by time from positions where side=`short")  
        data = data.to_records()
        if len(data)>0:
            return self._position_from_data(data[0]), True
        else:
            return None, False

    # TODO make simpler
    def get_both_position(self):
        data = self.exec("select by time from positions where side=`both")  
        data = data.to_records()
        if len(data)>0:
            return self._position_from_data(data[0]), True
        else:
            return None, False

    # TODO cache
    def get_all_positions(self):
        data = self.exec("select by side, time from positions")  
        return [self._position_from_data(d) for d in data.to_records()]

    # TODO cache
    def get_account(self):
        data = self.store.exec("0")  
        logging.error(data)

    # TODO cache
    def get_limit_orders(self):
        data = self.store.exec("select by orderid from orders where ordtyp=`limit, status=`new |\ status=`partially_filled")
        logging.error(data)

    # TODO cache
    def get_stop_limit_orders(self):
        data = self._exec("""select by orderid from orders where ordtyp=`stop_limit, status=`untriggered""")
        logging.error(data)

    # TODO cache
    def get_stop_limit_orders(self):
        data = self._exec("""select by orderid from orders where ordtyp=`stop_limit, status=`untriggered""")
        logging.error(data)