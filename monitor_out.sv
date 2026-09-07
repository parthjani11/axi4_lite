class monitor_out extends uvm_monitor;
	`uvm_component_utils(monitor_out)
	uvm_analysis_port#(axi_seq_item) ap_out;
	axi_config cfg;

	function new(string name="monitor_out",uvm_component parent=null);
		super.new(name,parent);
		ap_out=new("ap_out",this);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(axi_config)::get(this,"","cfg",cfg))
			`uvm_fatal("monitor_out","config not found")
	endfunction

	task run_phase(uvm_phase phase);
		axi_seq_item req;
		forever begin
			@(cfg.axi_vif.cb_monitor);
			req=axi_seq_item::type_id::create("req");
			req.AWREADY=cfg.axi_vif.cb_monitor.AWREADY;
			req.WREADY=cfg.axi_vif.cb_monitor.WREADY;
			req.BRESP=cfg.axi_vif.cb_monitor.BRESP;
			req.BVALID=cfg.axi_vif.cb_monitor.BVALID;
			req.ARREADY=cfg.axi_vif.cb_monitor.ARREADY;
			req.RDATA=cfg.axi_vif.cb_monitor.RDATA;
			req.RRESP=cfg.axi_vif.cb_monitor.RRESP;
			req.RVALID=cfg.axi_vif.cb_monitor.RVALID;
			ap_out.write(req);
		end
	endtask
endclass
