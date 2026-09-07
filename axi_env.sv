class axi_env extends uvm_env;
	`uvm_component_utils(axi_env)
	axi_agent active_agent1;
	axi_passive_agent passive_agent1;
	axi_subscriber sub;
	axi_scoreboard scb;

	function new(string name="env",uvm_component parent=null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		active_agent1=axi_agent::type_id::create("active_agent1",this);
		passive_agent1=axi_passive_agent::type_id::create("passive_agent1",this);
		sub=axi_subscriber::type_id::create("sub",this);
		scb=axi_scoreboard::type_id::create("scb",this);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		active_agent1.m1.ap_inp.connect(scb.imp_in);
		active_agent1.m1.ap_inp.connect(sub.imp_in);
		passive_agent1.m2.ap_out.connect(scb.imp_out);
	endfunction
endclass
