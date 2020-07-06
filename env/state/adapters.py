from env.models import *
import logging
import uuid
from gym import spaces

class ActionType(enum.Enum):
    BOX = 1
    DUALBOX = 2
    DISCRETE = 3
    MAKER = 4

# TODO lt adapter with staggered orders
# TODO lt adapter with agent based mm executer
# TODO lt adapter with hedged (not linked) action set
# TODO test trailing take profits etc. for lt action

class ActionAdapter():
    def __init__(self, state, **kwargs):
        self.state = state

    @property
    def action_space(self):
        raise NotImplementedError

    def _create_order_event_at_level(self, level, side, size, time):
        penalty, events = 0.0, []
        price = self.state.get_price_at_level(
            level=level, 
            side=side
        )
        
        events += [Event(
            time=time, # TODO set time as offset
            action=EventAction.NEW, 
            typ=EventType.PLACE_ORDER,
            datum=LimitOrder(
                side=side,
                price=price,
                size=round(size), #TODO allow for face value settings
            )
        )]
        return penalty, events

    def _create_market_order_event(self, side, size, time):
        penalty, events = 0.0, []
        events += [Event(
            time=time, # TODO set time as offset
            action=EventAction.NEW, 
            typ=EventType.PLACE_ORDER,
            datum=MarketOrder(
                order_id=str(uuid.uuid4()),
                side=side,
                size=round(size), # TODO allow for face value settings
            )
        )]
        return penalty, events

    def _create_flatten_position_events(self, time):
        penalty, events = 0.0, [] 

        if self.state.has_long_position:
            events += [Event(
                time=time, # TODO set time as offset
                action=EventAction.NEW, 
                typ=EventType.PLACE_ORDER,
                datum=MarketOrder(
                    order_id=str(uuid.uuid4()),
                    side=Side.SELL,
                    size=round(self.state.long_amount), # TODO allow for face value settings
                )
            )]

        if self.state.has_short_position:
            events += [Event(
                time=time, # TODO set time as offset
                action=EventAction.NEW, 
                typ=EventType.PLACE_ORDER,
                datum=MarketOrder(
                    order_id=str(uuid.uuid4()),
                    side=Side.BUY,
                    size=round(self.state.short_amount), # TODO allow for face value setting
                )
            )]

        if self.state.has_both_position:
            events += [Event(
                time=time, # TODO set time as offset
                action=EventAction.NEW, 
                typ=EventType.PLACE_ORDER,
                datum=MarketOrder(
                    order_id=str(uuid.uuid4()),
                    side=Side.BUY if self.state.both_amount > 0 else Side.SELL,
                    size=round(self.state.both_amount), # TODO allow for face value setting
                )
            )]

        return penalty, events

    def _create_cancel_all_orders_events(self, time):
        penalty, events = 0.0, []
        events += [Event(
            time=time, # TODO set time as offset
            action=EventAction.NEW, 
            typ=EventType.CANCEL_ALL_ORDERS
        )]
        return penalty, events

    def _create_order_events_from_dist(self, dist, side, time):
        penalty, events = 0.0, []
        if side.is_long:
            dlt = min(self.state.trading_value_cnt*dist, self.state.available_long)
            price = self.state.best_bid
        elif side.is_short:
            dlt = min(self.state.trading_value_cnt*dist, self.state.available_short)
            price = self.state.best_ask
        
        events += [Event(
            time=time,
            action=EventAction.NEW, 
            typ=EventType.PLACE_ORDER,
            datum=LimitOrder(
                order_id=str(uuid.uuid4()),
                side=Side.SELL if side.is_short else Side.BUY,
                price=price,
                size=round(dlt),
            )
        )]
        return penalty, events

    def _create_market_order_event_from_dist(self, dist, side, time):
        penalty, events = 0.0, []
        if side.is_long:
            dlt = min(self.state.trading_value_cnt*dist, self.state.available_long)
        elif side.is_short:
            dlt = min(self.state.trading_value_cnt*dist, self.state.available_short)
        
        events += [Event(
            time=time, # TODO set time as offset
            action=EventAction.NEW, 
            typ=EventType.PLACE_ORDER,
            datum=MarketOrder(
                order_id=str(uuid.uuid4()),
                side=Side.SELL if side.is_short else Side.BUY,
                size=round(dlt),
            )
        )]
        return penalty, events

    def gen_events_from_action(self, step_time, action):
        raise NotImplementedError



