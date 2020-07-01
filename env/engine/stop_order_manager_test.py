import asyncio
import random
import uuid
import time
import pytest 
from env.engine.account import Account, PositionType, MarginType, FlatFee, TieredFee
from env.engine.position import Position
from env.engine.orderbook import OrderBook
from env.engine.stop_order_manager import StopOrderManager
from env.models import LimitOrder, StopTrigger, StopMarketOrder, StopLimitOrder, Side, Depth
from env.models import PositionSide, Side
from unittest.mock import patch
import time
import numpy as np
import logging
from datetime import datetime

_time1 = time.time()
TEST_TIME = np.datetime64(datetime.now())

class TPosition(Position):
    def __init__(self, **kwargs):
        Position.__init__(
            self,
            **kwargs
        )

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

class TStopLimitOrder(StopLimitOrder):
    def __init__(self, side, stop_price, limit_price, trigger, order_id, price, size):
        self.tside = side 
        self.torder_id = order_id 
        self.tstop_price = stop_price 
        self.tsize = size
        self.ttrigger = trigger
        self.tlimit_price = limit_price
        StopLimitOrder.__init__(
            self,
            side=side,
            order_id=order_id,
            stop_price=stop_price,
            size=size,
            trigger=trigger,
            limit_price=limit_price
        )

    def __call__(self):
        self.reset()

    def reset(self, side=None, order_id=None, price=None, size=None):
        self.side=side if side!=None else self.tside 
        self.order_id=order_id if order_id!=None else self.torder_id
        self.price=price if price!=None else self.tprice
        self.size=size if size!=None else self.tsize
        return self

class TStopMarketOrder(StopMarketOrder):
    def __init__(self, side, order_id, trigger, stop_price, size):
        self.tside = side 
        self.ttrigger = trigger
        self.torder_id = order_id 
        self.tstop_price = stop_price 
        self.tsize = size
        StopLimitOrder.__init__(
            self,
            side=side,
            order_id=order_id,
            stop_price=stop_price,
            size=size,
            trigger=trigger
        )

    def __call__(self):
        self.reset()

    def reset(self, side=None, order_id=None, price=None, size=None):
        self.side=side if side!=None else self.tside 
        self.order_id=order_id if order_id!=None else self.torder_id
        self.price=price if price!=None else self.tprice
        self.size=size if size!=None else self.tsize
        return self

_sell1 = TLimitOrder(side=Side.SELL, order_id="test1", price=100.5, size=100)
_sell2 = TLimitOrder(side=Side.SELL, order_id="test2", price=100.5, size=100)

cases = {
    # OPEN HEDGED POSITION (ONE ACTIVE POSITION)
    "check no forced order cancellations or liquidations performced": {
        "account_args": {
            "balance": 0.5,
            "mark_price": 1000,
            "last_price": 1000,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.HEDGE,
        },
        "orderbook_args" :{
            "tick_size": 0.5,
            "num_lvls": 10,
            "ask_lvl_qtys": {100.5: 250},
            "bid_lvl_qtys": {100: 1000},
            "agent_orders": {_sell1.id: _sell1.reset()},
            "agent_ask_offsets": {_sell1.offset_id: 150},
            "agent_ask_qtys": {_sell1.qty_id: 100},
            "agent_order_margins": {_sell1.id: 1},
            "mark_price": 1000,
            "last_price": 1000,
        },
        "sm_args":{

        },
        "stops": [{
            "order_id": _sell1.id,
            "stop_price": 100,
            "size": 100,
            "side": Side.BUY,
            "trigger": StopTrigger.MARK_PRICE
        },{
            "order_id": _sell2.id,
            "stop_price": 100,
            "size": 100,
            "side": Side.BUY,
            "trigger": StopTrigger.MARK_PRICE
        }],
        "new_mark_price" : 1990,
        "expected_account": {
            "balance": 0.5, # 1- ((100 /1000) + (100/1000)*0.00075) 
            "is_long": False
        },
        "expected_orderbook": {
            "num_agent_orders": 1
        },
        "expected_stopman": {
            "num_stops": 2
        },
    },
}
@pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
def test_add_stop_market(monkeypatch, case):
    if "do_skip" in case and case["do_skip"]:pytest.skip("Case marked as skipped") 

    _account = Account(**case["account_args"])
    _orderbook = OrderBook(account=_account, **case["orderbook_args"]) 
    stop_manager = StopOrderManager(
        orderbook=_orderbook, 
        account=_account, 
        **case["sm_args"]
    )
 
    _account.mark_price = case["new_mark_price"]
    _orderbook.mark_price = case["new_mark_price"]

    for l in case["stops"]:
        stop_manager.add_stop_market(**l, time=TEST_TIME)

    ex = case["expected_account"]
    for e in ex.items():
        if not getattr(_account, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(_account, e[0]))+"!="+str(e[1]))

    ex = case["expected_orderbook"]
    for e in ex.items():
        if not getattr(_orderbook, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(_orderbook, e[0]))+"!="+str(e[1]))

    ex = case["expected_stopman"]
    for e in ex.items():
        if not getattr(stop_manager, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(stop_manager, e[0]))+"!="+str(e[1]))


