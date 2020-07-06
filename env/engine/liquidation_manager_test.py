import asyncio
import random
import uuid
import time
import pytest 
from env.engine.account import Account, PositionType, MarginType, FlatFee, TieredFee
from env.engine.position import Position
from env.engine.orderbook import OrderBook
from env.engine.liquidation_manager import LiquidationManager
from env.models import LimitOrder, Side, Depth
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
        "lm_args": {},
        "positions": {
            "long_inventory": {
                "initial":TPosition(side=PositionSide.LONG, current_qty=0),
                "expected": {
                    "abs_qty": 0
                }
            },
            "short_inventory": {
                "initial":TPosition(side=PositionSide.SHORT, current_qty=1000),
                "mocks": {
                    "total_entry": 1000,
                    "exec_costs": 100000000,
                },
                "expected": {
                    "abs_qty": 1000,
                    "average_entry_price": 1000
                }
            },
            "both_inventory": {
                "initial":TPosition(side=PositionSide.BOTH, current_qty=0),
                "expected": {
                    "abs_qty": 0
                }
            },
        }, 
        "new_mark_price" : 1990,
        "expected_account": {
            "balance": 0.5, # 1- ((100 /1000) + (100/1000)*0.00075) 
            "is_long": False
        },
        "expected_orderbook": {
            "num_agent_orders": 1
        },
        "expected_liqman": {

        },
        "do_skip": True
    },
    "test forced order cancellation on long position, updated resultant order margin etc.": {
        "account_args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.HEDGE
        },
        "orderbook_args" :{
            "tick_size": 0.5,
            "num_lvls": 10,
            "ask_lvl_qtys": {1000.5: 250},
            "bid_lvl_qtys": {1000: 1000},
            "agent_orders": {_sell1.id: _sell1.reset()},
            "agent_ask_offsets": {_sell1.offset_id: 150},
            "agent_ask_qtys": {_sell1.qty_id: 100},
            "agent_order_margins": {_sell1.id: 1},
            "mark_price": 1000,
            "last_price": 1000,
        },
        "lm_args": {},
        "positions": {
            "long_inventory": {
                "initial":TPosition(side=PositionSide.LONG, current_qty=0),
                "expected": {
                    "abs_qty": 0
                }, 
            },
            "short_inventory": {
                "initial":TPosition(side=PositionSide.SHORT, current_qty=1000),
                "mocks": {
                    "total_entry": 1000,
                    "exec_costs": 100000000,
                },
                "expected": {
                    "abs_qty": 1000,
                    "average_entry_price": 1000,
                }
            },
            "both_inventory": {
                "initial":TPosition(side=PositionSide.BOTH, current_qty=0),
                "expected": {
                    "abs_qty": 0
                }
            },
        },
        "new_mark_price" : 1000,
        "expected_account": {
            "balance": 1, # 1- ((100 /1000) + (100/1000)*0.00075) 
            "cross_liquidation_price": 996,
            "is_short": True
        },
        "expected_orderbook": {
            "num_agent_orders": 0
        },
        "expected_liqman": {
            "num_account_liquidations": 1,
            "num_position_liquidations": 0,
            "num_bankruptcy": 0
        },
        "do_skip": True
    },
}
@pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
def test_check_by_mark_price(monkeypatch, case):
    if "do_skip" in case and case["do_skip"]:pytest.skip("Case marked as skipped") 

    _account = Account(**case["account_args"])
    _orderbook = OrderBook(account=_account, **case["orderbook_args"]) 
    liquidation_manager = LiquidationManager(
        orderbook=_orderbook, 
        account=_account, 
        **case["lm_args"]
    )

    def add_acc(pos, acc):
        pos.account = acc
        return pos

    pos = case["positions"]
    if "long_inventory" in pos: 
        p = pos["long_inventory"]
        _account.long_inventory = add_acc(p["initial"], _account)
        if "mocks" in p:
            for m,v in p["mocks"].items():
                setattr(_account.long_inventory, m, v)

    if "short_inventory" in pos: 
        p = pos["short_inventory"]
        _account.short_inventory = add_acc(p["initial"], _account)
        if "mocks" in p:
            for m,v in p["mocks"].items():
                setattr(_account.short_inventory, m, v)
    
    if "both_inventory" in pos: 
        p = pos["both_inventory"]
        _account.both_inventory = add_acc(p["initial"], _account)
        if "mocks" in p:
            for m,v in p["mocks"].items():
                setattr(_account.both_inventory, m, v)

    logging.error(_account.both_inventory)

    if "property_mocks" in case:
        for m,v in case["property_mocks"].items():
            def get_value(self):return v
            monkeypatch.setattr(Account, m, property(get_value))

    _account.mark_price = case["new_mark_price"]
    _orderbook.mark_price = case["new_mark_price"]

    logging.error(_account.short_inventory.average_entry_price)
    logging.error(_account.short_inventory.unrealized_pnl)
    logging.error(_account.available_balance)
    logging.error("equity:"+str(_account.equity))
    logging.error("reserved balance:"+str(_account.reserved_balance))
    logging.error("cross liq price:"+str(_account.cross_liquidation_price))

    liquidation_manager.check_by_mark_price(case["new_mark_price"], time=TEST_TIME)

    def loop_assrt(pos, ex):
        for e in ex.items():
            if not getattr(pos, e[0]) == e[1]:
                pytest.fail(str(pos.side)+"_"+e[0]+":"+str(getattr(pos, e[0]))+"!="+str(e[1]))
    
    # import logging
    # logging.error(_account.long_inventory.average_entry_price)

    if "long_inventory" in pos: loop_assrt(_account.long_inventory, pos["long_inventory"]["expected"])
    if "short_inventory" in pos: loop_assrt(_account.short_inventory, pos["short_inventory"]["expected"])
    if "both_inventory" in pos: loop_assrt(_account.both_inventory, pos["both_inventory"]["expected"])

    ex = case["expected_account"]
    for e in ex.items():
        if not getattr(_account, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(_account, e[0]))+"!="+str(e[1]))

    ex = case["expected_orderbook"]
    for e in ex.items():
        if not getattr(_orderbook, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(_orderbook, e[0]))+"!="+str(e[1]))

    ex = case["expected_liqman"]
    for e in ex.items():
        if not getattr(liquidation_manager, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(liquidation_manager, e[0]))+"!="+str(e[1]))