class BoxAdapter(ActionAdapter):
    def __init__(self, state, *args, **kwargs):
        super(BoxAdapter, self).__init__(state, **kwargs)
        self.quadratic = kwargs.get('quadratic', False)
        self.symmetric = kwargs.get('symmetric', False)

    @property
    def action_space(self):
        if self.symmetric:
            return spaces.Box(shape=(1,), low=-1, high=1)
        else:
            return spaces.Box(shape=(1,), low=0, high=1)

    def _get_deltas(self, current_position, next_net, open_buy_qty, open_sell_qty):
        """
        
        """
        current_net = max([
            current_position + (open_buy_qty - open_sell_qty), 
            current_position + open_buy_qty, 
            current_position - open_sell_qty
        ], key=abs)
        is_long = current_net > 0 
        is_short = current_net < 0

        # Defines the change in the net amount 
        # held in either the position or in orders
        delta = next_net - current_net
        
        # Defines the absolute change in the delta
        a_delta = abs(delta)
        
        current_long = max([current_position+open_buy_qty, open_buy_qty])
        current_short = max([-current_position+open_sell_qty, open_sell_qty])
        
        # None
        if next_net == current_net:
            supercase = "none"
            case = 0
            buy_delta = 0 
            sell_delta = 0
        
        # Cross
        elif next_net * current_net < 0:
            supercase = "cross"
            if is_long:
                if a_delta > open_buy_qty:
                    case = 1
                    buy_delta = -open_buy_qty
                    sell_delta = abs(next_net - current_position) - open_sell_qty
                elif a_delta <= open_buy_qty: # TODO
                    case = 2
                    buy_delta = delta
                    sell_delta = 0
            
            elif is_short:
                if a_delta > open_sell_qty:
                    case = 3
                    sell_delta = -open_sell_qty
                    buy_delta = abs(next_net - current_position) - open_buy_qty
                elif a_delta <= open_sell_qty: #TODO
                    case = 4
                    sell_delta = -delta
                    buy_delta = 0
        
        # Close
        elif abs(next_net) < abs(current_net):
            supercase = "close"
            if is_long:
                if a_delta > open_buy_qty:
                    case = 5
                    buy_delta = -open_buy_qty
                    sell_delta = -delta-open_buy_qty
                elif a_delta <= open_buy_qty:
                    case = 6
                    buy_delta = next_net - open_buy_qty
                    sell_delta = next_net - open_sell_qty
            
            elif is_short:
                if a_delta > open_sell_qty:
                    case = 7
                    sell_delta = -open_sell_qty
                    buy_delta = delta - open_sell_qty
                elif a_delta <= open_sell_qty:
                    case = 8
                    sell_delta = next_net - open_sell_qty
                    buy_delta = next_net - open_buy_qty
        
        # Open
        else:
            supercase = "open"
            if is_long:
                if a_delta > open_sell_qty:
                    case = 9
                    sell_delta = -open_sell_qty
                    buy_delta = delta - open_sell_qty
                elif a_delta <= open_sell_qty: #TODO should close work?
                    case = 10
                    sell_delta = 0
                    buy_delta = abs(next_net - current_position) - open_buy_qty
            elif is_short:
                if a_delta > open_buy_qty:
                    case = 11
                    buy_delta = -open_buy_qty
                    sell_delta = -delta + open_buy_qty
                elif a_delta <= open_buy_qty: #TODO shuould close work?
                    case = 12
                    buy_delta = 0
                    sell_delta = abs(next_net - current_position) - open_sell_qty
            else:
                if delta > 0:
                    case = 13
                    buy_delta = delta
                    sell_delta = 0 
                elif delta < 0:
                    case = 14
                    sell_delta = -delta
                    buy_delta = 0
               
        return (buy_delta, sell_delta)

    #TODO test
    # TODO create events
    def gen_orders_from_delta(self, delta, orders, side, best_price, worst_price):
        """
        Given the current orders and a delta generates the set of orders that 
        needs to be placed on account of the delta. 
        """
        new_orders = []
        amend_orders = []

        try:
            # Filter orders based on their side
            orders = [o for o in orders if o.side==side]

            # drift merely refers to the orders that have moved outside of the allowed
            # bounds away from the bid ask spread.
            if side==Side.SELL: 
                drift = [o for o in orders if o.price>worst_price]
            elif side==Side.BUY: 
                drift = [o for o in orders if o.price<worst_price]

            # Calculate the total amount of outstanding order qty outside of the 
            # allowed order price bounds.
            sum_drift = sum([o.outstanding for o in drift])
            
            # If the delta is less than zero 
            # i.e. net delta change to the opposite side.
            if delta < 0:
                d = delta

                # If the amount of orders outside the allowed bounds is
                # greater than the magnitude of the delta cancel all 
                # out of bounds orders
                if sum_drift >= abs(d):
                    d = 0 
                    [amend_orders.append(o.update(
                        outstanding=0
                    )) for o in drift]

                # If the sum of the amount of the orders outside the allowed bounds is 
                # less than the magnitude of the delta and yet greater than zero.
                # add the sum of the out of bounds orders to the delta and cancel out 
                # or bounds orders
                elif sum_drift > 0:
                    d += sum_drift
                    [amend_orders.append(o.update(
                        outstanding=0
                    )) for o in drift]
                    
                    # If the delta is still greater than zero #TODO check
                    if d<0:
                        for o in orders:
                            if o.outstanding < abs(d): #TODO min order size
                                # cancel order
                                d += o.outstanding
                                amend_orders.append(o.update(
                                    outstanding=0
                                ))
                            else:
                                # decrease order size
                                new_amt = o.outstanding + d
                                d = 0
                                amend_orders.append(o.update(
                                    outstanding=new_amt
                                ))
                                break
                                
            # Increase the total amount of buy orders
            elif delta > 0:
                if len(drift)>0:
                    # If more than one order is outside bounds, 
                    # amend first order and delete the rest 
                    # if there are any.
                    amend_orders.append(drift[0].update(
                        outstanding=delta,
                        price=best_price
                    ))

                    if len(drift) > 1:
                        [amend_orders.append(o.update(
                            outstanding=0,
                        )) for o in drift[1:]] 

                else:
                    # If there are no orders outside of the bounds
                    # of the agent add a new order to be placed.
                    new_orders.append(Order(
                        qty=delta,
                        price=best_price,
                        side=side
                    ))
                
        except Exception as e:
            logging.error(e)

        return events

    
    def _gen_orders_from_deltas(self, buy_delta, sell_delta):
        """
        Generates a set of new orders and amend orders for both the sell and by side.
        """
        orders = self._orders

        new_buy_orders, amend_buy_orders = self.gen_orders_from_delta(
            delta=buy_delta, 
            orders=orders,
            side=Side.BUY,
            best_price=self.state.best_bid,
            worst_price=self.state.worst_bid
        )
       
        new_sell_orders, amend_sell_orders = self.gen_orders_from_delta(
            delta=sell_delta, 
            orders=orders,
            side=Side.SELL,
            best_price=self.state.best_ask,
            worst_price=self.state.worst_ask
        )

        new_orders = new_buy_orders + new_sell_orders
        amend_orders = amend_buy_orders + amend_sell_orders

        return new_orders, amend_orders

    def _gen_orders_from_action(self, action):
        """
        Derives a set of orders from an action, derives the buy and sell deltas from the current position and
        margin respectively then uses those deltas to generate orders.
        """

        action = float(action[0])
        action = (action - (self.action_space().high/2)) * 2

        if self.quadratic:
            action *= abs(action)

        next_position = int((self.available_trading_value_cnt * action) * self.max_leverage)
    
        buy_delta, sell_delta = self._get_deltas(
            current_position=self.position, 
            next_net=next_position, 
            open_buy_qty=self.buy_open_qty, 
            open_sell_qty=self.sell_open_qty
        )

        self.prev_buy_delta = buy_delta
        self.prev_sell_delta = sell_delta

        return self._gen_orders_from_deltas(buy_delta, sell_delta)

    def gen_events_from_action(self, step_time, action):
        pass



