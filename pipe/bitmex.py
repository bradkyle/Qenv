import pyarrow as pa 
import pyarrow.parquet as pq 
import pandas as pd 
import time 
from qpython import qconnection
import json
import math
import logging
from functools import reduce

PATH = "/home/thorad/Core/Projects/Coll/lcl/mnt/lcl/d22ad0e750dd428bbb602f708fae03b7/utc_day=20200610/sid=bitmexagentxbtusd"

dataset = pq.ParquetDataset(PATH)
table = dataset.read()
df = table.to_pandas()
logging.error(len(df))
trades = df[df["cid"]=="trade"]
orderbooks = df[df["cid"]=="orderbook"]
ins = df[df["cid"]=="instrument"]
liq = df[df["cid"]=="liquidation"]
co = df[df["cid"]=="connected"]
fnd = df[df["cid"]=="funding"]
logging.error(len(trades))
"""
'cid=announcement'
'cid=connected'
'cid=instrument'
'cid=liquidation'
'cid=orderbookl'
'cid=trade'
'cid=chat'
'cid=funding'  
'cid=insurance'
'cid=orderbook'    
'cid=settlement'
"""

def _exec(qry):
    with qconnection.QConnection(host = "localhost", port=5050, pandas=True) as q:
        data = q.sendSync(qry) 
        print(data)

def _derive_float_insert():
    pass

def _derive_time_insert():
    pass

def _derive_long_insert():
    pass

def create_funding_table():
    create_str = """source_funding:(
        []time:`datetime$();
        funding_rate:`float$();
        funding_rate_daily:`float$();
        funding_interval:`datetime$()
    );"""
    _exec(create_str)

def create_liquidation_table():
    create_str = """source_liquidation:(
        side:`symbol$();
        leaves:`float$();
        price:`float$();
    );    
    """
    _exec(create_str) 

def create_orderbookl_table():
    create_str = """source_orderbookl:(
        id:`long$();
        side:`symbol$();
        size:`float$();
        price:`float$();
    );"""
    _exec(create_str) 
 
def create_connected_table():
    create_str = """connected:(
        users: `long$();
        bots: `long$()
    );    
    """
    _exec(create_str)

def create_instrument_table():
    create_str = """source_instrument:(
        []time:`datetime$();
        volume24h:`float$();
        impactBidPrice:`float$();
        bidPrice:`float$();
        markPrice:`float$();
        openInterest:`float$();
        askPrice:`float$();
        homeNotional24h:`float$();
        totalTurnover:`float$();
        fairPrice:`float$();
        prevTotalVolume:`float$();
        volume:`float$();
        indicativeSettlePrice:`float$();
        turnover24h:`float$();
        vwap:`float$();
        prevPrice24h:`float$();
        fairBasis:`float$();
        prevTotalTurnover:`float$();
        turnover:`float$();
        lastPrice:`float$();
        totalVolume:`float$();
        lastPriceProtected:`float$();
        openValue:`float$();
        lastChangePcnt:`float$();
        midPrice:`float$();
        foreignNotional24h:`float$();
        impactAskPrice:`float$();
        impactMidPrice:`float$()
    )"""
    _exec(create_str)

def create_orderbook_table(levels=10, fields=[['price', 'float'],['size', 'float']]):
    o = []
    for s in ['ask', 'bid']:
        for i in range(10):
            for ps, t in fields:
                o.append(s+str(i)+"_"+ps+":`"+t+"$()")

    create_str = "source_depth:([]time:`datetime$();symbol:`symbol$();"+";".join(o)+")"
    _exec(create_str)

def create_orderbook_table_by_lvls():
    create_str = """orderbook:(
        []time:`datetime$();
        level:`long$();
        side:`symbol$();
        size:`float$();
        price:`float$();
        symbol:`symbol$()
    )"""
    _exec(create_str)


