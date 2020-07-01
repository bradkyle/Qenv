import asyncio
import random
import uuid
import time
import pytest 
from env.engine.orderbook import OrderBook
from env.engine.account import Account, FeeType, FlatFee, TieredFee, MarginType, PositionType
from env.models import LimitOrder, Side, Depth
from unittest.mock import patch
import time
import numpy as np
from datetime import datetime

_time1 = time.time()
TEST_TIME = np.datetime64(datetime.now())

# -----------------------
# TODO test rollout     |
# TODO test performance |
# ----------------------

class TLimitOrder(LimitOrder):
    def __init__(self, side, order_id, price, size):
        self.tside = side 
        self.torder_id = order_id 
        self.tprice = price 
        self.tsize = size
        LimitOrder.__init__(
            self,
            side=side,
            order_id=order_id,
            price=price,
            size=size
        )

    def __call__(self):
        self.reset()

    def reset(self, side=None, order_id=None, price=None, size=None):
        self.side=side if side!=None else self.tside 
        self.order_id=order_id if order_id!=None else self.torder_id
        self.price=price if price!=None else self.tprice
        self.size=size if size!=None else self.tsize
        return self

class TAccount(Account):
    def __init__(self, **kwargs):
        Account.__init__(
            self,
            **kwargs
        )
    
    def add_limit_order(self, side, price, size):
        pass

    def add_market_order(self, side, size):
        pass

_account1 = TAccount()

_sell1 = TLimitOrder(side=Side.SELL, order_id="test1", price=100.5, size=100)
_sell2 = TLimitOrder(side=Side.SELL, order_id="test2", price=100.5, size=100)
_buy1 = TLimitOrder(side=Side.BUY, order_id="test1buy", price=100, size=100)
_buy2 = TLimitOrder(side=Side.BUY, order_id="test2buy", price=100, size=100)

# TODO 0 agent orders
cases = {
    "ASK: No amount is removed from agent offset because the execution was not on the agents price level" : {
        "orderbook_args": {
            "tick_size": 0.5,
            "num_lvls": 10,
            "ask_lvl_qtys": {100.5: 1000, 101: 1000},
            "agent_orders": {_sell1.id: _sell1.reset(size=100, price=101)},
            "agent_ask_offsets": {_sell1.offset_id: 900},
            "agent_ask_qtys": {_sell1.qty_id: 100},
        },
        "exec": {
            "side": Side.SELL,
            "amount": 100,
            "price": 100.5
        },
        "expected": {
            "agent_ask_offsets": {_sell1.offset_id: 900},
        }
    },
    "ASK: Amount is removed from agent that is less than the agents offset" : {
        "orderbook_args": {
            "tick_size": 0.5,
            "num_lvls": 10,
            "ask_lvl_qtys": {100.5: 1000, 101: 1000},
            "agent_orders": {_sell1.id: _sell1.reset(size=100, price=100.5)},
            "agent_ask_offsets": {_sell1.offset_id: 900},
            "agent_ask_qtys": {_sell1.qty_id: 100},
        },
        "exec": {
            "side": Side.SELL,
            "amount": 100,
            "price": 100.5
        },
        "expected": {
            "agent_ask_offsets": {_sell1.offset_id: 800},
        }
    },
    "ASK: Amount is removed from agent that is greater than the agents offset" : {
        "orderbook_args": {
            "tick_size": 0.5,
            "num_lvls": 10,
            "ask_lvl_qtys": {100.5: 1000, 101: 1000},
            "agent_orders": {_sell1.id: _sell1.reset(size=100, price=100.5)},
            "agent_ask_offsets": {_sell1.offset_id: 100},
            "agent_ask_qtys": {_sell1.qty_id: 100},
        },
        "exec": {
            "side": Side.SELL,
            "amount": 200,
            "price": 100.5
        },
        "expected": {
            "agent_ask_offsets": {_sell1.offset_id: 0},
        }
    },
    "BID: No amount is removed from agent offset because the execution was not on the agents price level" : {
        "orderbook_args": {
            "tick_size": 0.5,
            "num_lvls": 10,
            "bid_lvl_qtys": {100.5: 1000, 100: 1000},
            "agent_orders": {_buy1.id: _buy1.reset(size=100, price=100.5)},
            "agent_bid_offsets": {_buy1.offset_id: 900},
            "agent_bid_qtys": {_buy1.qty_id: 900},
        },
        "exec": {
            "side": Side.BUY,
            "amount": 200,
            "price": 100
        },
        "expected": {
            "agent_bid_offsets": {_buy1.offset_id: 900},
        }
    },
    "BID: Amount is removed from agent that is less than the agents offset" : {
        "orderbook_args": {
            "tick_size": 0.5,
            "num_lvls": 10,
            "bid_lvl_qtys": {100.5: 1000, 100: 1000},
            "agent_orders": {_buy1.id: _buy1.reset(size=100, price=100.5)},
            "agent_bid_offsets": {_buy1.offset_id: 900},
            "agent_bid_qtys": {_buy1.qty_id: 100},
        },
        "exec": {
            "side": Side.BUY,
            "amount": 100,
            "price": 100.5
        },
        "expected": {
            "agent_bid_offsets": {_buy1.offset_id: 800},
        }
    },
    "BID: Amount is removed from agent that is greater than the agents offset" : {
        "orderbook_args": {
            "tick_size": 0.5,
            "num_lvls": 10,
            "bid_lvl_qtys": {100.5: 1000, 100: 1000},
            "agent_orders": {_buy1.id: _buy1.reset(size=100, price=100.5)},
            "agent_bid_offsets": {_buy1.offset_id: 100},
            "agent_bid_qtys": {_buy1.qty_id: 100},
        },
        "exec": {
            "side": Side.BUY,
            "amount": 200,
            "price": 100.5
        },
        "expected": {
            "agent_bid_offsets": {_buy1.offset_id: 0},
        }
    },
}
@pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
def test_decrement_offsets(monkeypatch, case):
    orderbook = OrderBook(
        account=_account1,
        **case["orderbook_args"]
    )

    orderbook._decrement_offsets(**case["exec"])

    if "mocks" in case:
        for m,v in case["mocks"].items():
            def get_value(self):return v
            monkeypatch.setattr(OrderBook, m, property(get_value))

    ex = case["expected"]
    for e in ex.items():
        assert getattr(orderbook, e[0]) == e[1]


