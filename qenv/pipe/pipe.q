

// Source Event Tables
// =====================================================================================>

book:([
  side:`symbol$();
  price:`int$();
  time:`datetime$()]
  intime:`datetime$();
  size:`int$());

trade:([
  side:`symbol$();
  time:`datetime$()]
  intime:`datetime$();
  price:`int$();
  size:`int$());

funding:(
  [intime:`datetime$()];
  fundingRate:`float$();
  fundingTime: `datetime$());

mark:(
  [time:`datetime$()]
  intime:`datetime$();
  price:`int$());

liquidation:(
  [time:`datetime$()]
  intime:`datetime$();
  price:`int$());


// Derive start and end