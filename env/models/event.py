from collections import namedtuple
import enum

class EventType(enum.Enum):
    DEPTH = 1
    TRADE = 2
    DEPOSIT = 3
    WITHDRAWAL = 4
    FUNDING = 5
    MARK = 6
    PLACE_ORDER = 7
    PLACE_BATCH_ORDER = 8
    CANCEL_ORDER = 9
    CANCEL_BATCH_ORDER = 10
    CANCEL_ALL_ORDERS = 11
    AMEND_ORDER = 12
    AMEND_BATCH_ORDERS = 13
    LEVERAGE_UPDATE = 14
    LIQUIDATION = 15
    ORDER_UPDATE = 16
    POSITION_UPDATE = 17
    ACCOUNT_UPDATE = 18
    INSTRUMENT_UPDATE = 19
    FEATURE = 20
    NEW_ORDER = 21
    ORDER_DELETED = 22
    AGENT_FORCED_CLOSE_ORDERS = 23
    AGENT_LIQUIDATED = 24

    @property
    def is_depth(self):return self.value == 1

    @property
    def is_trade(self):return self.value == 2

    @property
    def is_deposit(self):return self.value == 3

    @property
    def is_withdrawal(self):return self.value == 4

    @property
    def is_funding(self):return self.value == 5

    @property
    def is_mark(self):return self.value == 6

    @property
    def is_place_order(self):return self.value == 7

    @property
    def is_place_batch_order(self):return self.value == 8

    @property
    def is_cancel_order(self):return self.value == 9

    @property
    def is_cancel_batch_orders(self):return self.value == 10

    @property
    def is_cancel_all_orders(self):return self.value == 11

    @property
    def is_amend_order(self):return self.value == 12

    @property
    def is_amend_batch_orders(self):return self.value == 13

    @property
    def is_leverage_update(self):return self.value == 14

    @property
    def is_liquidation(self):return self.value == 15

    @property
    def is_order_update(self):return self.value == 16 # Either order create or update event

    @property
    def is_position_update(self):return self.value == 17 # Either order create or update event

    @property
    def is_account_update(self):return self.value == 18 # Either order create or update event

    @property
    def is_instrument_update(self):return self.value == 19 # Either order create or update event

    @property
    def is_feature(self):return self.value == 20 # Either order create or update event

    @property
    def is_new_order(self):return self.value == 21 # Either order create or update event
    
    @property
    def is_order_deleted(self):return self.value == 22 # Either order create or update event

    @property
    def is_forced_close_agent_orders(self): return self.value == 23

    @property
    def is_agent_liquidated(self): return self.value == 24

DEFAULT_ALLOWED_EVENT_TYPES = [
    EventType.DEPTH,
    EventType.TRADE,
    EventType.DEPOSIT,
    EventType.WITHDRAWAL,
    EventType.FUNDING,
    EventType.MARK,
    EventType.PLACE_ORDER,
    EventType.PLACE_BATCH_ORDER,
    EventType.CANCEL_ORDER,
    EventType.CANCEL_BATCH_ORDER,
    EventType.CANCEL_ALL_ORDERS,
    EventType.AMEND_ORDER,
    EventType.AMEND_BATCH_ORDERS,
    EventType.LIQUIDATION
]


class EventAction(enum.Enum):
    NEW = 1
    UPDATE = 2
    DELETE = 3

    @property
    def is_new(self):return self.value == 1

    @property
    def is_update(self):return self.value == 2
    
    @property
    def is_delete(self):return self.value == 2


class Event():
    def __init__(self, **kwargs):
        self.time = kwargs.get("time", 0) 
        self.action = kwargs.get("action", 0) 
        self.typ = kwargs.get("typ", 0) 
        self.datum = kwargs.get("datum", 0) 

# Event = namedtuple(
#     'Event', 
#     ['time','action','typ','datum']
# )