# TODO 0 agent orders
cases = {
    "BID: Amount is removed from agent that is greater than the agents offset" : {
        "orderbook_args": {
            "tick_size": 0.5,
            "num_lvls": 10,
            "bid_lvl_qtys": {100.5: 1000, 100: 1000},
            "agent_orders": {_buy1.id: _buy1.reset(size=100, price=100.5)},
            "agent_bid_offsets": {_buy1.offset_id: 100},
            "agent_bid_qtys": {_buy1.qty_id: 100},
        },
        "exec": {
            "side": Side.BUY,
            "amount": 200,
            "price": 100.5
        },
        "expected": {
            "agent_bid_offsets": {_buy1.offset_id: 0},
        }
    },
}
@pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
def test_premium(monkeypatch, case):
    orderbook = OrderBook(
        account=_account1,
        **case["orderbook_args"]
    )

    orderbook._decrement_offsets(**case["exec"])

    if "mocks" in case:
        for m,v in case["mocks"].items():
            def get_value(self):return v
            monkeypatch.setattr(OrderBook, m, property(get_value))

    ex = case["expected"]
    for e in ex.items():
        assert getattr(orderbook, e[0]) == e[1]



# TODO insert over max num levels
# TODO test agent inserts
# TODO test tick size
# TODO test agent and non agent
# TODO test bad prices 
# TODO add attrs
# TODO test cross book
# TODO test offset
# TODO test new_fill called and returned
cases = {
    "insert simple ask_non_agent" : {
        "tick_size": 0.5,
        "num_lvls": 10,
        "ask_lvl_qtys": {},
        "bid_lvl_qtys": {},
        "limits" : [{
            "order_id": _sell1.id,
            "price": 100,
            "size": 100,
            "is_agent": False,
            "side": Side.SELL
        }],
        "expected": {
            "ask_lvl_qtys": {100: 100},
            "bid_lvl_qtys": {}
        }
    },
    "insert simple bid non_agent" : {
        "tick_size": 0.5,
        "num_lvls": 10,
        "ask_lvl_qtys": {},
        "bid_lvl_qtys": {},
        "limits" : [{
            "order_id": _sell1.id,
            "price": 100,
            "size": 100,
            "is_agent": False,
            "side": Side.BUY
        }],
        "expected": {
            "ask_lvl_qtys": {},
            "bid_lvl_qtys": {100: 100},
        }
    },
    "insert simple ask agent" : {
        "tick_size": 0.5,
        "num_lvls": 10,
        "ask_lvl_qtys": {},
        "bid_lvl_qtys": {},
        "limits" : [{
            "order_id": _sell1.id,
            "price": 100,
            "size": 100,
            "is_agent": True,
            "side": Side.SELL
        }],
        "expected": {
            "ask_lvl_qtys": {100: 100},
            "bid_lvl_qtys": {},
            "agent_ask_offsets": {(100, _sell1.id):0},
            "agent_bid_offsets": {},
            "agent_ask_qtys": {(100, _sell1.id):100},
            "agent_bid_qtys": {},
            "agent_buy_open_qty": 0,
            "agent_sell_open_qty": 100,
            "spread": None,
            "best_ask_price": 100,
            "best_bid_price": None
        },
        "expected_oid": 1
    },
    "insert simple bid agent" : {
        "tick_size": 0.5,
        "num_lvls": 10,
        "ask_lvl_qtys": {},
        "bid_lvl_qtys": {},
        "limits" : [{
            "order_id": _sell1.id,
            "price": 100,
            "size": 100,
            "is_agent": True,
            "side": Side.BUY
        }],
        "expected": {
            "bid_lvl_qtys": {100: 100},
            "ask_lvl_qtys": {},
            "agent_bid_offsets": {(100, _sell1.id):0},
            "agent_ask_offsets": {},
            "agent_bid_qtys": {(100, _sell1.id):100},
            "agent_ask_qtys": {},
            "agent_sell_open_qty": 0,
            "agent_buy_open_qty": 100,
            "spread": None,
            "best_bid_price": 100,
            "best_ask_price": None,
        },
        "expected_oid": 1
    },
    "insert simple bid and ask agent" : {
        "tick_size": 0.5,
        "num_lvls": 10,
        "ask_lvl_qtys": {},
        "bid_lvl_qtys": {},
        "limits" : [{
            "order_id": _sell1.id,
            "price": 100,
            "size": 100,
            "is_agent": True,
            "side": Side.BUY
        },{
            "order_id": _sell2.id,
            "price": 101,
            "size": 100,
            "is_agent": True,
            "side": Side.SELL
        }],
        "expected": {
            "bid_lvl_qtys": {100: 100},
            "ask_lvl_qtys": {101: 100},
            "agent_bid_offsets": {(100, _sell1.id):0},
            "agent_ask_offsets": {(101, _sell2.id):0},
            "agent_bid_qtys": {(100, _sell1.id):100},
            "agent_ask_qtys": {(101, _sell2.id):100},
            "agent_sell_open_qty": 100,
            "agent_buy_open_qty": 100,
            "spread": 1,
            "best_bid_price": 100,
            "best_ask_price": 101,
        },
        "expected_oid": 1
    },
    "insert multiple on one level agent asks" : {
        "tick_size": 0.5,
        "num_lvls": 10,
        "ask_lvl_qtys": {},
        "bid_lvl_qtys": {},
        "limits" : [{
            "order_id": _sell1.id,
            "price": 100,
            "size": 100,
            "is_agent": True,
            "side": Side.SELL
        },{
            "order_id": _sell2.id,
            "price": 100,
            "size": 100,
            "is_agent": True,
            "side": Side.SELL
        }],
        "expected": {
            "bid_lvl_qtys": {},
            "ask_lvl_qtys": {100: 200},
            "agent_bid_offsets": {},
            "agent_ask_offsets": {(100, _sell1.id):0, (100, _sell2.id):100},
            "agent_bid_qtys": {},
            "agent_ask_qtys": {(100, _sell1.id):100, (100, _sell2.id):100},
            "agent_sell_open_qty": 200,
            "agent_buy_open_qty": 0,
            "spread": None,
            "best_bid_price": None,
            "best_ask_price": 100,
        },
        "expected_oid": 1
    },
    "insert test ask offset agent and non agent" : {
        "tick_size": 0.5,
        "num_lvls": 10,
        "ask_lvl_qtys": {},
        "bid_lvl_qtys": {},
        "limits" : [{
            "order_id": _sell1.id,
            "price": 100,
            "size": 100,
            "side": Side.SELL
        },{
            "order_id": _sell2.id,
            "price": 100,
            "size": 100,
            "is_agent": True,
            "side": Side.SELL
        }],
        "expected": {
            "bid_lvl_qtys": {},
            "ask_lvl_qtys": {100: 200},
            "agent_bid_offsets": {},
            "agent_ask_offsets": {(100, _sell2.id):100},
            "agent_bid_qtys": {},
            "agent_ask_qtys": {(100, _sell2.id):100},
            "agent_sell_open_qty": 100,
            "agent_buy_open_qty": 0,
            "spread": None,
            "best_bid_price": None,
            "best_ask_price": 100,
        },
        "expected_oid": 1
    },
    "insert test bid offset agent and non agent" : {
        "tick_size": 0.5,
        "num_lvls": 10,
        "ask_lvl_qtys": {},
        "bid_lvl_qtys": {},
        "limits" : [{
            "order_id": _sell1.id,
            "price": 100,
            "size": 100,
            "side": Side.BUY
        },{
            "order_id": _sell2.id,
            "price": 100,
            "size": 100,
            "is_agent": True,
            "side": Side.BUY
        }],
        "expected": {
            "ask_lvl_qtys": {},
            "bid_lvl_qtys": {100: 200},
            "agent_ask_offsets": {},
            "agent_bid_offsets": {(100, _sell2.id):100},
            "agent_ask_qtys": {},
            "agent_bid_qtys": {(100, _sell2.id):100},
            "agent_buy_open_qty": 100,
            "agent_sell_open_qty": 0,
            "spread": None,
            "best_ask_price": None,
            "best_bid_price": 100,
        },
        "expected_oid": 1
    },
}
@pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
def test_new_limit(monkeypatch, case):
    orderbook = OrderBook(
        account=_account1,
        tick_size=case["tick_size"],
        num_levels=case["num_lvls"]
    )

    for l in case["limits"]:
        order_id, trades = orderbook.new_limit_order(**l, time=TEST_TIME)

    if "mocks" in case:
        for m,v in case["mocks"].items():
            def get_value(self):return v
            monkeypatch.setattr(OrderBook, m, property(get_value))

    ex = case["expected"]
    for e in ex.items():
        assert getattr(orderbook, e[0]) == e[1]

    if "trades" in case:
        pass


