from env.models import Side, LimitOrder, EventAction, EventType, Event, Depth, Trade
from env.engine.errors import *
import logging
import numpy as np
from itertools import groupby

# TODO output with aggregation
# TODO multi agent impl
class OrderBook():
    def __init__(self, account, *args, **kwargs):

        self.account = account
        
        # General config
        self.max_price = kwargs.get('max_price', 1000000)
        self.min_price = kwargs.get('min_price', 0)
        self.min_size = kwargs.get('min_size', 0)
        self.max_size = kwargs.get('max_size', 10000000)
        self.tick_size = kwargs.get('tick_size', 0.5)
        self.num_levels = kwargs.get('num_levels', 10)
        self.maker_fee = kwargs.get('maker_fee', 0.0)
        self.taker_fee = kwargs.get('taker_fee', 0.0)
        self.max_open_agent_orders = kwargs.get('taker_fee', 200)
        self.charge_premium = kwargs.get('charge_premium', True)
        self.face_value = kwargs.get('face_value', 1)

        # General quantities
        self.ask_lvl_qtys = kwargs.get('ask_lvl_qtys', {})
        self.bid_lvl_qtys = kwargs.get('bid_lvl_qtys', {})

        # Agent related quantities
        self.agent_orders = kwargs.get('agent_orders', {})
        self.agent_ask_offsets = kwargs.get('agent_ask_offsets', {})
        self.agent_bid_offsets = kwargs.get('agent_bid_offsets', {})
        self.agent_ask_qtys = kwargs.get('agent_ask_qtys', {})
        self.agent_bid_qtys = kwargs.get('agent_bid_qtys', {})
        self.agent_order_margins = kwargs.get('agent_order_margins', {})
        self.agent_order_premiums = kwargs.get('agent_order_premiums', {})

        # Private state
        self.order_inc = 0

        self.last_price = kwargs.get('last_price', 0)
        self.mark_price = kwargs.get('mark_price', 0)

    # Properties
    # ==========================================================================================>

    # TODO setters for last price and mark price (position, account, orderbook)

    @property
    def sorted_asks(self):
        """
        Asks sorted in ascending order i.e. asks with the smallest price (closest to spread)
        are returned first.
        """
        return self.ask_lvl_qtys.keys().sort(key=lambda x:x[0], reverse=False)

    @property
    def sorted_bids(self):
        """
        Bids sorted in descending order i.e. bids with the largest price (closest to spread)
        are returned first.
        """
        return self.ask_lvl_qtys.keys().sort(key=lambda x:x[0], reverse=True)

    @property
    def has_asks(self):
        return len(self.ask_lvl_qtys)>0

    @property
    def has_bids(self):
        return len(self.bid_lvl_qtys)>0

    @property
    def has_agent_asks(self):
        """
        Returns true if the orderbook has any asks that belong to the agent.
        """
        return len(self.agent_ask_qtys) > 0

    @property
    def has_agent_bids(self):
        """
        Returns true if the orderbook has any bids that belong to the agent.
        """
        return len(self.agent_bid_qtys) > 0

    @property
    def best_ask_price(self):
        """
        Returns the smallest ask i.e. the ask that is closest to the bid ask spread
        """
        return min(self.ask_lvl_qtys.keys()) if len(self.ask_lvl_qtys)>0 else None

    @property
    def best_bid_price(self):
        """
        Returns the largest bid i.e. the bid that is the closest to the bid ask spread.
        """
        return max(self.bid_lvl_qtys.keys()) if len(self.bid_lvl_qtys)>0 else None

    @property
    def num_agent_orders(self):
        """
        Return the total amount of orders that belong to the agent in the orderbook.
        """
        return len(self.agent_orders)

    @property
    def agent_buy_open_qty(self):
        """
        Returns the total amount of active bid orders made by the agent
        """
        return sum(self.agent_bid_qtys.values())

    @property
    def agent_sell_open_qty(self):
        """
        Returns the total amount of active ask orders made by the agent
        """
        return sum(self.agent_ask_qtys.values())

    @property
    def spread(self):
        return self.best_ask_price - self.best_bid_price \
            if self.has_asks and self.has_bids else None

    @property
    def smallest_bid_offset(self):
        return sum(self.agent_bid_offsets.values())

    @property
    def smallest_ask_offsets(self):
        return sum(self.agent_ask_offsets.values())

    @property
    def next_ask(self):
        return self.agent_orders[min(self.agent_ask_offsets)[1]]

    @property
    def next_bid(self):
        return self.agent_orders[min(self.agent_bid_offsets)[1]]

    @property
    def depth_update_datum(self):
        return Depth(
            asks=self.ask_lvl_qtys,
            bids=self.bid_lvl_qtys
        )

    @property
    def info(self):
        return {
            "ask_lvl_qtys": self.ask_lvl_qtys,
            "bid_lvl_qtys": self.bid_lvl_qtys,
        }

    # Utilites
    # ==========================================================================================>

    def _new_order_id(self): # TODO use uuid
        self.order_inc += 1
        return self.order_inc

    def _get_available_qty(
        self,
        side,
        is_agent=False
    ):
        """
        Returns the sum of available qty available 
        """
        if side.is_sell:
            if is_agent:
                raise NotImplementedError()
            else: return self.agent_sell_open_qty
        elif side.is_buy:
            if is_agent:
                raise NotImplementedError()
            else: return self.agent_buy_open_qty
                

    def _get_smallest_offset(
        self,
        side
    ):
        """
        Returns the minimum offset i.e. the smallest amount of contracts
        that preceed an agent order.
        """
        if side.is_sell: return self.smallest_ask_offsets
        elif side.is_buy: return self.smallest_bid_offset
    
    def _decrement_offsets(
        self,
        side,
        price,
        amount
    ):
        """ # TODO test and make better
        Removes a given qty from all orders 
        """
        if side.is_buy:
            self.agent_bid_offsets.update({
                x[0]:max(x[1] - amount, 0) for x in self.agent_bid_offsets.items() if x[0][0] == price
            })
        elif side.is_sell:
            self.agent_ask_offsets.update({
                x[0]:max(x[1] - amount, 0) for x in self.agent_ask_offsets.items() if x[0][0] == price
            })

    def _increment_offset(
        self,
        side,
        price,
        amount
    ):
        if side.is_buy:
            self.agent_bid_offsets.update({
                x[0]:max(x[1] + amount, 0) for x in self.agent_bid_offsets.items() if x[0][0] == price
            })
        elif side.is_sell:
            self.agent_ask_offsets.update({
                x[0]:max(x[1] + amount, 0) for x in self.agent_ask_offsets.items() if x[0][0] == price
            })


    def has_order(self, order_id):
        return order_id in self.agent_orders

    # Limit Order logic
    # ==========================================================================================>

    # Place Limit Order Logic
    # ------------------------------------------------------------------------------------------>

    def add_new_qty(self, side, price, size):
        """
        Adds a given qty to the current asks or bids.
        if no qty exists at this level then it initializes
        the level with the quantity equal to the size.
        """
        if side.is_sell:
            if price in self.ask_lvl_qtys:
                self.ask_lvl_qtys[price] += size
            else:
                self.ask_lvl_qtys[price] = size
        elif side.is_buy:
            if price in self.bid_lvl_qtys:
                self.bid_lvl_qtys[price] += size
            else:
                self.bid_lvl_qtys[price] = size
        else:
            raise ValueError("Order has no side")

    
    def get_lvl_qty(self, side, price):
        """
        Gets a level quantity if it exists else returns 0
        """
        if side.is_sell:
            return self.ask_lvl_qtys[price] if price in self.ask_lvl_qtys else 0
        elif side.is_buy:
            return self.bid_lvl_qtys[price] if price in self.bid_lvl_qtys else 0


    # Simply retrieves the agent order given its id
    def get_agent_order(
        self,
        order_id
    ):
        """
        Returns a given agent order by the order id 
        provided, raises an error if it is not found.
        """
        if order_id in self.agent_orders:
            return self.agent_orders[order_id]
        else:
            raise OrderNotFound()

    # Margin 
    # ------------------------------------------------------------------------------------>

    def _premium(self, side, price): #TODO test
        """
        Calculates the premium charged on an order.
        if the order is a buy order and the price is less than the 
        best bid price i.e. it is away from the spread in the book or if the order
        is a sell order and the order is greater than the best sell
        price i.e. it is away from the spread in the book a premium on the 
        distance is charged.

        If the price is far above the mark price you have to pay the difference called gross open premium, this is the reason for the cost being higher for the Sell/Short.
        The calculation for Gross Open Premium is as follows:
        Math.abs((newOpenBuyPremium * net(currentQty, newOpenBuyQty) / newOpenBuyQty) || 0) +
        Math.abs((newOpenSellPremium * net(-currentQty, newOpenSellQty) / newOpenSellQty) || 0);
        Where:
        Math.abs = absolute value
        || 0 means, if net does not return a value, default to 0

        If a buy order is placed above the mark price, or if a sell order is 
        placed below the mark price then the trader must fully fund the 
        difference between the order price and the mark price

        GrossOpenPremium only applies to sell orders when the mark price is above 
        the limit price, and buy orders when the mark price is below the limit price
        """
        if self.charge_premium:
            if (side.is_buy and price > self.mark_price):
                return round((price - self.mark_price) * self.face_value, 8)
            elif (side.is_sell and price < self.mark_price):
                return round((self.mark_price - price) * self.face_value, 8)
            else:
                return 0
        else:
            return 0

    def _reserved(self, charged, premium, price, leverage):
        """
        The reserved order margin for a given order.
        # TODO test and make sure this function is correct!!!
        """
        return round(((charged + (self.account.initial_margin_coeficient * charged * self.face_value) + charged * premium)/price)/leverage, 8)

    # TODO exec inst
    def reserve_order_margin(self, side, price, size, order_id, time):
        """
        Adds an order to the order queue provided the current
        state can support it and thereafter updates the order
        margin.
        This function replicates the service that sits infront of 
        the engine to check that the account has the correct margin
        requirements to place the order.

        TODO cross and isolated margin.
        """        
        events = []
        # TODO update for isolated, hedge mode etc.
        # The following functionality ensures that margin is only decreased on net
        # If the order is a sell order and the current long position and buy open qty
        # is greater than the current sell open qty 
        if side.is_sell and self.account.long_open_qty > self.account.sell_order_qty:
            charged = max(size - (self.account.long_open_qty - self.account.sell_order_qty), 0) # TODO
        elif side.is_buy and self.account.short_open_qty > self.account.buy_order_qty:
            charged = max(size - (self.account.short_open_qty - self.account.buy_order_qty), 0) #TODO
        else:
            charged = size

        # Leverage here is identified as either the long positions leverage or short leverage
        # TODO make sure is good.
        leverage = self.account.long_leverage if side.is_buy else self.account.short_leverage

        premium = self._premium(side, price)
        reserved_margin = self._reserved(charged, premium, price, leverage)

        if reserved_margin < self.account.available_balance or reserved_margin == 0:
            events.append(Event(
                time=time,
                action=EventAction.UPDATE,
                typ=EventType.ACCOUNT_UPDATE,
                datum=self.account.account_update_datum
            ))
            self.account.order_margin += reserved_margin
            self.agent_order_margins[order_id] = reserved_margin
            return events, True, reserved_margin, premium # Returns new account available balance
        else:
            # TODO raise error
            # raise InsufficientBalance()
            return events, False, reserved_margin, premium

    # TODO testing
    def remove_order_margin(self, order_id, time):
        """
        Removes a given orders margin from the account order margin and
        the agent order margins and raises order not found error if the
        order was not found.
        """
        events = []
        if order_id in self.agent_order_margins:
            order_margin = self.agent_order_margins[order_id]
            self.account.order_margin = max(self.account.order_margin-order_margin, 0)
            del self.agent_order_margins[order_id]
            events.append(Event(
                time=time,
                action=EventAction.UPDATE,
                typ=EventType.ACCOUNT_UPDATE,
                datum=self.account.account_update_datum
            ))
        else:
            raise OrderNotFound()
        return events

    # TODO testing and account
    def reduce_order_margin(self, order_id, fraction, time):
        """
        Updates a given orders margin by reducing it by the fractional
        difference compared to the next order margin i.e. if the current
        order margin is 10 and it is to be reduced to 9, this would mean
        that the resultant order margin should = order margin * 0.9
        subsequently the total order margin should be altered by the 
        delta between the two.
        """
        events = []
        if order_id in self.agent_order_margins:
            order_margin = self.agent_order_margins[order_id]
            new_order_margin = order_margin * fraction
            order_margin_delta = new_order_margin - order_margin
            self.account.order_margin = max(self.account.order_margin+order_margin_delta, 0)
            self.agent_order_margins[order_id] = max(new_order_margin, 0) # TODO check if this is correct 
            events.append(Event(
                time=time,
                action=EventAction.UPDATE,
                typ=EventType.ACCOUNT_UPDATE,
                datum=self.account.account_update_datum
            ))
        else:
            raise OrderNotFound()
        return events

    # ------------------------------------------------------------------------------------>

    # TODO testing events generation
    def add_agent_order(
        self,
        side,
        price,
        size,
        time,
        order_id=None,
        event_action=EventAction.NEW
    ):
        """
        Adds an agent order with its given details to the state.
        """
        events = []
        order_id = order_id if order_id is not None else self._new_order_id()
        events += self.reserve_order_margin(
            side=side, 
            price=price, 
            size=size, 
            order_id=order_id,
            time=time
        ) # todo reserve margin
        if side.is_sell:
            # Return order with given order id or else return new generated order ID
            o = LimitOrder(side, order_id, price, size)
            self.agent_ask_offsets[o.offset_id] = self.get_lvl_qty(side, price)
            self.agent_ask_qtys[o.qty_id] = size
            self.agent_orders[order_id] = o
        elif side.is_buy:
            # Return order with given order id or else return new generated order ID 
            o = LimitOrder(side, order_id, price, size)
            self.agent_bid_offsets[o.offset_id] = self.get_lvl_qty(side, price)
            self.agent_bid_qtys[o.qty_id] = size
            self.agent_orders[order_id] = o 
        events.append(Event(
            time=time,
            action=event_action,
            typ=EventType.ORDER_UPDATE if event_action.is_update else EventType.NEW_ORDER,
            datum=o
        ))
        return events

    # TODO testing
    def remove_agent_order(
        self,
        order_id,
        time
    ):
        """
        Removes an agent order from the orderbook and updates the respective
        acccount, positions, etc.
        """
        events = []
        # TODO remove limit order from account
        o = self.get_agent_order(order_id)
        if o.side.is_buy:
            self.bid_lvl_qtys[o.price] -= o.size
            if self.has_agent_bids:
                del self.agent_bid_offsets[o.offset_id]
                del self.agent_bid_qtys[o.qty_id]
                self._decrement_offsets(o.side, o.price, o.size)
        elif o.side.is_sell:
            self.ask_lvl_qtys[o.price] -= o.size
            if self.has_agent_asks:
                del self.agent_ask_offsets[o.offset_id]
                del self.agent_ask_qtys[o.qty_id]
                self._decrement_offsets(o.side, o.price, o.size)
        del self.agent_orders[order_id]
        events += self.remove_order_margin(
            order_id=o.order_id,
            time=time
        ) # todo remove margin
        #TODO convert to event
        events.append(Event(
            time=time,
            action=EventAction.DELETE,
            typ=EventType.ORDER_DELETED,
            datum=order_id
        ))
        return events

    # TODO testing
    def update_agent_order(
        self,
        order_id,
        time,
        side=None,
        price=None,
        size=None,
    ):
        events = []
        """
        Updates a given agent order.
        If either the side, price or size (increased)
        are changed the order looses it's position in
        the orderbook. if the size is decreased the order
        maintains its position in the orderbook and updates
        offsets of all orders behind this order #TODO test only
        updates orders behind order.
        """
        o = self.get_agent_order(order_id)
        if  (side is not None and side != o.side) or \
            (price is not None and  price != o.price) or \
            (size is not None and size > o.size):
            self.remove_agent_order(order_id)
            events += self.new_limit_order(
                side=side if side is not None else o.side,
                price=price if price is not None else o.price,
                size=size if size is not None else o.size,
                is_agent=True,
                order_id=o.order_id, # TODO check if a new order is created
                event_action=EventAction.UPDATE,
                time=time
            )
        elif size is not None and size < o.size:
            delta = o.size-size
            frac = size/o.size
            if o.side.is_buy:
                self.agent_bid_qtys[o.qty_id] -= delta
                self.bid_lvl_qtys[o.price] -= delta
                self._decrement_offsets(o.side, o.price, delta) # TODO only decrement offsets behind agent order
                events += self.reduce_order_margin(
                    time=time,
                    order_id=o.order_id, 
                    fraction=frac
                )
                o.size = size
                self.agent_orders[o.order_id] = o
                events.append(Event(
                    time=time,
                    action=EventAction.UPDATE,
                    typ=EventType.ORDER_UPDATE,
                    datum=o
                )) # TODO update
            elif o.side.is_sell:
                self.agent_ask_qtys[o.qty_id] -= delta
                self.ask_lvl_qtys[o.price] -= delta
                self._decrement_offsets(o.side, o.price, delta) # TODO only decrement offsets behind agents order
                events += self.reduce_order_margin(
                    time=time,
                    order_id=o.order_id, 
                    fraction=frac
                )
                o.size = size
                self.agent_orders[o.order_id] = o
                events.append(Event(
                    time=time,
                    action=EventAction.UPDATE,
                    typ=EventType.ORDER_UPDATE,
                    datum=o
                ))
        return events
    
    def amend_order(self, order_id, side=None, price=None, size=None):
        """
        Amend order is a simple wrapper for the update order functionality
        expressed above.
        """
        return self.update_agent_order(order_id, side, price, size)

    def new_limit_order(
        self, 
        side,
        price, 
        size, 
        time,
        is_agent=False, 
        participate_do_not_initiate=True,
        order_id=None,
        event_action=EventAction.NEW,
    ):
        """

        """
        events = []

        # Preliminary checks
        if not price % self.tick_size == 0: raise InvalidTickSize();
        if not size < self.max_size: raise OrderSizeTooBig(str(self.max_size)+":"+str(size)+str({"side":side, "size": size, "price": price}))#"The order {id} had a size {size} that was larger than the max size {}")
        if not size > self.min_size: raise OrderSizeTooSmall(str(self.min_size)+":"+str(size)+str({"side":side, "size": size, "price": price}))
        if not price < self.max_price: raise OrderPriceTooHigh(str(self.max_price)+":"+str(price)+str({"side":side, "size": size, "price": price}))
        if not price > self.min_price: raise OrderPriceTooLow(str(self.min_price)+":"+str(price)+str({"side":side, "size": size, "price": price}))
        if is_agent and self.num_agent_orders > self.max_open_agent_orders: 
            raise TooManyOpenAgentOrders()

        # If the order is a sell order 
        # check that the order is better than the best bid price (not crossing spread)
        if side.is_sell:
            if price < (self.best_ask_price \
                if self.best_ask_price is not None else self.max_price):
                if participate_do_not_initiate:  raise OrderShouldParticipate(str({"best_ask_price":self.best_ask_price, "best_bid_price": self.best_bid_price, "price": price})+str({"side":side, "size": size, "price": price}))
                else: events += self.new_market_order(
                    side=side, 
                    size=size, 
                    is_agent=is_agent, 
                    order_id=order_id,
                    time=time
                )

            # Has the order been placed by the agent 
            if is_agent:events += self.add_agent_order(
                side=side, 
                price=price, 
                size=size, 
                order_id=order_id, 
                event_action=event_action,
                time=time
            )
            
            # if the ask lvl is present update else
            # create a new ask lvl
            self.add_new_qty(side, price, size)

        elif side.is_buy:
            if price > (self.best_bid_price \
                if self.best_bid_price is not None else self.min_price):
                if participate_do_not_initiate: raise OrderShouldParticipate(str({"best_ask_price":self.best_ask_price, "best_bid_price": self.best_bid_price, "price": price})+str({"side":side, "size": size, "price": price}))
                else: events += self.new_market_order(
                    side=side, 
                    size=size, 
                    is_agent=is_agent, 
                    order_id=order_id,
                    time=time
                )

            # Has the order been placed by the agent # TODO if errors make sure account not affected
            if is_agent: events += self.add_agent_order(
                side=side, 
                price=price, 
                size=size, 
                order_id=order_id, 
                event_action=event_action,
                time=time
            )
            
            # if the ask lvl is present update else
            # create a new ask lvl
            self.add_new_qty(side, price, size)
        
        else:
            raise ValueError("Side Not allowed")

        return order_id, events


    # Cancel/Decrement Limit Order Logic
    # ------------------------------------------------------------------------------------------>
 
    def cancel_agent_limit_order(
        self,
        order_id,
        time
    ):
        return self.remove_agent_order(
            order_id=order_id,
            time=time
        )

    def cancel_agent_limit_orders(
        self,
        order_ids,
        time
    ):
        events = []
        for oid in order_ids:
            events += self.cancel_agent_limit_order(
                order_id=oid, 
                time=time
            )
        return events

    # TODO does emit events?
    def cancel_all_agent_limit_orders(
        self,
        time
    ):
        events = []
        for i in self.agent_orders.keys():
            events += self.cancel_agent_limit_order(i, time=time)
        return events

        # TODO generate indicative events

    # Market Order Logic
    # ==========================================================================================>

    # TODO emit trades
    # TODO increment the occurance of self execution
    def _fill_buy(self, qtyToTrade, time, events=[], is_agent=False):
        price = self.best_ask_price
        # If the sum of ask qty's that exist at the best level (price) is greater than 0
        # 
        if sum([a[1] for a in self.agent_ask_qtys.items() if a[0][0] ==price]) > 0:
            smallest_offset, smallest_offset_id = min([[a[1], a[0]] for a in self.agent_ask_offsets.items() if a[0][0] == price], key=lambda x: x[0])
            # if the quantity left to trade is smaller than the 
            # minimum offset then remove amount from orderbook repr
            # and update all asks to represent execution
            if qtyToTrade <= smallest_offset:
                if is_agent:
                    self.ask_lvl_qtys[price] -= qtyToTrade
                    events += self.account.add_fill(
                        fill_qty=abs(qtyToTrade),
                        price=price, 
                        side=Side.BUY, 
                        is_maker=False, #TODO CLOSE ONLY
                        time=time   
                    )

                events += [Event(
                    time=time,
                    action=EventAction.NEW,
                    typ=EventType.TRADE,
                    datum=Trade(
                        side=Side.BUY,
                        size=qtyToTrade,
                        price=price
                    )
                )]

                # Recursively update agent offsets to represent executed/filled
                # amount that has occured
                self._decrement_offsets(Side.SELL, price, qtyToTrade)
                qtyToTrade = 0

                # TODO create trade event
            else:
                # TODO if is agent vs is not agent

                # remove the smallest offset from the qtyToTrade
                # which represents the trade moving up the queue.
                qtyToTrade -= smallest_offset

                # remove the offset from the qtys such that the
                # offset is no longer represented if the trade was
                # made by an agent
                if is_agent:
                    self.ask_lvl_qtys[price] -= smallest_offset

                events += [Event(
                    time=time,
                    action=EventAction.NEW,
                    typ=EventType.TRADE,
                    datum=Trade(
                        side=Side.BUY,
                        size=smallest_offset,
                        price=price
                    )
                )]
                
                # Either partially fill or fully fill the
                # order 
                #TODO allowed agent orders?

                next_ask = self.agent_orders[smallest_offset_id[1]]
                if qtyToTrade >= next_ask.size:
                    events += self.remove_agent_order(
                        order_id=next_ask.id,
                        time=time
                    )
                    events += self.account.add_fill(
                        fill_qty=next_ask.size,
                        price=price, 
                        side=Side.SELL, 
                        is_maker=True, #TODO CLOSE ONLY
                        time=time
                    )
                    events += [Event(
                        time=time,
                        action=EventAction.NEW,
                        typ=EventType.TRADE,
                        datum=Trade(
                            side=Side.BUY,
                            size=next_ask.size,
                            price=price
                        )
                    )]

                    qtyToTrade -= next_ask.size
                else:
                    events += self.update_agent_order(
                        order_id=next_ask.id,
                        size=abs(next_ask.size-qtyToTrade),
                        time=time
                    )
                    events += self.account.add_fill(
                        fill_qty=abs(qtyToTrade),
                        price=price, 
                        side=Side.SELL, 
                        is_maker=True, #TODO CLOSE ONLY
                        time=time
                    )
                    events += [Event(
                        time=time,
                        action=EventAction.NEW,
                        typ=EventType.TRADE,
                        datum=Trade(
                            side=Side.BUY,
                            size=qtyToTrade,
                            price=price
                        )
                    )]
                    qtyToTrade = 0

            # There exists an agent order at a specific price level
        else:
            # If the market order was made by the agent and the 
            # orderbook does not maintain a set of agent orders
            if is_agent:
                best_ask_qty = self.ask_lvl_qtys[price]
                if qtyToTrade <= best_ask_qty:
                    self.ask_lvl_qtys[price] -= qtyToTrade
                    events += [Event(
                        time=time,
                        action=EventAction.NEW,
                        typ=EventType.TRADE,
                        datum=Trade(
                            side=Side.BUY,
                            size=qtyToTrade,
                            price=price
                        )
                    )]
                    qtyToTrade = 0
                    events += self.account.add_fill(
                        fill_qty=abs(qtyToTrade),
                        price=price, 
                        side=Side.BUY, 
                        is_maker=False, #TODO CLOSE ONLY
                        time=time
                    )
                else:
                    del self.ask_lvl_qtys[price]
                    events += [Event(
                        time=time,
                        action=EventAction.NEW,
                        typ=EventType.TRADE,
                        datum=Trade(
                            side=Side.BUY,
                            size=abs(best_ask_qty),
                            price=price
                        )
                    )]
                    events += self.account.add_fill(
                        fill_qty=abs(best_ask_qty),
                        price=price, 
                        side=Side.BUY, 
                        is_maker=False, #TODO CLOSE ONLY
                        time=time
                    )
                    qtyToTrade -= best_ask_qty
            else:
                events += [Event(
                    time=time,
                    action=EventAction.NEW,
                    typ=EventType.TRADE,
                    datum=Trade(
                        side=Side.BUY,
                        size=qtyToTrade,
                        price=price
                    )
                )]
                qtyToTrade = 0
        return qtyToTrade, events

    # TODO emit trades
    # TODO increment the occurance of self execution
    def _fill_sell(self, qtyToTrade, time, events=[], is_agent=False):
        price = self.best_bid_price
        # If the sum of ask qty's that exist at the best level (price) is greater than 0
        # 
        if sum([a[1] for a in self.agent_bid_qtys.items() if a[0][0] ==price]) > 0:
            smallest_offset, smallest_offset_id = min([[a[1], a[0]] for a in self.agent_bid_offsets.items() if a[0][0] == price], key=lambda x: x[0])
            # if the quantity left to trade is smaller than the 
            # minimum offset then remove amount from orderbook repr
            # and update all bids to represent execution
            if qtyToTrade <= smallest_offset:
                if is_agent:
                    self.bid_lvl_qtys[price] -= qtyToTrade
                    events += self.account.add_fill(
                        fill_qty=abs(qtyToTrade),
                        price=price, 
                        side=Side.SELL,
                        time=time, 
                        is_maker=False #TODO CLOSE ONLY
                    )

                events += [Event(
                    time=time,
                    action=EventAction.NEW,
                    typ=EventType.TRADE,
                    datum=Trade(
                        side=Side.SELL,
                        size=qtyToTrade,
                        price=price
                    )
                )]

                # Recursively update agent offsets to represent executed/filled
                # amount that has occured
                self._decrement_offsets(Side.SELL, price, qtyToTrade)
                qtyToTrade = 0
                # TODO create trade event
            else:
                # TODO if is agent vs is not agent

                # remove the smallest offset from the qtyToTrade
                # which represents the trade moving up the queue.
                qtyToTrade -= smallest_offset

                # remove the offset from the qtys such that the
                # offset is no longer represented if the trade was
                # made by an agent
                if is_agent:
                    self.bid_lvl_qtys[price] -= smallest_offset
                
                events += [Event(
                    time=time,
                    action=EventAction.NEW,
                    typ=EventType.TRADE,
                    datum=Trade(
                        side=Side.SELL,
                        size=smallest_offset,
                        price=price
                    )
                )]

                # Either partially fill or fully fill the
                # order 
                #TODO allowed agent orders? !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

                next_bid = self.agent_orders[smallest_offset_id[1]]
                if qtyToTrade >= next_bid.size:
                    events += self.remove_agent_order(
                        next_bid.id,
                        time=time
                    )
                    events += self.account.add_fill(
                        fill_qty=next_ask.size,
                        price=price, 
                        side=Side.BUY, 
                        is_maker=True, #TODO CLOSE ONLY
                        time=time
                    )
                    events += [Event(
                        time=time,
                        action=EventAction.NEW,
                        typ=EventType.TRADE,
                        datum=Trade(
                            side=Side.SELL,
                            size=next_ask.size,
                            price=price
                        )
                    )]
                    qtyToTrade -= next_bid.size
                else:
                    events += self.update_agent_order(
                        order_id=next_bid.id,
                        size=abs(qtyToTrade-next_bid.size),
                        time=time
                    )
                    events += self.account.add_fill(
                        fill_qty=abs(qtyToTrade),
                        price=price, 
                        side=Side.BUY, 
                        is_maker=True, #TODO CLOSE ONLY
                        time=time
                    )
                    events += [Event(
                        time=time,
                        action=EventAction.NEW,
                        typ=EventType.TRADE,
                        datum=Trade(
                            side=Side.SELL,
                            size=qtyToTrade,
                            price=price
                        )
                    )]
                    qtyToTrade = 0

            # There exists an agent order at a specific price level
        else:
            # If the market order was made by the agent and the 
            # orderbook does not maintain a set of agent orders
            if is_agent:
                best_bid_qty = self.bid_lvl_qtys[price]
                if qtyToTrade <= best_bid_qty:
                    self.bid_lvl_qtys[price] -= qtyToTrade
                    qtyToTrade = 0
                    events += self.account.add_fill(
                        fill_qty=abs(qtyToTrade),
                        price=price, 
                        side=Side.SELL, 
                        is_maker=False, #TODO CLOSE ONLY
                        time=time
                    )
                    events += [Event(
                        time=time,
                        action=EventAction.NEW,
                        typ=EventType.TRADE,
                        datum=Trade(
                            side=Side.SELL,
                            size=qtyToTrade,
                            price=price
                        )
                    )]
                else:
                    del self.bid_lvl_qtys[price]
                    events += self.account.add_fill(
                        fill_qty=abs(best_bid_qty),
                        price=price, 
                        side=Side.SELL, 
                        is_maker=False, #TODO CLOSE ONLY
                        time=time
                    )
                    events += [Event(
                        time=time,
                        action=EventAction.NEW,
                        typ=EventType.TRADE,
                        datum=Trade(
                            side=Side.SELL,
                            size=abs(best_bid_qty),
                            price=price
                        )
                    )]
                    qtyToTrade -= best_bid_qty
            else:
                events += [Event(
                    time=time,
                    action=EventAction.NEW,
                    typ=EventType.TRADE,
                    datum=Trade(
                        side=Side.SELL,
                        size=qtyToTrade,
                        price=price
                    )
                )]
                qtyToTrade = 0
        return qtyToTrade, events

    def _get_available_asks(self, is_agent):
        return sum(self.ask_lvl_qtys.values())

    def _get_available_bids(self, is_agent):
        return sum(self.bid_lvl_qtys.values())

    # TODO test
    def new_market_order(
        self,
        side,
        size,
        time,
        is_agent=True,
        order_id=None
    ):
        """
        Considering that trades are already represented in the orderbook data i.e.
        trades that occur already decrease the orderbook at ask lvl 1 it should be the
        case that the deltas at the best bid or ask should be equal to the change minus the 
        sum of trades that have occured since the last update /2 if any of the agents are 
        on the best bid/ask level, they should be executed.
        """
        return self.process_trade(
            side=side, 
            price=self.best_ask_price if side.is_sell else self.best_bid_price, 
            size=size,
            is_agent=True,
            time=time
        )

    # TODO test
    def process_trade(
        self,
        side,
        price,
        size,
        time,
        is_agent=False
    ):
        # logging.error(price)
        # logging.error(size)
        # logging.error('-'*90)
        # import time 
        # time.sleep(10)
        events = []
        qtyToTrade = size
        if side.is_buy:
            # logging.error(self._get_available_asks(is_agent))
            while qtyToTrade < self._get_available_asks(is_agent) and qtyToTrade > 0:
                # logging.error(qtyToTrade)
                qtyToTrade, events = self._fill_buy(
                    qtyToTrade=qtyToTrade, 
                    events=events, 
                    is_agent=is_agent,
                    time=time
                )
                # time.sleep(1)
        elif side.is_sell:
            # logging.error(self._get_available_bids(is_agent))
            while qtyToTrade < self._get_available_bids(is_agent) and qtyToTrade > 0:
                # logging.error(qtyToTrade)
                qtyToTrade, events = self._fill_sell(
                    qtyToTrade=qtyToTrade, 
                    events=events, 
                    is_agent=is_agent,
                    time=time
                )
                # time.sleep(1)
        return events


    # =========================================================================>

    # TODO round by lot size
    # TODO comments
    def _derive_new_offsets(
        self,
        lvl_qtys,
        lvl_deltas,
        lvl_sizes,
        lvl_offsets
    ):
        """
        Derives new agent order offsets for the entire side of the book.
        assumes that the lvl_offsets and lvl_sizes are sorted such that 
        each scalar column represents one order.

        lvl_qtys: total size of level
        lvl_deltas: change in the size of the given lvl
        lvl_sizes: the size of orders at a given lvl
        lvl_offsets: the offsets for the orders at a given lvl

        """       

        #  
        lvl_qtys = np.array(lvl_qtys)
        num_lvls = len(lvl_qtys)
        max_num_updates = len(max(lvl_offsets, key=len))

        # Pad makes sure that the 
        # state matrixes have the 
        # same dimensionality
        def _pad(x, l):
            y = np.zeros(l)
            x = np.array(x)
            y[:x.shape[0]] = x
            return y

        # Convert to numpy arrays and 
        # fill where necessary
        lvl_deltas = np.array(lvl_deltas)
        lvl_offsets = np.array([_pad(i, max_num_updates) for i in lvl_offsets])
        lvl_sizes = np.array([_pad(i, max_num_updates) for i in lvl_sizes])
        
        # Calculate the shifted offsets, which infers
        # the amount of space between each offset
        shifted_offsets = lvl_sizes + lvl_offsets

        # Initialize non agent quantities matrix
        # The first column is set to the first lvl_offset
        # The last column is set to the size of the level minus the size of the last offset + order size
        # adn all levels in between this are set to the lvl_offsets minus the shifted offset 
        non_agent_qtys = np.zeros((num_lvls, max_num_updates+1))
        non_agent_qtys[:, 0] = lvl_offsets[:, 0]
        non_agent_qtys[:, 1:max_num_updates] = (lvl_offsets[:, 1:] - shifted_offsets[:, :-1]).clip(min=0)
        non_agent_qtys[:, -1] = (lvl_qtys - shifted_offsets[:, -1]).clip(min=0)
        
        # returns the sum of all the orders at each of the levels
        # provided that are not made by the agent
        sum_non_agent_qtys_by_lvl = np.sum(non_agent_qtys, axis=1).reshape(num_lvls,1)

        # Assuming the cancellation has occured with a uniform probability split through
        # The order book, amend the offsets according to the size of the offset with respect
        # to all other offsets (non agent qtys).
        derived_deltas = np.around((non_agent_qtys/sum_non_agent_qtys_by_lvl)*lvl_deltas.reshape(num_lvls, 1))[:,:-1]

        # Set the new offsets to equal the last offsets + the derived deltas.
        new_offsets = (lvl_offsets + derived_deltas).clip(min=0)

        return new_offsets, derived_deltas

    # TODO check that qty not reduced when delta cannot be filled
    # TODO comment
    def _process_asks_update(self, asks): # TODO return events
        ask_lvl_deltas = {
            x[0]: x[1] - self.ask_lvl_qtys[x[0]] 
            if x[0] in self.ask_lvl_qtys
            else x[1]
            for x in asks.items()
        }

        if self.has_agent_asks:
            offset_deltas = np.array([[k,v] for k,v in ask_lvl_deltas.items() if v<0]).transpose()
            if len(offset_deltas) > 0:
                lvl_prices, lvl_deltas = offset_deltas
                lvl_qtys = [self.ask_lvl_qtys[p] if p in self.ask_lvl_qtys else 0 for p in lvl_prices]

                # Groupes agent order offsets by price
                grouped_offsets = np.array([sorted(v, key=lambda x: x[1]) for l,v in groupby(self.agent_ask_offsets.items(), lambda x: x[0][0])])
                lvl_offsets, offsets_ids = grouped_offsets[:,:,1], grouped_offsets[:,:,0]
                lvl_sizes = [[self.agent_ask_qtys[x] for x in i] for i in offsets_ids]
                new_offsets, derived_deltas = self._derive_new_offsets(lvl_qtys, lvl_deltas, lvl_sizes, lvl_offsets)
                self.agent_ask_offsets = dict(np.stack((offsets_ids, new_offsets), axis=2).reshape(len(self.agent_ask_offsets), 2))

        # TODO remove qtys less than 0
        self.ask_lvl_qtys.update({
            a[0]:max(round(self.ask_lvl_qtys[a[0]] + a[1]), 0) 
            if a[0] in self.ask_lvl_qtys else a[1] if a[1] > 0 else logging.error("Initial delta less than zero") 
            for a in ask_lvl_deltas.items() 
        })

        return self.ask_lvl_qtys, ask_lvl_deltas

    # TODO check that qty not reduced when delta cannot be filled
    # TODO comment
    def _process_bids_update(self, bids): # TODO return events
        bid_lvl_deltas = {
            x[0]: x[1] - self.bid_lvl_qtys[x[0]] 
            if x[0] in self.bid_lvl_qtys
            else x[1]
            for x in bids.items()
        }

        if self.has_agent_bids:
            offset_deltas = np.array([[k,v] for k,v in bid_lvl_deltas.items() if v<0]).transpose()
            if len(offset_deltas) > 0:
                lvl_prices, lvl_deltas = offset_deltas
                lvl_qtys = [self.bid_lvl_qtys[p] if p in self.bid_lvl_qtys else 0 for p in lvl_prices]
                grouped_offsets = np.array([sorted(v, key=lambda x: x[1]) for l,v in groupby(self.agent_bid_offsets.items(), lambda x: x[0][0])])
                lvl_offsets, offsets_ids = grouped_offsets[:,:,1], grouped_offsets[:,:,0]
                lvl_sizes = [[self.agent_bid_qtys[x] for x in i] for i in offsets_ids]
                new_offsets, derived_deltas = self._derive_new_offsets(lvl_qtys, lvl_deltas, lvl_sizes, lvl_offsets)
                self.agent_bid_offsets = dict(np.stack((offsets_ids, new_offsets), axis=2).reshape(len(self.agent_bid_offsets), 2))

        # TODO remove qtys less than 0
        self.bid_lvl_qtys.update({
            a[0]:max(round(self.bid_lvl_qtys[a[0]] + a[1]), 0) 
            if a[0] in self.bid_lvl_qtys else a[1] if a[1] > 0 else logging.error("Initial delta less than zero") 
            for a in bid_lvl_deltas.items() 
        })

        return self.bid_lvl_qtys, bid_lvl_deltas


    def process_depth_update(
        self,
        depth,
        time
    ):
        """
        Calculate delta between next depth and current depth
        if delta increases i.e. qty is added to the book the qty is added without changing the offsets
        If the delta decreases i.e. qty is being removed from the respective level, it is assumed
        that either a cancellation(s) has occurred before the order or after the order (seen as though
        trades have been accounted for).
        One problem does arise, however, due the fact that we only have
        aggregate information about the limit orders. When we see that the
        amount of volume at a particular price level has decreased, we know
        that either some of the orders at that level have either been executed
        or they have been cancelled. Since we have transaction data, we
        can deal with the case where limit orders have been executed, but
        when limit orders are cancelled, we do not know precisely which
        orders have been removed.
        This causes a problem when an agent’s order is currently being
        simulated for that price level, because we do not know whether
        the cancelled order was ahead or behind the simulated order in the
        queue. Our solution is to assume that cancellations are distributed
        uniformly throughout the queue. This means that the probability
        that the cancelled order is ahead of the agent’s order is proportional
        to the amount of volume ahead of the agent’s order compared to
        the amount of volume behind it.
        """
        events = []
        self._process_asks_update(asks=depth.asks)
        self._process_bids_update(bids=depth.bids)
        events.append(Event(
            time=time,
            action=EventAction.UPDATE,
            typ=EventType.DEPTH,
            datum=self.depth_update_datum
        ))
        return events
