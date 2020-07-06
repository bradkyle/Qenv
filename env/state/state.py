import logging
from env.models import *
import uuid
import numpy as np
from sklearn import preprocessing

class State():
    """
    This state assumes a discrete progression of step intervals
    i.e. for each second/'s the agent will take a step in the 
    environment and the environment will be updated thereafter
    etc. as opposed to event based (event count based) agents
    which would take a step in the environment every x events
    be that orderbook events, trades, mark price or a combination
    thereof.
    """
    def __init__(
        self,
        store,
        engine,
        adapter,
        **kwargs
    ):
        self.store = store
        self.engine = engine
        self.adapter = adapter(state=self)
        self.min_balance = kwargs.get('min_balance', 0)
        self.trading_fraction = kwargs.get('trading_fraction', 0.6)
        self.initial_balance = kwargs.get('initial_balance', 1)

        # State query config
        self.next_auxillary_events_qry = kwargs.get('next_auxillary_events_qry', "")
        self._next_source_events_qry = kwargs.get('next_source_events_qry', "")
        self.next_feature_vector_qry = kwargs.get('next_feature_vector_qry', "")
        self.resultant_info_qry = kwargs.get('resultant_info_qry', "")
        self.resultant_reward_qry = kwargs.get('resultant_reward_qry', "")

        # Metrics and INC state
        self.current_step = kwargs.get('current_step', 0)
        self.rest_requests = kwargs.get('rest_requests', 0)
        self.scaler = preprocessing.MinMaxScaler(feature_range=(0,255))

        # State
        self.bids = {}
        self.asks = {}
        self.bids_by_lvl = {}
        self.asks_by_lvl = {}
        self.last_price = kwargs.get('last_price', 0)
        self.mark_price = kwargs.get('mark_price', 0)
        self.trading_fraction = kwargs.get('trading_fraction', 0.2) # 20% of maximum leverage
        self.cross_leverage = kwargs.get('cross_leverage', 100) 
        self.face_value = kwargs.get('face_value', 1) 

        self.account = kwargs.get('account', None)
        self.long_position = kwargs.get('long_position', PositionR(side=PositionSide.LONG))
        self.short_position = kwargs.get('short_position', PositionR(side=PositionSide.SHORT))
        self.both_position = kwargs.get('both_position', PositionR(side=PositionSide.BOTH))
        self.stop_orders = kwargs.get('stop_orders', {})
        self.orders = kwargs.get('orders', {})
        
        self.store.init()
        # self.reset()

    @property
    def best_bid(self):
        return max(list(self.bids.keys()))

    @property
    def worst_bid(self):
        return min(list(self.bids.keys()))

    @property
    def best_ask(self):
        return min(list(self.bids.keys()))

    @property
    def worst_ask(self):
        return max(list(self.bids.keys()))

    @property
    def has_long_position(self):
        return self.long_position is not None and \
            self.long_position.abs_amount > 0

    @property
    def has_short_position(self):
        return self.short_position is not None and \
            self.short_position.abs_amount > 0

    @property
    def has_both_position(self):
        return self.both_position is not None and \
            self.both_position.abs_amount > 0

    @property
    def long_amount(self):
        return self.long_position.amount

    @property
    def short_amount(self):
        return self.short_position.amount

    @property
    def both_amount(self):
        return self.both_position.amount

    @property
    def price_per_contract(self):
        if self.last_price>0:
            return self.face_value/self.last_price 
        else: 
            return 0
    
    @property
    def balance(self):
        return self.account.balance

    @property
    def unrealized_pnl(self):
        return (self.long_position.unrealized_pnl + self.short_position.unrealized_pnl + self.both_position.unrealized_pnl)

    @property
    def equity(self):
        """
        Your total equity held with the exchange. Margin Balance = Wallet Balance + Unrealized PNL.
        """ 
        return self.balance + self.unrealized_pnl

    @property
    def net_position(self):
        return (self.long_position.amount - self.short_position.amount + self.both_position.amount)

    @property
    def total_state_value_mrg(self):
        """
        Returns the current value of the state denominated in margin.
        """
        return self.equity + (abs(self.net_position) * self.price_per_contract)/self.cross_leverage

    @property
    def total_state_value_cnt(self):
        """
        Returns the current value of the state denominated in contracts.
        """
        return int(self.equity/self.price_per_contract + abs(self.net_position)/self.cross_leverage)

    @property
    def trading_balance(self):
        """
        Determines the amount of balance available for trading as a allocated by the specified 
        trading fraction.
        trading balance = max(self.total_state_value_mrg * self.trading_fraction, 0)
        """
        pass

    @property
    def trading_value_cnt(self):
        """
        Returns the total portion of trading value in contracts that can be traded within the 
        constraints of the trading fraction.
        """
        return self.total_state_value_cnt * self.trading_fraction

    @property
    def notional_long(self):
        return self.long_position.abs_amount/self.cross_leverage

    @property
    def notional_short(self):
        return self.short_position.abs_amount/self.cross_leverage


    @property
    def reserved_balance_cnt(self):
        return 0

    @property
    def available_long(self): # TODO take into account orders
        """
        Returns the amount of availabe contracts that can be purchaced with the current state
        denominated in contracts
        """
        return max(self.trading_value_cnt - (self.notional_long + self.reserved_balance_cnt), 0)

    @property
    def available_short(self): #TODO take into account orders
        """
        Returns the amount of availabe contracts that can be purchaced with the current state
        denominated in contracts
        """
        return max(self.trading_value_cnt - (self.notional_short + self.reserved_balance_cnt), 0)

    @property
    def max_steps(self):
        """
        Returns the maximum number of steps the data can
        represent.
        """
        data = self.store.exec("max exec grp from prim")  
        return data.__dict__['values'][0] - 1

    @property
    def info(self):
        return {

        }
 
    # General state management logic
    # ------------------------------------------------------------------------->

    # TODO cache
    def get_price_at_level(self, level, side):
        """
        Returns the last price for a given level in the orderbook.
        """
        if side.is_buy:
            return self.bids_by_lvl[level][0]
        elif side.is_sell:
            return self.asks_by_lvl[level][0]

    # TODO cache
    def get_size_at_level(self, level, side):
        """
        Returns the last size for a given level in the orderbook.
        """
        if side.is_buy:
            return self.bids_by_lvl[level][1]
        elif side.is_sell:
            return self.asks_by_lvl[level][1]

    
    def _create_deposit(self, step_time, amount):
        events = []
        events += [Event(
            time=step_time, # TODO set time as offset
            action=EventAction.NEW, 
            typ=EventType.DEPOSIT,
            datum=Withdrawal(
                amount=amount,
            )
        )]
        return events

    def _create_withdraw(self, step_time, amount):
        events = []
        events += [Event(
            time=step_time, # TODO set time as offset
            action=EventAction.NEW, 
            typ=EventType.WITHDRAWAL,
            datum=Withdrawal(
                amount=amount,
            )
        )]
        return events

    # TODO derive liqquidation price / 10% loss point
    # TODO stepped stop order strategy
    def _gen_stop_orders_for_positions(self, step_time):
        """
        Generates a set of stop market orders that diametrically
        opose the current open positions and have the inverse 
        sign and a matching amount as a result, they execute
        at a specific price.  
        """
        events = []

        if self.has_long_position:
            events += [Event(
                time=step_time,
                action=EventAction.NEW, 
                typ=EventType.PLACE_ORDER,
                datum=StopMarketOrder(
                    side=Side.SELL,
                    size=self.long_amount,
                    trigger=StopTrigger.MARK_PRICE,
                    order_id=str(uuid.uuid4()),
                    stop_price=0, # TODO derive stop price
                    close_on_trigger=True
                )
            )]

        if self.has_short_position:
            events += [Event(
                time=step_time,
                action=EventAction.NEW, 
                typ=EventType.PLACE_ORDER,
                datum=StopMarketOrder(
                    side=Side.BUY,
                    size=self.short_amount,
                    trigger=StopTrigger.MARK_PRICE,
                    order_id=str(uuid.uuid4()),
                    stop_price=0, # TODO derive stop price
                    close_on_trigger=True
                )
            )]

        if self.has_both_position:
            events += [Event(
                time=step_time,
                action=EventAction.NEW, 
                typ=EventType.PLACE_ORDER,
                datum=StopMarketOrder(
                    side=Side.BUY if self.both_amount > 0 else Side.SELL,
                    size=self.both_amount,
                    trigger=StopTrigger.MARK_PRICE,
                    order_id=str(uuid.uuid4()),
                    stop_price=0, # TODO derive stop_price
                    close_on_trigger=True
                )
            )]

        return events

    def _get_auxillary_events_by_step(self, step):
        """
        Uses a preset query to derive a set of events
        that represent the progression of state on
        an exchange, thereafter the events are parsed
        into the forms defined by the models after which
        they are returned.
        """ 
        return self.store.exec(
            self.next_auxillary_events_qry.format(
                step=self.current_step
            ),
            parse_events=True
        )

    def _proc_next_state_resp(self, data):
        def depth_event(e):

            asks = {
                e[1]:e[2],
                e[3]:e[4],
                e[5]:e[6],
                e[7]:e[8],
                e[9]:e[10],
                e[11]:e[12],
                e[13]:e[14],
                e[15]:e[16],
                e[17]:e[18],
                e[19]:e[20],
            } 

            bids = {
                e[21]:e[22],
                e[23]:e[24],
                e[25]:e[26],
                e[27]:e[28],
                e[29]:e[30],
                e[31]:e[32],
                e[33]:e[34],
                e[35]:e[36],
                e[37]:e[38],
                e[39]:e[40],
            } 

            logging.error("asks:"+str(asks))
            logging.error("bids:"+str(bids))

            return Event(
                time=e[0],
                action=EventAction.UPDATE,
                typ= EventType.DEPTH,
                datum= Depth(
                    asks=asks,
                    bids=bids
                )
            )

        # logging.error(data.__dict__["parameters"][1].to_records())
        ob = [depth_event(e) for e in data.parameters[1]] 
        if len(ob)>0:
            ob = sorted(ob, key=lambda x: x.time)
            self.asks = ob[0].datum.asks
            self.bids = ob[0].datum.bids

        def trade_event(e):
            trade = Event(
                time=e[1],
                action=EventAction.NEW,
                typ= EventType.TRADE,
                datum=Trade(
                    side=Side.BUY if e[2] is "Buy" else Side.SELL,
                    size=e[3],
                    price=e[4]
                )
            )
            return trade


        # logging.error(data.__dict__["parameters"][2].to_records())
        tr = [trade_event(e) for e in data.parameters[2]]
        if len(tr)>0:
            tr = sorted(tr, key=lambda x: x.time) 
            self.last_price=tr[0].datum.price

        def mark_event(e):
            return Event(
                time=e[1],
                action=EventAction.UPDATE,
                typ= EventType.MARK,
                datum=MarkPrice(
                    mark_price=e[3]
                )
            )

        # logging.error(data.__dict__["parameters"][3].to_records())
        mk = [mark_event(e) for e in data.parameters[3]]
        if len(mk)>0:
            mk = sorted(mk, key=lambda x: x.time) 
            self.mark_price=mk[0].datum.mark_price 

        def funding_event(e):
            return Event(
                time=e[0],
                action=EventAction.UPDATE,
                typ= EventType.FUNDING,
                datum=Funding(
                    funding_rate=e[2],
                    next_funding_time=e[0] # TODO add funding interval
                )
            )

        # logging.error(data.__dict__["parameters"][3].to_records())
        fd = [funding_event(e) for e in data.parameters[4]]
        return ob + tr + mk + fd 

    # TODO convert to batches
    def _next_state(self, step):
        """
        Uses a preset query to derive a set of events
        that represent the progression of state on
        an exchange, thereafter the events are parsed
        into the forms defined by the models after which
        they are returned.
        """

        # TODO make configurable and move replace
        # to configuration
        qry = """(
            select from source_depth where grp={step};
            select from source_trades where grp={step};
            select from source_mark where grp={step};
            select from source_funding where grp={step};
            exec from prim where grp={step};
        )"""\
        .replace("\n", "")\
        .replace("  ", "")\
        .format(step=step)

        data = self.store.exec(qry, pandas=False)
        # xm = self.store.exec(qry, pandas=False)
        
        # logging.error(xm)
        # logging.error(xm[0][1])
        
        events = self._proc_next_state_resp(data)
        return events, data.parameters[5].values[0]
 
    def _get_feature_vector(self, step):
        """
        Uses a preset query to derive a feature vector
        from a database aggregating the data derived
        from the modified source events derived from
        an exchange(s). Seen as though the result will
        be merely returned in vector form, there is no
        need for a parser to be passed.
        Uses a seperate table to the above event query
        function on account of the premise that the event
        flow and resultant state representation need
        to be simulated.
        """

        # TODO clean and scale feature vector
        # TODO add percepts to a lookback buffer that is scaled
        # TODO add additional features such as minute/5minute/10minute predictions, data from multiple exchanges, tweet sentiment, candle indicators, sub model predictions etc.
        # qry = """.ml.minmaxscaler[.automl.prep.i.nullencode[]]"""\
        # .replace("\n", "")\
        # .replace("  ", "")
        # data = self.store.exec(qry, pandas=False)

        # obs =  np.nan_to_num(data)
        # obs = np.array(self.scaler.transform(np.expand_dims(obs,axis=0))).flatten() # TODO change to kdb implementation
        # obs = np.nan_to_num(obs)

        # logging.error(obs)

        return np.random.uniform(low=0, high=255, size=(100,))

    def _get_resultant_reward(self):
        """
        Uses a query to derive a given reward.
        """
        return np.random.uniform(low=-1, high=1, size=(1,))[0]

    # TODO do async
    def _insert_resultant_events(self, events, raise_errors=False):
        """
        Insert resultant events, groupes events by type and then
        batch inserts them into the store by deriving the query from
        the parsers located in the parsers model.
        """
        self.store.insert_events(events)

    def _derive_events_from_action(self, step_time, action):
        """
        Recieves an action from the agent and subsequently 
        produces a set of events given the current state
        that correspond to the delta between the current 
        state and the desired state.
        """
        penalty, events = 0.0, []
        penalty, events = self.adapter.gen_events_from_action(
            step_time = step_time,
            action=action
        )

        # Introduce offset for each event, batch them
        # based on allowed request endpoints for the
        # given exchange.  TODO do grouping?
        # events = [e.time for e in events] # TODO insert event offset

        # Insert stop order updates for each mark price
        # update based on configuration

        # Increment request count based on config
        return penalty, events

    def derive(self, action):
        """
        Derives the set of events that would constitute the
        state representation of the exchange before the action
        took place.
        """
        penalty, events, fevents = 0.0, [], [] 

        source_events, step_time = self._next_state(
            step=self.current_step
        )
        events += source_events
        # logging.error(source_events)
        # fevents += self._get_auxillary_events_by_step(
        #   step=self.current_step
        # ) # TODO config generate auxillary events

        # Generates stop market events that diametrically
        # oppose the current open positions and prevent
        # liquidation.
        events += self._gen_stop_orders_for_positions(
            step_time=step_time
        )
        # logging.error(events)

        # Generates a set of events that represent the 
        # change from the current state of the agent
        # to the desired state.
        if hasattr(self, 'prev_step_time'):
            logging.error("-"*90)
            logging.error(self.prev_step_time)
            offset_time = self.prev_step_time + np.timedelta64(100, 'ms')  
        else:
            offset_time = step_time
        penalty, action_events = self._derive_events_from_action(
            step_time=offset_time, #TODO should be prev step time + average request delay
            action=action
        )
        # logging.error("-"*90)
        # logging.error(action_events)
        events += action_events 
        self.prev_step_time = step_time

        return penalty, events, fevents

    def advance(self, events):
        """
        Recieves events from either the exchange or the engine
        and inserts those events into the store, thereafter deriving
        the next observations, reward, done and state info from
        various sources.
        """
        self.current_step += 1

        # Insert the res
        self._insert_resultant_events(events)

        # Derive the next feature vector that is to be fed
        # to the agent 
        feature_vector = self._get_feature_vector(self.current_step)
        reward = self._get_resultant_reward() 

        return feature_vector, reward

    # Reset and Step Logic
    # ------------------------------------------------------------------------->

    def reset(self):
        self.current_step, events = 0, []

        # Add initial account update events etc. 
        # to events that will be
        source_events, step_time = self._next_state(
            step=self.current_step
        )
        events += self._create_deposit(
            step_time=step_time,
            amount=self.initial_balance
        )

        # Process initial event batch event batch
        events, _ = self.engine.process_event_batch(
            events=events
        )

        # append a set of events that represent the current
        # initial state of the agent account, positions and
        # orders such that they can be represented locally
        # these will be implemented with simulated rest 
        # requests.

        def account_event(e, step_time):
            self.account = e
            return Event(
                time=step_time,
                action=EventAction.UPDATE,
                typ=EventType.ACCOUNT_UPDATE,
                datum=e
            )

        events += [account_event(e, step_time) for e in self.engine._get_account()]

        def position_event(e, step_time):
            if e.side.is_long:
                self.long_position = e
            elif e.side.is_short:
                self.short_position = e
            elif e.side.is_both:
                self.both_position = e
            return Event(
                time=step_time,
                action=EventAction.UPDATE,
                typ=EventType.POSITION_UPDATE,
                datum=e
            )

        events += [position_event(e, step_time) for e in self.engine._get_positions()]
        
        def order_event(e, step_time):
            return Event(
                time=step_time,
                action=EventAction.UPDATE,
                typ=EventType.ORDER_UPDATE,
                datum=e
            )

        events += [order_event(e) for e in self.engine._get_orders()] 

        # Insert resultant events into the
        # local state representation.
        logging.error([e.__dict__ for e in events])
        self._insert_resultant_events(events)

        # Derive the next feature vector that is to be fed
        # to the agent 
        feature_vector = self._get_feature_vector(self.current_step) 
        
        self.current_step += 1
        return feature_vector

    def step(self, action):
        info = {}
        done = False
        penalty = 0.0

        # Get the set of events that have occurred between
        # the end of the last step and the current step
        # this replicates what the agent will "see"
        # given the ingress model, it will also
        # derive a set of events from the action, an
        # adapter utilizes the state representation held
        # in the store to derive certain parameters, 
        # just like they would be derived in production.
        # The function also returns an action penalty 
        # which would be muted in production.
        # The events are ordered in a manner to replicate
        # the dynamics of a production environment.
        action_penalty, events, fevents = self.derive(
            action=action
        )
        penalty += action_penalty

        # The engine which handles the progression of logic
        # will loop through the events batch derived from the
        # action and source (from exchange). It will subsequently
        # raise errors if any exist or else will update its own
        # internal state. It will then return a set of statistics
        # which could be logged, and a set of new events which
        # represent the updated state of the next step.
        new_events, engine_info = self.engine.process_event_batch(
            events=events
        )
        info.update(engine_info)

        # The state will then recieve the events from the engine
        # which is analagous of what will occur in a live environment
        # it will subsequently insert the events into the store
        # and derive the next (aggregated) observation set from this
        # including positions, account, orders, depth, aux etc.
        # It will also derive a reward from the state depending
        # on the provided config, check if it is done and return 
        # state info
        next_obs, reward = self.advance(
            events=new_events+fevents
        ) 
        

        
        # TODO get if done
        info.update(self.info)


        return next_obs, reward, done, info