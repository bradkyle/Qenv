/
Global is used to store enumeration types and state that can be
unilaterraly accessed throughout the program. For instance the 
current step, step time and default instrument (and associated config)
that serves as a single source of configuration.
\

/ StateFul Singletons
/ -------------------------------------------------------------------->

CurrentStep: `long$();
StepTime: `datetime$();