def create_trades_table():
    create_str = """source_trades:(
        []time:`datetime$();
        side:`symbol$();
        size:`float$();
        price:`float$();
        grossValue:`float$();
        homeNotional:`float$();
        foreignNotional:`float$();
        symbol:`symbol$()
    )"""
    _exec(create_str)

import numpy as np
from qpython.qtype import qnull, QDOUBLE
def _st(i):
    if np.isnan(i):
        return "null"
    else:
        return str(i)

# TODO pivot table convert to events table
def insert_instruments(df):   
    # df.fillna(method="ffill", inplace=True)     
    # df.fillna(0, inplace=True)
    ins_str="`source_instrument insert("+"".join([
        '[]time:"Z"$('+"; ".join('"'+str(i)+'"' for i in df["timestamp"].tolist()) + ");",
#         "symbol:"+"".join('`'+_st("XBTUSD").lower() for i in df["symbol"].tolist())+";",
        "volume24h:"+" ".join(_st(i) for i in df["volume24h"].tolist())+"f;", #
        "impactBidPrice:"+" ".join(_st(i) for i in df['impactBidPrice'].tolist()) + "f;",
        "bidPrice:"+" ".join(_st(i) for i in df['bidPrice'].tolist()) + "f;",
        "markPrice:"+" ".join(_st(i) for i in df['markPrice'].tolist()) + "f;",
        "openInterest:"+" ".join(_st(i) for i in df['openInterest'].tolist()) + "f;",
        "askPrice:"+" ".join(_st(i) for i in df['askPrice'].tolist()) + "f;",
        "homeNotional24h:"+" ".join(_st(i) for i in df['homeNotional24h'].tolist()) + "f;",
        "totalTurnover:"+" ".join(_st(i) for i in df['totalTurnover'].tolist()) + "f;",
        "fairPrice:"+" ".join(_st(i) for i in df['fairPrice'].tolist()) + "f;",
        "prevTotalVolume:"+" ".join(_st(i) for i in df['prevTotalVolume'].tolist()) + "f;",
        "volume:"+" ".join(_st(i) for i in df['volume'].tolist()) + "f;",
        "indicativeSettlePrice:"+" ".join(_st(i) for i in df['indicativeSettlePrice'].tolist()) + "f;",
        "turnover24h:"+" ".join(_st(i) for i in df['turnover24h'].tolist()) + "f;",
        "vwap:"+" ".join(_st(i) for i in df['vwap'].tolist()) + "f;",
        "prevPrice24h:"+" ".join(_st(i) for i in df['prevPrice24h'].tolist()) + "f;",
        "fairBasis:"+" ".join(_st(i) for i in df['fairBasis'].tolist()) + "f;",
        "prevTotalTurnover:"+" ".join(_st(i) for i in df['prevTotalTurnover'].tolist()) + "f;",
        "turnover:"+" ".join(_st(i) for i in df['turnover'].tolist()) + "f;",
        "lastPrice:"+" ".join(_st(i) for i in df['lastPrice'].tolist()) + "f;",
        "totalVolume:"+" ".join(_st(i) for i in df['totalVolume'].tolist()) + "f;",
        "lastPriceProtected:"+" ".join(_st(i) for i in df['lastPriceProtected'].tolist()) + "f;",
        "openValue:"+" ".join(_st(i) for i in df['openValue'].tolist()) + "f;",
        "lastChangePcnt:"+" ".join(_st(i) for i in df['lastChangePcnt'].tolist()) + "f;",
        "midPrice:"+" ".join(_st(i) for i in df['midPrice'].tolist()) + "f;",
        "foreignNotional24h:"+" ".join(_st(i) for i in df['foreignNotional24h'].tolist()) + "f;",
        "impactAskPrice:"+" ".join(_st(i) for i in df['impactAskPrice'].tolist()) + "f;",
        "impactMidPrice:"+" ".join(_st(i) for i in df['impactMidPrice'].tolist()) + "",
    ]) + ");"
    # logging.error(ins_str)
    _exec(ins_str)

