


q)book:`time xasc (flip `time`intime`side`price`size!raze'[flip (deriveBook each (select from depth where utc_time>(mxt-`minute$30)))]);
q)trd:flip `time`intime`side`price`size!raze'[flip (deriveTrade each (select from trade where utc_time>(mxt-`minute$30)))]
q)select pqty:prev size, tsize, nqty:next size by time, price from x where not[null[tsize]]