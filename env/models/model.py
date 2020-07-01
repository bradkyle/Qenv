import enum

# Defines models for a common set of attributes that need to be simulated across exchanges

# Base
# ===================================================>

class Model():
    def __init__(self, time, *args, **kwargs):
        self.time = time
    
    @staticmethod
    def parse(cls, msg):
        raise NotImplementedError

class Side(enum.Enum):
    BUY = 1
    SELL = 2

    @property
    def is_buy(self):return self.value == 1

    @property
    def is_sell(self):return self.value == 2

    def __str__(self):
        if self.is_buy:
            return "buy"
        elif self.is_sell:
            return "sell"
    

class PositionSide(enum.Enum):
    SHORT = 1
    LONG = 2
    BOTH = 3

    @property
    def is_short(self):return self.value == 1

    @property
    def is_long(self):return self.value == 2

    @property
    def is_both(self):return self.value == 3

    def __str__(self):
        if self.is_long:
            return "long"
        elif self.is_short:
            return "short"
        elif self.is_both:
            return "both"

    @staticmethod
    def from_str(tstr):
        if tstr == "short":
            return PositionSide.SHORT
        elif tstr == "long":
            return PositionSide.LONG
        elif tstr == "both":
            return PositionSide.BOTH
        else:
            raise ValueError("Invalid side type: "+str(tstr))

class MarginType(enum.Enum):
    ISOLATED = 1
    CROSS = 2

    @property
    def is_isolated(self):return self.value == 1

    @property
    def is_cross(self):return self.value == 2

    
    def __str__(self):
        if self.is_isolated:
            return "isolated"
        elif self.is_cross:
            return "cross"

class StopTrigger(enum.Enum):
    MARK_PRICE = 1
    LAST_PRICE = 2
    INDEX_PRICE = 3

    @property
    def is_mark(self):return self.value == 1

    @property
    def is_last(self):return self.value == 2

    @property
    def is_index(self):return self.value == 3

    def __str__(self):
        if self.is_mark:
            return "mark"
        elif self.is_last:
            return "last"
        elif self.is_index:
            return "index"

class StopState(enum.Enum):
    UNTRIGGERED = 1
    TRIGGERED = 2
    FILLED = 3

    @property
    def is_untriggered(self):return self.value == 1

    @property
    def is_triggered(self):return self.value == 2

    @property
    def is_filled(self):return self.value == 3

    def __str__(self):
        if self.is_untriggered:
            return "untriggered"
        elif self.is_triggered:
            return "triggered"
        elif self.is_filled:
            return "filled"

class OrderState(enum.Enum):
    NEW = 1
    CANCELLED = 2
    FILLED = 3
    PARTIALLY_FILLED = 4

    @property
    def is_new(self):return self.value == 1

    @property
    def is_cancelled(self):return self.value == 2

    @property
    def is_filled(self):return self.value == 3

    @property
    def is_partially_filled(self):return self.value == 4

    def __str__(self):
        if self.is_new:
            return "new"
        elif self.is_cancelled:
            return "cancelled"
        elif self.is_filled:
            return "filled"
        elif self.is_partially_filled:
            return "partially_filled"

# Public Datums
# ===================================================>

class Depth():
    def __init__(self, asks, bids, *args, **kwargs):
        self.asks = asks
        self.bids = bids


class Trade():
    def __init__(self, **kwargs):
        self.side = kwargs.get("side", 0) 
        self.size = kwargs.get("size", 0) 
        self.price = kwargs.get("price", 0) 

# Swap specific Public datums
# ===================================================>

class Funding():
    def __init__(self, funding_rate, next_funding_time):
        self.funding_rate = funding_rate
        self.next_funding_time = next_funding_time

class MarkPrice():
    def __init__(self, mark_price):
        self.mark_price = mark_price

class Detail():
    def __init__(self, *args, **kwargs):
        pass

class Liquidation():
    def __init__(self, *args, **kwargs):
        pass

# Swap specific Private datums (Agent Only)
# ===================================================>