# TODO test without asks
# TODO offsets + price
# TODO offset 0
# TODO offset becomes greater
cases = {
    # Considering the premise that the depth updates on
    # account of trades are already represented, trades
    # should only be represented when there are agent orders
    # present.
    "buy simple market" : {
        "tick_size": 0.5,
        "num_lvls": 10,
        "ask_lvl_qtys": {100.5: 1000}, 
        "bid_lvl_qtys": {100: 1000},
        "markets" : [{
            "qtyToTrade": 100
        },{
            "qtyToTrade": 100,
        }],
        "expected": {
            "ask_lvl_qtys": {100.5: 1000},
            "bid_lvl_qtys": {100: 1000},
            "agent_ask_offsets": {},
            "agent_bid_offsets": {},
            "agent_ask_qtys": {},
            "agent_bid_qtys": {},
            "agent_buy_open_qty": 0,
            "agent_sell_open_qty": 0,
            "spread": 0.5,
            "best_ask_price": 100.5,
            "best_bid_price": 100,
        },
        "expected_oid": 1,
    },
    "buy simple market agent" : {
        "tick_size": 0.5,
        "num_lvls": 10,
        "ask_lvl_qtys": {100.5: 1000},
        "bid_lvl_qtys": {100: 1000},
        "markets" : [{
            "qtyToTrade": 100,
            "is_agent": True
        },{
            "qtyToTrade": 100,
            "is_agent": True
        }],
        "expected": {
            "ask_lvl_qtys": {100.5: 800},
            "bid_lvl_qtys": {100: 1000},
            "agent_ask_offsets": {},
            "agent_bid_offsets": {},
            "agent_ask_qtys": {},
            "agent_bid_qtys": {},
            "agent_buy_open_qty": 0,
            "agent_sell_open_qty": 0,
            "spread": 0.5,
            "best_ask_price": 100.5,
            "best_bid_price": 100,
        },
        "expected_oid": 1,
    },
    "buy simple market agent with agent orders not overlapping offset>fill does not decrease agent orders at level" : {
        "tick_size": 0.5,
        "num_lvls": 10,
        "ask_lvl_qtys": {100.5: 1000},
        "bid_lvl_qtys": {100: 1000},
        "agent_orders": {_sell1.id: _sell1.reset()},
        "agent_ask_offsets": {_sell1.offset_id: 900},
        "agent_ask_qtys": {_sell1.qty_id: 100},
        "markets" : [{
            "qtyToTrade": 100,
            "is_agent": True
        },{
            "qtyToTrade": 100,
            "is_agent": True
        }],
        "expected": {
            "has_agent_asks": True,
            "has_agent_bids": False,
            "ask_lvl_qtys": {100.5: 800},
            "bid_lvl_qtys": {100: 1000},
            "agent_orders": {_sell1.id: _sell1},
            "agent_ask_qtys": {_sell1.qty_id: 100},
            "agent_ask_offsets": {_sell1.offset_id: 700},
            "agent_bid_offsets": {},
            "agent_bid_qtys": {},
            "agent_buy_open_qty": 0,
            "agent_sell_open_qty": 100,
            "spread": 0.5,
            "best_ask_price": 100.5,
            "best_bid_price": 100,
        },
        "expected_oid": 1,
    },
    "buy simple market agent with agent orders partially overlapping offset<fill<offset+size": {
        "setup": _sell1.reset(),
        "tick_size": 0.5,
        "num_lvls": 10,
        "ask_lvl_qtys": {100.5: 250},
        "bid_lvl_qtys": {100: 1000},
        "agent_orders": {_sell1.id: _sell1},
        "agent_ask_offsets": {_sell1.offset_id: 150},
        "agent_ask_qtys": {_sell1.qty_id: 100},
        "agent_order_margins": {_sell1.id: 1},
        "markets" : [{
            "qtyToTrade": 100,
            "is_agent": True
        },{
            "qtyToTrade": 100,
            "is_agent": True
        }],
        "expected": {
            "has_agent_asks": True,
            "has_agent_bids": False,
            "ask_lvl_qtys": {100.5: 50},
            "bid_lvl_qtys": {100: 1000},
            "agent_orders": {_sell1.id: _sell1},
            "agent_ask_offsets":  {_sell1.offset_id: 0},
            "agent_bid_offsets": {},
            "agent_ask_qtys": {_sell1.qty_id: 50},
            "agent_bid_qtys": {},
            "agent_buy_open_qty": 0,
            "agent_sell_open_qty": 50,
            "spread": 0.5,
            "best_ask_price": 100.5,
            "best_bid_price": 100,
        },
        "expected_oid": 1,
    },
}
@pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
def test_fill_buy(monkeypatch, case):
    if "setup" in case:
        case["setup"]()

    orderbook = OrderBook(
        account=_account1,
        tick_size=case["tick_size"],
        num_levels=case["num_lvls"],
        ask_lvl_qtys=case["ask_lvl_qtys"],
        bid_lvl_qtys=case["bid_lvl_qtys"],
        agent_orders=case["agent_orders"] if "agent_orders" in case else {},
        agent_ask_offsets=case["agent_ask_offsets"] if "agent_ask_offsets" in case else {},
        agent_bid_offsets=case["agent_bid_offsets"] if "agent_bid_offsets" in case else {},
        agent_ask_qtys=case["agent_ask_qtys"] if "agent_ask_qtys" in case else {},
        agent_bid_qtys=case["agent_bid_qtys"] if "agent_bid_qtys" in case else {},
        agent_order_margins=case["agent_order_margins"] if "agent_order_margins" in case else {}
    ) 

    for l in case["markets"]:
        order_id, trades = orderbook._fill_buy(**l, time=TEST_TIME)

    ex = case["expected"]
    for e in ex.items():
        if not getattr(orderbook, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(orderbook, e[0]))+"!="+str(e[1]))

    if "trades" in case:
        pass

