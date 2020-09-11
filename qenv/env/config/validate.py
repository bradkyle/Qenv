
import json

def Validatev1(conf):
    # https://pypi.org/project/python-json-config/
    from python_json_config import ConfigBuilder
    builder = ConfigBuilder()
    
    # Add all validation constructs here

    config = builder.parse_config(conf)
    return config.to_json()

def Validatev2(conf):
    # https://pypi.org/project/json-cfg/

    return 