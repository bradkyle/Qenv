# https://pypi.org/project/python-json-config/
# https://pypi.org/project/json-cfg/

from python_json_config import ConfigBuilder
import json

def Validatev1(conf):
    builder = ConfigBuilder()
    
    # Add all validation constructs here

    config = builder.parse_config(conf)
    return config.to_json()

def Validatev2(conf):
    builder = ConfigBuilder()
    
    # Add all validation constructs here

    config = builder.parse_config(conf)
    return config.to_json()