# TODO multiple orders differing levels and differing order counts
# TODO no offsets
# TODO zero offsets on both ends
# TODO zero quantity
# TODO delta greater than agent orders #TODO return ask count
cases = {
    "1 order at 1 level": {
        "params":{
            "lvl_qtys": [1500],
            "lvl_deltas": [-100],
            "lvl_sizes": np.array([100]).reshape(1,1),
            "lvl_offsets": np.array([100]).reshape(1,1)
        },
        "expected":{
            "new_offsets": np.array([
                [93]
            ]),
            "derived_deltas": np.array([
                [-7.]
            ])
        },
        "do_benchmark": False
    },
    "3 orders at one level": {
        "params":{
            "lvl_qtys": [1500],
            "lvl_deltas": [-100],
            "lvl_sizes": np.array([100, 100, 100]).reshape(1,3),
            "lvl_offsets": np.array([100, 500, 1000]).reshape(1,3)
        },
        "expected":{
            "new_offsets": np.array([
                [92., 475., 967.]
            ]),
            "derived_deltas": np.array([
                [-8., -25., -33.]
            ])
        },
        "do_benchmark": False
    },
    "1 order at 3 different levels and differing offsets": {
        "params":{
            "lvl_qtys": [1500, 1500, 1500],
            "lvl_deltas": [-100, -100, -100],
            "lvl_sizes": np.array([100, 100, 100]).reshape(3,1),
            "lvl_offsets": np.array([100, 500, 1000]).reshape(3,1)
        },
        "expected":{
            "new_offsets": np.array([
                [93],
                [464],
                [929]
            ]),
            "derived_deltas": np.array([
                [-7.],
                [-36.],
                [-71.]
            ])
        },
        "do_benchmark": False
    },
    "3 orders of different quantities at 3 different levels and differing offsets": {
        "params":{
            "lvl_qtys": [1500, 1500, 1500],
            "lvl_deltas": [-100, -100, -100],
            "lvl_sizes": [[100, 200, 300], [100, 200, 300], [100, 200, 300]],
            "lvl_offsets": [[100, 300, 700], [100, 300, 700], [100, 300, 700]]
        },
        "expected":{
            "new_offsets": np.array([
            [ 89., 289., 678.],
            [ 89., 289., 678.],
            [ 89., 289., 678.]
            ]),
            "derived_deltas": np.array([
                [-11., -11., -22.],
                [-11., -11., -22.],
                [-11., -11., -22.]
            ])
        },
        "do_benchmark": False
    },
    "mixed orders of different quantities at 3 different levels and differing offsets": { # TODO fix not working
        "params":{
            "lvl_qtys": [1500, 1500, 1500],
            "lvl_deltas": [-100, -100, -100],
            "lvl_sizes": [[100, 200, 300, 100], [100, 200, 300], [100, 200, 300]],
            "lvl_offsets": [[100, 300, 700, 1200], [100, 300, 700], [100, 300, 700]]
        },
        "expected":{
            "new_offsets": np.array([
                [  88.,  288.,  675., 1175.],
                [  95.,  295.,  689.,    0.], # offsets less because of the non presense of 
                [  95.,  295.,  689.,    0.]
            ]),
            "derived_deltas": np.array([
                [-12., -12., -25., -25],
                [-5., -5., -11., 0],
                [-5., -5., -11., 0]
            ])
        },
        "do_benchmark": False
    },
    "mixed orders of different quantities at 3 different levels and differing offsets: There are no non agent orders left": { # TODO fix not working
        "params":{
            "lvl_qtys": [800, 700, 700],
            "lvl_deltas": [-100, -100, -100],
            "lvl_sizes": [[100, 200, 300, 100], [100, 200, 300], [100, 200, 300]],
            "lvl_offsets": [[0, 100, 300, 600], [0, 100, 300], [0, 100, 300]]
        },
        "expected":{
            "new_offsets": np.array([
                [  0.,  100.,  300., 600.],
                [  0.,  100.,  300.,    0.], # offsets less because of the non presense of 
                [  0.,  100.,  300.,    0.]
            ]),
            "derived_deltas": np.array([
                [0., 0., 0., 0],
                [0., 0., 0., 0],
                [0., 0., 0., 0]
            ])
        },
        "do_benchmark": False
    },
}
@pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
def test_derive_new_offsets(benchmark, case):
    orderbook = OrderBook(
        account=_account1,
        tick_size=0.5,
        num_levels=10
    ) 
    if "do_benchmark" in case and case["do_benchmark"]:
        bres = benchmark(orderbook._derive_new_offsets, **case["params"])
        res = orderbook._derive_new_offsets(**case["params"])
    else:
        res = orderbook._derive_new_offsets(**case["params"])
    
    exp = case["expected"]
    if "new_offsets" in exp:
        if not np.array_equal(res[0], exp["new_offsets"]):
            pytest.fail("new_offsets:"+str(res[0])+"!= expected:"+str(exp["new_offsets"]))
    if "derived_deltas" in exp:
        if not np.array_equal(res[1], exp["derived_deltas"]):
            pytest.fail("derived_deltas:"+str(res[1])+"!= expected:"+str(exp["derived_deltas"]))


