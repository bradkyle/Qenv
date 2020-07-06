import enum
from env.engine.position import Position
from env.models import PositionSide, AccountR, PositionR, Funding, EventAction, Event, EventType
from env.engine.errors import *
import logging


class FeeType(enum.Enum):
    FLAT = 1
    TIERED = 2

    @property
    def is_flat(self):return self.value == 1

    @property
    def is_tiered(self):return self.value == 2

class TieredFee():
    def __init__(self, fee_dict):
        self.fee_dict = fee_dict
        self.fee_type = FeeType.TIERED

    def _next_idx(self, traded_amount):
        return min([x for x in self.fee_dict.keys() if x>traded_amount])

    def get_maker_fee(self, traded_amount):
        return self.fee_dict[self._next_idx(traded_amount)][0]

    def get_taker_fee(self, traded_amount):
        return self.fee_dict[self._next_idx(traded_amount)][1]

class FlatFee():
    def __init__(self, maker_fee, taker_fee):
        self.maker_fee = maker_fee 
        self.taker_fee = taker_fee
        self.fee_type = FeeType.FLAT
    
    def get_maker_fee(self):
        return self.maker_fee

    def get_taker_fee(self):
        return self.taker_fee

# Follows the format of 
# max_tier volume: maker_fee, taker_fee
# Default tiered fee is modelled on binance futures
# fee with bnb over 30 day volume (naively implemented)
DEFAULT_TIERED_FEE = TieredFee({
    0: (0.00018, 0.00036),
    250: (0.000144, 0.00036),
    2500: (0.000126, 0.000315),
    7500: (0.000108, 0.000288),
    22500: (0.00009, 0.000270),
    50000: (0.000072, 0.000243),
    100000: (0.000054, 0.000225),
    200000: (0.000036, 0.000198),
    400000: (0.000018, 0.00018),
    750000: (0.0000, 0.000153),
})

# Default flat fee is derived from bitmex
# with a referral code i.e. 
# minus commission on XBTUSD contract
DEFAULT_FLAT_MAKER_FEE = FlatFee(-0.00025, 0.00075)

class MarginType(enum.Enum):
    CROSS = 1
    ISOLATED = 2

    @property
    def is_cross(self):return self.value == 1

    @property
    def is_isolated(self):return self.value == 2


class PositionType(enum.Enum):
    HEDGE = 1
    COMBINED = 2

    @property
    def is_hedged(self):return self.value == 1

    @property
    def is_combined(self):return self.value == 2

# https://www.binance.com/en/support/articles/360033525271
# In hedge mode, both long and short positions of the same contract are sharing the same liquidation price in cross margin mode.
# If both long and short positions of the same contract are in isolated mode, the positions will have two different liquidation 
# prices depending on the margin allocated to the positions.