class DualBoxAdapter(BoxAdapter):
    def __init__(self, state, *args, **kwargs):
        super(DualBoxAdapter, self).__init__(state, **kwargs)

    @property
    def action_space(self):
        return spaces.Box(shape=(2,), low=-1, high=1)
    
    def _gen_orders_from_action(self, action):
        """
        Derives a set of orders from an action, derives the buy and sell deltas from the current position and
        margin respectively then uses those deltas to generate orders.
        """

        leverage_action, action = action

        next_position = int(
            (self.trading_value_cnt * action) * 
            (((leverage_action+1)/2) * (self.leverage*self.trading_fraction))
        )
    
        buy_delta, sell_delta = self._get_deltas(
            current_position=self.position, 
            next_net=next_position, 
            open_buy_qty=self.buy_open_qty, 
            open_sell_qty=self.sell_open_qty
        )

        self.prev_buy_delta = buy_delta
        self.prev_sell_delta = sell_delta
        self.prev_leverage_action = leverage_action

        return self._gen_orders_from_deltas(buy_delta, sell_delta)

    def gen_events_from_action(self, step_time, action):
        pass


# TODO allowed action mapping
class DiscreteAdapter(ActionAdapter):
    def __init__(self, state, *args, **kwargs):
        super(DiscreteAdapter, self).__init__(state, **kwargs)
        self.max_position = kwargs.get('realized_pnl', 0)
        self.market_order_dist = kwargs.get('unrealized_pnl', 0)
        self.market_order_dist = kwargs.get('unrealized_pnl', 0)
        self.encouragement = kwargs.get('encouragement', 0.000000000001)
        self.num_actions = kwargs.get('num_actions', 7)

    @property
    def action_space(self):
        return spaces.Discrete(self.num_actions)

    def gen_events_from_action(self, step_time, action):
        """
        Create or adjust orders per a specified action and adjust for penalties.

        :param action: (int) current step's action
        :return: (float) reward
        """
        action_penalty, events = 0.0, []

        if action == 0:  # do nothing
            action_penalty -= self.encouragement
        
        elif action == 1: # flatten
            p, e = self._create_flatten_position_events(time=step_time)
            action_penalty += p
            events += e

        elif action == 2: # exec long
            p, e = self._create_order_events_from_dist(dist=0.05, side=PositionSide.LONG, time=step_time)
            action_penalty += p
            events += e

        elif action == 3: # exec short
            p, e = self._create_order_events_from_dist(dist=0.05, side=PositionSide.SHORT, time=step_time)
            action_penalty += p
            events += e
        
        elif action == 4: # exec long market
            p, e = self._create_market_order_event_from_dist(dist=0.05, side=PositionSide.LONG, time=step_time)
            action_penalty += p
            events += e
        
        elif action == 5: # exec short market: 
            p, e = self._create_market_order_event_from_dist(dist=0.05, side=PositionSide.SHORT, time=step_time)
            action_penalty += p
            events += e

        elif action == 6: # exec full long
            p, e = self._create_market_order_event_from_dist(dist=0.1, side=PositionSide.LONG, time=step_time)
            action_penalty += p
            events += e

        elif action == 7: # exec full short
            p, e = self._create_market_order_event_from_dist(dist=0.1, side=PositionSide.SHORT, time=step_time)
            action_penalty += p
            events += e
        
        else:
            raise ValueError("The action does not exist")

        return action_penalty, events            