# TODO test fill sell

# TODO test when overlapping levels
# TODO test when not in tick
# TODO test when agent offsets != 0 when update is 0
# TODO test irregular
# TODO changing best ask
cases = {
    "simple ask update no agent orders or previous depth": {
        "tick_size": 0.5,
        "num_lvls": 10,
        "updates":[
            [Depth(
                time = time.time(),
                asks = {100.5:100},
                bids = {}
            ),{100.5: 100},{100.5: 100}]
        ],
        "expected": {
            "has_agent_asks": False,
            "has_agent_bids": False,
            "ask_lvl_qtys": {100.5: 100},
            "best_ask_price": 100.5,
        },
        "expected_oid": 1,
    },
    "Depth update with single agent ask decreasing (delta less than offset)": {
        "tick_size": 0.5,
        "num_lvls": 10,
        "ask_lvl_qtys": {100.5: 1000, 101: 1000},
        "agent_orders": {_sell1.id: _sell1.reset(size=100, price=100.5)},
        "agent_ask_offsets": {_sell1.offset_id: 900},
        "agent_ask_qtys": {_sell1.qty_id: 100},
        "updates":[
            [Depth(
                time = time.time(),
                asks = {100.5: 900, 103: 100},
                bids = {}
            ),{100.5: 900, 101: 1000, 103:100},{100.5: -100, 103:100}],
        ],
        "expected": {
            "has_agent_asks": True,
            "has_agent_bids": False,
            "best_ask_price": 100.5,
            "ask_lvl_qtys": {100.5: 900, 101: 1000, 103:100},
            "agent_orders": {_sell1.id: _sell1},
            "agent_ask_offsets":  {_sell1.offset_id: 800}, # Is set to 800 because there is no qty behind the order
            "agent_ask_qtys": {_sell1.qty_id: 100},
        },
    },
}
@pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
def test_process_update_new(monkeypatch, case):

    if "do_skip" in case and case["do_skip"]:pytest.skip("Case marked as skipped") 

    orderbook = OrderBook(
        account=_account1,
        tick_size=case["tick_size"],
        num_levels=case["num_lvls"],
        ask_lvl_qtys=case["ask_lvl_qtys"] if "ask_lvl_qtys" in case else {},
        bid_lvl_qtys=case["bid_lvl_qtys"] if "bid_lvl_qtys" in case else {},
        agent_orders=case["agent_orders"] if "agent_orders" in case else {},
        agent_ask_offsets=case["agent_ask_offsets"] if "agent_ask_offsets" in case else {},
        agent_bid_offsets=case["agent_bid_offsets"] if "agent_bid_offsets" in case else {},
        agent_ask_qtys=case["agent_ask_qtys"] if "agent_ask_qtys" in case else {},
        agent_bid_qtys=case["agent_bid_qtys"] if "agent_bid_qtys" in case else {},
    ) 
    for l in case["updates"]:
        if len(l) == 3:
            new_depth, ask_lvl_deltas = orderbook._process_asks_update(l[0].asks)
            assert new_depth == l[1]
            assert ask_lvl_deltas == l[2]

        else:
            new_depth, ask_lvl_deltas = orderbook._process_asks_update(l.asks) 

    ex = case["expected"]
    for e in ex.items():
        if not getattr(orderbook, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(orderbook, e[0]))+"!="+str(e[1]))


    if "trades" in case:
        pass

@pytest.mark.slow
def test_benchmark_process_updates_new(benchmark):
    orderbook = OrderBook(
        tick_size=0.5,
        num_levels=10
    ) 

    def gen_random_depth_update():
        return {x[0]:x[1] for x in zip(np.arange(start=100, stop=110, step=0.5), np.random.randint(low=1, high=100, size=20))}

    res = benchmark(orderbook._process_update_new, gen_random_depth_update())


# TODO test fill sell

