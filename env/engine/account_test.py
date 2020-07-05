import asyncio
import random
import uuid
import time
import pytest 
from env.engine.account import Account, PositionType, MarginType, FlatFee, TieredFee
from env.engine.position import Position
from env.models import PositionSide, Side
from unittest.mock import patch
import time
import numpy as np
from datetime import datetime

_time1 = time.time()
TEST_TIME = np.datetime64(datetime.now())

class TPosition(Position):
    def __init__(self, **kwargs):
        Position.__init__(
            self,
            **kwargs
        )


cases = {
    "Because long position is entered into, liquidation price should be above the ave price": {
        "args":{
            "balance": 0.1,
            "mark_price": 1005,
            "position_type": PositionType.HEDGE
        },
        "positions": {
            "short_inventory": {
                "initial":TPosition(side=PositionSide.SHORT, current_qty=0),
                "expected": {
                    "abs_qty": 0
                }, 
            },
            "long_inventory": {
                "initial":TPosition(side=PositionSide.LONG, current_qty=0),
                "exec": {
                    "execution": 100,
                    "price": 1005,
                    "fee": 0
                }
            },
            "both_inventory": {
                "initial":TPosition(side=PositionSide.BOTH, current_qty=0),
                "exec": {
                    "execution": 100,
                    "price": 1005,
                    "fee": 0
                }
            },
        },
        "expected": {
            # "long_qty": 1000,
            # "reserved_balance": 8,
            # "equity": 0.09,
            "cross_liquidation_price": 1001
        },
        "do_skip": True
    },
    "Because short position is entered into, liquidation price should be less than short price": {
        "args":{
            "balance": 1,
            "mark_price": 1005,
            "position_type": PositionType.HEDGE
        },
        "positions": {
            "short_inventory": {
                "initial":TPosition(side=PositionSide.SHORT, current_qty=0),
                "exec": {
                    "execution": 7000,
                    "price": 1005,
                    "fee": 0
                }
            },
            "long_inventory": {
                "initial":TPosition(side=PositionSide.LONG, current_qty=0),
            },
            "both_inventory": {
                "initial":TPosition(side=PositionSide.BOTH, current_qty=0),
                
            },
        },
        "expected": {
            # "long_qty": 1000,
            # "reserved_balance": 8,
            # "equity": 0.09,
            "cross_liquidation_price": 1009
        },
        "do_skip": True
    },
}
@pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
def test_cross_liquidation_price(monkeypatch, case):
    if "do_skip" in case and case["do_skip"]:pytest.skip("Case marked as skipped") 

    account = Account(**case["args"])

    def add_acc(pos, acc):
        pos.account = acc
        return pos

    pos = case["positions"]
    if "long_inventory" in pos: 
        p = pos["long_inventory"]
        account.long_inventory = add_acc(p["initial"], account)
        if "mocks" in p:
            for m,v in p["mocks"].items():
                setattr(account.long_inventory, m, v)
        if "exec" in p:
            account._exec(account.long_inventory, **p["exec"])

    if "short_inventory" in pos: 
        p = pos["short_inventory"]
        account.short_inventory = add_acc(p["initial"], account)
        if "mocks" in p:
            for m,v in p["mocks"].items():
                setattr(account.short_inventory, m, v)
        if "exec" in p:
            account._exec(account.short_inventory, **p["exec"])
    
    if "both_inventory" in pos: 
        p = pos["both_inventory"]
        account.both_inventory = add_acc(p["initial"], account)
        if "mocks" in p:
            for m,v in p["mocks"].items():
                setattr(account.both_inventory, m, v)
        if "exec" in p:
            account._exec(account.both_inventory, **p["exec"])

    import logging
    logging.error(account.available_balance)

    ex = case["expected"]
    for e in ex.items():
        if not getattr(account, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(account, e[0]))+"!="+str(e[1]))