cases = {
    # OPEN HEDGED POSITION (ONE ACTIVE POSITION)
    "check no forced order cancellations or liquidations performced": {
        "account_args": {
            "balance": 0.5,
            "mark_price": 1000,
            "last_price": 1000,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.HEDGE,
        },
        "orderbook_args" :{
            "tick_size": 0.5,
            "num_lvls": 10,
            "ask_lvl_qtys": {100.5: 250},
            "bid_lvl_qtys": {100: 1000},
            "agent_orders": {_sell1.id: _sell1.reset()},
            "agent_ask_offsets": {_sell1.offset_id: 150},
            "agent_ask_qtys": {_sell1.qty_id: 100},
            "agent_order_margins": {_sell1.id: 1},
            "mark_price": 1000,
            "last_price": 1000,
        },
        "sm_args":{

        },
        "stops": [{
            "order_id": _sell1.id,
            "stop_price": 100,
            "limit_price": 105,
            "size": 100,
            "side": Side.BUY,
            "trigger": StopTrigger.MARK_PRICE
        },{
            "order_id": _sell2.id,
            "stop_price": 100,
            "limit_price": 105,
            "size": 100,
            "side": Side.BUY,
            "trigger": StopTrigger.MARK_PRICE
        }],
        "new_mark_price" : 1990,
        "expected_account": {
            "balance": 0.5, # 1- ((100 /1000) + (100/1000)*0.00075) 
            "is_long": False
        },
        "expected_orderbook": {
            "num_agent_orders": 1
        },
        "expected_stopman": {
            "num_stops": 2
        },
    },
}
@pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
def test_add_stop_limit(monkeypatch, case):
    if "do_skip" in case and case["do_skip"]:pytest.skip("Case marked as skipped") 

    _account = Account(**case["account_args"])
    _orderbook = OrderBook(account=_account, **case["orderbook_args"]) 
    stop_manager = StopOrderManager(
        orderbook=_orderbook, 
        account=_account, 
        **case["sm_args"]
    )
 
    _account.mark_price = case["new_mark_price"]
    _orderbook.mark_price = case["new_mark_price"]

    for l in case["stops"]:
        stop_manager.add_stop_limit(**l, time=TEST_TIME)

    ex = case["expected_account"]
    for e in ex.items():
        if not getattr(_account, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(_account, e[0]))+"!="+str(e[1]))

    ex = case["expected_orderbook"]
    for e in ex.items():
        if not getattr(_orderbook, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(_orderbook, e[0]))+"!="+str(e[1]))

    ex = case["expected_stopman"]
    for e in ex.items():
        if not getattr(stop_manager, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(stop_manager, e[0]))+"!="+str(e[1]))


