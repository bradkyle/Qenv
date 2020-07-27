

// Source Event Tables
// =====================================================================================>

book:([]
  time:`datetime$();
  intime:`datetime$();
  side:`symbol$();
  price:`int$();
  size:`int$());
book:`side`price`time xkey book;

trade:([]
  time:`datetime$();
  intime:`datetime$();
  side:`symbol$();
  price:`int$();
  size:`int$());
trade:`side`price`time xkey trade;

funding:(
  [intime:`datetime$()];
  fundingRate:`float$();
  fundingTime: `datetime$());

mark:(
  [time:`datetime$()]
  intime:`datetime$();
  price:`int$());

// Derive start and end