# TODO test none taken from hedge during cross
# TODO inverse contract vs vanilla contract
cases = {
    "check no funding occurs": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000
        },
        "property_mocks": {

        },
        "long_inventory": TPosition(side=PositionSide.LONG, current_qty=0),
        "short_inventory": TPosition(side=PositionSide.SHORT, current_qty=1000),
        "both_inventory": TPosition(side=PositionSide.BOTH, current_qty=0),
        "exec": {
            "funding_rate": 0,
            "next_funding_time": 0
        },
        "expected": {
            "balance": 1,
            "total_funding_cost_margin": 0,
            "total_funding_cost_cnt": 0,
            "total_short_funding_cost": 0,
            "total_long_funding_cost": 0
        },
    },
    "apply positive (0.0001) funding hedged short only (recieves funding value) Positive funding rate means long pays short": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000
        },
        "property_mocks": {

        },
        "long_inventory": TPosition(side=PositionSide.LONG, current_qty=0),
        "short_inventory": TPosition(side=PositionSide.SHORT, current_qty=1000), #Shorts recieve from longs
        "both_inventory": TPosition(side=PositionSide.BOTH, current_qty=0),
        "exec": {
            "funding_rate": 0.0001,
            "next_funding_time": _time1
        },
        "expected": {
            "balance": 1.0001,
            "total_funding_cost_margin": -0.0001,
            "total_funding_cost_cnt": -0.1,
            "total_short_funding_cost": -0.1,
            "total_long_funding_cost": 0,
            "next_funding_time": _time1
        },
    },
    "apply positive (0.0001) funding hedged long only (recieves funding value) Negative funding rate means short pays long": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000
        },
        "property_mocks": {

        },
        "long_inventory": TPosition(side=PositionSide.LONG, current_qty=1000), # Longs recieve from shorts
        "short_inventory": TPosition(side=PositionSide.SHORT, current_qty=0), 
        "both_inventory": TPosition(side=PositionSide.BOTH, current_qty=0),
        "exec": {
            "funding_rate": -0.0001,
            "next_funding_time": _time1
        },
        "expected": {
            "balance": 1.0001,
            "total_funding_cost_margin": -0.0001,
            "total_funding_cost_cnt": -0.1,
            "total_short_funding_cost": 0,
            "total_long_funding_cost": -0.1,
            "next_funding_time": _time1
        },
    },

    "apply negative (-0.0001) funding hedged short only (removes funding value) Negative funding rate means short pays long": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000
        },
        "property_mocks": {

        },
        "long_inventory": TPosition(side=PositionSide.LONG, current_qty=0),
        "short_inventory": TPosition(side=PositionSide.SHORT, current_qty=1000), # Shorts pay longs
        "both_inventory": TPosition(side=PositionSide.BOTH, current_qty=0),
        "exec": {
            "funding_rate": -0.0001,
            "next_funding_time": _time1
        },
        "expected": {
            "balance": 0.9999,
            "total_funding_cost_margin": 0.0001,
            "total_funding_cost_cnt": 0.1,
            "total_short_funding_cost": 0.1,
            "total_long_funding_cost": 0,
            "next_funding_time": _time1
        },
    },

    "apply positive (0.0001) funding hedged long only (removes funding value) Positive funding rate means long pays short": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000
        },
        "property_mocks": {

        },
        "long_inventory": TPosition(side=PositionSide.LONG, current_qty=1000), # Longs pay shorts
        "short_inventory": TPosition(side=PositionSide.SHORT, current_qty=0),
        "both_inventory": TPosition(side=PositionSide.BOTH, current_qty=0),
        "exec": {
            "funding_rate": 0.0001,
            "next_funding_time": _time1
        },
        "expected": {
            "balance": 0.9999,
            "total_funding_cost_margin": 0.0001,
            "total_funding_cost_cnt": 0.1,
            "total_short_funding_cost": 0,
            "total_long_funding_cost": 0.1,
            "next_funding_time": _time1
        },
    },

    "apply positive (0.0001) funding hedged long and short (position sizes nullify) Position sizes nullify cost": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000
        },
        "property_mocks": {

        },
        "long_inventory": TPosition(side=PositionSide.LONG, current_qty=1000), # Longs pay shorts
        "short_inventory": TPosition(side=PositionSide.SHORT, current_qty=1000), # Shorts recieve from longs
        "both_inventory": TPosition(side=PositionSide.BOTH, current_qty=0),
        "exec": {
            "funding_rate": 0.0001,
            "next_funding_time": _time1
        },
        "expected": {
            "balance": 1,
            "total_funding_cost_margin": 0.0000,
            "total_funding_cost_cnt": 0,
            "total_short_funding_cost": -0.1,
            "total_long_funding_cost": 0.1,
            "next_funding_time": _time1
        },
    },


    "apply negative (-0.0001) funding hedged long and short (position sizes nullify) Position sizes nullify cost": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000
        },
        "property_mocks": {

        },
        "long_inventory": TPosition(side=PositionSide.LONG, current_qty=1000), # Longs recieve from shorts
        "short_inventory": TPosition(side=PositionSide.SHORT, current_qty=1000), # Shorts pay longs
        "both_inventory": TPosition(side=PositionSide.BOTH, current_qty=0),
        "exec": {
            "funding_rate": -0.0001,
            "next_funding_time": _time1
        },
        "expected": {
            "balance": 1,
            "total_funding_cost_margin": 0.0000,
            "total_funding_cost_cnt": 0,
            "total_short_funding_cost": 0.1,
            "total_long_funding_cost": -0.1,
            "next_funding_time": _time1
        },
    },

    "apply negative (-0.0001) funding hedged long and short (position sizes 1 short/2 long)": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000
        },
        "property_mocks": {

        },
        "long_inventory": TPosition(side=PositionSide.LONG, current_qty=2000), # Longs recieve from shorts
        "short_inventory": TPosition(side=PositionSide.SHORT, current_qty=1000), # Shorts pay longs
        "both_inventory": TPosition(side=PositionSide.BOTH, current_qty=0),
        "exec": {
            "funding_rate": -0.0001,
            "next_funding_time": _time1
        },
        "expected": {
            "balance": 1.0001,
            "total_funding_cost_margin": -0.0001,
            "total_funding_cost_cnt": -0.1,
            "total_short_funding_cost": 0.1,
            "total_long_funding_cost": -0.2,
            "next_funding_time": _time1
        },
    },

    "apply negative (-0.0001) funding hedged long and short (position sizes 2 short/1 long)": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000
        },
        "property_mocks": {

        },
        "long_inventory": TPosition(side=PositionSide.LONG, current_qty=1000), # Longs recieve from shorts
        "short_inventory": TPosition(side=PositionSide.SHORT, current_qty=2000), # Shorts pay longs
        "both_inventory": TPosition(side=PositionSide.BOTH, current_qty=0),
        "exec": {
            "funding_rate": -0.0001,
            "next_funding_time": _time1
        },
        "expected": {
            "balance": 0.9999,
            "total_funding_cost_margin": 0.0001,
            "total_funding_cost_cnt": 0.1,
            "total_short_funding_cost": 0.2,
            "total_long_funding_cost": -0.1,
            "next_funding_time": _time1
        },
    },

    "apply positive (0.0001) funding hedged long and short (position sizes 1 short/2 long)": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000
        },
        "property_mocks": {

        },
        "long_inventory": TPosition(side=PositionSide.LONG, current_qty=2000), # Longs recieve from shorts
        "short_inventory": TPosition(side=PositionSide.SHORT, current_qty=1000), # Shorts pay longs
        "both_inventory": TPosition(side=PositionSide.BOTH, current_qty=0),
        "exec": {
            "funding_rate": 0.0001,
            "next_funding_time": _time1
        },
        "expected": {
            "balance": 0.9999,
            "total_funding_cost_margin": 0.0001,
            "total_funding_cost_cnt": 0.1,
            "total_short_funding_cost": -0.1,
            "total_long_funding_cost": 0.2,
            "next_funding_time": _time1
        },
    },

    "apply positive (0.0001) funding hedged long and short (position sizes 2 short/1 long)": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000
        },
        "property_mocks": {

        },
        "long_inventory": TPosition(side=PositionSide.LONG, current_qty=1000), # Longs recieve from shorts
        "short_inventory": TPosition(side=PositionSide.SHORT, current_qty=2000), # Shorts pay longs
        "both_inventory": TPosition(side=PositionSide.BOTH, current_qty=0),
        "exec": {
            "funding_rate": 0.0001,
            "next_funding_time": _time1
        },
        "expected": {
            "balance": 1.0001,
            "total_funding_cost_margin": -0.0001,
            "total_funding_cost_cnt": -0.1,
            "total_short_funding_cost": -0.2,
            "total_long_funding_cost": 0.1,
            "next_funding_time": _time1
        },
    },


    "apply positive (0.0001) funding combined short -1000 (longs pay shorts)": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000
        },
        "property_mocks": {

        },
        "long_inventory": TPosition(side=PositionSide.LONG, current_qty=0), # Longs recieve from shorts
        "short_inventory": TPosition(side=PositionSide.SHORT, current_qty=0), # Shorts pay longs
        "both_inventory": TPosition(side=PositionSide.BOTH, current_qty=-1000),
        "exec": {
            "funding_rate": 0.0001,
            "next_funding_time": _time1
        },
        "expected": {
            "balance": 1.0001,
            "total_funding_cost_margin": -0.0001,
            "total_funding_cost_cnt": -0.1,
            "total_short_funding_cost": -0.1,
            "total_long_funding_cost": 0.0,
            "next_funding_time": _time1
        },
    },


    "apply negative (-0.0001) funding combined short -1000 (shorts pay longs)": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000
        },
        "property_mocks": {

        },
        "long_inventory": TPosition(side=PositionSide.LONG, current_qty=0), # Longs recieve from shorts
        "short_inventory": TPosition(side=PositionSide.SHORT, current_qty=0), # Shorts pay longs
        "both_inventory": TPosition(side=PositionSide.BOTH, current_qty=-1000),
        "exec": {
            "funding_rate": -0.0001,
            "next_funding_time": _time1
        },
        "expected": {
            "balance": 0.9999,
            "total_funding_cost_margin": 0.0001,
            "total_funding_cost_cnt": 0.1,
            "total_short_funding_cost": 0.1,
            "total_long_funding_cost": 0.0,
            "next_funding_time": _time1
        },
    },

    
    "apply positive (0.0001) funding combined long 1000 (longs pay shorts)": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000
        },
        "property_mocks": {

        },
        "long_inventory": TPosition(side=PositionSide.LONG, current_qty=0), # Longs recieve from shorts
        "short_inventory": TPosition(side=PositionSide.SHORT, current_qty=0), # Shorts pay longs
        "both_inventory": TPosition(side=PositionSide.BOTH, current_qty=1000),
        "exec": {
            "funding_rate": 0.0001,
            "next_funding_time": _time1
        },
        "expected": {
            "balance": 0.9999,
            "total_funding_cost_margin": 0.0001,
            "total_funding_cost_cnt": 0.1,
            "total_short_funding_cost": 0,
            "total_long_funding_cost": 0.1,
            "next_funding_time": _time1
        },
    },
    "apply negative (-0.0001) funding combined long 1000 (shorts pay longs)": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000
        },
        "property_mocks": {

        },
        "long_inventory": TPosition(side=PositionSide.LONG, current_qty=0), # Longs recieve from shorts
        "short_inventory": TPosition(side=PositionSide.SHORT, current_qty=0), # Shorts pay longs
        "both_inventory": TPosition(side=PositionSide.BOTH, current_qty=1000),
        "exec": {
            "funding_rate": -0.0001,
            "next_funding_time": _time1
        },
        "expected": {
            "balance": 1.0001,
            "total_funding_cost_margin": -0.0001,
            "total_funding_cost_cnt": -0.1,
            "total_short_funding_cost": 0.0,
            "total_long_funding_cost": -0.1,
            "next_funding_time": _time1
        },
    },
}
@pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
def test_apply_funding(monkeypatch, case):
    if "do_skip" in case and case["do_skip"]:pytest.skip("Case marked as skipped") 

    account = Account(**case["args"])

    def add_acc(pos, acc):
        pos.account = acc
        return pos

    if "long_inventory" in case: account.long_inventory = add_acc(case["long_inventory"], account)
    if "short_inventory" in case: account.short_inventory = add_acc(case["short_inventory"], account)
    if "both_inventory" in case: account.both_inventory = add_acc(case["both_inventory"], account)

    if "property_mocks" in case:
        for m,v in case["property_mocks"].items():
            def get_value(self):return v
            monkeypatch.setattr(Account, m, property(get_value))

    account.apply_funding(**case["exec"], time=TEST_TIME)

    ex = case["expected"]
    for e in ex.items():
        if not getattr(account, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(account, e[0]))+"!="+str(e[1]))