# TODO allowed action mapping
class MarketMakerAdapter(ActionAdapter):
    def __init__(self, state, *args, **kwargs):
        super(MarketMakerAdapter, self).__init__(state, **kwargs)
        self.encouragement = kwargs.get('encouragement', 0)
        self.num_actions = kwargs.get('num_actions', 20)

    @property
    def action_space(self):
        return spaces.Discrete(self.num_actions)

    def gen_events_from_action(self, step_time, action):
        """
        Create or adjust orders per a specified action and adjust for penalties.

        :param action: (int) current step's action
        :return: (float) reward
        """
        action_penalty = 0.0

        if action == 0:  # do nothing
            action_penalty +=  self.encouragement

        elif action == 1:
            action_penalty, events =  self._create_order_event_at_level(
                level=0, 
                side='long',
                size=self.exec_size
            )
            action_penalty, events =  self._create_order_event_at_level(level=4, side='short')

        elif action == 2:
            action_penalty, events =  self._create_order_event_at_level(level=0, side='long')
            action_penalty, events =  self._create_order_event_at_level(level=9, side='short')

        elif action == 3:
            action_penalty, events =  self._create_order_event_at_level(level=0, side='long')
            action_penalty, events =  self._create_order_event_at_level(level=14, side='short')

        elif action == 4:
            action_penalty, events =  self._create_order_event_at_level(level=4, side='long')
            action_penalty, events =  self._create_order_event_at_level(level=0, side='short')

        elif action == 5:
            action_penalty, events =  self._create_order_event_at_level(level=4, side='long')
            action_penalty, events =  self._create_order_event_at_level(level=4, side='short')

        elif action == 6:
            action_penalty, events =  self._create_order_event_at_level(level=4, side='long')
            action_penalty, events =  self._create_order_event_at_level(level=9, side='short')

        elif action == 7:
            action_penalty, events =  self._create_order_event_at_level(level=4, side='long')
            action_penalty, events =  self._create_order_event_at_level(level=14, side='short')

        elif action == 8:
            action_penalty, events =  self._create_order_event_at_level(level=9, side='long')
            action_penalty, events =  self._create_order_event_at_level(level=0, side='short')

        elif action == 9:
            action_penalty, events =  self._create_order_event_at_level(level=9, side='long')
            action_penalty, events =  self._create_order_event_at_level(level=4, side='short')

        elif action == 10:
            action_penalty, events =  self._create_order_event_at_level(level=9, side='long')
            action_penalty, events =  self._create_order_event_at_level(level=9, side='short')

        elif action == 11:
            action_penalty, events =  self._create_order_event_at_level(level=9, side='long')
            action_penalty, events =  self._create_order_event_at_level(level=14, side='short')

        elif action == 12:
            action_penalty, events =  self._create_order_event_at_level(level=14, side='long')
            action_penalty, events =  self._create_order_event_at_level(level=0, side='short')

        elif action == 13:
            action_penalty, events =  self._create_order_event_at_level(level=14, side='long')
            action_penalty, events =  self._create_order_event_at_level(level=4, side='short')

        elif action == 14:
            action_penalty, events =  self._create_order_event_at_level(level=14, side='long')
            action_penalty, events =  self._create_order_event_at_level(level=9, side='short')

        elif action == 15:
            action_penalty, events =  self._create_order_event_at_level(level=14, side='long')
            action_penalty, events =  self._create_order_event_at_level(level=14, side='short')

        elif action == 16:
            action_penalty, events = self._create_flatten_position_events()

        elif action == 17:
            action_penalty, events = self._create_market_order_event(side='long')

        elif action == 18:
            action_penalty, events = self._create_market_order_event(side='short')

        elif action == 21:
            action_penalty, events = self._create_cancel_all_orders_events()

        else:
            raise ValueError("The action does not exist")



class TupleAdapter(ActionAdapter):
    def __init__(self, state):
        super().__init__(state)

    @property
    def action_space(self):
        pass

    def gen_events_from_action(self, step_time, action):
        pass