cases = {
    # OPEN HEDGED POSITION (ONE ACTIVE POSITION)
    "check no forced order cancellations or liquidations performced": {
        "account_args": {
            "balance": 0.5,
            "mark_price": 1000,
            "last_price": 1000,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.HEDGE,
        },
        "orderbook_args" :{
            "tick_size": 0.5,
            "num_lvls": 10,
            "ask_lvl_qtys": {100.5: 250},
            "bid_lvl_qtys": {100: 1000},
            "agent_orders": {_sell1.id: _sell1.reset()},
            "agent_ask_offsets": {_sell1.offset_id: 150},
            "agent_ask_qtys": {_sell1.qty_id: 100},
            "agent_order_margins": {_sell1.id: 1},
            "mark_price": 1000,
            "last_price": 1000,
        },
        "sm_args":{

        },
        "stops": [{
            "order_id": _sell1.id,
            "stop_price": 100,
            "limit_price": 105,
            "size": 100,
            "side": Side.BUY,
            "trigger": StopTrigger.MARK_PRICE
        },{
            "order_id": _sell2.id,
            "stop_price": 100,
            "limit_price": 105,
            "size": 100,
            "side": Side.BUY,
            "trigger": StopTrigger.MARK_PRICE
        }],
        "remove_stops": [
            _sell1.id,
            _sell2.id
        ],
        "new_mark_price" : 1990,
        "expected_account": {
            "balance": 0.5, # 1- ((100 /1000) + (100/1000)*0.00075) 
            "is_long": False
        },
        "expected_orderbook": {
            "num_agent_orders": 1
        },
        "expected_stopman": {
            "num_stops": 0
        },
    },
}
@pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
def test_remove_stop_order(monkeypatch, case):
    if "do_skip" in case and case["do_skip"]:pytest.skip("Case marked as skipped") 

    _account = Account(**case["account_args"])
    _orderbook = OrderBook(account=_account, **case["orderbook_args"]) 
    stop_manager = StopOrderManager(
        orderbook=_orderbook, 
        account=_account, 
        **case["sm_args"]
    )
 
    _account.mark_price = case["new_mark_price"]
    _orderbook.mark_price = case["new_mark_price"]

    for l in case["stops"]:
        stop_manager.add_stop_limit(**l, time=TEST_TIME)

    for l in case["remove_stops"]:
        stop_manager.remove_stop_order(order_id=l, time=TEST_TIME)

    ex = case["expected_account"]
    for e in ex.items():
        if not getattr(_account, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(_account, e[0]))+"!="+str(e[1]))

    ex = case["expected_orderbook"]
    for e in ex.items():
        if not getattr(_orderbook, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(_orderbook, e[0]))+"!="+str(e[1]))

    ex = case["expected_stopman"]
    for e in ex.items():
        if not getattr(stop_manager, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(stop_manager, e[0]))+"!="+str(e[1]))