class PositionR():
    def __init__(self, *args, **kwargs):
        self.side = kwargs.get('side', PositionSide.BOTH)
        self.amount = kwargs.get('amount', 0)
        self.average_entry_price = kwargs.get('average_entry_price', 0)
        self.leverage = kwargs.get('leverage', 0)
        self.realised_pnl = kwargs.get('realised_pnl', 0)
        self.unrealised_pnl = kwargs.get('unrealised_pnl', 0)

    @property
    def abs_amount(self):
        return abs(self.amount)

class AccountR():
    def __init__(self, *args, **kwargs):
        self.balance = kwargs.get('balance', 0)
        self.frozen = kwargs.get('frozen', 0)
        self.maint_margin = kwargs.get('maint_margin', 0)
        self.available_balance = kwargs.get('available_balance', 0)

# Private Datums (Agent Only)
# ===================================================>

class OrderType(enum.Enum):
    MARKET_ORDER = 1
    LIMIT_ORDER = 2
    STOP_MARKET_ORDER = 3
    STOP_LIMIT_ORDER = 4

    @property
    def is_market(self):return self.value == 1

    @property
    def is_limit(self):return self.value == 2
    
    @property
    def is_stop_market(self):return self.value == 3

    @property
    def is_stop_limit(self):return self.value == 4
    
    def __str__(self):
        if self.is_market:
            return "market"
        elif self.is_limit:
            return "limit"
        elif self.is_stop_limit:
            return "stop_limit"
        elif self.is_stop_market:
            return "stop_market"

class LimitOrder():
    typ = OrderType.LIMIT_ORDER
    def __init__(
        self,
        side,
        order_id,
        price,
        size,
        **kwargs
    ):
        self.side = side
        self.price = price 
        self.size = size
        self.order_id = order_id 
        self.leaves = kwargs.get('leaves', self.size)
        self.filled = kwargs.get('filled', self.size-self.leaves)
        self.status = kwargs.get('status', OrderState.NEW)

    @property
    def id(self):
        return self.order_id

    @property
    def qty_id(self):
        return (self.price, self.order_id)

    @property
    def offset_id(self):
        return (self.price, self.order_id)


class MarketOrder():
    typ = OrderType.MARKET_ORDER
    def __init__(self, side, size, order_id, **kwargs):
        self.side = side
        self.size = size
        self.order_id = order_id 
        self.status = kwargs.get('status', OrderState.NEW)


class StopOrder():
    def __init__(
        self,
        side,
        size,
        trigger,
        status,
        order_id,
        stop_price,
        close_on_trigger
    ):
        self.side = side
        self.size = size
        self.trigger=trigger
        self.status = status
        self.order_id = order_id 
        self.stop_price = stop_price
        self.close_on_trigger = close_on_trigger

    @property
    def is_stop(self):
        return True

    @property
    def id(self):
        return self.order_id


class StopMarketOrder(StopOrder):
    typ = OrderType.STOP_MARKET_ORDER
    def __init__(
        self,
        side,
        size,
        trigger,
        order_id,
        stop_price,
        status=StopState.UNTRIGGERED,
        close_on_trigger=True
    ):
        StopOrder.__init__(
            self,
            side,
            size,
            trigger,
            status,
            order_id,
            stop_price,
            close_on_trigger
        )

    @property
    def is_stop_market(self):
        return True

    @property
    def id(self):
        return self.order_id


class StopLimitOrder():
    typ = OrderType.STOP_LIMIT_ORDER
    def __init__(
        self,
        side,
        size,
        trigger,
        order_id,
        stop_price,
        limit_price,
        status=StopState.UNTRIGGERED,
        close_on_trigger=True
    ):
        self.limit_price = limit_price 
        StopOrder.__init__(
            self,
            side,
            size,
            trigger,
            status,
            order_id,
            stop_price,
            close_on_trigger
        )

    @property
    def is_stop_limit(self):
        return True

    @property
    def id(self):
        return self.order_id


class Deposit():
    def __init__(self, amount):
        self.amount = amount

class Withdrawal():
    def __init__(self, amount):
        self.amount = amount


# AUXILLARY DATUMS
# ===================================================>


class Feature():
    def __init__(self, fid, value):
        self.fid = fid 
        self.value = value


class Feature():
    def __init__(self, fid, value):
        self.fid = fid 
        self.value = value