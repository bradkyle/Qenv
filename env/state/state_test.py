import asyncio
import random
import uuid
import time
import pytest 
from env.engine.orderbook import OrderBook
from env.engine.account import Account, FeeType, FlatFee, TieredFee, MarginType, PositionType
from env.models import *
from unittest.mock import patch
import time
import numpy as np
from env.state.state import State
from env.engine.engine import Engine
from env.kdb.kdb_client import KDBClient
from env.state.adapters import *
from profilehooks import profile


cases = {
    "Test best bid": {
        "setup": 0,
        "expected": {}
    },
    "Test best bid missing": {
        "action": 1,
        "expected": {}
    },
    "Test worst bid": {
        "action": 1,
        "expected": {}
    },
    "Test worst bid missing": {
        "action": 1,
        "expected": {}
    },
    "Test best ask": {
        "action": 1,
        "expected": {}
    },
    "Test best ask missing": {
        "action": 1,
        "expected": {}
    },
    "Test worst ask": {
        "action": 1,
        "expected": {}
    },
    "Test worst ask missing": {
        "action": 1,
        "expected": {}
    },
}
@pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
def test_state_utils(benchmark, monkeypatch, case):
    
    engine = Engine(config={"allowed_event_types": DEFAULT_ALLOWED_EVENT_TYPES})
    state = State(
        engine=engine,
        store=KDBClient(),
        adapter=DiscreteAdapter 
    ) 
    
    # from itertools import groupby
    # grouped_events = {k:list(it) for k, it in groupby(case["events"], lambda e: e.typ)}
    # import logging
    # logging.error(grouped_events)
    
    ex = case["expected"]
    for e in ex.items():
        if not getattr(engine, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(engine, e[0]))+"!="+str(e[1]))
 
    if "bench" in case and case["bench"] is True:
        res = benchmark(state.advance, case["events"])


ALL_EVENTS = [
Event(time="2020-06-10T11:07:24.387Z", action=EventAction.UPDATE, typ=EventType.DEPTH, datum=Depth(
    asks = {
        100.5:1000,
        101: 1000,
        103: 1000,
        103.5: 1000,
        104: 1000,
        105: 10,
        106: 10,
        107: 100,
        109: 100,
        105.5: 100
    },
    bids = {
        100: 1000,
        99: 1000,
        99.5: 100,
        98: 100,
        98.5: 100,
        97: 100,
        96: 100,
        95: 100,
        94: 100,
        94.5: 100
    }
)),
Event(time="2020-06-10T11:07:24.387Z", action=EventAction.UPDATE, typ=EventType.TRADE, datum=Trade( # TODO
    side = Side.BUY,
    size = 100,
    price = 100.5
)),
Event(time="2020-06-10T11:07:24.387Z", action=EventAction.NEW, typ=EventType.DEPOSIT, datum=Deposit(
    amount=1000
)),
Event(time="2020-06-10T11:07:24.387Z", action=EventAction.NEW, typ=EventType.WITHDRAWAL, datum=Withdrawal(
    amount=100
)),
Event(time="2020-06-10T11:07:24.387Z", action=EventAction.UPDATE, typ=EventType.FUNDING, datum=Funding(
    funding_rate=0.0001,
    next_funding_time="2020-06-10T11:07:24.387Z"
)),
Event(time="2020-06-10T11:07:24.387Z", action=EventAction.UPDATE, typ=EventType.MARK, datum=MarkPrice(
    mark_price=101
)),
Event(time="2020-06-10T11:07:24.387Z", action=EventAction.NEW, typ=EventType.ORDER_UPDATE, datum=LimitOrder(
    side=Side.SELL, order_id="test1", price=100.5, size=100
)),
Event(time="2020-06-10T11:07:24.387Z", action=EventAction.NEW, typ=EventType.ORDER_UPDATE, datum=StopLimitOrder(
    **{
        "order_id": "test_stop_limit",
        "stop_price": 100,
        "limit_price": 105,
        "size": 100,
        "side": Side.BUY,
        "trigger": StopTrigger.MARK_PRICE
    }
)),
Event(time="2020-06-10T11:07:24.387Z", action=EventAction.NEW, typ=EventType.ORDER_UPDATE, datum=StopMarketOrder(
    **{
        "order_id": "test_stop_market",
        "stop_price": 100,
        "size": 100,
        "side": Side.BUY,
        "trigger": StopTrigger.MARK_PRICE
    }
)),
Event(time="2020-06-10T11:07:24.387Z", action=EventAction.NEW, typ=EventType.POSITION_UPDATE, datum=PositionR(
    side=PositionSide.SHORT,
    amount=110,
    average_entry_price=110,
    leverage=10,
    realised_pnl=10,
    unrealised_pnl=10,
)),
Event(time="2020-06-10T11:07:24.387Z", action=EventAction.NEW, typ=EventType.POSITION_UPDATE, datum=PositionR(
    side=PositionSide.LONG,
    amount=110,
    average_entry_price=110,
    leverage=10,
    realised_pnl=10,
    unrealised_pnl=10,
)),
Event(time="2020-06-10T11:07:24.387Z", action=EventAction.NEW, typ=EventType.ACCOUNT_UPDATE, datum=AccountR(
    balance =1,
    frozen =0,
    maint_margin =0,
    available_balance =0,
)),
Event(time="2020-06-10T11:07:24.387Z", action=EventAction.UPDATE, typ=EventType.FEATURE, datum=Feature(
    fid="testing",
    value=0,
)),
]

cases = {
    "ALL Events Run Through": {
        "action": 1,
        "expected": {}
    }
}
@pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
def test_derive(benchmark, monkeypatch, case):
    
    engine = Engine(config={"allowed_event_types": DEFAULT_ALLOWED_EVENT_TYPES})
    state = State(
        engine=engine,
        store=KDBClient(),
        adapter=DiscreteAdapter 
    )
    state.advance(ALL_EVENTS)
    state.derive(case["action"])
    
    # from itertools import groupby
    # grouped_events = {k:list(it) for k, it in groupby(case["events"], lambda e: e.typ)}
    # import logging
    # logging.error(grouped_events)
    
    ex = case["expected"]
    for e in ex.items():
        if not getattr(engine, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(engine, e[0]))+"!="+str(e[1]))
 
    if "bench" in case and case["bench"] is True:
        res = benchmark(state.advance, case["events"])

cases = {
    "ALL Events Run Through": {
        "args": {
            "current_step": 17
        },
        "events": ALL_EVENTS*100,
        "bench": False,
        "expected": {
            
        }
    }
}
@pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
def test_state_benchmark_advance(benchmark, monkeypatch, case):
    
    engine = Engine(config={"allowed_event_types": DEFAULT_ALLOWED_EVENT_TYPES})
    state = State(
        engine=engine,
        store=KDBClient(),
        adapter=MarketMakerAdapter,
        current_step=17
    )

    state.advance(case["events"])
    
    # from itertools import groupby
    # grouped_events = {k:list(it) for k, it in groupby(case["events"], lambda e: e.typ)}
    # import logging
    # logging.error(grouped_events)
    
    ex = case["expected"]
    for e in ex.items():
        if not getattr(engine, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(engine, e[0]))+"!="+str(e[1]))
 
    if "bench" in case and case["bench"] is True:
        res = benchmark(state.advance, case["events"])

