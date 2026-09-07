class axi_passive_agent extends uvm_agent;
	`uvm_component_utils(axi_passive_agent)
	monitor_out m2;

	function new(string name="axi_passive_agent",uvm_component parent=null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		m2=monitor_out::type_id::create("m2",this);
	endfunction
endclass