def insert_orderbooks_by_lvl(df):
    ins_str = "`orderbook insert("+"".join([
    '[]time:"Z"$('+"; ".join('"'+str(i)+'"' for i in df["timestamp"].tolist()) + ");",
    "symbol:"+"".join('`'+str(i).lower() for i in df["symbol"].tolist())+";",
    "side:"+"".join('`'+str(i) for i in df["side"].tolist()) + ";",
    "level:"+" ".join(str(i) for i in df["level"].tolist()) + ";",
    "size:"+" ".join(str(i) for i in df["size"].tolist()) + ";",
    "price:"+" ".join(str(i) for i in df["price"].tolist()) + "f",
    ]) + ")"
    _exec(ins_str)


def insert_orderbookl(df):
    ins_str = "`orderbook insert("+"".join([
    '[]time:"Z"$('+"; ".join('"'+str(i)+'"' for i in df["timestamp"].tolist()) + ");",
    "symbol:"+"".join('`'+str(i).lower() for i in df["symbol"].tolist())+";",
    "id:"+" ".join(str(i) for i in df["id"].tolist()) + ";",
    "side:"+"".join('`'+str(i) for i in df["side"].tolist()) + ";",
    "size:"+" ".join(str(i) for i in df["size"].tolist()) + "f;",
    "price:"+" ".join(str(i) for i in df["price"].tolist()) + "f",
    ]) + ")"
    _exec(ins_str)

def insert_orderbooks(df):
    ins_str = "`source_depth insert("+"".join([
        '[]time:"Z"$('+"; ".join('"'+str(i)+'"' for i in df["timestamp"].tolist()) + ");",
        "symbol:"+"".join('`'+str(i).lower() for i in df["symbol"].tolist())+";",
        "ask0_price:"+" ".join(str(i) for i in df['ask0_price'].tolist()) + "f;",
        "ask1_price:"+" ".join(str(i) for i in df['ask1_price'].tolist()) + "f;",
        "ask2_price:"+" ".join(str(i) for i in df['ask2_price'].tolist()) + "f;",
        "ask3_price:"+" ".join(str(i) for i in df['ask3_price'].tolist()) + "f;",
        "ask4_price:"+" ".join(str(i) for i in df['ask4_price'].tolist()) + "f;",
        "ask5_price:"+" ".join(str(i) for i in df['ask5_price'].tolist()) + "f;",
        "ask6_price:"+" ".join(str(i) for i in df['ask6_price'].tolist()) + "f;",
        "ask7_price:"+" ".join(str(i) for i in df['ask7_price'].tolist()) + "f;",
        "ask8_price:"+" ".join(str(i) for i in df['ask8_price'].tolist()) + "f;",
        "ask9_price:"+" ".join(str(i) for i in df['ask9_price'].tolist()) + "f;",
        "ask0_size:"+" ".join(str(i) for i in df["ask0_size"].tolist()) + "f;",
        "ask1_size:"+" ".join(str(i) for i in df["ask1_size"].tolist()) + "f;",
        "ask2_size:"+" ".join(str(i) for i in df["ask2_size"].tolist()) + "f;",
        "ask3_size:"+" ".join(str(i) for i in df["ask3_size"].tolist()) + "f;",
        "ask4_size:"+" ".join(str(i) for i in df["ask4_size"].tolist()) + "f;",
        "ask5_size:"+" ".join(str(i) for i in df["ask5_size"].tolist()) + "f;",
        "ask6_size:"+" ".join(str(i) for i in df["ask6_size"].tolist()) + "f;",
        "ask7_size:"+" ".join(str(i) for i in df["ask7_size"].tolist()) + "f;",
        "ask8_size:"+" ".join(str(i) for i in df["ask8_size"].tolist()) + "f;",
        "ask9_size:"+" ".join(str(i) for i in df["ask9_size"].tolist()) + "f;",
        "bid0_price:"+" ".join(str(i) for i in df['bid0_price'].tolist()) + "f;",
        "bid1_price:"+" ".join(str(i) for i in df['bid1_price'].tolist()) + "f;",
        "bid2_price:"+" ".join(str(i) for i in df['bid2_price'].tolist()) + "f;",
        "bid3_price:"+" ".join(str(i) for i in df['bid3_price'].tolist()) + "f;",
        "bid4_price:"+" ".join(str(i) for i in df['bid4_price'].tolist()) + "f;",
        "bid5_price:"+" ".join(str(i) for i in df['bid5_price'].tolist()) + "f;",
        "bid6_price:"+" ".join(str(i) for i in df['bid6_price'].tolist()) + "f;",
        "bid7_price:"+" ".join(str(i) for i in df['bid7_price'].tolist()) + "f;",
        "bid8_price:"+" ".join(str(i) for i in df['bid8_price'].tolist()) + "f;",
        "bid9_price:"+" ".join(str(i) for i in df['bid9_price'].tolist()) + "f;",
        "bid0_size:"+" ".join(str(i) for i in df["bid0_size"].tolist()) + "f;",
        "bid1_size:"+" ".join(str(i) for i in df["bid1_size"].tolist()) + "f;",
        "bid2_size:"+" ".join(str(i) for i in df["bid2_size"].tolist()) + "f;",
        "bid3_size:"+" ".join(str(i) for i in df["bid3_size"].tolist()) + "f;",
        "bid4_size:"+" ".join(str(i) for i in df["bid4_size"].tolist()) + "f;",
        "bid5_size:"+" ".join(str(i) for i in df["bid5_size"].tolist()) + "f;",
        "bid6_size:"+" ".join(str(i) for i in df["bid6_size"].tolist()) + "f;",
        "bid7_size:"+" ".join(str(i) for i in df["bid7_size"].tolist()) + "f;",
        "bid8_size:"+" ".join(str(i) for i in df["bid8_size"].tolist()) + "f;",
        "bid9_size:"+" ".join(str(i) for i in df["bid9_size"].tolist()) + "f",
    ]) + ")"
    _exec(ins_str)

