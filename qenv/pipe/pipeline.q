
book:([]
  time:`datetime$();
  intime:`datetime$();
  side:`char$();
  price:`int$();
  size:`int$());
book:`side`price`time xkey book;

trade:([]
  time:`datetime$();
  intime:`datetime$();
  side:`char$();
  price:`int$();
  size:`int$());
trade:`side`price`time xkey trade;

funding:();

mark:();

ingressD :{[u]
    `book upsert ([] side:10#`B,10#`S;[] price:`int$(); [] time: "Z"$(); intime: "Z"$(); size:`int$());
    };