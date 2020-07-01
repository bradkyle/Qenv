import enum
# TODO functionality for each exchange
from env.models import PositionSide, AccountR, PositionR, Funding, EventAction, Event, EventType, Liquidation

class LiquidationStrategy(enum.Enum):
    TOTAL_LIQUIDATION = 0

class LiquidationManager():
    def __init__(self, orderbook, account, *args, **kwargs):
        self.orderbook = orderbook
        self.account = account

        self.num_forced_order_cancellations = kwargs.get('num_forced_order_cancellations', 0)
        self.num_account_liquidations = kwargs.get('num_account_liquidations', 0)
        self.num_position_liquidations = kwargs.get('num_position_liquidations', 0)
        self.num_bankruptcy = kwargs.get('num_bankruptcy', 0)
        self.insurance_fund = kwargs.get('insurance_fund', 0)
        self.liquidation_strategy =  kwargs.get('liquidation_strategy', 0)

    @property
    def mark_price(self):
        return self.orderbook.mark_price

    @property
    def info(self):
        return {
            "num_forced_order_liquidations": self.num_forced_order_cancellations,
            "num_account_liquidations": self.num_account_liquidations,
            "num_position_liquidations": self.num_position_liquidations,
        }

    def _force_order_cancellations(self, time):
        self.num_forced_order_cancellations += 1
        return [Event(
            time=time,
            action=EventAction.NEW,
            typ=EventType.AGENT_FORCED_CLOSE_ORDERS,
            datum={}
        )] + self.orderbook.cancel_all_agent_limit_orders(time=time)

    def _liquidate_account(self, time):
        self.num_account_liquidations += 1
        return [Event(
            time=time,
            action=EventAction.NEW,
            typ=EventType.AGENT_LIQUIDATED,
            datum=Liquidation()
        )] + self.account.reset(time=time) 

    def _liquidate_position(self):
        self.num_position_liquidations += 1

    def check_by_mark_price(self, mark_price, time): # TODO emit events
        # TODO other data updates
        events = []
        if self.account.margin_type.is_cross:
            if self.account.equity < self.account.reserved_balance:
                events += self._force_order_cancellations(time=time) # TODO
                if self.account.equity < self.account.reserved_balance:
                    events += self._liquidate_account(time=time) # TODO
        elif self.account.margin_type.is_isolated:
            raise NotImplementedError
        return events