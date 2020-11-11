
.qt.Unit[
    ".util.batch.PurgeFails";
    {[c]
			p:c`params;
			.qt.CheckErr[{[c]	 
				p:c`params;
				.util.batch.test.resfn:{:x};

				m:0!.qt.M[`.util.batch.test.resfn;.util.batch.test.resfn;c];
				.util.batch.PurgeFails[.util.batch.test.resfn] . p`args;  

				if[count[p`mocks]>0;[
						em:p[`mocks];
						.qt.MA[m`mockId;em[0];em[1];em[2];c];
				]];
							
				};c;p`err;c]; // `mocks`args`err`eRes 
		.qt.RestoreMocks[];

    };.qt.generalParams; // `mocks`args`err`eRes 
    (
				("no items should error";(
				  ((0b;0;()));
					(
						();
						0;
						"TEST"
					);
					"EMPTY_BATCH";
					()     
        ));
				("single item dict ok";(
					((1b;1;()));
					(
					`eid`time`kind`datum!(1 1 3 0);
						0;
						"TEST"
					);
					();
					()     
        ));
				("single item list dict ok";(
				((1b;1;enlist `eid`kind`datum`time!(16;0;enlist `eid`time`kind`datum!(1;1;3;3);1)));
					(
					  enlist[`eid`time`kind`datum!(1 1 3 3)];
						0;
						"TEST"
					);
					();
					()     
        ));
				("single item table ok";(
					((1b;1;()));
					(
					  flip[enlist `eid`time`kind`datum!(1 1 3 3)];
						0;
						"TEST"
					);
					();
					()     
        ))
    );
    ({};{};{};{});
    "Global function for creating a new account inventorys"];


//TODO test table list
// TODO check actual results and purge format
// TODO testing non event like feed 
.qt.Unit[
    ".util.batch.Purge";
    {[c]
			p:c`params;
			.qt.CheckErr[{[c]	 
				p:c`params;
				.util.batch.test.resfn:{
						:x
					};

				m:0!.qt.M[`.util.batch.test.resfn;.util.batch.test.resfn;c];
				res:.util.batch.Purge[.util.batch.test.resfn] . p`args;  

				if[count[p`mocks]>0;[
						em:p[`mocks];
						.qt.MA[m`mockId;em[0];em[1];em[2];c];
				]];
				.qt.A[res;~;p[`eRes];"res";c];
							
				};c;p`err;c]; // `mocks`args`err`eRes 

				.qt.RestoreMocks[];

    };.qt.generalParams; // `mocks`args`err`eRes 
    (
				("no items should error";(
				  ((0b;0;()));
					(
						();
						();
						0;
						"TEST"
					);
					();
					()     
        ));
				("single item ok, none purged";(
				  ((0b;0;()));
					(
					  `eid`time`kind`datum!(1 1 3 3);
						0b;
						0;
						"TEST"
					);
					();
					()     
        ));
				("single item ok";(
				  ((1b;1;()));
					(
					  `eid`time`kind`datum!(1 1 3 3);
						1b;
						0;
						"TEST"
					);
					"NONE_OK";
					()     
				));
				("single item dict list none purged";(
				  ((0b;0;()));
					(
					  enlist `eid`time`kind`datum!(1 1 3 3);
						0b;
						0;
						"TEST"
					);
					();
					()     
        ));
				("single item dict list";(
				  ((1b;1;()));
					(
					  enlist `eid`time`kind`datum!(1 1 3 3);
						1b;
						0;
						"TEST"
					);
					"NONE_OK";
					()     
				));
				("single item table none purged";(
				  ((0b;0;()));
					(
					  flip enlist `eid`time`kind`datum!(1 1 3 3);
						0b;
						0;
						"TEST"
					);
					();
					()     
        ));
				("single item table";(
				  ((1b;1;()));
					(
					  flip enlist `eid`time`kind`datum!(1 1 3 3);
						1b;
						0;
						"TEST"
					);
					"NONE_OK";
					()     
				));
				("4 item dict list none purged";(
				  ((0b;0;()));
					(
					  (
						`eid`time`kind`datum!(1 1 3 3);
						`eid`time`kind`datum!(1 1 3 3);
						`eid`time`kind`datum!(1 1 3 3);
						`eid`time`kind`datum!(1 1 3 3)
						);
						4#0b;
						0;
						"TEST"
					);
					();
					()     
        ));
				("4 item dict list 2 purged";(
				  ((1b;1;()));
					(
					  (
						`eid`time`kind`datum!(1 1 3 3);
						`eid`time`kind`datum!(1 1 3 3);
						`eid`time`kind`datum!(1 1 3 3);
						`eid`time`kind`datum!(1 1 3 3)
						);
						1010b;
						0;
						"TEST"
					);
					();
					()     
				));
				("4 item dict list all purged";(
				  ((1b;1;()));
					(
					  (
						`eid`time`kind`datum!(1 1 3 3);
						`eid`time`kind`datum!(1 1 3 3);
						`eid`time`kind`datum!(1 1 3 3);
						`eid`time`kind`datum!(1 1 3 3)
						);
						4#1b;
						0;
						"TEST"
					);
					"NONE_OK";
					()     
				));
				// tables
				("4 item table none purged";(
				  ((0b;0;()));
					(
					  flip (
						`eid`time`kind`datum!(1 1 3 3);
						`eid`time`kind`datum!(1 1 3 3);
						`eid`time`kind`datum!(1 1 3 3);
						`eid`time`kind`datum!(1 1 3 3)
						);
						4#0b;
						0;
						"TEST"
					);
					();
					()     
        ));
				("4 item table 2 purged";(
				  ((1b;1;()));
					(
					  flip (
						`eid`time`kind`datum!(1 1 3 3);
						`eid`time`kind`datum!(1 1 3 3);
						`eid`time`kind`datum!(1 1 3 3);
						`eid`time`kind`datum!(1 1 3 3)
						);
						1010b;
						0;
						"TEST"
					);
					();
					()     
				));
				("4 item table all purged";(
					((1b;1;(
						`eid`time`kind`datum!(1 1 3 3);
						`eid`time`kind`datum!(1 1 3 3)
					)));
					(
					  flip (
						`eid`time`kind`datum!(1 1 3 3);
						`eid`time`kind`datum!(1 1 3 3);
						`eid`time`kind`datum!(1 1 3 3);
						`eid`time`kind`datum!(1 1 3 3)
						);
						4#1b;
						0;
						"TEST"
					);
					"NONE_OK";
					(
						`eid`time`kind`datum!(1 1 3 3);
						`eid`time`kind`datum!(1 1 3 3);
					)     
				))
    );
    ({};{};{};{});
    "Global function for creating a new account inventorys"];


.qt.Unit[
    ".util.batch.TPurge";
    {[c]
			p:c`params;
			.qt.CheckErr[{[c]	 
				p:c`params;
				.util.batch.test.resfn:{
						:x
					};

				m:0!.qt.M[`.util.batch.test.resfn;.util.batch.test.resfn;c];
				res:.util.batch.TPurge[.util.batch.test.resfn] . p`args;  

				if[count[p`mocks]>0;[
						em:p[`mocks];
						.test.m:m;
						.test.em:em;
						.qt.MA[m`mockId;em[0];em[1];em[2];c];
				]];
				.qt.A[res;~;p[`eRes];"res";c];
							
				};c;p`err;c]; // `mocks`args`err`eRes 

				.qt.RestoreMocks[];
    };.qt.generalParams;
    (
				("no items should error";(
				  ((0b;0;()));
					(
						();
						();
						0;
						"TEST"
					);
					();
					()     
        ));
				("single item ok, none purged";(
				  ((0b;0;()));
					(
					  `eid`time`kind`datum!(1 1 3 3);
						{x[`datum]:prd[x`datum`kind];x};
						0;
						"TEST"
					);
					();
					enlist[`eid`time`kind`datum!(1 1 3 9)]
        ));
				("single item dict, purged";(
				  ((1b;1;enlist[`kind`kind`datum`time!(16;0;enlist[`eid`time`kind`datum!(1;1;"c";3)];1)])); 
				  /* ((0b;0;())); */
				  (
					 `eid`time`kind`datum!(1; 1; "c"; 3);
						{x[`datum]:prd[x`datum`kind];x};
						0;
						"TEST"
					);
					();
					()
        ));
				("single item table, none purged";(
				  ((0b;0;()));
				  (
					  flip enlist[`eid`time`kind`datum!(1; 1; 3; 3)];
						{x[`datum]:prd[x`datum`kind];x};
						0;
						"TEST"
					);
					();
					enlist[`eid`time`kind`datum!(1 1 3 3)]
				));
				("4 item dict list none purged";(
				  ((0b;0;()));
					(
					  (
						`eid`time`kind`datum!(1; 1; 3; 3);
						`eid`time`kind`datum!(1; 1; 3; 3);
						`eid`time`kind`datum!(1; 1; 3; 3);
						`eid`time`kind`datum!(1; 1; 3; 3)
						);
						{x[`datum]:prd[x`datum`kind];x};
						0;
						"TEST"
					);
					();
					(
					`eid`time`kind`datum!(1; 1; 3; 9);
					`eid`time`kind`datum!(1; 1; 3; 9);
					`eid`time`kind`datum!(1; 1; 3; 9);
					`eid`time`kind`datum!(1; 1; 3; 9)
					)
        ));
				("4 item dict list 2 purged";(
				((1b;1;
						enlist enlist flip `eid`time`kind`datum`cmd!(2#1; 2#1; 2#16;2#enlist("c";3); 2#0)
						));
					(
					  (
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; 3; 3);
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; 3; 3)
						);
						{x[`datum]:prd[x`datum`kind];x};
						0;
						"TEST"
					);
					();
					flip	`eid`time`kind`datum!(1 1; 1 1; 3 3; 9 9)
				));
				("4 item dict list all purged";(
				((1b;1;
						enlist enlist flip `eid`time`kind`datum`cmd!(4#1; 4#1; 4#16; 4#enlist("c";3); 4#0)
						));
					(
					  (
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; "c"; 3)
						);
						{x[`datum]:prd[x`datum`kind];x};
						0;
						"TEST"
					);
					();
					()     
				));
				// tables
				("4 item table none purged";(
				  ((0b;0;()));
					(
					  flip (
						`eid`time`kind`datum!(1; 1; 3; 3);
						`eid`time`kind`datum!(1; 1; 3; 3);
						`eid`time`kind`datum!(1; 1; 3; 3);
						`eid`time`kind`datum!(1; 1; 3; 3)
						);
						{x[`datum]:prd[x`datum`kind];x};
						0;
						"TEST"
					);
					();
					(
					  `eid`time`kind`datum!(1; 1; 3; 9);
						`eid`time`kind`datum!(1; 1; 3; 9);
						`eid`time`kind`datum!(1; 1; 3; 9);
						`eid`time`kind`datum!(1; 1; 3; 9)
					)     
        ));
				("4 item table 2 purged";(
					((1b;1;
						enlist enlist flip `eid`time`kind`datum`cmd!(2#1; 2#1; 2#16;2#enlist("c";3); 2#0)
					));
					(
					  flip (
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; 3; 3);
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; 3; 3)
						);
						{x[`datum]:prd[x`datum`kind];x};
						0;
						"TEST"
					);
					();
					flip	`eid`time`kind`datum!(1 1; 1 1; 3 3; 9 9)
				));
				("4 item table all purged";(
					((1b;1;
					enlist enlist flip `eid`time`kind`datum`cmd!(4#1; 4#1; 4#16; 4#enlist("c";3); 4#0)
					));
					(
					  flip (
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; "c"; 3)
						);
						{x[`datum]:prd[x`datum`kind];x};
						0;
						"TEST"
					);
					();
					()
				))
    );
    ({};{};{};{});
    "Global function for creating a new account inventorys"];


/* // TODO */ 
/* .qt.Unit[ */
/*     ".util.batch.Parse"; */
/*     {[c] */
/* 				p:c`params; */
/* 				resfn:  .qt.MS[{[a;b;c]};c]; */
/* 				args:resfn,p[`args]; */
/* 				res: .qt.CheckErr[.util.batch.Parse;args;p`err;c]; */
/*     		.qt.A[res;~;p[`eRes];"res";c]; */
/* 				.qt.MA[]; */
/* 				.qt.RestoreMocks[]; */

/*     };.qt.generalParams; */
/*     ( */
/* 				("no items should error";( */
/* 				  ((0b;0;())); */
/* 					( */
/* 						(); */
/* 						(); */
/* 						0; */
/* 						"TEST" */
/* 					); */
/* 					(); */
/* 					() */     
/*         )); */
/* 				("single item ok, none purged";( */
/* 				  ((0b;0;())); */
/* 					( */
/* 					 `eid`time`kind`datum!(1;1;3;(`a`b`c`d!(1;1;1;1))); */
/* 						([]a:`long$();b:`long$();c:`long$();d:`long$()); */
/* 						0; */
/* 						"TEST" */
/* 					); */
/* 					(); */
/* 					enlist[`eid`time`kind`datum!(1 1 3 9)] */
/* 				)) */
/*     ); */
/*     ({};{};{};{}); */
/*     "global function for creating a new account inventorys"]; */


.qt.Unit[
    ".util.batch.Branch";
    {[c]
			p:c`params;
			.qt.CheckErr[{[c]	 
				p:c`params;
				.util.batch.test.resfn:{:x};

				m:0!.qt.M[`.util.batch.test.resfn;.util.batch.test.resfn;c];
				res:.util.batch.Branch[.util.batch.test.resfn] . p`args;  

				if[count[p`mocks]>0;[
						em:p[`mocks];
						.test.m:m;
						.qt.MA[m`mockId;em[0];em[1];em[2];c];
				]];
				.qt.A[res;~;p[`eRes];"res";c];
							
				};c;p`err;c]; // `mocks`args`err`eRes 
				.qt.RestoreMocks[];
		};
	  .qt.generalParams;
    (
				("no items should error";(
				  ((0b;0;()));
					(
						();
						();
						1b;
						0;
						"TEST"
					);
					();
					()     
        ));
				("single item ok, none purged";(
				  ((0b;0;()));
					(
					  `eid`time`kind`datum!(1 1 3 3);
						{x[`datum]:prd[x`datum`kind];x};
						1b;
						0;
						"TEST"
					);
					();
					(
					 (
					 enlist `eid`time`kind`datum!(1; 1; 3; 9)
						);
						()
					)     
        ));
				("single item dict, purged";(
				((1b;1;
						enlist enlist flip `eid`time`kind`datum`cmd!(1; 1; 16; enlist("c";3); 0)
				  )); 
				  /* ((0b;0;())); */
				  (
					 `eid`time`kind`datum!(1; 1; "c"; 3);
						{x[`datum]:prd[x`datum`kind];x};
						1b;
						0;
						"TEST"
					);
					();
					(();())
        ));
				("single item table, none purged";(
				  ((0b;0;()));
				  (
					  flip enlist[`eid`time`kind`datum!(1; 1; 3; 3)];
						{x[`datum]:prd[x`datum`kind];x};
						1b;
						0;
						"TEST"
					);
					();
					(
					 (
					 enlist flip enlist `eid`time`kind`datum!(1; 1; 3; 9)
						);
						()
					)     
				));
				("4 item dict list none purged";(
				  ((0b;0;()));
					(
					  (
						`eid`time`kind`datum!(1; 1; 3; 3);
						`eid`time`kind`datum!(1; 1; 3; 3);
						`eid`time`kind`datum!(1; 1; 3; 3);
						`eid`time`kind`datum!(1; 1; 3; 3)
						);
						{x[`datum]:prd[x`datum`kind];x};
						enlist[4#1b];
						0;
						"TEST"
					);
					();
					(
					 (
						`eid`time`kind`datum!(1; 1; 3; 9);
						`eid`time`kind`datum!(1; 1; 3; 9);
						`eid`time`kind`datum!(1; 1; 3; 9);
						`eid`time`kind`datum!(1; 1; 3; 9)
						);
						()
					)     
        ));
				("4 item dict list 2 purged";(
				((1b;1;
						enlist enlist flip `eid`time`kind`datum`cmd!(2#1; 2#1; 2#16;2#enlist("c";3); 2#0)
						));
					(
					  (
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; 3; 3);
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; 3; 3)
						);
						{x[`datum]:prd[x`datum`kind];x};
						4#1b;
						0;
						"TEST"
					);
					();
					(
					 (
						`eid`time`kind`datum!(1; 1; 3; 9);
						`eid`time`kind`datum!(1; 1; 3; 9)
						);
						()
					)     
				));
				("4 item dict list all purged";(
				((1b;1;
					enlist enlist flip `eid`time`kind`datum`cmd!(4#1; 4#1; 4#16;4#enlist("c";3); 4#0)
						));
					(
					  (
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; "c"; 3)
						);
						{x[`datum]:prd[x`datum`kind];x};
						4#1b;
						0;
						"TEST"
					);
					();
					(();())     
				));
				// tables
				("4 item table none purged";(
				  ((0b;0;()));
					(
					  flip (
						`eid`time`kind`datum!(1; 1; 3; 3);
						`eid`time`kind`datum!(1; 1; 3; 3);
						`eid`time`kind`datum!(1; 1; 3; 3);
						`eid`time`kind`datum!(1; 1; 3; 3)
						);
						{x[`datum]:prd[x`datum`kind];x};
						4#1b;
						0;
						"TEST"
					);
					();
					(
					 (
						`eid`time`kind`datum!(1; 1; 3; 9);
						`eid`time`kind`datum!(1; 1; 3; 9);
						`eid`time`kind`datum!(1; 1; 3; 9);
						`eid`time`kind`datum!(1; 1; 3; 9)
						);
						()
					)     
        ));
				("4 item table 2 purged";(
					((1b;1;
						enlist enlist flip `eid`time`kind`datum`cmd!(2#1; 2#1; 2#16;2#enlist("c";3); 2#0)
					));
					(
					  flip (
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; 3; 3);
						`eid`time`kind`datum!(1; 1; 3; 3)
						);
						{x[`datum]:prd[x`datum`kind];x};
						4#1b;
						0;
						"TEST"
					);
					();
					(
					(
					`eid`time`kind`datum!(1; 1; 3; 9);
					`eid`time`kind`datum!(1; 1; 3; 9));
					()
					)     
				));
				("4 item table all purged";(
					((1b;1;
					enlist enlist flip `eid`time`kind`datum`cmd!(2#1; 2#1; 2#16;2#enlist("c";3); 2#0)
					));
					(
					  flip (
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; 3; 3);
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; 3; 3)
						);
						{x[`datum]:prd[x`datum`kind];x};
						4#1b;
						0;
						"TEST"
					);
					();
					(
					(
					`eid`time`kind`datum!(1; 1; 3; 9);
					`eid`time`kind`datum!(1; 1; 3; 9));
					()
					)     
				))
    );
    ({};{};{};{});
    "global function for creating a new account inventorys"];



.qt.Unit[
	".util.batch.RowDropout";
    {[c]
			p:c`params;
			.qt.CheckErr[{[c]	 
				p:c`params;
				.util.batch.test.resfn:{:x};

				m:0!.qt.M[`.util.batch.test.resfn;.util.batch.test.resfn;c];
				res:.util.batch.RowDropout[.util.batch.test.resfn] . p`args;  

				if[count[p`mocks]>0;[
						em:p[`mocks];
						.test.m:m;
						.qt.MA[m`mockId;em[0];em[1];em[2];c];
				]];
				.qt.A[res;~;p[`eRes];"res";c];
							
				};c;p`err;c]; // `mocks`args`err`eRes 
				.qt.RestoreMocks[];
    };.qt.generalParams;
    (
				("no items should error";(
				  ((0b;0;()));
					(
						();
						();
						0;
						"TEST"
					);
					();
					()     
        ));
		    ("single item dict ok";(
					((1b;1;(
						`eid`time`kind`datum!(1; 1; 2; 3);
						`eid`time`kind`datum!(1; 1; 3; 3)
					)));
					(
					  flip (
						`eid`time`kind`datum!(1; 1; 2; 3);
						`eid`time`kind`datum!(1; 1; 3; 3);
						`eid`time`kind`datum!(1; 1; 3; 3);
						`eid`time`kind`datum!(1; 1; 3; 3)
						);
						0.5;
						0;
						"TEST"
					);
					();
					()
				));
		    ("single item dict ok";(
					((1b;1;(
						`eid`time`kind`datum!(1; 1; 2; 3);
						`eid`time`kind`datum!(1; 1; 3; 3);
						`eid`time`kind`datum!(1; 1; 3; 3);
						`eid`time`kind`datum!(1; 1; 3; 3)
					)));
					(
					  flip (
						`eid`time`kind`datum!(1; 1; 2; 3);
						`eid`time`kind`datum!(1; 1; 3; 3);
						`eid`time`kind`datum!(1; 1; 3; 3);
						`eid`time`kind`datum!(1; 1; 3; 3)
						);
						1;
						0;
						"TEST"
					);
					();
					()
				))					  
    );
    ({};{};{};{});
    "global function for creating a new account inventorys"];


.qt.Unit[
	".util.batch.RowDropoutK";
    {[c]
			p:c`params;
			.qt.CheckErr[{[c]	 
				p:c`params;
				.util.batch.test.resfn:{:x};

				m:0!.qt.M[`.util.batch.test.resfn;.util.batch.test.resfn;c];
				res:.util.batch.RowDropout[.util.batch.test.resfn] . p`args;  

				if[count[p`mocks]>0;[
						em:p[`mocks];
						.test.m:m;
						.qt.MA[m`mockId;em[0];em[1];em[2];c];
				]];
				.qt.A[res;~;p[`eRes];"res";c];
							
				};c;p`err;c]; // `mocks`args`err`eRes 
				.qt.RestoreMocks[];
    };.qt.generalParams;
    (
				("no items should error";(
				  ((0b;0;()));
					(
						();
						();
						0;
						"TEST"
					);
					();
					()     
        ));
		    ("single item dict ok";(
					((1b;1;(
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; "c"; 3)
					)));
					(
					  flip (
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; 3; 3);
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; 3; 3)
						);
						0.5;
						0;
						"TEST"
					);
					();
					()
				));
		    ("single item dict ok";(
					((1b;1;(
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; "c"; 3)
					)));
					(
					  flip (
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; 3; 3);
						`eid`time`kind`datum!(1; 1; "c"; 3);
						`eid`time`kind`datum!(1; 1; 3; 3)
						);
						0.5;
						0;
						"TEST"
					);
					();
					()
				))					  
    );
    ({};{};{};{});
    "global function for creating a new account inventorys"];


.qt.Unit[
    ".util.batch.TimeOffset";
    {[c]
			p:c`params;
			.qt.CheckErr[{[c]	 
				p:c`params;
				.util.batch.test.resfn:{:x};

				m:0!.qt.M[`.util.batch.test.resfn;.util.batch.test.resfn;c];
				res:.util.batch.TimeOffset[.util.batch.test.resfn] . p`args;  

				if[count[p`mocks]>0;[
						em:p[`mocks];
						.test.m:m;
						.qt.MA[m`mockId;em[0];em[1];em[2];c];
				]];
				.qt.A[res;~;p[`eRes];"res";c];
							
				};c;p`err;c]; // `mocks`args`err`eRes 
				.qt.RestoreMocks[];
		};
	  .qt.generalParams;
    (
		    ("single item dict ok";(
								();();();()     
        ));
				("single item table ok";(
								();();();()     
        ));
		    ("single item dict not ok";(
								();();();()     
        ));
				("single item table not ok";(
								();();();()     
        ));
				("four items dict list ok";(
								();();();()     
        ));
				("four items table list ok";(
								();();();()     
        ));
				("four items dict list all not ok";(
								();();();()     
        ));
				("four items table list all not ok";(
								();();();()     
        ));
				("four items dict list 2 not ok 2 ok";(
								();();();()     
        ));
				("four items table list 2 not ok 2 ok";(
								();();();()     
        ))
    );
    ({};{};{};{});
    "global function for creating a new account inventorys"];


.qt.Unit[
    ".util.batch.TimeOffsetK";
    {[c]
			p:c`params;
			.qt.CheckErr[{[c]	 
				p:c`params;
				.util.batch.test.resfn:{:x};

				m:0!.qt.M[`.util.batch.test.resfn;.util.batch.test.resfn;c];
				res:.util.batch.TineOffsetK[.util.batch.test.resfn] . p`args;  

				if[count[p`mocks]>0;[
						em:p[`mocks];
						.test.m:m;
						.qt.MA[m`mockId;em[0];em[1];em[2];c];
				]];
				.qt.A[res;~;p[`eRes];"res";c];
							
				};c;p`err;c]; // `mocks`args`err`eRes 
				.qt.RestoreMocks[];
		};
	  .qt.generalParams;
    (
		    ("single item dict ok";(
								();();();()     
        ));
				("single item table ok";(
								();();();()     
        ));
		    ("single item dict not ok";(
								();();();()     
        ));
				("single item table not ok";(
								();();();()     
        ));
				("four items dict list ok";(
								();();();()     
        ));
				("four items table list ok";(
								();();();()     
        ));
				("four items dict list all not ok";(
								();();();()     
        ));
				("four items table list all not ok";(
								();();();()     
        ));
				("four items dict list 2 not ok 2 ok";(
								();();();()     
        ));
				("four items table list 2 not ok 2 ok";(
								();();();()     
        ))
    );
    ({};{};{};{});
    "global function for creating a new account inventorys"];



.qt.Unit[
    ".util.batch.GausTimeOffset";
    {[c]
			p:c`params;
			.qt.CheckErr[{[c]	 
				p:c`params;
				.util.batch.test.resfn:{:x};

				m:0!.qt.M[`.util.batch.test.resfn;.util.batch.test.resfn;c];
				res:.util.batch.TimeOffset[.util.batch.test.resfn] . p`args;  

				if[count[p`mocks]>0;[
						em:p[`mocks];
						.test.m:m;
						.qt.MA[m`mockId;em[0];em[1];em[2];c];
				]];
				.qt.A[res;~;p[`eRes];"res";c];
							
				};c;p`err;c]; // `mocks`args`err`eRes 
				.qt.RestoreMocks[];

		};
	  .qt.generalParams;
    (
		    ("single item dict ok";(
								();();();()     
        ));
				("single item table ok";(
								();();();()     
        ));
		    ("single item dict not ok";(
								();();();()     
        ));
				("single item table not ok";(
								();();();()     
        ));
				("four items dict list ok";(
								();();();()     
        ));
				("four items table list ok";(
								();();();()     
        ));
				("four items dict list all not ok";(
								();();();()     
        ));
				("four items table list all not ok";(
								();();();()     
        ));
				("four items dict list 2 not ok 2 ok";(
								();();();()     
        ));
				("four items table list 2 not ok 2 ok";(
								();();();()     
        ))
    );
    ({};{};{};{});
    "global function for creating a new account inventorys"];


.qt.Unit[
    ".util.batch.GausTimeOffsetK";
    {[c]
			p:c`params;
			.qt.CheckErr[{[c]	 
				p:c`params;
				.util.batch.test.resfn:{:x};

				m:0!.qt.M[`.util.batch.test.resfn;.util.batch.test.resfn;c];
				res:.util.batch.TineOffsetK[.util.batch.test.resfn] . p`args;  

				if[count[p`mocks]>0;[
						em:p[`mocks];
						.test.m:m;
						.qt.MA[m`mockId;em[0];em[1];em[2];c];
				]];
				.qt.A[res;~;p[`eRes];"res";c];
							
				};c;p`err;c]; // `mocks`args`err`eRes 
				.qt.RestoreMocks[];
		};
	  .qt.generalParams;
    (
		    ("single item dict ok";(
								();();();()     
        ));
				("single item table ok";(
								();();();()     
        ));
		    ("single item dict not ok";(
								();();();()     
        ));
				("single item table not ok";(
								();();();()     
        ));
				("four items dict list ok";(
								();();();()     
        ));
				("four items table list ok";(
								();();();()     
        ));
				("four items dict list all not ok";(
								();();();()     
        ));
				("four items table list all not ok";(
								();();();()     
        ));
				("four items dict list 2 not ok 2 ok";(
								();();();()     
        ));
				("four items table list 2 not ok 2 ok";(
								();();();()     
        ))
    );
    ({};{};{};{});
    "global function for creating a new account inventorys"];



