

event:(
  time    :  `datetime$()
  kind    :  `.event.EVENTKIND$();
  cmd     :  `.event.EVENTCMD$();
  datum   :  ();  
  );



events: processBitmex each `chan xgroup select from data where source=`bitmexagentxbtusd, inst=`xbtusd;