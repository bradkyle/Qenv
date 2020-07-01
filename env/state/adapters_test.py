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
    "ALL Events Run Through": {
        "action": 1,
        "expected": {}
    }
}
@pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
def test_create_order_at_level(benchmark, monkeypatch, case):
    
    engine = Engine(config={"allowed_event_types": DEFAULT_ALLOWED_EVENT_TYPES})
    state = State(
        engine=engine,
        store=KDBClient(),
        adapter=DiscreteAdapter 
    ) 
    
    