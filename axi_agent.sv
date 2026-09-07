class axi_agent extends uvm_agent;
	`uvm_component_utils(axi_agent)
	monitor m1;
	driver d1;
	seqr sq1;
	axi_config cfg;

	function new(string name="axi_agent",uvm_component parent=null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		m1=monitor::type_id::create("m1",this);
		if(!uvm_config_db#(axi_config)::get(this,"","cfg",cfg))
			`uvm_fatal("axi_agent","did not find config object")
		if(cfg.axi_is_active==UVM_ACTIVE)begin
			d1=driver::type_id::create("d1",this);
			sq1=seqr::type_id::create("sq1",this);
		end
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		d1.seq_item_port.connect(sq1.seq_item_export);
	endfunction
endclass
