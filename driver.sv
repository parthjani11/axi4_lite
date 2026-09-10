class driver extends uvm_driver#(axi_seq_item);
	`uvm_component_utils(driver)
	axi_config cfg;

	// persists ACROSS items - tracks a write whose address and/or data
	// phase has been sent but whose response hasn't been collected yet
	bit aw_sent, w_sent;

	function new(string name="driver",uvm_component parent=null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(axi_config)::get(this,"","cfg",cfg))
			`uvm_fatal("driver","config not found")
	endfunction

	virtual task run_phase(uvm_phase phase);
		forever begin
			seq_item_port.get_next_item(req);
			@(cfg.axi_vif.cb_driver);

			fork
				begin
					if(req.AWVALID) begin
						cfg.axi_vif.cb_driver.AWADDR  <= req.AWADDR;
						cfg.axi_vif.cb_driver.AWPROT  <= req.AWPROT;
						cfg.axi_vif.cb_driver.AWVALID <= req.AWVALID;
						do @(cfg.axi_vif.cb_driver); while(!cfg.axi_vif.cb_driver.AWREADY);
						cfg.axi_vif.cb_driver.AWVALID <= 1'b0;
						aw_sent = 1'b1;
					end
				end
				begin
					if(req.WVALID) begin                       // was: if(req.AWVALID) -- see chat
						cfg.axi_vif.cb_driver.WDATA  <= req.WDATA;
						cfg.axi_vif.cb_driver.WSTRB  <= req.WSTRB;
						cfg.axi_vif.cb_driver.WVALID <= req.WVALID;
						do @(cfg.axi_vif.cb_driver); while(!cfg.axi_vif.cb_driver.WREADY);
						cfg.axi_vif.cb_driver.WVALID <= 1'b0;
						w_sent = 1'b1;
					end
				end
				begin
					if(req.ARVALID) begin
						cfg.axi_vif.cb_driver.ARADDR  <= req.ARADDR;
						cfg.axi_vif.cb_driver.ARPROT  <= req.ARPROT;
						cfg.axi_vif.cb_driver.ARVALID <= req.ARVALID;
						do @(cfg.axi_vif.cb_driver); while(!cfg.axi_vif.cb_driver.ARREADY);
						cfg.axi_vif.cb_driver.ARVALID <= 1'b0;
					end
				end
				begin
					if(req.ARVALID) begin
						cfg.axi_vif.cb_driver.RREADY <= req.RREADY;
						do @(cfg.axi_vif.cb_driver); while(!cfg.axi_vif.cb_driver.RVALID);
						cfg.axi_vif.cb_driver.RREADY <= 1'b0;
					end
				end
			join
			// NOTE: the old code had a 5th parallel branch here that drove
			// BREADY and did `do @(cb_driver); while(!BVALID);` gated on
			// req.AWVALID, *inside* this same join. That is the deadlock:
			// it blocks item_done() below on a BVALID that the DUT cannot
			// produce until both AWVALID and WVALID have been accepted
			// (axi4_lite_slave.sv W_BOTH/W_ADDR/W_DATA/W_RESP), and no
			// item that only carries one of AWVALID/WVALID will ever
			// supply the other half by itself.

			seq_item_port.item_done();
			// item_done() no longer waits on the response phase, so the
			// sequencer can issue the next item (which may be exactly the
			// item that completes a split address-then-data or
			// data-then-address write) while the response below is
			// collected in the background.

			if(aw_sent && w_sent) begin
				// this item completed BOTH halves of a write (either both
				// were asserted together, or this item supplied whichever
				// half an earlier item had withheld) - only now will the
				// DUT ever assert BVALID, so only now do we wait for it.
				automatic bit b_ready = req.BREADY;
				aw_sent = 1'b0;
				w_sent  = 1'b0;
				fork
					begin
						cfg.axi_vif.cb_driver.BREADY <= b_ready;
						do @(cfg.axi_vif.cb_driver); while(!cfg.axi_vif.cb_driver.BVALID);
						cfg.axi_vif.cb_driver.BREADY <= 1'b0;
					end
				join_none
			end
		end
	endtask
endclass

class driver_many_transactions extends driver;
	`uvm_component_utils(driver_many_transactions)

	semaphore write_ch_lock;
	semaphore read_ch_lock;

	function new(string name="driver_many_transactions", uvm_component parent=null);
		super.new(name, parent);
		write_ch_lock=new(1);
		read_ch_lock=new(1);
	endfunction

	virtual task run_phase(uvm_phase phase);
		forever begin
			seq_item_port.get_next_item(req);

			fork
				begin
					automatic axi_seq_item local_req = req;

					if(local_req.AWVALID) begin
						write_ch_lock.get();
						fork
							begin
								cfg.axi_vif.cb_driver.AWADDR  <= local_req.AWADDR;
								cfg.axi_vif.cb_driver.AWPROT  <= local_req.AWPROT;
								cfg.axi_vif.cb_driver.AWVALID <= local_req.AWVALID;
								do @(cfg.axi_vif.cb_driver); while(!cfg.axi_vif.cb_driver.AWREADY);
								cfg.axi_vif.cb_driver.AWVALID <= 1'b0;
							end
							begin
								cfg.axi_vif.cb_driver.WDATA  <= local_req.WDATA;
								cfg.axi_vif.cb_driver.WSTRB  <= local_req.WSTRB;
								cfg.axi_vif.cb_driver.WVALID <= local_req.WVALID;
								do @(cfg.axi_vif.cb_driver); while(!cfg.axi_vif.cb_driver.WREADY);
								cfg.axi_vif.cb_driver.WVALID <= 1'b0;
							end
						join
						write_ch_lock.put();

						cfg.axi_vif.cb_driver.BREADY <= local_req.BREADY;
						do @(cfg.axi_vif.cb_driver); while(!cfg.axi_vif.cb_driver.BVALID);
						cfg.axi_vif.cb_driver.BREADY <= 1'b0;
					end

					if(local_req.ARVALID) begin
						read_ch_lock.get();
						cfg.axi_vif.cb_driver.ARADDR  <= local_req.ARADDR;
						cfg.axi_vif.cb_driver.ARPROT  <= local_req.ARPROT;
						cfg.axi_vif.cb_driver.ARVALID <= local_req.ARVALID;
						do @(cfg.axi_vif.cb_driver); while(!cfg.axi_vif.cb_driver.ARREADY);
						cfg.axi_vif.cb_driver.ARVALID <= 1'b0;
						read_ch_lock.put();

						cfg.axi_vif.cb_driver.RREADY <= local_req.RREADY;
						do @(cfg.axi_vif.cb_driver); while(!cfg.axi_vif.cb_driver.RVALID);
						cfg.axi_vif.cb_driver.RREADY <= 1'b0;
					end
				end
			join_none

			seq_item_port.item_done();
		end
	endtask
endclass
