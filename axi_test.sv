class axi_test extends uvm_test;
	`uvm_component_utils(axi_test)
	axi_env env;
	axi_config cfg;

	function new(string name="axi_test",uvm_component parent=null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		cfg=axi_config::type_id::create("cfg");
		if(!uvm_config_db#(virtual axi_if)::get(this,"","axi_vif",cfg.axi_vif))
			`uvm_fatal("test","interface not available")
		cfg.axi_is_active=UVM_ACTIVE;
		uvm_config_db#(axi_config)::set(this,"*","cfg",cfg);
		env=axi_env::type_id::create("env",this);
	endfunction

	task run_phase(uvm_phase phase);
		axi_seq s1;
		phase.raise_objection(this);
		s1=axi_seq::type_id::create("s1");
		s1.start(env.active_agent1.sq1);
		#100;
		phase.drop_objection(this);
	endtask
endclass

class axi_reset_test extends axi_test;
	`uvm_component_utils(axi_reset_test)

	function new(string name="axi_reset_test",uvm_component parent=null);
		super.new(name,parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		axi_seq_item::type_id::set_type_override(axi_reset::get_type(),1);
		super.build_phase(phase);
	endfunction
endclass

class axi_write_with_wboth_test extends axi_test;
	`uvm_component_utils(axi_write_with_wboth_test)

	function new(string name="axi_write_with_wboth_test",uvm_component parent=null);
		super.new(name,parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		axi_seq_item::type_id::set_type_override(axi_write_with_wboth::get_type(),1);
		super.build_phase(phase);
	endfunction
endclass

class axi_write_with_waddr_test extends axi_test;
	`uvm_component_utils(axi_write_with_waddr_test)

	function new(string name="axi_write_with_waddr_test",uvm_component parent=null);
		super.new(name,parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		axi_seq_item::type_id::set_type_override(axi_write_with_waddr::get_type(),1);
		super.build_phase(phase);
	endfunction
endclass

class axi_write_with_wdata_test extends axi_test;
	`uvm_component_utils(axi_write_with_wdata_test)

	function new(string name="axi_write_with_wdata_test",uvm_component parent=null);
		super.new(name,parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		axi_seq_item::type_id::set_type_override(axi_write_with_wdata::get_type(),1);
		super.build_phase(phase);
	endfunction
endclass

class axi_random_write_test extends axi_test;
	`uvm_component_utils(axi_random_write_test)

	function new(string name="axi_random_write_test",uvm_component parent=null);
		super.new(name,parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		axi_seq_item::type_id::set_type_override(axi_random_write::get_type(),1);
		super.build_phase(phase);
	endfunction
endclass

class axi_read_without_wait_test extends axi_test;
	`uvm_component_utils(axi_read_without_wait_test)

	function new(string name="axi_read_without_wait_test",uvm_component parent=null);
		super.new(name,parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		axi_seq_item::type_id::set_type_override(axi_read_without_wait::get_type(),1);
		super.build_phase(phase);
	endfunction
endclass

class axi_read_with_wait_test extends axi_test;
	`uvm_component_utils(axi_read_with_wait_test)

	function new(string name="axi_read_with_wait_test",uvm_component parent=null);
		super.new(name,parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		axi_seq_item::type_id::set_type_override(axi_read_with_wait::get_type(),1);
		super.build_phase(phase);
	endfunction
endclass

class axi_simultaneous_read_and_write_test extends axi_test;
	`uvm_component_utils(axi_simultaneous_read_and_write_test)

	function new(string name="axi_simultaneous_read_and_write_test",uvm_component parent=null);
		super.new(name,parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		axi_seq_item::type_id::set_type_override(axi_simultaneous_read_and_write::get_type(),1);
		super.build_phase(phase);
	endfunction
endclass

class axi_read_on_next_cycle_of_write_test extends axi_test;
	`uvm_component_utils(axi_read_on_next_cycle_of_write_test)

	function new(string name="axi_read_on_next_cycle_of_write_test",uvm_component parent=null);
		super.new(name,parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		axi_seq_item::type_id::set_type_override(axi_read_on_next_cycle_of_write::get_type(),1);
		super.build_phase(phase);
	endfunction
endclass

class axi_regression_test extends axi_test;
	`uvm_component_utils(axi_regression_test)

	function new(string name="axi_regression_test",uvm_component parent=null);
		super.new(name,parent);
	endfunction

	virtual task run_phase(uvm_phase phase);
		axi_seq s1;
		uvm_object_wrapper target_types[];
		target_types=new[9];

		target_types[0]=axi_reset::get_type();
		target_types[1]=axi_write_with_wboth::get_type();
		target_types[2]=axi_write_with_waddr::get_type();
		target_types[3]=axi_write_with_wdata::get_type();
		target_types[4]=axi_random_write::get_type();
		target_types[5]=axi_read_without_wait::get_type();
		target_types[6]=axi_read_with_wait::get_type();
		target_types[7]=axi_simultaneous_read_and_write::get_type();
		target_types[8]=axi_read_on_next_cycle_of_write::get_type();

		phase.raise_objection(this);
		foreach(target_types[i])begin
			`uvm_info("regression",$sformatf("starting scenario %0d: using overridden type: %s",i,target_types[i].get_type_name()),UVM_LOW)
			axi_seq_item::type_id::set_type_override(target_types[i],1);
			s1=axi_seq::type_id::create("s1");
			s1.start(env.active_agent1.sq1);
			#100;
		end
		phase.drop_objection(this);
	endtask
endclass
