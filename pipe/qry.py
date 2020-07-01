
num_lvls = 10


l = []
for i in range(num_lvls):
    for s in ['ask', 'bid']:
        l.append("".join([
            "_".join([s+str(i), "dlt"]),
            ":{0,1_deltas x}",
            "_".join([s+str(i), "size"]),
        ]))


qry = """
x:update """+','.join(l)+""" from orderbook;
"""

with open("./qry.txt", "a+") as f:
    f.write(qry)
    f.close()

l = []
for i in range(num_lvls):
    for s in ['ask', 'bid']:
        l.append("".join([
            "sum ",
            "_".join([s+str(i), "dlt"]),
            ", last ",
            "_".join([s+str(i), "price"]),
            ", last ",
            "_".join([s+str(i), "size"]),
        ]))


qry2 = """
x:select """+','.join(l)+""" by time from x;
"""

with open("./qry2.txt", "a+") as f:
    f.write(qry2)
    f.close()


l = []
for i in range(num_lvls):
    for s in ['ask', 'bid']:
        l.append("".join([
            "sum ",
            "_".join([s+str(i), "dlt"]),
            ", last ",
            "_".join([s+str(i), "price"]),
            ", last ",
            "_".join([s+str(i), "size"]),
        ]))


qry3 = """
x:select """+','.join(l)+""" by time from x;
"""

with open("./qry2.txt", "a+") as f:
    f.write(qry2)
    f.close()