# TODO more tests etc check raises etc.
cases = {
    # OPEN HEDGED POSITION (ONE ACTIVE POSITION)
    "change side of stop order maintaining other attributes.": { # TODO should check stop price
        "account_args": {
            "balance": 0.5,
            "mark_price": 1000,
            "last_price": 1000,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.HEDGE,
        },
        "orderbook_args" :{
            "tick_size": 0.5,
            "num_lvls": 10,
            "ask_lvl_qtys": {100.5: 250},
            "bid_lvl_qtys": {100: 1000},
            "agent_orders": {_sell1.id: _sell1.reset()},
            "agent_ask_offsets": {_sell1.offset_id: 150},
            "agent_ask_qtys": {_sell1.qty_id: 100},
            "agent_order_margins": {_sell1.id: 1},
            "mark_price": 1000,
            "last_price": 1000,
        },
        "sm_args":{

        },
        "stop_limit": {
            "order_id": _sell2.id,
            "stop_price": 100,
            "limit_price": 105,
            "size": 100,
            "side": Side.BUY,
            "trigger": StopTrigger.MARK_PRICE
        },
        "update": {
            "side": Side.SELL
        },
        "expected": {
            "side": Side.SELL,
        },
        "new_mark_price" : 1990,
        "expected_account": {
            "balance": 0.5, # 1- ((100 /1000) + (100/1000)*0.00075) 
            "is_long": False
        },
        "expected_orderbook": {
            "num_agent_orders": 1
        },
        "expected_stopman": {
            "num_stops": 1
        },
    },
    "Update price maintaining other attributes": { # TODO should check stop price
        "account_args": {
            "balance": 0.5,
            "mark_price": 1000,
            "last_price": 1000,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.HEDGE,
        },
        "orderbook_args" :{
            "tick_size": 0.5,
            "num_lvls": 10,
            "ask_lvl_qtys": {100.5: 250},
            "bid_lvl_qtys": {100: 1000},
            "agent_orders": {_sell1.id: _sell1.reset()},
            "agent_ask_offsets": {_sell1.offset_id: 150},
            "agent_ask_qtys": {_sell1.qty_id: 100},
            "agent_order_margins": {_sell1.id: 1},
            "mark_price": 1000,
            "last_price": 1000,
        },
        "sm_args":{

        },
        "stop_limit": {
            "order_id": _sell2.id,
            "stop_price": 100,
            "limit_price": 105,
            "size": 100,
            "side": Side.BUY,
            "trigger": StopTrigger.MARK_PRICE
        },
        "update": {
            "stop_price": 1005
        },
        "expected": {
            "stop_price": 1005,
        },
        "new_mark_price" : 1990,
        "expected_account": {
            "balance": 0.5, # 1- ((100 /1000) + (100/1000)*0.00075) 
            "is_long": False
        },
        "expected_orderbook": {
            "num_agent_orders": 1
        },
        "expected_stopman": {
            "num_stops": 1
        },
    },
}
@pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
def test_update_stop_order(monkeypatch, case):
    if "do_skip" in case and case["do_skip"]:pytest.skip("Case marked as skipped") 

    _account = Account(**case["account_args"])
    _orderbook = OrderBook(account=_account, **case["orderbook_args"]) 
    stop_manager = StopOrderManager(
        orderbook=_orderbook, 
        account=_account, 
        **case["sm_args"]
    )
 
    _account.mark_price = case["new_mark_price"]
    _orderbook.mark_price = case["new_mark_price"]

    if "stop_limit" in case:
        sl = case["stop_limit"]
    elif "stop_market" in case:
        sl = case["stop_market"]
    else:
        pytest.fail("no initial stop order specified")

    i = sl["order_id"]
    stop_manager.add_stop_limit(**sl, time=TEST_TIME)

    stop_manager.update_stop_order(order_id=i, **case["update"], time=TEST_TIME)

    rs = stop_manager.get_stop_order(i)
    logging.error(rs.__dict__)

    for e in case["expected"].items():
        if not getattr(rs, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(rs, e[0]))+"!="+str(e[1]))

    ex = case["expected_account"]
    for e in ex.items():
        if not getattr(_account, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(_account, e[0]))+"!="+str(e[1]))

    ex = case["expected_orderbook"]
    for e in ex.items():
        if not getattr(_orderbook, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(_orderbook, e[0]))+"!="+str(e[1]))

    ex = case["expected_stopman"]
    for e in ex.items():
        if not getattr(stop_manager, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(stop_manager, e[0]))+"!="+str(e[1]))




cases = {
    # OPEN HEDGED POSITION (ONE ACTIVE POSITION)
    "change side of stop order maintaining other attributes.": { # TODO should check stop price
        "account_args": {
            "balance": 0.5,
            "mark_price": 1000,
            "last_price": 1000,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.HEDGE,
        },
        "orderbook_args" :{
            "tick_size": 0.5,
            "num_lvls": 10,
            "ask_lvl_qtys": {100.5: 250},
            "bid_lvl_qtys": {100: 1000},
            "agent_orders": {_sell1.id: _sell1.reset()},
            "agent_ask_offsets": {_sell1.offset_id: 150},
            "agent_ask_qtys": {_sell1.qty_id: 100},
            "agent_order_margins": {_sell1.id: 1},
            "mark_price": 1000,
            "last_price": 1000,
        },
        "sm_args":{

        },
        "stop_limits": [{
            "order_id": _sell2.id,
            "stop_price": 95,
            "limit_price": 95,
            "size": 100,
            "side": Side.BUY,
            "trigger": StopTrigger.LAST_PRICE
        },
        {
            "order_id": "lll",
            "stop_price": 100,
            "limit_price": 99,
            "size": 100,
            "side": Side.BUY,
            "trigger": StopTrigger.LAST_PRICE
        },
        {
            "order_id": "mmm",
            "stop_price": 101,
            "limit_price": 99,
            "size": 100,
            "side": Side.BUY,
            "trigger": StopTrigger.LAST_PRICE
        },
        {
            "order_id": "ddd",
            "stop_price": 101,
            "limit_price": 105,
            "size": 100,
            "side": Side.SELL,
            "trigger": StopTrigger.LAST_PRICE
        }],
        "new_last_price" : 100,
        "expected_account": {
            "balance": 0.5, # 1- ((100 /1000) + (100/1000)*0.00075) 
            "is_long": False
        },
        "expected_orderbook": {
            "num_agent_orders": 3
        },
        "expected_stopman": {
            "num_stops": 2
        },
    },
}
@pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
def test_check_stops_by_last_price(monkeypatch, case):
    if "do_skip" in case and case["do_skip"]:pytest.skip("Case marked as skipped") 

    _account = Account(**case["account_args"])
    _orderbook = OrderBook(account=_account, **case["orderbook_args"]) 
    stop_manager = StopOrderManager(
        orderbook=_orderbook, 
        account=_account, 
        **case["sm_args"]
    )

    if "stop_limits" in case:
        for s in case["stop_limits"]:
            stop_manager.add_stop_limit(**s, time=TEST_TIME)

    if "stop_markets" in case:
        for s in case["stop_markets"]:
            stop_manager.add_stop_market(**s, time=TEST_TIME)

    stop_manager.check_stops_by_last_price(last_price=case["new_last_price"], time=TEST_TIME)

    ex = case["expected_account"]
    for e in ex.items():
        if not getattr(_account, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(_account, e[0]))+"!="+str(e[1]))

    ex = case["expected_orderbook"]
    for e in ex.items():
        if not getattr(_orderbook, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(_orderbook, e[0]))+"!="+str(e[1]))

    ex = case["expected_stopman"]
    for e in ex.items():
        if not getattr(stop_manager, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(stop_manager, e[0]))+"!="+str(e[1]))




