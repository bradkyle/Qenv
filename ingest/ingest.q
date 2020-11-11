
getNextBatch   :{[kinds;start;end]
  select from events where time within (start;end), kind in kinds 
  };

registerWorker :{[]
				  
  };
