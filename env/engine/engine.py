import logging 
from env.engine.account import Account
from env.engine.orderbook import OrderBook
from env.engine.stop_order_manager import StopOrderManager
from env.engine.liquidation_manager import LiquidationManager
from env.models import *

# TODO implement rate limiting
class Engine():
    def __init__(self, config, **kwargs):
        
        self.config = config

        self.allowed_event_types = config["allowed_event_types"]

        self.account = Account(
            **self.config
        )

        self.orderbook = OrderBook(
            account=self.account
        )

        self.stop_manager = StopOrderManager(
            orderbook=self.orderbook,
            account=self.account
        )

        # TODO liquidation engine
        self.liquidation_manager = LiquidationManager(
            orderbook=self.orderbook,
            account=self.account
        )

        self.total_event_count = kwargs.get('total_event_count', 0)
        self.total_agent_event_count = kwargs.get('total_agent_event_count', 0)
        self.do_funding = kwargs.get('do_funding', True)
        self.mark_price = kwargs.get('mark_price', 0)
        self.last_price = kwargs.get('last_price', 0)
        self.rest_request_count = kwargs.get('rest_request_count', 0)

    # Properties
    # =========================================================>

    @property
    def face_value(self):
        return self.config.face_value

    @property
    def long_qty(self):
        return self.account.long_qty

    @property
    def short_qty(self):
        return self.account.short_qty

    @property
    def info(self):
        info = {} 
        info.update(self.account.info)
        info.update(self.orderbook.info)
        info.update(self.stop_manager.info)
        info.update(self.liquidation_manager.info)
        return info

    
    # Reset functionality
    # =========================================================>

    def reset(self):
        self.account.reset()
        self.orderbook.reset()
        self.stop_manager.reset()
        self.liquidation_manager.reset()

        self.total_agent_event_count = 0
        self.total_event_count = 0
        self.mark_price = 0
        self.last_price = 0

    # State Request Logic
    # =========================================================>

    def _get_account(self):
        self.rest_request_count += 1
        return [self.account.account_update_datum]

    def _get_positions(self):
        self.rest_request_count += 1
        if self.account.position_type.is_hedged:
            return [
                self.account.long_inventory_update_datum,
                self.account.short_inventory_update_datum
            ]
        elif self.account.position_type.is_combined:
            return [self.account.both_inventory_update_datum]

    def _get_orders(self):
        self.rest_request_count += 1
        return list(self.orderbook.agent_orders.values()) + \
               list(self.stop_manager.stop_orders.values())

    def _get_agent_orders(self):
        self.rest_request_count += 1
        return list(self.orderbook.agent_orders.values())

    def _get_stop_orders(self):
        self.rest_request_count += 1
        return list(self.stop_manager.stop_orders.values())

    # Utilities
    # =========================================================>

    def _cnt_to_mrg(self, price, qty, do_abs=True):
        """
        Converts contracts to their equivalent amount denominated in the margin asset.
        """
        if price==0:return 0
        if do_abs: return ((self.face_value/price) * abs(qty))
        else: return (self.face_value/price) * qty

    # Public event processing methods
    # =========================================================>

    # TODO make sure book does not represent depth change and trades
    def _process_trade(self, event):
        """
        Process trade event sourced from the data, the trade will be sent
        to the orderbook in order to update the state, the orderbook 
        should return a depth update event and a trade event as a result. 
        If the price is not equal to the last price, the event will trigger the stop
        manager to check the current stop orders by last price triggers,
        and will subsequently place an order in the book if a stop has
        been triggered, It will also return order updated events if this has occured.
        """
        events = []
        trade = event.datum
        events += self.orderbook.process_trade(
            side=trade.side,
            size=trade.size,
            price=trade.price,
            time=event.time
        )
        if trade.price != self.last_price:
            self.last_price = trade.price
            events += self.stop_manager.check_stops_by_last_price(
                last_price=trade.price,
                time=event.time
            )
        return events

    # TODO make sure book does not represent depth change and trades
    def _process_depth_update(self, event):
        """
        Processing a depth update refers to the premise that an order has been
        placed or cancelled in the book, the book will update the offsets of the
        agent orders and subsequently return a representation of the orderbook
        modified to include the agent orders.
        """
        return self.orderbook.process_depth_update(event.datum, time=event.time) # TODO time

    # TODO testing
    def _process_funding_update(self, event):
        """
        "It forces trading on the platform. Bitmex loves traders who constantly buy and sell, 
        because they earn only on fees from active trading".
        The engine processes a funding update by adding or removing from the accounts positions
        this will subsequently trigger position/balance updates depending on the respective config.

        Binance:
            When "FUNDING FEE" changes to the user's balance, the event will be pushed with
            the brief message:
            When "FUNDING FEE" occurs in a crossed position, ACCOUNT_UPDATE will be pushed with only the balance
                B(including the "FUNDING FEE" asset only), without any position P message.
            When "FUNDING FEE" occurs in an isolated position, ACCOUNT_UPDATE will be pushed with only the balance 
                B(including the "FUNDING FEE" asset only) and the relative position message P( including the isolated 
                position on which the "FUNDING FEE" occurs only, without any other position message).

        """
        events = []
        funding_event = event.datum
        if self.do_funding:
            events += self.account.apply_funding(
                funding_rate=funding_event.funding_rate, 
                next_funding_time=funding_event.next_funding_time,
                time=event.time
            )
        else:
            logging.info("Funding has been disabled")
        return events

    # TODO risk tiers (ADL), Testing
    def _process_mark_price_update(self, event):
        """
        Processes a mark price update, when the mark price is updated
        it triggers a check of the current positions i.e. liquidation
        and updates other details etc.

        Partial liquidation process involving automatic reduction of 
        maintenance margin in an attempt to avoid a full liquidation of a 
        trader’s position.
        Users on the Lowest Risk Limit tiers
        Cancels any open orders in the contract.
        If this does not satisfy the maintenance margin requirement then 
        the position will be liquidated by the liquidation engine at the
        bankruptcy price.
        The following simulates a close stop loss.

        Assumes that the agent is not subject to risk queue i.e. trades on lower leverage.
        """
        events = []
        mark_price = event.datum.mark_price

        if hasattr(self, 'mark_price'):
            self.mark_price_delta = mark_price - self.mark_price
        self.mark_price = mark_price
        events += self.stop_manager.check_stops_by_mark_price(mark_price=mark_price, time=event.time)
        events += self.liquidation_manager.check_by_mark_price(mark_price=mark_price, time=event.time)
        return events

    # Private state methods
    # =========================================================>

    def __switch_order_type(self, o, time, events):
        """
        Based on the type of event invoke different logic from different
        classes.
        """
        if o.typ.is_market:
            events += self.orderbook.new_market_order(
                side=o.side,
                size=o.size,
                time=time
            )
        elif o.typ.is_limit:
            events += self.orderbook.new_limit_order(
                side=o.side,
                price=o.price,
                size=o.size,
                time=time
            )
        elif o.typ.is_stop_limit:
            events += self.stop_manager.add_stop_limit(
                side=o.side,
                size=o.size,
                limit_price=o.limit_price,
                stop_price=o.stop_price,
                trigger=o.trigger,
                time=time
            )
        elif o.typ.is_stop_market:
            events += self.stop_manager.add_stop_market(
                side=o.side,
                size=o.size,
                stop_price=o.stop_price,
                trigger=o.trigger,
                time=time
            )
        return events

    def _process_new_order(self, event):
        """
        Simply invokes the above functionality to switch 
        between what order type is being placed.
        """
        events = []
        o = event.datum
        return self.__switch_order_type(o, event.time, events)

    def _process_batch_new_order(self, event):
        """
        Loops through a set of orders and processes them.
        """
        events = []
        new_orders = event.datum
        if len(new_orders) > 0 and \
           len(new_orders) < self.config.max_batch_orders:
           for o in new_orders:
                events = self.__switch_order_type(o, event.time, events)
        return events

    def __switch_cancel_type(self, o, time, events):
        """
        Switches logic based on the order type, removes/cancels 
        orders in the orderbook if the order is a limit order
        or removes/cacels the order from the stop manager if
        the order is a stop order.
        """
        if o.typ.is_limit:
            events += self.orderbook.cancel_order(o.order_id, time=time)
        elif o.typ.is_stop:
            events += self.stop_manager.cancel_stop(o.order_id, time=time)
        else:
            raise Exception()
        return events            

    def _process_cancel_order(self, event):
        """
        Removes a single order from the state
        """
        events = []
        order = event.datum
        return self.__switch_cancel_type(order, event.time, events)

    def _process_cancel_batch_orders(self, event):
        """
        Loops through a set of orders provided by the 
        event datum and iteratively cancels them.
        """
        events = []
        orders = event.datum
        if len(orders) > 0 and \
           len(orders) < self.config.max_batch_orders:
           for o in orders:
                events += self.__switch_cancel_type(o, event.time, events)
        return events

    def _process_cancel_all_orders(self, event):
        """
        This function handles the cancellation of all orders in the 
        stop manager and the orderbook. 
        """
        events = []
        events += self.orderbook.cancel_all_orders(time=event.time)
        events += self.stop_manager.cancel_all_stop_orders(time=event.time)
        return events

    def __switch_amend_type(self, o, time, events):
        """
        Switches logic based on the order type, removes/cancels 
        orders in the orderbook if the order is a limit order
        or removes/cacels the order from the stop manager if
        the order is a stop order.
        """
        if o.typ.is_limit:
            events += self.orderbook.amend_order(
                order_id=o.order_id, 
                side=o.side, 
                price=o.price, 
                size=o.size,
                time=time
            )
        elif o.typ.is_stop_limit:
           events += self.stop_manager.amend_stop(
                side=o.side,
                size=o.size,
                limit_price=o.limit_price,
                stop_price=o.stop_price,
                trigger=o.trigger,
                time=time
            )
        elif o.typ.is_stop_market:
            events += self.stop_manager.amend_stop(
                side=o.side,
                size=o.size,
                stop_price=o.stop_price,
                trigger=o.trigger,
                time=time
            )
        else:
            raise Exception()
        return events

    def _process_amend_order(self, event):
        """
        This function handles the amending of all orders in the 
        stop manager and the orderbook. 
        """
        events = []
        order = event.datum
        return self.__switch_amend_type(order, event.time, events)

    def _process_amend_batch_orders(self, event):
        """
        Loops through a set of orders provided by the 
        event datum and iteratively amends them 
        """
        events = []
        orders = event.datum
        if len(orders) > 0 and \
           len(orders) < self.config.max_batch_orders:
           for o in orders:
                events += self.__switch_amend_type(o, event.time, events)
        return events

    def _process_deposit(self, event):
        """
        Adds a specified amount of balance to the 
        account balance.
        """
        events = []
        deposit_amount = event.datum.amount
        events += self.account.add_deposit(deposit_amount, time=event.time)
        return events

    def _process_withdraw(self, event):
        """
        Checks if the agent can withdraw the 
        specified amount, then proceeds to
        execute the withdraw operation.
        """
        events = []
        withdraw_amount = event.datum.amount
        events += self.account.withdraw(withdraw_amount, time=event.time)
        return events

    def process_event_batch(self, events, raise_errors = False):
        revents = []
        # Range through events, sort by time which ensures that
        # events are executed in a logical progression of state.
        # logging.error([e.time for e in events if type(e.time)==str])
        # logging.error("-"*90)
        for e in sorted(events, key=lambda e: e.time):
            self.total_event_count += 1
            try:
                if e.typ in self.allowed_event_types:
                    if e.typ.is_depth: revents += self._process_depth_update(e) #
                    elif e.typ.is_trade: revents += self._process_trade(e) #
                    elif e.typ.is_deposit: revents += self._process_deposit(e) #
                    elif e.typ.is_withdrawal: revents += self._process_withdraw(e) #
                    elif e.typ.is_funding: revents += self._process_funding_update(e) #
                    elif e.typ.is_mark: revents += self._process_mark_price_update(e) #
                    elif e.typ.is_place_order: revents += self._process_new_order(e) #
                    elif e.typ.is_place_batch_order: revents += self._process_batch_new_order(e) #
                    elif e.typ.is_cancel_order: revents += self._process_cancel_order(e) #
                    elif e.typ.is_cancel_batch_orders: revents += self._process_cancel_batch_orders(e) #
                    elif e.typ.is_cancel_all_orders: revents += self._process_cancel_all_orders(e) #
                    elif e.typ.is_amend_order: revents += self._process_amend_order(e) #
                    elif e.typ.is_amend_batch_orders: revents += self._process_amend_batch_order(e) # 
                else:
                    raise ValueError("Event type not allowed according to config")
            except Exception as e:
                logging.error(e)
                logging.exception(e)
                if raise_errors:raise e
        return [e for e in revents if isinstance(e, Event)], self.info


    