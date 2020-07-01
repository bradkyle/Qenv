

class InvalidTickSize(Exception): pass
class OrderShouldParticipate(Exception): pass
class OrderSizeTooBig(Exception): pass
class OrderSizeTooSmall(Exception): pass
class OrderPriceTooHigh(Exception): pass
class OrderPriceTooLow(Exception): pass
class TooManyOpenAgentOrders(Exception): pass
class OrderNotFound(Exception): pass
class ZeroExecution(Exception): pass
class InvalidExecutionPrice(Exception): pass
class InsufficientBalance(Exception): pass