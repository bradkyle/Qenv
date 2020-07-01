import math
from env.models import PositionSide, PositionR, EventAction, EventType, Event
from env.engine.errors import *
import logging 

class TieredRisk():
    def __init__(self, risk_tiers):
        self.risk_tiers = risk_tiers

    def get_rate(self, qty):
        return [x[1][0] for x in self.risk_tiers.items() if x[0] > qty][0]

    def get_amt(self, qty):
        return [x[1][1] for x in self.risk_tiers.items() if x[0] > qty][0]

    @staticmethod # TODO
    def from_step(self):
        pass

# Derived from https://binance.zendesk.com/hc/en-us/articles/360033525271-Liquidation
# Binance 125X perpetual swap contract
# Position bracket (notional value in usdt): (maintainence margin rate, maintenese amount usdt)
# TODO max position size
DEFAULT_TIERED_MAINT = TieredRisk({
    50000: (0.004, 0),
    250000: (0.005, 50),
    1000000: (0.01, 1300),
    5000000: (0.025, 16300),
    20000000: (0.05, 141300),
    50000000: (0.1, 1141300),
    100000000: (0.125, 2391300),
    200000000: (0.15, 4891300),
    500000000: (0.25, 24891300)
})

class Position(object):
    def __init__(self, account=None, *args, **kwargs):
        self.account = account
        self.side = kwargs.get('side', PositionSide.BOTH)
        
        # Static settings
        self.max_leverage = int(kwargs.get('max_leverage', 100))
        self.min_leverage = int(kwargs.get('min_leverage', 1))
        self.face_value = kwargs.get('face_value', 1)

        # # Updateable state
        # self.leverage = int(kwargs.get('leverage', 1)) # TODO move to account
        self.current_qty = kwargs.get('current_qty', 0)
        self.total_entry = kwargs.get('total_entry', 0)
        self.exec_costs = kwargs.get('exec_costs', 0)
        
        # Risk manager
        self.tiered_risk = kwargs.get('tiered_risk', DEFAULT_TIERED_MAINT)

        # Metrics
        self.total_realised_pnl = kwargs.get('total_realised_pnl', 0)
        self.total_summed_returns = kwargs.get('total_summed_returns', 0)
        self.total_costs = kwargs.get('total_costs', 0)
        self.total_close_amount = kwargs.get('total_close_amount', 0)
        self.total_cross_amount = kwargs.get('total_cross_amount', 0)
        self.total_open_amount = kwargs.get('total_open_amount', 0)
        self.total_buy_exec = kwargs.get('total_buy_exec', 0)
        self.total_sell_exec = kwargs.get('total_sell_exec', 0)
        self.total_fills = kwargs.get('total_fills', 0)
        self.total_fills_completed = kwargs.get('total_fills_completed', 0)

    @property
    def mark_price(self):
        return self.account.mark_price

    @property
    def last_price(self):
        return self.account.last_price

    @property
    def maker_fee(self):
        return self.account.maker_fee

    @property
    def taker_fee(self):
        return self.account.taker_fee

    @property
    def funding_rate(self):
        return self.account.funding_rate

    @property
    def realised_pnl(self):
        return self.total_realised_pnl

    @property
    def current_qty(self):
        """
        Acts as the getter method for the current qty variable which subsequently
        references the number of contracts open and in which direction they are
        actingi (sign) i.e. long + sign, shirt - sign
        """
        return self.__current_qty

    @current_qty.setter
    def current_qty(self, value):
        if self.side.is_long:
            self.__current_qty = abs(value)
        elif self.side.is_short:
            self.__current_qty = -abs(value)
        elif self.side.is_both:
            self.__current_qty = value    

    @property
    def abs_qty(self):
        """
        Abs Qty returns the absolute value of the number of contracts that make up
        the position regardless of long/short
        """
        return abs(self.current_qty)

    @property
    def position(self):
        """
        Position serves as an alias for the current_qty of contracts that make up
        the position 
        """
        return self.current_qty

    @property
    def is_short(self):
        return self.side.is_short or self.current_qty < 0

    @property
    def is_long(self):
        return self.side.is_long or self.current_qty > 0

    @property
    def sign(self):
        return -1 if self.is_short else 1

    @property
    def long_position(self):
        return max(self.position, 0)

    @property
    def short_position(self):
        return abs(min(self.position, 0))

    @property
    def short_qty(self):
        return self.short_position

    @property
    def leverage(self):
        return self.account.leverage

    @property
    def long_qty(self):
        return self.long_position

    @property
    def notional_long(self):
        return self.long_position/self.leverage

    @property
    def notional_short(self):
        return self.short_position/self.leverage

    @property
    def initial_margin_coeficient(self):
        return 0.01 + self.taker_fee * 2

    @property
    def maint_margin_rate(self):
        return self.tiered_risk.get_rate(self.abs_qty)

    @property
    def maintainence_amount(self):
        """
        Derived from https://binance.zendesk.com/hc/en-us/articles/360033525271-Liquidation
        Maintenance Amount formula 
        = [ 
            Floor of Position Bracket on Level n * 
            difference between Maintenance Margin Rate on Level n and Maintenance Margin Rate on Level n-1) ] 
            + Maintenance Amount on Level n-1
        ]
        """
        return self.tiered_risk.get_amt(self.abs_qty)
        # return self.maintainence_margin

    @property
    def maint_margin_coeficcient(self):
        return 0.005 + self.taker_fee + self.funding_rate

    @property 
    def average_entry_price(self):
        """
        Calculates the average price of entry for the current postion, used in calculating 
        realized and unrealized pnl.
        """
        if self.total_entry > 0:
            asp = self.exec_costs/self.total_entry
            if self.is_long:
                return 1e8/math.floor(asp)
            elif self.is_short:
                return 1e8/round(asp)
            else:
                return 0 
        else:
            return 0

    @property
    def price_per_contract(self):
        if self.last_price>0:
            return self.face_value/self.last_price 
        else: 
            return 0

    @property
    def mark_per_contract(self):
        if self.mark_price>0:
            return self.face_value/self.mark_price
        else:
            return 0

    @property
    def position_value_mrg(self):
        """
        Returns the current value of the state denominated in margin.
        """
        return self.equity + (abs(self.position) * self.price_per_contract)/self.leverage

    @property
    def average_per_contract(self):
        """
        Returns the average price per contract for the current postition.
        """
        if self.average_entry_price > 0:
            return self.face_value/self.average_entry_price
        else:
            return 0

    @property
    def unrealised_pnl(self):
        """
        Returns the unrealized profit for the current position considering the current
        mark price and the average entry price (uses mark price to prevent liquidation).
        """
        return (self.average_per_contract - self.mark_per_contract) * self.current_qty

    @property
    def isolated_bankruptcy_price(self):
        """
        Upon liquidation, the liquidated position will be closed at the Bankruptcy Price,
        and this means that you have lost all the position margin. If the liquidated 
        position has its final liquidation price better than the bankruptcy price, 
        the excess margin will be contributed to the Insurance Fund. Vice versa, 
        if the liquidated position has its final liquidation price worse than 
        the bankruptcy price, the Insurance fund will cover the loss gap.

        For long position, the bankruptcy price will be rounded up to the 
        nearest 0.5 decimal place or integer while for short position, 
        the bankruptcy price will be rounded down to the nearest 0.5 
        decimal place or integer.
        """
        if self.is_long:
            return self.average_entry_price * (self.leverage/(self.leverage+1))
        elif self.is_short:
            return self.average_entry_price * (self.leverage/(self.leverage-1))

    @property
    def isolated_liquidation_price(self):
        """
        derived from https://help.bybit.com/hc/en-us/articles/360039261334-How-to-calculate-Liquidation-Price-Inverse-Contract-

        Infers inverse contract, #  TODO test

        Note: For long position, the liquidation price will be rounded up to the nearest 0.5 decimal place or integer while for 
        short position, the liquidation price will be rounded down to the nearest 0.5 decimal place or integer.

        """
        if self.is_long:
            return (self.average_entry_price * self.leverage)/(self.leverage-1-(self.maint_margin_rate * self.leverage))
        elif self.is_short:
            return (self.average_entry_price * self.leverage)/(self.leverage-1+(self.maint_margin_rate * self.leverage))

    @property
    def margin(self):
        """
        Refers to the margin allocated to the given position
        """
        if self.average_entry_price > 0:
            return (self.position/self.average_entry_price)/self.leverage + self.unrealised_pnl
        else:
            return 0

    @property
    def maintainence_margin(self):
        """
        Derived from bitmex
        This is the minimum amount of margin you must maintain to avoid liquidation on your position.
        The amount of commission applicable to close out all your positions will also be added onto 
        your maintenance margin requirement.
        """
        return ((self.maint_margin_coeficcient + self.taker_fee)*self.abs_qty) * self.mark_per_contract

    @property
    def side_str(self):
        return "long_" if self.is_long else "short_" 

    @property
    def position_update_datum(self):
        return PositionR(
            side=self.side,
            amount=self.current_qty,
            average_entry_price=self.average_entry_price,
            leverage=self.leverage,
            realised_pnl=self.realised_pnl,
            unrealised_pnl=self.unrealised_pnl
        )

    @property
    def info(self):
        return {
            self.side_str + "": 0
        }

    def reset(self, time):
        """

        """
        events = []
        self.total_entry = 0
        self.exec_costs = 0
        self.current_qty = 0
        self.total_realised_pnl = 0
        self.total_close_amount = 0
        self.total_cross_amount = 0
        self.total_open_amount = 0

        events += [Event(
            time=time,
            action=EventAction.UPDATE,
            typ=EventType.POSITION_UPDATE,
            datum=self.position_update_datum
        )]


    def _add_entry(self, size, price):
        """
        Entries are used to calculate the average entry price of the current position.
        """
        self.total_entry += abs(size)
        self.exec_costs += round(1e8/price) * abs(size)

    def _reset_entry(self):
        """
        Resets the current state of total entry and exec costs, used when closing a position
        or crossing a position.
        """
        self.total_entry = 0
        self.exec_costs = 0

    def _cnt_to_mrg(self, price, qty, do_abs=True):
        """
        Converts contracts to their equivalent amount denominated in the margin asset.
        """
        if price==0:return 0
        if do_abs: return ((self.face_value/price) * abs(qty))
        else: return (self.face_value/price) * qty

    def _realised_pnl(self, size, price): # TODO make sure is correct
        """
        Calculates the realized profit and losses for a given position, size is a positive
        or negative number that represents the portion of the current position that has been
        closed and thus should be of the same side as the position i.e. negative for short and 
        positive for long.
        """
        return (self.average_per_contract - self.face_value/price) * size
 