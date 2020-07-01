import asyncio
import random
import uuid
import time
import pytest 
from env.models import *
from env.engine.orderbook import OrderBook
from env.models import Side, LimitOrder
from unittest.mock import patch
from env.engine.engine import Engine
from profilehooks import profile
import logging

EVENT_PERMUTATIONS = [
    Event(time="", action=EventAction.UPDATE, typ=EventType.DEPTH, datum=Depth(
        time = time.time(),
        asks = {100.5:1000},
        bids = {100: 1000}
    )),
    Event(time="", action=EventAction.UPDATE, typ=EventType.TRADE, datum=Trade( # TODO
        side = Side.BUY,
        size = 100,
        price = 100.5
    )),
    Event(time="", action=EventAction.NEW, typ=EventType.DEPOSIT, datum=Deposit(
        amount=1000
    )),
    Event(time="", action=EventAction.NEW, typ=EventType.WITHDRAWAL, datum=Withdrawal(
        amount=100
    )),
    Event(time="", action=EventAction.UPDATE, typ=EventType.FUNDING, datum=Funding(
        funding_rate=0.0001,
        next_funding_time=time.time()
    )),
    Event(time="", action=EventAction.UPDATE, typ=EventType.MARK, datum=MarkPrice(
        mark_price=101
    )),
    Event(time="", action=EventAction.NEW, typ=EventType.PLACE_ORDER, datum=LimitOrder(
        side=Side.SELL, order_id="test1", price=100.5, size=100
    )),
    Event(time="", action=EventAction.NEW, typ=EventType.PLACE_ORDER, datum=MarketOrder(
        side=Side.SELL, order_id="test1", size=100
    )),
    Event(time="", action=EventAction.NEW, typ=EventType.PLACE_ORDER, datum=StopLimitOrder(
        **{
            "order_id": "test_stop_limit",
            "stop_price": 100,
            "limit_price": 105,
            "size": 100,
            "side": Side.BUY,
            "trigger": StopTrigger.MARK_PRICE
        }
    )),
    Event(time="", action=EventAction.NEW, typ=EventType.PLACE_ORDER, datum=StopMarketOrder(
        **{
            "order_id": "test_stop_market",
            "stop_price": 100,
            "size": 100,
            "side": Side.BUY,
            "trigger": StopTrigger.MARK_PRICE
        }
    )),
    # TODO place batch order   
]

@pytest.mark.slow
def test_profile():
    ENGINE = Engine(config={"allowed_event_types": DEFAULT_ALLOWED_EVENT_TYPES})
    logging.info("ENGINE PROFILING")
    logging.info("="*90)
    @profile(entries=400)
    def profile_process_event_batch():
        ENGINE.process_event_batch(EVENT_PERMUTATIONS*100, raise_errors=False)
    profile_process_event_batch()


# cases = {
#     "process limit order": {
#         "events": [
#             Event("", EventAction.UPDATE, Depth())
#         ],
#         "expected":{
            
#         },
#         "revents": {

#         },
#     }
# }
# @pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
# def test_process_liquidation(monkeypatch, case):
#     pass



# cases = {
#     "case1": {
#         "events": [
#             Event("", EventAction.UPDATE, Depth())
#         ],
#         "expected":{
            
#         },
#         "revents": {

#         },
#     }
# }
# @pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
# def test_process_trade(monkeypatch, case):
#     pass


# cases = {
#     "case1": {
#         "events": [
#             Event("", EventAction.UPDATE, Depth())
#         ],
#         "expected":{
            
#         },
#         "revents": {

#         },
#     }
# }
# @pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
# def test_process_depth_update(monkeypatch, case):
#     pass


cases = {
    "ALL Events Run Through": {
        "events": EVENT_PERMUTATIONS,
        "expected":{
            "total_event_count": 10
        },
    }
}
@pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
def test_engine(benchmark, monkeypatch, case):
    
    engine = Engine(config={"allowed_event_types": DEFAULT_ALLOWED_EVENT_TYPES})

    engine.process_event_batch(case["events"], raise_errors=True)
    
    # from itertools import groupby
    # grouped_events = {k:list(it) for k, it in groupby(case["events"], lambda e: e.typ)}
    # import logging
    # logging.error(grouped_events)
    
    ex = case["expected"]
    for e in ex.items():
        if not getattr(engine, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(engine, e[0]))+"!="+str(e[1]))

    # pytest.fail()
    # res = benchmark(engine.process_event_batch, case["events"])