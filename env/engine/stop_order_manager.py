from env.models import Side, StopLimitOrder, StopMarketOrder, EventAction, EventType, Event, StopState
from functools import reduce

# TODO the stop order manager should simulate a delay/slippage in placement of stop orders
class StopOrderManager():
    def __init__(self, orderbook, account):
        self.orderbook = orderbook
        self.account = account
        self.reset()

        self.order_inc = 0

    @property
    def info(self):
        # TODO add more
        return {
            "stop_limit_sells_triggered": self.stop_limit_sells_triggered,
            "stop_limit_buys_triggered": self.stop_limit_buys_triggered,
            "stop_market_sells_triggered": self.stop_market_sells_triggered,
            "stop_market_buys_triggered": self.stop_market_buys_triggered,
            "num_stops": self.num_stops
        }
    
    @property
    def mark_price(self):
        return self.orderbook.mark_price

    @property
    def last_price(self):
        return self.orderbook.last_price

    @property
    def num_stops(self):
        return len(self.stop_orders)

    def has_stop(self, order_id):
        return order_id in self.stop_orders

    def reset(self):
        self.stop_limit_sells_triggered = 0
        self.stop_limit_buys_triggered = 0
        self.stop_market_sells_triggered = 0
        self.stop_market_buys_triggered = 0
        self.cancel_all_stop_orders()

    def cancel_all_stop_orders(self):
        self.stop_orders = {}
        self.sell_last_price_triggers = {}
        self.buy_last_price_triggers = {}
        self.sell_mark_price_triggers = {}
        self.buy_mark_price_triggers = {}

    def _new_order_id(self):
        self.order_inc += 1
        return self.order_inc

    def _insert_trigger(self, side, stop_price, order_id, trigger):
        """
        Inserts a trigger into the given indexes such that it can
        be easily (quickly) referenced when checking trigger events.
        """
        if side.is_sell:
            # Return order with given order id or else return new generated order ID 
            if trigger.is_last:
                if stop_price not in self.sell_last_price_triggers:
                    self.sell_last_price_triggers[stop_price] = []
                self.sell_last_price_triggers[stop_price].append(order_id)

            elif trigger.is_mark:
                if stop_price not in self.sell_mark_price_triggers:
                    self.sell_mark_price_triggers[stop_price] = []
                self.sell_mark_price_triggers[stop_price].append(order_id)
            else:
                raise ValueError()
        elif side.is_buy:
            # Return order with given order id or else return new generated order ID
            # # Return order with given order id or else return new generated order ID 
            if trigger.is_last:
                if stop_price not in self.buy_last_price_triggers:
                    self.buy_last_price_triggers[stop_price] = []
                self.buy_last_price_triggers[stop_price].append(order_id)

            elif trigger.is_mark:
                if stop_price not in self.buy_mark_price_triggers:
                    self.buy_mark_price_triggers[stop_price] = []
                self.buy_mark_price_triggers[stop_price].append(order_id)
            else:
                raise ValueError()   

    def _remove_trigger(self, side, stop_price, order_id, trigger):
        """
        Removes a given trigger from its index dict, the function checks the
        given index list of stop triggers and will remove the first instance 
        of the order id it finds at this level.
        """
        if side.is_sell:
            if trigger.is_last:
                if stop_price in self.sell_last_price_triggers:
                    self.sell_last_price_triggers[stop_price].remove(order_id)
            elif trigger.is_mark:
                if stop_price in self.sell_mark_price_triggers:
                    self.sell_mark_price_triggers[stop_price].remove(order_id)
            else:
                raise ValueError()
        elif side.is_buy:
            if trigger.is_last:
                if stop_price in self.buy_last_price_triggers:
                    self.buy_last_price_triggers[stop_price].remove(order_id)
            elif trigger.is_mark:
                if stop_price in self.buy_mark_price_triggers:
                    self.buy_mark_price_triggers[stop_price].remove(order_id)
            else:
                raise ValueError()
    
    # TODO cannot be in mark price or last price
    def add_stop_market(
        self, 
        side, 
        size, 
        stop_price, 
        trigger, 
        time, 
        order_id=None,
        event_action=EventAction.NEW,
        status=StopState.UNTRIGGERED
    ): # TODO build events
        """
        Adds a stop market to the stop manager, if the stop_price (trigger_price) condition
        is met by either the mark price or the last price (more to be implemented) a market
        order will be triggered # TODO this functionality should account for delays in 
        order trigger events that occur on the exchange (perhaps domain randomization)
        """
        events = []
        order_id = order_id if order_id is not None else self._new_order_id()
        o = StopMarketOrder(
            side=side, 
            order_id=order_id, 
            stop_price=stop_price, 
            size=size,
            trigger=trigger,
            status=status
        )
        self._insert_trigger(side, stop_price, order_id, trigger)
        self.stop_orders[order_id] = o
        events.append(Event(
            time=time,
            action=event_action,
            typ=EventType.NEW_ORDER if event_action.is_new else EventType.ORDER_UPDATE,
            datum=o
        ))
        return events

    # TODO cannot be in mark price or last price
    def add_stop_limit(
        self, 
        side, 
        size, 
        limit_price, 
        stop_price, 
        trigger, 
        time, 
        order_id=None,
        event_action=EventAction.NEW,
        status=StopState.UNTRIGGERED
    ): # TODO build events
        """
        Adds a stop market to the stop manager, if the stop_price (trigger_price) condition
        is met by either the mark price or the last price (more to be implemented) a market
        order will be triggered # TODO this functionality should account for delays in 
        order trigger events that occur on the exchange (perhaps domain randomization)
        """
        events = []
        order_id = order_id if order_id is not None else self._new_order_id()
        o = StopLimitOrder(
            side=side, 
            order_id=order_id,
            limit_price=limit_price, 
            stop_price=stop_price, 
            size=size,
            trigger=trigger,
            status=status
        )
        self._insert_trigger(side, stop_price, order_id, trigger)
        self.stop_orders[order_id] = o
        events.append(Event(
            time=time,
            action=event_action,
            typ=EventType.NEW_ORDER if event_action.is_new else EventType.ORDER_UPDATE,
            datum=o
        ))
        return events

    # Simply retrieves the agent order given its id
    def get_stop_order(
        self,
        order_id
    ):
        """
        Returns a given agent order by the order id 
        provided, raises an error if it is not found.
        """
        if order_id in self.stop_orders:
            return self.stop_orders[order_id]
        else:
            raise OrderNotFound()

    def remove_stop_order(
        self,
        order_id,
        time
    ):
        """
        Removes an agent order from the orderbook and updates the respective
        acccount, positions, etc.
        """
        events = []
        o = self.get_stop_order(order_id)
        self._remove_trigger(o.side, o.stop_price, o.order_id, o.trigger)
        del self.stop_orders[o.order_id]
        events.append(Event(
            time=time,
            action=EventAction.DELETE,
            typ=EventType.ORDER_DELETED,
            datum=o.order_id
        ))
        return events

    def cancel_stop(self, order_id, time):
        """
        Simple wrapper around the remove stop order method referenced above.
        """
        return self.remove_stop_order(
            order_id=order_id,
            time=time
        )

    def update_stop_order(
        self,
        order_id,
        time,
        side=None,
        stop_price=None,
        limit_price=None,
        trigger=None,
        size=None,
        status=None
    ):
        """
        Updates a given agent order and its respective trigger indicies if the stop
        price has changed.
        """
        events = []
        o = self.get_stop_order(order_id)
        if  (side is not None and side != o.side) or \
            (stop_price is not None and  stop_price != o.stop_price) or \
            (o.is_stop_limit and limit_price is not None and limit_price != o.limit_price) or \
            (size is not None and size > o.size): 
                self.remove_stop_order(
                    order_id=o.order_id,
                    time=time
                )
                if o.is_stop_limit:
                    events += self.add_stop_limit(
                        time=time,
                        side=side if side is not None else o.side, 
                        order_id=o.order_id,
                        limit_price=limit_price if limit_price is not None else o.limit_price, 
                        stop_price=stop_price if stop_price is not None else o.stop_price, 
                        size=size if size is not None else o.size, 
                        trigger=trigger if trigger is not None else o.trigger,
                        event_action=EventAction.UPDATE,
                        status=status if status is not None else o.status
                    )
                elif o.is_stop_market:
                    events += self.add_stop_market(
                        time=time,
                        side=side if side is not None else o.side,
                        size=size if size is not None else o.size, 
                        stop_price=stop_price if stop_price is not None else o.stop_price, 
                        trigger=trigger if trigger is not None else o.trigger,
                        order_id=o.order_id,
                        event_action=EventAction.UPDATE,
                        status=status if status is not None else o.status
                    )
                else:
                    raise ValueError()
        return events

    def amend_stop(self, order_id, time, side=None, price=None, size=None):
        """
        Simple method around the update stop order method referenced above.
        """
        return self.update_stop_order(
            order_id=order_id, 
            side=side, 
            price=price, 
            size=size,
            time=time
        )

    def _switch_stop_execution(self, o, time, events):
        """
        Switches the execution of a stop order, either
        a limit order is placed given the stop is a stop
        limit in which case the limit price will be used
        or it is a stop market in which case it will be executed
        at the best market price.
        """
        if o.is_stop_limit:
            events += self.orderbook.new_limit_order(
                side=o.side,
                price=o.limit_price,
                size=o.size,
                is_agent=True,
                time=time
            )
            events += self.update_stop_order(
                order_id=o.order_id,
                status=StopState.TRIGGERED,
                time=time
            )
            self.remove_stop_order(
                order_id=o.order_id,
                time=time
            ) # TODO emit event
        elif o.is_stop_market:
            events += self.orderbook.new_market_order(
                side=o.side,
                size=o.size,
                is_agent=True,
                time=time
            )
            events += self.update_stop_order(
                order_id=o.order_id,
                status=StopState.TRIGGERED,
                time=time
            )
            self.remove_stop_order(
                order_id=o.order_id,
                time=time
            ) # TODO emit event/update stop to triggered (removed to save memory)
        return events

    def _activated_ids(self, idx, price):
        import logging
        # logging.error(idx.keys())
        return [idx[i] for i in idx.keys() if i<=price]

    def check_stops_by_last_price(self, last_price, time):
        """
        Checks for stop orders to be executed based on a 
        change in the last price. If the last price has 
        increased in which case the last price delta would
        be positive, considering that all deltas are checked
        would mean that sell triggers are to be checked 
        conversely if the price has decreased buy stop triggers
        are to be checked.
        """
        events = []

        order_ids = self._activated_ids(self.sell_last_price_triggers, last_price) + \
                    self._activated_ids(self.buy_last_price_triggers, last_price)
        
        # TODO make better/async
        if len(order_ids)>0:
            for oid in reduce(lambda x,y: x+y,order_ids):
                o = self.get_stop_order(oid)
                events += self._switch_stop_execution(o, time, events)
        return events
            
    # TODO insert order into event queue!
    def check_stops_by_mark_price(self, mark_price, time):
        """
        Checks for stop orders to be executed based on a 
        change in the mark price. If the mark price has 
        increased in which case the last price delta would
        be positive, considering that all deltas are checked
        would mean that sell triggers are to be checked 
        conversely if the price has decreased buy stop triggers
        are to be checked.
        """
        events = []

        order_ids = self._activated_ids(self.sell_mark_price_triggers, mark_price) + \
                    self._activated_ids(self.buy_mark_price_triggers, mark_price)
        
        # TODO make better/async
        if len(order_ids)> 0:
            for oid in reduce(lambda x,y: x+y,order_ids):
                o = self.get_stop_order(oid)
                events += self._switch_stop_execution(o, time, events)
        return events

