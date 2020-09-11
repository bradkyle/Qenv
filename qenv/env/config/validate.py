
import json

# uses python-json-config
# https://pypi.org/project/python-json-config/
def ValidateV1(conf):
    from python_json_config import ConfigBuilder
    builder = ConfigBuilder()
    
    # Add all validation constructs here

    config = builder.parse_config(conf)
    return config.to_json()

# uses json-cfg
# https://pypi.org/project/json-cfg/
def ValidateV2(conf):
    import datetime
    import jsoncfg
    from jsoncfg import JSONValueMapper
    from jsoncfg.value_mappers import require_integer

    class OneOf(JSONValueMapper):
        def __init__(self, *enum_members):
            self.enum_members = set(enum_members)

        def __call__(self, v):
            if v not in self.enum_members:
                raise ValueError('%r is not one of these: %r' % (v, self.enum_members))
            return v

    class RangeCheck(JSONValueMapper):
        def __init__(self, min_, max_):
            self.min = min_
            self.max = max_

        def __call__(self, v):
            if self.min <= v < self.max:
                return v
            raise ValueError('%r is not in range [%r, %r)' % (v, self.min, self.max))

    class ToDateTime(JSONValueMapper):
        def __call__(self, v):
            if not isinstance(v, str):
                raise TypeError('Expected a naive iso8601 datetime string but found %r' % (v,))
            return datetime.datetime.strptime(v, '%Y-%m-%dT%H:%M:%S')

    conf = json.loads(conf)

    return 