# TODO test when overlapping levels
# TODO test when not in tick
# TODO test when agent offsets != 0 when update is 0
# TODO test irregular
# TODO changing best ask
cases = {
    "simple ask update no agent orders or previous depth": {
        "tick_size": 0.5,
        "num_lvls": 10,
        "updates":[
            [Depth(
                time = time.time(),
                asks = {100.5:100},
                bids = {}
            ),{100.5: 100},{100.5: 100}]
        ],
        "expected": {
            "has_agent_asks": False,
            "has_agent_bids": False,
            "ask_lvl_qtys": {100.5: 100},
            "best_ask_price": 100.5,
        },
        "expected_oid": 1,
    },
    "simple ask update no agent orders with previous depth": {
        "tick_size": 0.5,
        "num_lvls": 10,
        "ask_lvl_qtys": {100.5: 1000},
        "updates":[
            [Depth(
                time = time.time(),
                asks = {100.5:100},
                bids = {}
            ),{100.5: 100},{100.5: -900}]
        ],
        "expected": {
            "has_agent_asks": False,
            "has_agent_bids": False,
            "ask_lvl_qtys": {100.5: 100},
            "best_ask_price": 100.5,
        },
        "expected_oid": 1,
    },
    "simple ask update no agent orders with previous multi level depth": {
        "tick_size": 0.5,
        "num_lvls": 10,
        "ask_lvl_qtys": {100.5: 1000, 101: 1000},
        "updates":[
            [Depth(
                time = time.time(),
                asks = {100.5:100},
                bids = {}
            ),{100.5: 100, 101: 1000},{100.5: -900}]
        ],
        "expected": {
            "has_agent_asks": False,
            "has_agent_bids": False,
            "best_ask_price": 100.5,
        },
        "expected_oid": 1,
    },
    "Multiple asks decreasing then increasing": {
        "tick_size": 0.5,
        "num_lvls": 10,
        "ask_lvl_qtys": {100.5: 1000, 101: 1000},
        "updates":[
            [Depth(
                time = time.time(),
                asks = {100.5:100},
                bids = {}
            ),{100.5: 100, 101: 1000},{100.5: -900}],
            [Depth(
                time = time.time(),
                asks = {100.5:1000},
                bids = {}
            ),{100.5: 1000, 101: 1000},{100.5: 900}],
        ],
        "expected": {
            "has_agent_asks": False,
            "has_agent_bids": False,
            "best_ask_price": 100.5,
        },
        "expected_oid": 1,
    },
    "Multiple level updates simultaneously": {
        "tick_size": 0.5,
        "num_lvls": 10,
        "ask_lvl_qtys": {100.5: 1000, 101: 1000},
        "updates":[
            [Depth(
                time = time.time(),
                asks = {100.5:100, 103: 100},
                bids = {}
            ),{100.5: 100, 101: 1000, 103:100},{100.5: -900, 103:100}],
            [Depth(
                time = time.time(),
                asks = {100.5:1000},
                bids = {}
            ),{100.5: 1000, 101: 1000, 103:100},{100.5: 900}],
        ],
        "expected": {
            "has_agent_asks": False,
            "has_agent_bids": False,
            "best_ask_price": 100.5,
        },
        "expected_oid": 1,
    },
    "Multiple level updates simultaneously with null one": {
        "tick_size": 0.5,
        "num_lvls": 10,
        "ask_lvl_qtys": {100.5: 1000, 101: 1000},
        "updates":[
            [Depth(
                time = time.time(),
                asks = {100.5:100, 103: 100},
                bids = {}
            ),{100.5: 100, 101: 1000, 103:100},{100.5: -900, 103:100}],
            [Depth(
                time = time.time(),
                asks = {},
                bids = {}
            ),{100.5: 100, 101: 1000, 103:100},{}],
            [Depth(
                time = time.time(),
                asks = {100.5:1000},
                bids = {}
            ),{100.5: 1000, 101: 1000, 103:100},{100.5: 900}],
        ],
        "expected": {
            "has_agent_asks": False,
            "has_agent_bids": False,
            "best_ask_price": 100.5,
        },
        "expected_oid": 1,
    },
    "Depth update with single agent ask increasing": {
        "tick_size": 0.5,
        "num_lvls": 10,
        "ask_lvl_qtys": {100.5: 1000, 101: 1000},
        "agent_orders": {_sell1.id: _sell1.reset(size=100, price=100.5)},
        "agent_ask_offsets": {_sell1.offset_id: 900},
        "agent_ask_qtys": {_sell1.qty_id: 100},
        "updates":[
            [Depth(
                time = time.time(),
                asks = {100.5:1100, 103: 100},
                bids = {}
            ),{100.5: 1100, 101: 1000, 103:100},{100.5: 100, 103:100}],
        ],
        "expected": {
            "has_agent_asks": True,
            "has_agent_bids": False,
            "best_ask_price": 100.5,
            "ask_lvl_qtys": {100.5: 1100, 101: 1000, 103:100},
            "agent_orders": {_sell1.id: _sell1},
            "agent_ask_offsets":  {_sell1.offset_id: 900},
            "agent_ask_qtys": {_sell1.qty_id: 100},
        },
    },
    "Depth update with single agent ask decreasing (delta less than offset)": {
        "tick_size": 0.5,
        "num_lvls": 10,
        "ask_lvl_qtys": {100.5: 1000, 101: 1000},
        "agent_orders": {_sell1.id: _sell1.reset(size=100, price=100.5)},
        "agent_ask_offsets": {_sell1.offset_id: 900},
        "agent_ask_qtys": {_sell1.qty_id: 100},
        "updates":[
            [Depth(
                time = time.time(),
                asks = {100.5: 900, 103: 100},
                bids = {}
            ),{100.5: 900, 101: 1000, 103:100},{100.5: -100, 103:100}],
        ],
        "expected": {
            "has_agent_asks": True,
            "has_agent_bids": False,
            "best_ask_price": 100.5,
            "ask_lvl_qtys": {100.5: 900, 101: 1000, 103:100},
            "agent_orders": {_sell1.id: _sell1},
            "agent_ask_offsets":  {_sell1.offset_id: 800}, # Is set to 800 because there is no qty behind the order
            "agent_ask_qtys": {_sell1.qty_id: 100},
        },
    },
    "Depth update with single agent ask multiple decreasing (delta less than offset)": {
        "tick_size": 0.5,
        "num_lvls": 10,
        "ask_lvl_qtys": {100.5: 1000, 101: 1000},
        "agent_orders": {_sell1.id: _sell1.reset(size=100, price=100.5)},
        "agent_ask_offsets": {_sell1.offset_id: 900},
        "agent_ask_qtys": {_sell1.qty_id: 100},
        "updates":[
            [Depth(
                time = time.time(),
                asks = {100.5: 900, 103: 100},
                bids = {}
            ),{100.5: 900, 101: 1000, 103:100},{100.5: -100, 103:100}],
            [Depth(
                time = time.time(),
                asks = {100.5: 800, 103: 100},
                bids = {}
            ),{100.5: 800, 101: 1000, 103:100},{100.5: -100, 103:0}],
        ],
        "expected": {
            "has_agent_asks": True,
            "has_agent_bids": False,
            "best_ask_price": 100.5,
            "ask_lvl_qtys": {100.5: 800, 101: 1000, 103:100},
            "agent_orders": {_sell1.id: _sell1},
            "agent_ask_offsets":  {_sell1.offset_id: 700}, # Is set to 700 because there is no qty behind the order
            "agent_ask_qtys": {_sell1.qty_id: 100},
        },
    },
    "Depth update with single agent ask multiple decreasing (delta equal to offset)": {
        "tick_size": 0.5,
        "num_lvls": 10,
        "ask_lvl_qtys": {100.5: 300, 101: 1000},
        "agent_orders": {_sell1.id: _sell1.reset(size=100, price=100.5)},
        "agent_ask_offsets": {_sell1.offset_id: 200},
        "agent_ask_qtys": {_sell1.qty_id: 100},
        "updates":[
            [Depth(
                time = time.time(),
                asks = {100.5: 200, 103: 100}, # Book is equal to offset + order
                bids = {}
            ),{100.5: 200, 101: 1000, 103:100},{100.5: -100, 103:100}],
            [Depth(
                time = time.time(),
                asks = {100.5: 100, 103: 100}, # Offset is decreased to 0
                bids = {}
            ),{100.5: 100, 101: 1000, 103:100},{100.5: -100, 103:0}], # TODO remove levels=0
        ],
        "expected": {
            "has_agent_asks": True,
            "has_agent_bids": False,
            "best_ask_price": 100.5,
            "ask_lvl_qtys": {100.5: 100, 101: 1000, 103:100},
            "agent_orders": {_sell1.id: _sell1},
            "agent_ask_offsets":  {_sell1.offset_id: 0},
            "agent_ask_qtys": {_sell1.qty_id: 100},
        },
    },
    "Depth update with multiple agent ask multiple decreasing (delta equal to offset)": {
        "tick_size": 0.5,
        "num_lvls": 10,
        "ask_lvl_qtys": {100.5: 1000},
        "agent_orders": {_sell1.id: _sell1.reset(size=100, price=100.5), _sell2.id: _sell2.reset(size=100, price=100.5)},
        "agent_ask_offsets": {_sell1.offset_id: 200, _sell1.offset_id: 600},
        "agent_ask_qtys": {_sell1.qty_id: 100, _sell1.qty_id: 100},
        "updates":[
            [Depth(
                time = time.time(),
                asks = {100.5: 900}, # asks is decreased by 100
                bids = {}
            ),{100.5: 900},{100.5: -100}],
            [Depth(
                time = time.time(),
                asks = {100.5: 800}, # Offset is decreased to 0
                bids = {}
            ),{100.5: 800},{100.5: -100}], # TODO remove levels=0
        ],
        "expected": {
            "has_agent_asks": True,
            "has_agent_bids": False,
            "best_ask_price": 100.5,
            "ask_lvl_qtys": {100.5: 800},
            "agent_orders": {_sell1.id: _sell1, _sell2.id:_sell2},
            "agent_ask_offsets":  {_sell1.offset_id: 100, _sell2.offset_id: 100},
            "agent_ask_qtys": {_sell1.qty_id: 100, _sell2.qty_id: 100},
        },
        "do_skip": True
    },
}
@pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
def test_process_asks_updates(monkeypatch, case):

    if "do_skip" in case and case["do_skip"]:pytest.skip("Case marked as skipped") 

    orderbook = OrderBook(
        account=_account1,
        tick_size=case["tick_size"],
        num_levels=case["num_lvls"],
        ask_lvl_qtys=case["ask_lvl_qtys"] if "ask_lvl_qtys" in case else {},
        bid_lvl_qtys=case["bid_lvl_qtys"] if "bid_lvl_qtys" in case else {},
        agent_orders=case["agent_orders"] if "agent_orders" in case else {},
        agent_ask_offsets=case["agent_ask_offsets"] if "agent_ask_offsets" in case else {},
        agent_bid_offsets=case["agent_bid_offsets"] if "agent_bid_offsets" in case else {},
        agent_ask_qtys=case["agent_ask_qtys"] if "agent_ask_qtys" in case else {},
        agent_bid_qtys=case["agent_bid_qtys"] if "agent_bid_qtys" in case else {},
    ) 
    for l in case["updates"]:
        if len(l) == 3:
            new_depth, ask_lvl_deltas = orderbook._process_asks_update(l[0].asks)
            assert new_depth == l[1]
            assert ask_lvl_deltas == l[2]

        else:
            new_depth, ask_lvl_deltas = orderbook._process_asks_update(l.asks) 

    ex = case["expected"]
    for e in ex.items():
        if not getattr(orderbook, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(orderbook, e[0]))+"!="+str(e[1]))


    if "trades" in case:
        pass

