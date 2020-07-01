import asyncio
import random
import uuid
import time
import pytest 
from env.env import Env
from env.engine.account import Account, FeeType, FlatFee, TieredFee, MarginType, PositionType
from env.models import LimitOrder, Side, Depth
from unittest.mock import patch
import time
import numpy as np
from profilehooks import profile
import logging

@pytest.mark.slow
def test_profile():
    ENV = Env()
    ENV.reset()
    logging.info("ENV PROFILING")
    logging.info("="*90)
    @profile(entries=400)
    def profile_env_step():
        ENV.step(1)
    profile_env_step()

cases = {
    "first": {
        "env_args": {

        },
        "action": 1,
        "expected": {

        }
    }
}
@pytest.mark.parametrize("case", list(cases.values()), ids=list(cases.keys()))
def test_step(monkeypatch, case):
    if "setup" in case:
        case["setup"]()
        
    env = Env( 
        **case["env_args"]
    )

    env.reset()

    env.step(case["action"])

    if "mocks" in case:
        for m,v in case["mocks"].items():
            def get_value(self):return v
            monkeypatch.setattr(Env, m, property(get_value))

    ex = case["expected"]
    for e in ex.items():
        assert getattr(env, e[0]) == e[1]


@pytest.mark.slow
def test_benchmark_process_asks_updates(benchmark):
    env = Env()
    env.reset()
 
    def gen_action():
        return 1

    res = benchmark(env.step, gen_action())