cases = { #TODO test realized pnl
    "long_to_longer" : {
        "args": {
            "balance": 500,
            "position": 100,
            "last_price": 10,
            "mark_price": 10,
            "leverage": 1,
        },
        "mocks": {
            "average_entry_price": 10,
        },
        "raises": None,
        "execution": 100,
        "price": 10,
        "fee": -0.00025,
        "expected_balance": 490.0025,
        "expected_position": 200,
        "expected_case": "open",
        "expected_cost": -0.025,
        "expected_rpnl": 0,
        "expected_amt": 9.9975
    },
    "longer_to_long" : {
        "args": {
            "balance": 500,
            "position": 100,
            "last_price": 10,
            "mark_price": 10,
            "leverage": 1,
        },
        "mocks": {
            "average_entry_price": 10,
        },
        "raises": None,
        "execution": -50,
        "price": 10,
        "fee": -0.00025,
        "expected_balance": 505.00125,
        "expected_position": 50,
        "expected_case": "close",
        "expected_cost": -0.0125,
        "expected_rpnl": 0,
        "expected_amt": 5.00125
    },
    "long_to_flat" : {
        "args": {
            "balance": 500,
            "position": 100,
            "last_price": 10,
            "mark_price": 10,
            "leverage": 1,
        },
        "mocks": {
            "average_entry_price": 10,
        },
        "raises": None,
        "execution": -100,
        "price": 10,
        "fee": -0.00025,
        "expected_balance": 510.0025,
        "expected_position": 0,
        "expected_case": "close",
        "expected_cost": -0.025,
        "expected_rpnl": 0,
        "expected_amt": 10.0025
    },
    "longer_to_short" : {
        "args": {
            "balance": 500,
            "position": 100,
            "last_price": 10,
            "mark_price": 10,
            "leverage": 1,
        },
        "mocks": {
            "average_entry_price": 10,
        },
        "raises": None,
        "execution": -150,
        "price": 10,
        "fee": -0.00025,
        "expected_balance": 505.00375,
        "expected_position": -50,
        "expected_case": "cross",
        "expected_cost": -0.0375,
        "expected_rpnl": 0,
        "expected_amt": 5.00375
    },
    "long_to_short" : {
        "args": {
            "balance": 500,
            "position": 100,
            "last_price": 10,
            "mark_price": 10,
            "leverage": 1,
        },
        "mocks": {
            "average_entry_price": 10,
        },
        "raises": None,
        "execution": -200,
        "price": 10,
        "fee": -0.00025,
        "expected_balance": 500.005,
        "expected_position": -100,
        "expected_case": "cross",
        "expected_cost": -0.05,
        "expected_rpnl": 0,
        "expected_amt": 0.005
    },
    "long_to_shorter" : {
        "args": {
            "balance": 500,
            "position": 100,
            "last_price": 10,
            "mark_price": 10,
            "leverage": 1,
        },
        "mocks": {
            "average_entry_price": 10,
        },
        "raises": None,
        "execution": -250,
        "price": 10,
        "fee": -0.00025,
        "expected_balance": 495.00625,
        "expected_position": -150,
        "expected_case": "cross",
        "expected_cost": -0.0625,
        "expected_rpnl": 0,
        "expected_amt": -4.99375
    },
    "short_to_shorter" : {
        "args": {
            "balance": 500,
            "position": -100,
            "last_price": 10,
            "mark_price": 10,
            "leverage": 1,
        },
        "mocks": {
            "average_entry_price": 10,
        },
        "raises": None,
        "execution": -100,
        "price": 10,
        "fee": -0.00025,
        "expected_balance": 490.0025,
        "expected_position": -200,
        "expected_case": "open",
        "expected_cost": -0.025,
        "expected_rpnl": 0,
        "expected_amt": 9.9975
    },
    "shorter_to_short" : {
        "args": {
            "balance": 500,
            "position": -100,
            "last_price": 10,
            "mark_price": 10,
            "leverage": 1,
        },
        "mocks": {
            "average_entry_price": 10,
        },
        "raises": None,
        "execution": 50,
        "price": 10,
        "fee": -0.00025,
        "expected_balance": 505.00125,
        "expected_position": -50,
        "expected_case": "close",
        "expected_cost": -0.0125,
        "expected_rpnl": 0,
        "expected_amt": 5.00125
    },
    "short_to_flat" : {
        "args": {
            "balance": 500,
            "position": -100,
            "last_price": 10,
            "mark_price": 10,
            "leverage": 1,
        },
        "mocks": {
            "average_entry_price": 10,
        },
        "raises": None,
        "execution": 100,
        "price": 10,
        "fee": -0.00025,
        "expected_balance": 510.0025,
        "expected_position": 0,
        "expected_case": "close",
        "expected_cost": -0.025,
        "expected_rpnl": 0,
        "expected_amt": 10.0025
    },
    "shorter_to_long" : {
        "args": {
            "balance": 500,
            "position": -100,
            "last_price": 10,
            "mark_price": 10,
            "leverage": 1,
        },
        "mocks": {
            "average_entry_price": 10,
        },
        "raises": None,
        "execution": 150,
        "price": 10,
        "fee": -0.00025,
        "expected_balance": 505.00375,
        "expected_position": 50,
        "expected_case": "cross",
        "expected_cost": -0.0375,
        "expected_rpnl": 0,
        "expected_amt": 5.00375
    },
    "short_to_long" : {
        "args": {
            "balance": 500,
            "position": -100,
            "last_price": 10,
            "mark_price": 10,
            "leverage": 1,
        },
        "mocks": {
            "average_entry_price": 10,
        },
        "raises": None,
        "execution": 200,
        "price": 10,
        "fee": -0.00025,
        "expected_balance": 500.005,
        "expected_position": 100,
        "expected_case": "cross",
        "expected_cost": -0.05,
        "expected_rpnl": 0,
        "expected_amt": 0.005
    },
    "short_to_longer" : {
        "args": {
            "balance": 500,
            "position": -100,
            "last_price": 10,
            "mark_price": 10,
            "leverage": 1,
        },
        "mocks": {
            "average_entry_price": 10,
        },
        "raises": None,
        "execution": 250,
        "price": 10,
        "fee": -0.00025,
        "expected_balance": 495.00625,
        "expected_position": 150,
        "expected_case": "cross",
        "expected_cost": -0.0625,
        "expected_rpnl": 0,
        "expected_amt": -4.99375
    },
    #TODO test realized pnl

    "short_to_flat_rpl_-50" : {
        "args": {
            "balance": 500,
            "position": -100,
            "last_price": 10,
            "mark_price": 10,
            "leverage": 1,
        },
        "mocks": {
            "average_entry_price": 10,
        },
        "raises": None,
        "execution": 100,
        "price": 20,
        "fee": -0.00025,
        "expected_balance": 500.00125,
        "expected_position": 0,
        "expected_case": "close",
        "expected_cost": -0.025,
        "expected_rpnl": -5,
        "expected_amt": 5.00125
    },
    "long_to_flat_rpl_-50" : {
        "args": {
            "balance": 500,
            "position": 100,
            "last_price": 10,
            "mark_price": 10,
            "leverage": 1,
        },
        "mocks": {
            "average_entry_price": 10,
        },
        "raises": None,
        "execution": -100,
        "price": 20,
        "fee": -0.00025,
        "expected_balance": 510.00125,
        "expected_position": 0,
        "expected_case": "close",
        "expected_cost": -0.025,
        "expected_rpnl": 5,
        "expected_amt": 5.00125
    },
    "long_to_short_rpl_-50" : {
        "args": {
            "balance": 500,
            "position": 100,
            "last_price": 10,
            "mark_price": 10,
            "leverage": 1,
        },
        "mocks": {
            "average_entry_price": 10,
        },
        "raises": None,
        "execution": -200,
        "price": 20,
        "fee": -0.00025,
        "expected_balance": 505.0025,
        "expected_position": -100,
        "expected_case": "cross",
        "expected_cost": -0.05,
        "expected_rpnl": 5,
        "expected_amt": 0.0025
    },
    
} #TODO implement
@pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
@pytest.mark.skip("need to convert the position to account")
def test_exec(monkeypatch, case):
    if "mocks" in case:
        for m,v in case["mocks"].items():
            def get_value(self):return v
            monkeypatch.setattr(Position, m, property(get_value))

    position = Position(**case["args"])

    tpe, rpl, cost, amt = position._exec(
        execution=case["execution"],
        price=case["price"],
        fee=case["fee"]
    )


    assert tpe == case["expected_case"]
    assert rpl == case["expected_rpnl"]
    assert cost == case["expected_cost"]
    assert amt == case["expected_amt"]