def insert_trades(df):   
    ins_str = "`source_trades insert("+"".join([
    '[]time:"Z"$('+"; ".join('"'+str(i)+'"' for i in df["timestamp"].tolist()) + ");",
    "symbol:"+"".join('`'+str(i).lower() for i in df["symbol"].tolist())+";",
    "side:"+"".join('`'+str(i) for i in df["side"].tolist()) + ";",
    "size:"+" ".join(str(i) for i in df["size"].tolist()) + "f;",
    "price:"+" ".join(str(i) for i in df["price"].tolist()) + "f;",
    "grossValue:"+" ".join(str(i) for i in df["grossValue"].tolist()) + "f;",
    "homeNotional:"+" ".join(str(i) for i in df["homeNotional"].tolist()) + "f;",
    "foreignNotional:"+" ".join(str(i) for i in df["foreignNotional"].tolist()) + "f",
    ]) + ")"
    _exec(ins_str)

logging.error(len(fnd))

def insert_funding(df):   
    ins_str = "`source_funding insert("+"".join([
    'time:"Z"$('+"; ".join('"'+str(i)+'"' for i in df["timestamp"].tolist()) + ");", 
    "funding_rate:"+" ".join(str(round(i, 6)) for i in df["fundingRate"].tolist()) + "f;", 
    "funding_rate_daily:"+" ".join(str(round(i, 6)) for i in df["fundingRateDaily"].tolist()) + "f;", 
    'funding_interval:"Z"$('+"; ".join('"'+str(i)+'"' for i in df["fundingInterval"].tolist()) + ")", 
    ]) + ");"
    logging.error(ins_str)
    _exec(ins_str)

