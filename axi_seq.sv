class axi_seq extends uvm_sequence#(axi_seq_item);
	`uvm_object_utils(axi_seq)

	function new(string name="axi_seq");
		super.new(name);
	endfunction

	task body();
		axi_seq_item req;
		repeat(`num_transactions)begin
			req=axi_seq_item::type_id::create("req");
			start_item(req);
			if(!req.randomize())
				`uvm_fatal("sequence","randomization failed")
			finish_item(req);
		end
	endtask
endclass