# INTEGRATION TEST 
# ============================================================================>
cases = {
    # OPEN HEDGED POSITION (ONE ACTIVE POSITION)
    "fill hedged position open short inventory with short position": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.HEDGE,
            "max_leverage": 1
        },
        "property_mocks": {
            
        },
        "positions": {
            "long_inventory": {
                "initial":TPosition(side=PositionSide.LONG, current_qty=0),
                "expected": {
                    "abs_qty": 0
                }
            },
            "short_inventory": {
                "initial":TPosition(side=PositionSide.SHORT, current_qty=100),
                "expected": {
                    "abs_qty": 200, # TODO total open amount etc
                    "exec_costs": 10000000
                }
            },
            "both_inventory": {
                "initial":TPosition(side=PositionSide.BOTH, current_qty=0),
                "expected": {
                    "abs_qty": 0
                }
            },
        },
        "exec": {
            "fill_qty": 100,
            "price": 1000,
            "side": Side.SELL,
            "is_maker": False,
            "close": False
        },
        "expected": {
            "balance": 0.899925, # 1- ((100 /1000) + (100/1000)*0.00075) 
        },
    },
    "fill hedged position open long inventory with long position": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.HEDGE,
            "max_leverage": 1
        },
        "property_mocks": {
            
        },
        "positions": {
            "long_inventory": {
                "initial":TPosition(side=PositionSide.LONG, current_qty=100),
                "expected": {
                    "abs_qty": 200, # TODO total open amount etc.
                    "total_entry": 100,
                    "exec_costs": 10000000
                }
            },
            "short_inventory": {
                "initial":TPosition(side=PositionSide.SHORT, current_qty=0),
                "expected": {
                    "abs_qty": 0,
                }
            },
            "both_inventory": {
                "initial":TPosition(side=PositionSide.BOTH, current_qty=0),
                "expected": {
                    "abs_qty": 0
                }
            },
        },
        "exec": {
            "fill_qty": 100,
            "price": 1000,
            "side": Side.BUY,
            "is_maker": False,
            "close": False
        },
        "expected": {
            "balance": 0.899925, # 1- ((100 /1000) + (100/1000)*0.00075) 
        },
    },
    # CLOSE HEDGED POSITION (ONE ACTIVE POSITION)
    "CLOSE HEDGED POSITION: fill hedged position close long, inventory with long position": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.HEDGE,
            "max_leverage": 1
        }, 
        "positions": {
            "long_inventory": {
                "initial":TPosition(side=PositionSide.LONG, current_qty=200),
                "mocks": {
                    "total_entry": 200,
                    "exec_costs": 20000000,
                },
                "expected": {
                    "abs_qty": 100,
                    "average_entry_price": 1000
                }
            },
            "short_inventory": {
                "initial":TPosition(side=PositionSide.SHORT, current_qty=0), 
                "expected": {
                    "abs_qty": 0
                }
            },
            "both_inventory": {
                "initial":TPosition(side=PositionSide.BOTH, current_qty=0),
                "mocks": {
                    "total_entry": 1000,
                },
                "expected": {
                    "abs_qty": 0
                }
            },
        },
        "exec": {
            "fill_qty": 100,
            "price": 1000, # ASSUMES no realized pnl
            "side": Side.BUY,
            "is_maker": False,
            "close": True
        },
        "expected": {
            "balance": 1.099925, # 1+ ((100 /1000) + (100/1000)*0.00075) 
        },
    },
    "CLOSE HEDGED POSITION: fill hedged position close short, inventory with short position": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.HEDGE,
            "max_leverage": 1
        }, 
        "positions": {
            "long_inventory": {
                "initial":TPosition(side=PositionSide.LONG, current_qty=0),
                "expected": {
                    "abs_qty": 0
                }
            },
            "short_inventory": {
                "initial":TPosition(side=PositionSide.SHORT, current_qty=200), 
                "mocks": {
                    "total_entry": 200,
                    "exec_costs": 20000000,
                },
                "expected": {
                    "abs_qty": 100,
                    "average_entry_price": 1000
                }
            },
            "both_inventory": {
                "initial":TPosition(side=PositionSide.BOTH, current_qty=0),
                "mocks": {
                    "total_entry": 1000,
                },
                "expected": {
                    "abs_qty": 0
                }
            },
        },
        "exec": {
            "fill_qty": 100,
            "price": 1000, # ASSUMES no realized pnl
            "side": Side.SELL,
            "is_maker": False,
            "close": True
        },
        "expected": {
            "balance": 1.099925, # 1+ ((100 /1000) + (100/1000)*0.00075) 
        },
    },
    # FLATTEN HEDGED POSITION (ONE ACTIVE POSITION)
    "FLATTEN HEDGED POSITION: fill hedged position close long, inventory with long position": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.HEDGE,
            "max_leverage": 1
        }, 
        "positions": {
            "long_inventory": {
                "initial":TPosition(side=PositionSide.LONG, current_qty=200),
                "mocks": {
                    "total_entry": 200,
                    "exec_costs": 20000000,
                },
                "expected": {
                    "abs_qty": 0,
                    "average_entry_price": 0
                }
            },
            "short_inventory": {
                "initial":TPosition(side=PositionSide.SHORT, current_qty=0), 
                "expected": {
                    "abs_qty": 0
                }
            },
            "both_inventory": {
                "initial":TPosition(side=PositionSide.BOTH, current_qty=0),
                "mocks": {
                    "total_entry": 1000,
                },
                "expected": {
                    "abs_qty": 0
                }
            },
        },
        "exec": {
            "fill_qty": 200,
            "price": 1000, # ASSUMES no realized pnl
            "side": Side.BUY,
            "is_maker": False,
            "close": True
        },
        "expected": {
            "balance": 1.19985, # 1+ ((100 /1000) + (100/1000)*0.00075) 
        },
    },
    "FLATTEN HEDGED POSITION: fill hedged position close short, inventory with short position": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.HEDGE,
            "max_leverage": 1
        }, 
        "positions": {
            "long_inventory": {
                "initial":TPosition(side=PositionSide.LONG, current_qty=0),
                "expected": {
                    "abs_qty": 0
                }
            },
            "short_inventory": {
                "initial":TPosition(side=PositionSide.SHORT, current_qty=200), 
                "mocks": {
                    "total_entry": 200,
                    "exec_costs": 20000000,
                },
                "expected": {
                    "abs_qty": 0,
                    "average_entry_price": 0,
                    "current_qty": 0
                }
            },
            "both_inventory": {
                "initial":TPosition(side=PositionSide.BOTH, current_qty=0),
                "mocks": {
                    "total_entry": 1000,
                },
                "expected": {
                    "abs_qty": 0
                }
            },
        },
        "exec": {
            "fill_qty": 200,
            "price": 1000, # ASSUMES no realized pnl
            "side": Side.SELL,
            "is_maker": False,
            "close": True
        },
        "expected": {
            "balance": 1.19985, # 1+ ((100 /1000) + (100/1000)*0.00075) 
        },
    },
    # OPEN HEDGED POSITION (TWO ACTIVE POSITIONS)
    "fill hedged position open short inventory with short position and long position": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.HEDGE,
            "max_leverage": 1
        },
        "property_mocks": {
            
        },
        "positions": {
            "long_inventory": {
                "initial":TPosition(side=PositionSide.LONG, current_qty=100),
                "expected": {
                    "abs_qty": 100
                }
            },
            "short_inventory": {
                "initial":TPosition(side=PositionSide.SHORT, current_qty=100),
                "expected": {
                    "abs_qty": 200, # TODO total open amount etc
                    "exec_costs": 10000000,
                    "current_qty": -200
                }
            },
            "both_inventory": {
                "initial":TPosition(side=PositionSide.BOTH, current_qty=0),
                "expected": {
                    "abs_qty": 0
                }
            },
        },
        "exec": {
            "fill_qty": 100,
            "price": 1000,
            "side": Side.SELL,
            "is_maker": False,
            "close": False
        },
        "expected": {
            "balance": 0.899925, # 1- ((100 /1000) + (100/1000)*0.00075) 
        },
    },
    "fill hedged position open long inventory with long position and short position": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.HEDGE,
            "max_leverage": 1
        }, 
        "positions": {
            "long_inventory": {
                "initial":TPosition(side=PositionSide.LONG, current_qty=100),
                "expected": {
                    "abs_qty": 200, # TODO total open amount etc.
                    "total_entry": 100,
                    "exec_costs": 10000000
                }
            },
            "short_inventory": {
                "initial":TPosition(side=PositionSide.SHORT, current_qty=100),
                "expected": {
                    "abs_qty": 100,
                    "current_qty": -100
                }
            },
            "both_inventory": {
                "initial":TPosition(side=PositionSide.BOTH, current_qty=0),
                "expected": {
                    "abs_qty": 0
                }
            },
        },
        "exec": {
            "fill_qty": 100,
            "price": 1000,
            "side": Side.BUY,
            "is_maker": False,
            "close": False
        },
        "expected": {
            "balance": 0.899925, # 1- ((100 /1000) + (100/1000)*0.00075) 
        },
    },
    # CLOSE HEDGED POSITION (TWO ACTIVE POSITIONS)
    "CLOSE HEDGED POSITION: fill hedged position close long, inventory with long position and short position": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.HEDGE,
            "max_leverage": 1
        }, 
        "positions": {
            "long_inventory": {
                "initial":TPosition(side=PositionSide.LONG, current_qty=200),
                "mocks": {
                    "total_entry": 200,
                    "exec_costs": 20000000,
                },
                "expected": {
                    "abs_qty": 100,
                    "average_entry_price": 1000
                }
            },
            "short_inventory": {
                "initial":TPosition(side=PositionSide.SHORT, current_qty=100), 
                "expected": {
                    "abs_qty": 100,
                    "current_qty": -100
                }
            },
            "both_inventory": {
                "initial":TPosition(side=PositionSide.BOTH, current_qty=0),
                "mocks": {
                    "total_entry": 1000,
                },
                "expected": {
                    "abs_qty": 0
                }
            },
        },
        "exec": {
            "fill_qty": 100,
            "price": 1000, # ASSUMES no realized pnl
            "side": Side.BUY,
            "is_maker": False,
            "close": True
        },
        "expected": {
            "balance": 1.099925, # 1+ ((100 /1000) + (100/1000)*0.00075) 
        },
    },
    "CLOSE HEDGED POSITION: fill hedged position close short, inventory with short position and long position": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.HEDGE,
            "max_leverage": 1
        }, 
        "positions": {
            "long_inventory": {
                "initial":TPosition(side=PositionSide.LONG, current_qty=100),
                "expected": {
                    "abs_qty": 100
                }
            },
            "short_inventory": {
                "initial":TPosition(side=PositionSide.SHORT, current_qty=200), 
                "mocks": {
                    "total_entry": 200,
                    "exec_costs": 20000000,
                },
                "expected": {
                    "abs_qty": 100,
                    "average_entry_price": 1000,
                    "current_qty": -100
                }
            },
            "both_inventory": {
                "initial":TPosition(side=PositionSide.BOTH, current_qty=0),
                "mocks": {
                    "total_entry": 1000,
                },
                "expected": {
                    "abs_qty": 0
                }
            },
        },
        "exec": {
            "fill_qty": 100,
            "price": 1000, # ASSUMES no realized pnl
            "side": Side.SELL,
            "is_maker": False,
            "close": True
        },
        "expected": {
            "balance": 1.099925, # 1+ ((100 /1000) + (100/1000)*0.00075) 
        },
    },
    # ==========================================================================================>
    # BOTH POSITION OPEN
    "BOTH POSITION: open short position": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.COMBINED,
            "max_leverage": 1
        },
        "positions": {
            "both_inventory": {
                "initial":TPosition(side=PositionSide.BOTH, current_qty=0),
                "expected": {
                    "current_qty": -100
                }
            },
        },
        "exec": {
            "fill_qty": 100,
            "price": 1000,
            "side": Side.SELL,
            "is_maker": False,
            "close": False
        },
        "expected": {
            "balance": 0.899925, # 1- ((100 /1000) + (100/1000)*0.00075) 
        },
    },
    "BOTH POSITION: open long position": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.COMBINED,
            "max_leverage": 1
        },
        "positions": {
            "both_inventory": {
                "initial":TPosition(side=PositionSide.BOTH, current_qty=0),
                "expected": {
                    "current_qty": 100
                }
            },
        },
        "exec": {
            "fill_qty": 100,
            "price": 1000,
            "side": Side.BUY,
            "is_maker": False,
            "close": False
        },
        "expected": {
            "balance": 0.899925, # 1- ((100 /1000) + (100/1000)*0.00075) 
        },
    },
    # BOTH position close
    "BOTH POSITION: close short position": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.COMBINED,
            "max_leverage": 1
        },
        "positions": {
            "both_inventory": {
                "initial":TPosition(side=PositionSide.BOTH, current_qty=-200),
                "mocks": {
                    "total_entry": 200,
                    "exec_costs": 20000000,
                },
                "expected": {
                    "abs_qty": 100,
                    "current_qty": -100
                }
            },
        },
        "exec": {
            "fill_qty": 100,
            "price": 1000,
            "side": Side.BUY,
            "is_maker": False,
            "close": True
        },
        "expected": {
            "balance": 1.099925, # 1- ((100 /1000) + (100/1000)*0.00075) 
        },
    },
    "BOTH POSITION: close long position": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.COMBINED,
            "max_leverage": 1
        },
        "positions": {
            "both_inventory": {
                "initial":TPosition(side=PositionSide.BOTH, current_qty=200),
                "mocks": {
                    "total_entry": 200,
                    "exec_costs": 20000000,
                },
                "expected": {
                    "abs_qty": 100,
                    "current_qty": 100
                }
            },
        },
        "exec": {
            "fill_qty": 100,
            "price": 1000,
            "side": Side.SELL,
            "is_maker": False,
            "close": True
        },
        "expected": {
            "balance": 1.099925, # 1- ((100 /1000) + (100/1000)*0.00075) 
        },
    },
    # BOTH position cross
    "BOTH POSITION: cross short position to long position": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.COMBINED,
            "max_leverage": 1
        },
        "positions": {
            "both_inventory": {
                "initial":TPosition(side=PositionSide.BOTH, current_qty=-200),
                "mocks": {
                    "total_entry": 200,
                    "exec_costs": 20000000,
                },
                "expected": {
                    "abs_qty": 100,
                    "current_qty": 100
                }
            },
        },
        "exec": {
            "fill_qty": 300,
            "price": 1000,
            "side": Side.BUY,
            "is_maker": False
        },
        "expected": {
            "balance": 1.099775, # 1- ((100 /1000) + (100/1000)*0.00075) 
        },
    },
    "BOTH POSITION: cross long position to short position": {
        "args": {
            "balance": 1,
            "mark_price": 1000,
            "last_price": 1000,
            "commission_manager": FlatFee(-0.00025, 0.00075),
            "position_type": PositionType.COMBINED,
            "max_leverage": 1
        },
        "positions": {
            "both_inventory": {
                "initial":TPosition(side=PositionSide.BOTH, current_qty=200),
                "mocks": {
                    "total_entry": 200,
                    "exec_costs": 20000000,
                },
                "expected": {
                    "abs_qty": 100,
                    "current_qty": -100
                }
            },
        },
        "exec": {
            "fill_qty": 300,
            "price": 1000,
            "side": Side.SELL,
            "is_maker": False
        },
        "expected": {
            "balance": 1.099775, # 1- ((100 /1000) + (100/1000)*0.00075) 
        },
    },
}
@pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
def test_add_fill(monkeypatch, case):
    if "do_skip" in case and case["do_skip"]:pytest.skip("Case marked as skipped") 

    account = Account(**case["args"])


    def add_acc(pos, acc):
        pos.account = acc
        return pos

    pos = case["positions"]
    if "long_inventory" in pos: 
        p = pos["long_inventory"]
        account.long_inventory = add_acc(p["initial"], account)
        if "mocks" in p:
            for m,v in p["mocks"].items():
                setattr(account.long_inventory, m, v)

    if "short_inventory" in pos: 
        p = pos["short_inventory"]
        account.short_inventory = add_acc(p["initial"], account)
        if "mocks" in p:
            for m,v in p["mocks"].items():
                setattr(account.short_inventory, m, v)
    
    if "both_inventory" in pos: 
        p = pos["both_inventory"]
        account.both_inventory = add_acc(p["initial"], account)
        if "mocks" in p:
            for m,v in p["mocks"].items():
                setattr(account.both_inventory, m, v)

    if "property_mocks" in case:
        for m,v in case["property_mocks"].items():
            def get_value(self):return v
            monkeypatch.setattr(Account, m, property(get_value))

    account.add_fill(**case["exec"], time=TEST_TIME)

    def loop_assrt(pos, ex):
        for e in ex.items():
            if not getattr(pos, e[0]) == e[1]:
                pytest.fail(str(pos.side)+"_"+e[0]+":"+str(getattr(pos, e[0]))+"!="+str(e[1]))
    
    # import logging
    # logging.error(account.long_inventory.average_entry_price)

    if "long_inventory" in pos: account.long_inventory = loop_assrt(account.long_inventory, pos["long_inventory"]["expected"])
    if "short_inventory" in pos: account.short_inventory = loop_assrt(account.short_inventory, pos["short_inventory"]["expected"])
    if "both_inventory" in pos: account.both_inventory = loop_assrt(account.both_inventory, pos["both_inventory"]["expected"])

    ex = case["expected"]
    for e in ex.items():
        if not getattr(account, e[0]) == e[1]:
            pytest.fail(e[0]+":"+str(getattr(account, e[0]))+"!="+str(e[1]))