def insert_liquidation(df):   
    ins_str = "`trades insert("+"".join([
    '[]time:"Z"$('+"; ".join('"'+str(i)+'"' for i in df["timestamp"].tolist()) + ");",
    "symbol:"+"".join('`'+str(i).lower() for i in df["symbol"].tolist())+";",
    "side:"+"".join('`'+str(i) for i in df["side"].tolist()) + ";",
    "leaves:"+" ".join(str(i) for i in df["size"].tolist()) + ";",
    "price:"+" ".join(str(i) for i in df["price"].tolist()) + "f"
    ]) + ")"
    _exec(ins_str)

def insert_connected(df):   
    ins_str = "`connected insert("+"".join([
    '[]time:"Z"$('+"; ".join('"'+str(i)+'"' for i in df["timestamp"].tolist()) + ");",
    "users:"+" ".join(str(i) for i in df["users"].tolist()) + ";",
    "bots:"+" ".join(str(i) for i in df["bots"].tolist()) + ""
    ]) + ")"
    _exec(ins_str)

def parse_and_return(r, ret_first=False):
    x = json.loads(r)
    if ret_first:
        return x["data"][0]
    else:
        return x["data"]

def preprocess_trades(df):
    trades = df["resp"].apply(parse_and_return).tolist()
    final_trades = []
    for trade_item in trades:
        for trade in trade_item:
            final_trades.append(trade)
    return pd.DataFrame(final_trades)

def preprocess_funding(df):
    fs = df["resp"].apply(parse_and_return).tolist()
    fundings = []
    for funding_item in fs:
        for trade in funding_item:
            fundings.append(trade)
    return pd.DataFrame(fundings)

def preprocess_connected(df):
    df["resp"] = df["resp"].apply(parse_and_return).tolist()
    connected = []
    for connected_item in cs:
        for it in connected_item:
            connected.append(it)
    return pd.DataFrame(connected)

def preprocess_liquidation(df):
    ls = df["resp"].apply(parse_and_return).tolist()
    liquidations = []
    for li in ls:
        for it in li:
            liquidations.append(it)
    return pd.DataFrame(liquidations)

def preprocess_orderbookl(df):
    obl = df["resp"].apply(parse_and_return).tolist()
    obls = []
    for li in obl:
        for it in li:
            obls.append(it)
    return pd.DataFrame(obls)

def preprocess_instrument(df):
    obl = df["resp"].apply(parse_and_return).tolist()
    obls = []
    for li in obl:
        for it in li:
            obls.append(it)
    # logging.error(obls)
    df = pd.DataFrame(obls)
    # logging.error(df.head())
    return df

def preprocess_orderbooks(df):
    orderbooks = df["resp"].apply(parse_and_return).tolist()
    final_obs = []
    for obs in orderbooks:
        for x in obs:
            final_obs.append({
                'symbol':x['symbol'],
                'timestamp': x['timestamp'],
                'ask0_price': x['asks'][0][0],
                'ask1_price': x['asks'][1][0],
                'ask2_price': x['asks'][2][0],
                'ask3_price': x['asks'][3][0],
                'ask4_price': x['asks'][4][0],
                'ask5_price': x['asks'][5][0],
                'ask6_price': x['asks'][6][0],
                'ask7_price': x['asks'][7][0],
                'ask8_price': x['asks'][8][0],
                'ask9_price': x['asks'][9][0],
                'ask0_size': x['asks'][0][1],
                'ask1_size': x['asks'][1][1],
                'ask2_size': x['asks'][2][1],
                'ask3_size': x['asks'][3][1],
                'ask4_size': x['asks'][4][1],
                'ask5_size': x['asks'][5][1],
                'ask6_size': x['asks'][6][1],
                'ask7_size': x['asks'][7][1],
                'ask8_size': x['asks'][8][1],
                'ask9_size': x['asks'][9][1],
                'bid0_price': x['bids'][0][0],
                'bid1_price': x['bids'][1][0],
                'bid2_price': x['bids'][2][0],
                'bid3_price': x['bids'][3][0],
                'bid4_price': x['bids'][4][0],
                'bid5_price': x['bids'][5][0],
                'bid6_price': x['bids'][6][0],
                'bid7_price': x['bids'][7][0],
                'bid8_price': x['bids'][8][0],
                'bid9_price': x['bids'][9][0],
                'bid0_size': x['bids'][0][1],
                'bid1_size': x['bids'][1][1],
                'bid2_size': x['bids'][2][1],
                'bid3_size': x['bids'][3][1],
                'bid4_size': x['bids'][4][1],
                'bid5_size': x['bids'][5][1],
                'bid6_size': x['bids'][6][1],
                'bid7_size': x['bids'][7][1],
                'bid8_size': x['bids'][8][1],
                'bid9_size': x['bids'][9][1],
            })
    return pd.DataFrame(final_obs)