@pytest.mark.slow
def test_benchmark_process_asks_updates(benchmark):
    orderbook = OrderBook(
        account=_account1,
        tick_size=0.5,
        num_levels=10
    ) 

    def gen_random_depth_update():
        return {x[0]:x[1] for x in zip(np.arange(start=100, stop=110, step=0.5), np.random.randint(low=1, high=100, size=20))}

    res = benchmark(orderbook._process_asks_update, gen_random_depth_update())



# TODO test when overlapping levels
# TODO test when not in tick
# TODO test when agent offsets != 0 when update is 0
# TODO test irregular
# TODO changing best ask
cases = {
    "COMBINED CROSS: no premoum charged, should return true": {
        "account_args": {
            "balance": 1,
            "mark_price": 100,
            "last_price": 100,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.COMBINED,
            "margin_type": MarginType.CROSS 
        },
        "orderbook_args" :{
            "tick_size": 0.5,
            "num_lvls": 10,
            "ask_lvl_qtys": {100.5: 1000},
            "ask_lvl_qtys": {100.0: 1000},
            "mark_price": 100,
            "last_price": 100,
        },
        "exec": {
            "side": Side.SELL, # Side is sell and price is above mark price: no premium charged
            "price": 100.5,
            "size": 10,
            "order_id": 1
        },
        "expected": {
            "ret": True,
            "ava":   0.99899353,
            "mar": 0.00100647,
            "pr": 0,
            "account": {
                "order_margin":0.00100647 # THE margin amount used here is low because the leverage is high ()
            },
        }
    },
    "COMBINED CROSS: should fail not enough margin": {
        "account_args": {
            "balance": 1,
            "mark_price": 100,
            "last_price": 100,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.COMBINED,
            "margin_type": MarginType.CROSS 
        },
        "orderbook_args" :{
            "tick_size": 0.5,
            "num_lvls": 10,
            "ask_lvl_qtys": {100.5: 1000},
            "ask_lvl_qtys": {100.0: 1000},
            "mark_price": 100,
            "last_price": 100,
        },
        "exec": {
            "side": Side.SELL,
            "price": 100.5, # Side is sell and price is above mark price: no premium charged
            "size": 10000,
            "order_id": 1
        },
        "expected": {
            "ret": False,
            "mar":  1.00646766,
            "ava": 1,
            "pr": 0,
            "account": {
                "order_margin": 0
            },
        }
    },
    "COMBINED CROSS: premium charged on sell order below mark price, should return true": {
        "account_args": {
            "balance": 1,
            "mark_price": 1001,
            "last_price": 1000,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.COMBINED,
            "margin_type": MarginType.CROSS 
        },
        "orderbook_args" :{
            "tick_size": 0.5,
            "num_lvls": 10,
            "ask_lvl_qtys": {1000.5: 1000},
            "ask_lvl_qtys": {1000.0: 1000},
            "mark_price": 1001,
            "last_price": 1000,
        },
        "exec": {
            "side": Side.SELL, # Side is sell and price is above mark price: no premium charged
            "price": 1000.5,
            "size": 100,
            "order_id": 1
        },
        "expected": {
            "ret": True,
            "ava":   0.99848926,
            "mar":  0.00151074,
            "pr": 0.5,
            "account": {
                "order_margin": 0.00151074 # THE margin amount used here is low because the leverage is high ()
            },
            "orderbook": {
                "agent_order_margins": {1: 0.00151074}
            }
        }
    },
    "COMBINED CROSS: premium charged on buy order above mark price, should return true": {
        "account_args": {
            "balance": 1,
            "mark_price": 999.5,
            "last_price": 1000,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.COMBINED,
            "margin_type": MarginType.CROSS 
        },
        "orderbook_args" :{
            "tick_size": 0.5,
            "num_lvls": 10,
            "ask_lvl_qtys": {1000.5: 1000},
            "ask_lvl_qtys": {1000.0: 1000},
            "mark_price": 999.5,
            "last_price": 1000,
        },
        "exec": {
            "side": Side.BUY, # Side is sell and price is above mark price: no premium charged
            "price": 1000,
            "size": 100,
            "order_id": 1
        },
        "expected": {
            "ret": True,
            "ava":    0.9984885,
            "mar": 0.0015115,
            "pr": 0.5,
            "account": {
                "order_margin": 0.0015115, # THE margin amount used here is low because the leverage is high ()
            },
            "orderbook": {
                "agent_order_margins": {1: 0.0015115}
            }
        }
    },
}
@pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
def test_reserve_order_margin(monkeypatch, case):
    if "do_skip" in case and case["do_skip"]:pytest.skip("Case marked as skipped") 

    _account = Account(**case["account_args"])
    orderbook = OrderBook(account=_account, **case["orderbook_args"]) 
    e, res, mar, pr = orderbook.reserve_order_margin(**case["exec"], time=TEST_TIME)

    ex = case["expected"]

    if "pr" in ex:
        if not ex["pr"] == pr:
            pytest.fail("premium "+str(pr)+":!= expected "+str(ex["pr"]))

    if "ret" in ex:
        if not ex["ret"] == res:
            pytest.fail("res "+str(res)+":!="+str(ex["ret"]))

    if "mar" in ex:
        if not ex["mar"] == mar:
            pytest.fail("reserved margin "+str(mar)+":!= expected "+str(ex["mar"]))

    if "ava" in ex:
        if not ex["ava"] == _account.available_balance:
            pytest.fail("available balance "+str(_account.available_balance)+":!= expected "+str(ex["ava"]))

    if "account" in ex:
        exa = ex["account"]
        for e in exa.items():
            if not getattr(_account, e[0]) == e[1]:
                pytest.fail(e[0]+":"+str(getattr(_account, e[0]))+"!="+str(e[1]))

    if "orderbook" in ex:
        exa = ex["orderbook"]
        for e in exa.items():
            if not getattr(orderbook, e[0]) == e[1]:
                pytest.fail(e[0]+":"+str(getattr(orderbook, e[0]))+"!="+str(e[1]))