cases = {
    # OPEN HEDGED POSITION (ONE ACTIVE POSITION)
    "change side of stop order maintaining other attributes.": { # TODO should check stop price
        "account_args": {
            "balance": 0.5,
            "mark_price": 1000,
            "last_price": 1000,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.HEDGE,
        },
        "orderbook_args" :{
            "tick_size": 0.5,
            "num_lvls": 10,
            "ask_lvl_qtys": {100.5: 250},
            "bid_lvl_qtys": {100: 1000},
            "agent_orders": {_sell1.id: _sell1.reset()},
            "agent_ask_offsets": {_sell1.offset_id: 150},
            "agent_ask_qtys": {_sell1.qty_id: 100},
            "agent_order_margins": {_sell1.id: 1},
            "mark_price": 1000,
            "last_price": 1000,
        },
        "sm_args":{

        },
        "stop_limit": {
            "order_id": _sell2.id,
            "stop_price": 100,
            "limit_price": 105,
            "size": 100,
            "side": Side.BUY,
            "trigger": StopTrigger.MARK_PRICE
        },
        "update": {
            "side": Side.SELL
        },
        "expected": {
            "side": Side.SELL,
        },
        "new_mark_price" : 1990,
        "expected_account": {
            "balance": 0.5, # 1- ((100 /1000) + (100/1000)*0.00075) 
            "is_long": False
        },
        "expected_orderbook": {
            "num_agent_orders": 1
        },
        "expected_stopman": {
            "num_stops": 1
        },
    },
}
@pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
def test_check_stops_by_mark_price(monkeypatch, case):
    if "do_skip" in case and case["do_skip"]:pytest.skip("Case marked as skipped") 

    _account = Account(**case["account_args"])
    _orderbook = OrderBook(account=_account, **case["orderbook_args"]) 
    stop_manager = StopOrderManager(
        orderbook=_orderbook, 
        account=_account, 
        **case["sm_args"]
    )
 
    _account.mark_price = case["new_mark_price"]
    _orderbook.mark_price = case["new_mark_price"]

    if "stop_limit" in case:
        sl = case["stop_limit"]
    elif "stop_market" in case:
        sl = case["stop_market"]
    else:
        pytest.fail("no initial stop order specified")

    i = sl["order_id"]
    stop_manager.add_stop_limit(**sl, time=TEST_TIME)

    stop_manager.update_stop_order(order_id=i, **case["update"], time=TEST_TIME)

    rs = stop_manager.get_stop_order(i)
    logging.error(rs.__dict__)

    for e in case["expected"].items():
        if not getattr(rs, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(rs, e[0]))+"!="+str(e[1]))

    ex = case["expected_account"]
    for e in ex.items():
        if not getattr(_account, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(_account, e[0]))+"!="+str(e[1]))

    ex = case["expected_orderbook"]
    for e in ex.items():
        if not getattr(_orderbook, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(_orderbook, e[0]))+"!="+str(e[1]))

    ex = case["expected_stopman"]
    for e in ex.items():
        if not getattr(stop_manager, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(stop_manager, e[0]))+"!="+str(e[1]))