def preprocess_orderbooks_by_lvl(df, num_lvls=10):
    orderbooks = df["resp"].apply(parse_and_return).tolist()
    final_obs = []
    for obs in orderbooks:
        for x in obs:
            for n in range(num_lvls):
                for s in ['ask', 'bid']:
                    final_obs.append({
                        'symbol':x['symbol'],
                        'timestamp': x['timestamp'],
                        'level': n,
                        'side': s, 
                        'price': x[s + 's'][n][0],
                        'size': x[s + 's'][n][1]
                    })
    return pd.DataFrame(final_obs)

def do_trades(df):
    create_trades_table()
    df = preprocess_trades(df)
    logging.error(len(df))
    insert_trades(df)

def do_fundings(df):
    create_funding_table()
    df = preprocess_funding(df)
    insert_funding(df)

def do_liquidations(df):
    create_liquidation_table()
    df = preprocess_liquidation(df)
    insert_liquidation(df)

def do_connected(df):
    create_connected_table()
    df = preprocess_connected(df)
    insert_connected(df)

def do_orderbooks(df, split=25000, by_level=False):
    if not by_level:
        create_orderbook_table()
        cnt = math.ceil(len(df)/split)
        for x in range(cnt):
            idx = [x*split, min((x+1)*split, len(df))]
            print(idx)
            o = preprocess_orderbooks(df.iloc[x*split: min((x+1)*split, len(df))])
            print(o.describe())
            insert_orderbooks(o)
    else:
        create_orderbook_table_by_lvls()
        cnt = math.ceil(len(df)/split)
        for x in range(cnt):
            idx = [x*split, min((x+1)*split, len(df))]
            print(idx)
            o = preprocess_orderbooks_by_lvl(df.iloc[x*split: min((x+1)*split, len(df))])
            print(list(o.columns))
            print(o.describe())
            print(o.shape)
            insert_orderbooks_by_lvl(o)

def do_instruments(df):
    df= pd.DataFrame(reduce(lambda x,y: x+y, df[df.cid=="instrument"]["resp"].apply(lambda x: json.loads(x)["data"]).tolist()))
    ac = [
        "time",
        "volume24h",                     
        "impactBidPrice",                
        "bidPrice",                      
        "markPrice",                     
        "openInterest",                  
        "askPrice",                      
        "homeNotional24h",               
        "totalTurnover",                 
        "fairPrice",                     
        "prevTotalVolume",               
        "volume",                        
        "indicativeSettlePrice",         
        "turnover24h",                   
        "vwap",                          
        "prevPrice24h",                  
        "fairBasis",                     
        "prevTotalTurnover",             
        "turnover",                      
        "lastPrice",                     
        "totalVolume",                   
        "lastPriceProtected",            
        "openValue",                     
        "lastChangePcnt",                
        "midPrice",                      
        "foreignNotional24h",            
        "impactAskPrice",                
        "impactMidPrice",                
    ]
    df.rename(columns={"timestamp": "time"}, inplace=True)
    _exec(('{source_instrument:: x}',df[ac]))

do_trades(trades)
do_orderbooks(orderbooks)
do_fundings(fnd)
# do_connected(co)
# do_liquidations(liq)
do_instruments(ins)