_sell1.reset(size=100, price=101)

cases = {
    "BID: Amount is removed from agent that is greater than the agents offset" : {
        "orderbook_args": {
            "tick_size": 0.5,
            "num_lvls": 10,
            "ask_lvl_qtys": {100.5: 1000, 101: 1000},
            "agent_orders": {_sell1.id: _sell1.reset(size=100, price=101)},
            "agent_ask_offsets": {_sell1.offset_id: 100},
            "agent_ask_qtys": {_sell1.qty_id: 100},
            "agent_order_margins": {_sell1.id: 1},
        },
        "exec": {
            "side": Side.BUY,
            "size": 200,
        },
        "expected": {
            "agent_ask_offsets": {_sell1.offset_id: 100},
            "agent_ask_qtys": {_sell1.qty_id: 100},
        }
    },
}
@pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
def test_new_market_order(monkeypatch, case):
    if "setup" in case:
        case["setup"]()
        
    orderbook = OrderBook(
        account=_account1,
        **case["orderbook_args"]
    )

    orderbook.new_market_order(**case["exec"], time=TEST_TIME)

    if "mocks" in case:
        for m,v in case["mocks"].items():
            def get_value(self):return v
            monkeypatch.setattr(OrderBook, m, property(get_value))

    ex = case["expected"]
    for e in ex.items():
        assert getattr(orderbook, e[0]) == e[1]