
\l kafka/kfk.q
\l prometheuskdb/q/exporter.q 
\p 8080

khost:getenv[`KAFKA_HOST]
kport:getenv[`KAFKA_PORT]
ktopic:getenv[`KAFKA_TOPIC]
kgroup:getenv[`KAFKA_GROUP]
show (khost;kport;ktopic)

kfk_cfg:(!) . flip(
    (`metadata.broker.list;(`$":"sv (khost;kport)));
    (`group.id;`0);
    (`fetch.wait.max.ms;`10);
    (`statistics.interval.ms;`10000)
    );
client:.kfk.Consumer[kfk_cfg];

// reads from kafka topic  
// and writes to partitioned table 
// that can then be transitioned to 
// long term permenant storage
events:();
upd:{[msg]
  msg[`data]:"c"$msg[`data];
  msg[`rcvtime]:.z.p;
  if[count[events];[
      path:.Q.par[`:data;];
    ]];


  };

// Subscribe to topic1 and topic2 with different callbacks from a single client
.kfk.Subscribe[client;`$ktopic;enlist .kfk.PARTITION_UA;upd]


.z.ts :{
  // Get a batch from kafka 

  // write the files to google cloud storage in a partitioned manner

  // ack/progress the consumer watermark 

  };