# On the other hand, adjusting the margin mode associated with a position after it has already been opened is not possible. It is highly advised to check the margin mode settings before entering a position.
# TODO inverse contract vs vanilla contract
class Account():
    def __init__(
        self,
        **kwargs
    ):
        # TODO if position side == BOTH enable cross?

        # Updateable state
        self.face_value = kwargs.get('face_value', 1)
        self.tick_size = kwargs.get('tick_size', 0.5)
        self.margin_type = kwargs.get('margin_type', MarginType.CROSS)
        self.position_type = kwargs.get('position_type', PositionType.COMBINED)

        # Balance and deposit/withdraw qtys
        self.balance = kwargs.get('balance', 0)
        self.total_deposit = kwargs.get('total_deposit', 0)
        self.total_withdraw = kwargs.get('trade_withdraw', 0)
        self.order_margin = kwargs.get('order_margin', 0)
        self.num_withdraws = kwargs.get('num_withdraws', 0)
        self.num_deposits = kwargs.get('num_deposits', 0)

        # Funding 
        self.funding_rate = kwargs.get('funding_rate', 0)
        self.total_funding_cost_margin = kwargs.get('total_funding_cost_margin', 0)
        self.total_funding_cost_cnt = kwargs.get('total_funding_cost_cnt', 0)
        self.total_short_funding_cost = kwargs.get('total_short_funding_cost', 0)
        self.total_long_funding_cost = kwargs.get('total_long_funding_cost', 0)
        self.next_funding_time = kwargs.get('next_funding_time', 0)

        self.max_leverage = int(kwargs.get('max_leverage', 100))
        self.min_leverage = int(kwargs.get('min_leverage', 1))

        # Trades
        self.num_fills = kwargs.get('num_fills', 0)
        self.open_limit_sell = kwargs.get('open_limit_sell', 0)
        self.open_limit_buy = kwargs.get('open_limit_buy', 0)
        self.trade_volume = kwargs.get('trade_volume', 0)

        # Commission
        self.commission_manager = kwargs.get('commission_manager', DEFAULT_FLAT_MAKER_FEE)

        # Price/Orderbook properties
        self.mark_price = kwargs.get('mark_price', 0)
        self.last_price = kwargs.get('last_price', 0)


        self.long_inventory = kwargs.get('long_inventory', Position(
            account=self,
            side=PositionSide.LONG
        ))

        self.short_inventory = kwargs.get('short_inventory', Position(
            account=self,
            side=PositionSide.SHORT
        ))

        self.both_inventory = kwargs.get('both_inventory', Position(
            account=self,
            side=PositionSide.BOTH
        ))

        # TODO maint margin, frozen available balance

    @property
    def rounder(self):
        return 1/self.tick_size

    @property
    def buy_order_qty(self):
        return self.open_limit_buy

    @property
    def sell_order_qty(self):
        return self.open_limit_sell

    @property
    def frozen(self):
        return 0

    @property
    def long_qty(self):
        return self.long_inventory.long_qty + self.both_inventory.long_qty

    @property
    def short_qty(self):
        return self.short_inventory.short_qty + self.both_inventory.short_qty
    
    @property
    def is_long(self):
        return self.long_qty > self.short_qty

    @property
    def is_short(self):
        return self.long_qty < self.short_qty

    @property
    def long_open_qty(self):
        return self.open_limit_buy + self.long_inventory.long_qty + self.both_inventory.long_qty

    @property
    def short_open_qty(self):
        return self.open_limit_sell + self.short_inventory.short_qty + self.both_inventory.short_qty

    @property
    def has_position(self):
        return self.long_open_qty > 0 and self.short_open_qty > 0

    @property
    def leverage(self):
        return self.max_leverage if self.margin_type.is_cross else self.leverage

    @property
    def long_leverage(self): # TODO implement isolated leverage
        return self.max_leverage if self.margin_type.is_cross else self.long_inventory.leverage

    @property
    def short_leverage(self): # TODO implement isolated leverage
        return self.max_leverage if self.margin_type.is_cross else self.short_inventory.leverage

    @property
    def effective_leverage(self):
        pass

    @property
    def maker_fee(self):
        """
        Refers to the amount that is charged on a given
        trade when the current agent is adding liquidity
        to the book.
        """
        if self.commission_manager.fee_type.is_flat:
            return self.commission_manager.get_maker_fee()
        elif self.commission_manager.fee_type.is_tiered:
            return self.commission_manager.get_maker_fee(self.trade_volume)
        else:
            raise ValueError("Invalid commission fee type")

    @property
    def taker_fee(self):
        """
        Refers to the amount that is charged on a given
        trade when the current agent is removing liquidity
        from the book.
        """
        if self.commission_manager.fee_type.is_flat:
            return self.commission_manager.get_taker_fee()
        elif self.commission_manager.fee_type.is_tiered:
            return self.commission_manager.get_taker_fee(self.trade_volume)
        else:
            raise ValueError("Invalid commission fee type")

    @property
    def unrealized_pnl(self):
        """
        Returns the sum of the unrealized pnl of the long and short inventory
        """
        return (
            self.long_inventory.unrealized_pnl +  
            self.short_inventory.unrealized_pnl + 
            self.both_inventory.unrealized_pnl
        )

    @property
    def equity(self):
        """
        Your total equity held with the exchange. Margin Balance = Wallet Balance + Unrealized PNL.
        """ 
        return self.balance + self.unrealized_pnl

    @property
    def total_realized_pnl(self):
        return (
            self.long_inventory.total_realized_pnl +
            self.short_inventory.total_realized_pnl +
            self.both_inventory.total_realized_pnl
        )

    # TODO make into config
    @property
    def initial_margin_coeficient(self):
        return 0.01 + self.taker_fee * 2

    # TODO make into config
    @property
    def maint_margin_coeficcient(self):
        return 0.005 + self.taker_fee + self.funding_rate

    @property
    def average_entry_price(self): # TODO do and test
        return 

    @property
    def maintenence_margin(self):
        return (
            self.long_inventory.maintainence_margin + 
            self.short_inventory.maintainence_margin + 
            self.both_inventory.maintainence_margin
        )

    @property
    def reserved_balance(self):
        """
        Calculates the total reserved margin required for open positions and orders
        """
        return round((max(self.order_margin, 0) + self.maintenence_margin),8)

    @property
    def available_balance(self):
        """
        Amount allowed for making orders removes order margin from 
        """
        return max(self.balance - self.reserved_balance, 0)#TODO add order margin

    @property
    def available_balance_cnt(self):
        """
        Amount allowed for making orders removes order margin from 
        """
        return int(self.available_balance/self.price_per_contract)

    @property
    def cross_bankruptcy_price(self): # TODO
        return 

    def _get_cross_liqudiation_price(self):
        pass

    @property
    def cross_liquidation_price(self): # TODO check applies to bitmex, huobi, okex
        # Derived from: https://binance.zendesk.com/hc/en-us/articles/360033525271-Liquidation

        # TODO check qty
        if self.has_position:

            # Wallet Balance
            wb = self.balance
            tmm1 = 0 # Total Maintenance Margin of Other Contracts (except Contract 1) (Ignored)
            upnl1 = 0 # Total Unrealized PnL of Other Contracts (except Contract 1) (ignored)

            # Maintenance Amount of One-Way Mode Contract 1
            cumb = self.both_inventory.maintainence_amount
            
            # Maintenance Amount of Short Contract 1 (Hedge Mode)
            cums = self.short_inventory.maintainence_amount

            # Maintenance Amount of Long Contract 1 (Hedge Mode)
            cuml = self.long_inventory.maintainence_amount
            
            # Direction of Contract 1 (One Way Mode); “1” for 
            # long position, “-1” for short position 
            side1both = self.both_inventory.sign
            
            # Size of Position for Contract 1 (One Way Mode); 
            # Absolute value regardless long/short
            position1both = self.both_inventory.abs_qty
            
            # Entry Price of Contract 1 (One Way Mode)
            ep1both = self.both_inventory.average_entry_price
            
            # Entry Price of Short Position (Hedge Mode); 
            # Absolute value regardless long/short
            ep1short = self.short_inventory.average_entry_price
            
            # Size of Short Position (Hedge Mode); 
            # Absolute value regardless long/short
            position1short = self.short_inventory.abs_qty

            # Size of Long Position (Hedge Mode); Absolute value
            # regardless long/short
            position1long = self.long_inventory.abs_qty
            
            # Entry Price of Long Position (Hedge Mode); 
            # Absolute value regardless long/short
            ep1long = self.long_inventory.average_entry_price

            # Maintenance Margin Rate of One-Way Mode Contract
            mmb = self.both_inventory.maint_margin_rate

            # Maintenance Margin Rate of Long Contract (Hedge Mode)
            mml = self.long_inventory.maint_margin_rate

            # Maintenance Margin Rate of Short Contract (Hedge Mode)
            mms = self.short_inventory.maint_margin_rate

            # logging.error({
            #     "mmb":mmb, 
            #     "mml":mml, 
            #     "mms":mms, 
            #     "wb":wb, 
            #     "tmm1":tmm1, 
            #     "upnl1":upnl1, 
            #     "cumb":cumb, 
            #     "cuml":cuml, 
            #     "cums":cums, 
            #     "side1both":side1both, 
            #     "position1both":position1both, 
            #     "ep1both":ep1both, 
            #     "position1long":position1long, 
            #     "ep1long":ep1long, 
            #     "position1short":position1short, 
            #     "ep1short":ep1short,
            # })

            if self.position_type.is_combined:
                
                return round(((
                    wb - tmm1 + upnl1 + cumb + cuml + cums -
                    (side1both * position1both * ep1both) -
                    position1long * ep1long + position1short * ep1short
                ) / (
                    position1both * mmb + position1long * mml + position1short * mms -
                    side1both * position1both - position1long + position1short
                )) * self.rounder)/self.rounder

            elif self.position_type.is_hedged:  
                
                return round(((
                    wb - tmm1 + upnl1 + cumb + cuml + cums -
                    (side1both * position1both * ep1both) -
                    (position1long * ep1long) + (position1short * ep1short)
                ) / (
                    (position1both * mmb) + (position1long * mml) - (position1short * mms) -
                    (side1both * position1both) - (position1long - position1short)
                )) * self.rounder)/self.rounder
        else:
            return 0

    @property
    def info(self):
        info = {
            "total_trade_volume": self.trade_volume,
            "maker_fee": self.maker_fee,
            "taker_fee": self.taker_fee,
            "balance": self.balance,
            "total_deposit": self.total_deposit,
            "unrealized_pnl": self.unrealized_pnl,
            "total_realized_pnl": self.total_realized_pnl,
            "average_entry_price": self.average_entry_price,
            "cross_bankruptcy_price": self.cross_bankruptcy_price,
            "cross_liquidation_price": self.cross_liquidation_price,
        }
        info.update(self.long_inventory.info)
        info.update(self.short_inventory.info)
        return info

    @property
    def account_update_datum(self):
        return AccountR(
            balance=self.balance,
            frozen=self.frozen,
            maint_margin=self.maintenence_margin,
            available_balance=self.available_balance
        )

    @property
    def short_inventory_update_datum(self):
        return self.short_inventory.position_update_datum

    @property
    def long_inventory_update_datum(self):
        return self.short_inventory.position_update_datum

    @property
    def both_inventory_update_datum(self):
        return self.both_inventory.position_update_datum


    # Reset
    # --------------------------------------------------------->

    def reset(self, time):
        events = []
        self.balance = 0
        self.total_deposit = 0
        self.total_withdraw = 0
        self.order_margin = 0
        self.num_withdraws = 0
        self.num_deposits = 0
        self.num_fills = 0
        self.trade_volume = 0
        self.funding_rate = 0
        self.total_funding_cost_margin = 0
        self.total_funding_cost_cnt = 0
        self.total_short_funding_cost = 0
        self.total_long_funding_cost = 0
        self.next_funding_time = 0

        events += [Event(
            time=time,
            action=EventAction.UPDATE,
            typ=EventType.ACCOUNT_UPDATE,
            datum=self.account_update_datum
        )]

        if self.position_type.is_combined:
            events += self.both_inventory.reset(time=time)
        elif self.position_type.is_hedged:
            events += self.short_inventory.reset(time=time)
            events += self.long_inventory.reset(time=time)

        return events

    # Utilities
    # --------------------------------------------------------->
    
    def _cnt_to_mrg(self, price, qty, do_abs=True):
        """
        Converts contracts to their equivalent amount denominated in the margin asset.
        """
        if price==0:return 0
        if do_abs: return ((self.face_value/price) * abs(qty))
        else: return (self.face_value/price) * qty

    # Apply funding to account
    # --------------------------------------------------------->

    # TODO update funding with same function # TODO generate events
    def apply_funding(self, funding_rate, next_funding_time, time):
        """
        Positive funding rate means long pays short an amount equal to their current position
        * the funding rate.
        Negative funding rate means short pays long an amount equal to their current position
        * the funding rate.
        The funding rate6\ can either be applied to the current position or to the margin/balance.
        """
        events = []
        self.next_funding_time = next_funding_time
        
        short_funding_cost_cnt = -(self.short_inventory.short_qty + self.both_inventory.short_qty) * funding_rate
        long_funding_cost_cnt = (self.long_inventory.long_qty + self.both_inventory.long_qty) * funding_rate
        funding_cost_cnt = short_funding_cost_cnt + long_funding_cost_cnt

        funding_cost_margin = self._cnt_to_mrg(
            qty=funding_cost_cnt,
            price=self.mark_price,
            do_abs=False
        )

        self.total_funding_cost_margin += funding_cost_margin
        self.total_funding_cost_cnt += funding_cost_cnt
        self.total_short_funding_cost += short_funding_cost_cnt
        self.total_long_funding_cost += long_funding_cost_cnt
        self.balance -= funding_cost_margin

        events.append(Event(
            time=time,
            action=EventAction.UPDATE,
            typ=EventType.ACCOUNT_UPDATE,
            datum=self.account_update_datum
        ))

        return events

    # Add fill
    # --------------------------------------------------------->

    def _exec(self, position, execution, price, fee):
        """
        Converts an execution from a fill operation on an order to the corresponding 
        position and balance respectively. 
        """
        execution = int(execution)
        price = float(price)
        cost = float(fee) * abs(execution)
        next_position = position.current_qty+execution
        realized_pnl = 0
        case="none"

        if abs(execution) == 0:
            raise ZeroExecution("The execution magnitude should be greater than 0")

        if price <= 0:
            raise InvalidExecutionPrice("The price given to the execution is invalid")

        # CROSS POSITION
        if position.current_qty * next_position < 0:
            case="cross"
            # Calculate the realized pnl of the previous 
            # position, using the current execution price
            realized_pnl = position._realized_pnl(
                size=position.current_qty,
                price=price
            )

            # reset entries because of change in position
            # side and add an entry of a size equal to the
            # size of the next position
            position._reset_entry()
            position._add_entry(
                size=abs(next_position),
                price=price
            )

            # Closing of position means that value is 
            # moving from the current position into
            # the balance, cost is subtracted from this 
            # execution amount. Because the execution is larger 
            # than the position the amount of value added back
            # to the balance is equivalent to the position # TODO leverage vs margin (cross/isolated)
            amt = self._cnt_to_mrg(
                qty=((abs(position.current_qty)-abs(next_position))/position.leverage)-cost, 
                price=price,
                do_abs=False
            )
            next_balance = self.balance + amt + realized_pnl
            position.total_cross_amount += amt

        # CLOSE POSITION
        elif abs(position.current_qty) > abs(next_position):
            case="close"
            # Because the position is being closed
            # the realized pnl will be opposite the
            # position.
            realized_pnl = position._realized_pnl(
                size=-execution,
                price=price
            )

            # Closing of position means that value is 
            # moving from the current position into
            # the balance, cost is subtracted from this 
            # execution amount, it also means that the
            # exectution is smaller than the position
            # and as such is used as the value. # TODO leverage vs margin (cross/isolated)
            amt = self._cnt_to_mrg(
                qty=(abs(execution)/position.leverage)-cost, 
                price=price,
            )
            next_balance = self.balance + amt + realized_pnl
            position.total_close_amount += amt

        # OPEN POSITION
        else:
            case="open"
            # Because the current position is being increased
            # an entry is added for calculation of average entry
            # price.
            position._add_entry(
                size=abs(execution),
                price=price
            )

            # Opening of position means that value is moving from
            # the current balance to the position and as thus
            # the cost is added to the execution i.e. an additional
            # amount is subtracted to simulate fee.
            amt = self._cnt_to_mrg(
                qty=(abs(execution)/position.leverage)+cost, 
                price=price,
            )
            next_balance = self.balance - amt
            position.total_open_amount += amt

        if next_position == 0:
            position._reset_entry()

        if execution > 0:
            position.total_buy_exec += abs(execution)
        else:
            position.total_sell_exec += abs(execution)

        self.balance = round(next_balance, 8)
        position.current_qty = next_position
        position.total_costs += (cost/price)
        position.total_realized_pnl += realized_pnl
        position.total_summed_returns += realized_pnl - (cost/price)
        position.total_fills_completed += 1
        
        return case, realized_pnl, cost, round(amt, 6)

    # TODO gen account update event if neccessary
    def add_fill(self, fill_qty, price, side, time, close=False, is_maker=False):
        """
        Adds a fill to the given inventory
        """
        events = []
        nfill_qty = fill_qty
        fill_qty = abs(fill_qty)
        
        # TODO close only for both positions?
        if fill_qty > 0:
            if self.position_type.is_hedged:
                if side.is_sell: # TODO close only orders
                    # Because 
                    self._exec(
                        self.short_inventory,
                        fill_qty if close else -fill_qty, # TODO based on conditional close/open 
                        price, 
                        self.maker_fee if is_maker else self.taker_fee
                    )
                    events.append(Event(
                        time=time,
                        action=EventAction.UPDATE,
                        typ=EventType.POSITION_UPDATE,
                        datum=self.short_inventory_update_datum
                    ))
                elif side.is_buy:
                    self._exec(
                        self.long_inventory,
                        -fill_qty if close else fill_qty, 
                        price, 
                        self.maker_fee if is_maker else self.taker_fee
                    )
                    events.append(Event(
                        time=time,
                        action=EventAction.UPDATE,
                        typ=EventType.POSITION_UPDATE,
                        datum=self.long_inventory_update_datum
                    ))
            elif self.position_type.is_combined:
                if side.is_sell:
                    self._exec(
                        self.both_inventory,
                        -nfill_qty, # Fill qty is set to negative to represent sell order
                        price, 
                        self.maker_fee if is_maker else self.taker_fee
                    )
                elif side.is_buy:
                    self._exec(
                        self.both_inventory,
                        nfill_qty,
                        price, 
                        self.maker_fee if is_maker else self.taker_fee
                    )
                events.append(Event(
                    time=time,
                    action=EventAction.UPDATE,
                    typ=EventType.POSITION_UPDATE,
                    datum=self.both_inventory_update_datum
                ))
            self.trade_volume += fill_qty
            self.num_fills += 1
            events.append(Event(
                time=time,
                action=EventAction.UPDATE,
                typ=EventType.ACCOUNT_UPDATE,
                datum=self.account_update_datum
            ))
        return events

    # Withdraw and Deposit logic
    # --------------------------------------------------------->

    def add_deposit(self, deposit_amount, time):
        events = []
        self.total_deposit += deposit_amount
        self.balance += deposit_amount
        self.num_deposits += 1
        events.append(Event(
            time=time,
            action=EventAction.UPDATE,
            typ=EventType.ACCOUNT_UPDATE,
            datum=self.account_update_datum
        ))
        return events

    def withdraw(self, withdraw_amount, time):
        events = []
        if withdraw_amount < self.available_balance:
            self.balance -= withdraw_amount
            self.total_withdraw += withdraw_amount
            self.num_withdraws += 1
            events.append(Event(
                time=time,
                action=EventAction.UPDATE,
                typ=EventType.ACCOUNT_UPDATE,
                datum=self.account_update_datum
            ))
        else:
            raise InsufficientBalance("There is insufficient balance to process withdraw")
        return events