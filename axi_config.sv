class axi_config extends uvm_object;
	`uvm_object_utils(axi_config)

	uvm_active_passive_enum axi_is_active=UVM_ACTIVE;
	virtual axi_if axi_vif;

	function new(string name="axi_config");
		super.new(name);
	endfunction
endclass
