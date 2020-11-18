

.order.Fill :{

				};


.account.Withdraw:{
				a:?[`account;enlist]
				a[`widdraw]+:withdrawn;
				a[`imr]:0;
				a[`mmr]:0;

				// pos order margin
				a[`avail]:()
				.account.account,:a;
				// TODO add events
				};

.account.Deposit:{
				a:?[`account;enlist]
				a[`deposited]+:deposited;
				a[`imr]:0;
				a[`mmr]:0;

				// pos order margin
				a[`avail]:()
				.account.account,:a;
				//TODO add events	

				};

.account.Leverage:{
				a:?[`account;enlist]
				a[`leverage]:leverage;
				a[`imr]:0;
				a[`mmr]:0;

				// pos order margin
				a[`avail]:()
				.account.account,:a;
				// TODO add events
				};
