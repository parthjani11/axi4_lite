class monitor extends uvm_monitor;
	`uvm_component_utils(monitor)
	uvm_analysis_port#(axi_seq_item) ap_inp;
	axi_config cfg;

	function new(string name="monitor",uvm_component parent=null);
		super.new(name,parent);
		ap_inp=new("ap_inp",this);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(axi_config)::get(this,"","cfg",cfg))
			`uvm_fatal("monitor","config not found")
	endfunction

	task run_phase(uvm_phase phase);
		axi_seq_item req;
		forever begin
			@(cfg.axi_vif.cb_monitor);
			req=axi_seq_item::type_id::create("req");
			req.ARESETn=cfg.axi_vif.cb_monitor.ARESETn;
			req.AWADDR=cfg.axi_vif.cb_monitor.AWADDR;
			req.AWPROT=cfg.axi_vif.cb_monitor.AWPROT;
			req.AWVALID=cfg.axi_vif.cb_monitor.AWVALID;
			req.WDATA=cfg.axi_vif.cb_monitor.WDATA;
			req.WSTRB=cfg.axi_vif.cb_monitor.WSTRB;
			req.WVALID=cfg.axi_vif.cb_monitor.WVALID;
			req.BREADY=cfg.axi_vif.cb_monitor.BREADY;
			req.ARADDR=cfg.axi_vif.cb_monitor.ARADDR;
			req.ARPROT=cfg.axi_vif.cb_monitor.ARPROT;
			req.ARVALID=cfg.axi_vif.cb_monitor.ARVALID;
			req.RREADY=cfg.axi_vif.cb_monitor.RREADY;
			ap_inp.write(req);
		end
	endtask
endclass
