class axi_seq_item extends uvm_sequence_item;
	`uvm_object_utils(axi_seq_item)

	rand bit ARESETn;
	rand logic [`ADDR_WIDTH-1:0]AWADDR;
	rand logic [2:0]AWPROT;
	rand logic AWVALID;
	logic AWREADY;

	rand logic [`DATA_WIDTH-1:0]WDATA;
	rand logic [(`DATA_WIDTH/8)-1:0]WSTRB;
	rand logic WVALID;
	logic WREADY;

	logic [1:0]BRESP;
	logic BVALID;
	rand logic BREADY;

	rand logic [`ADDR_WIDTH-1:0]ARADDR;
	rand logic [2:0]ARPROT;
	rand logic ARVALID;
	logic ARREADY;

	logic [`DATA_WIDTH-1:0]RDATA;
	logic [1:0]RRESP;
	logic RVALID;
	rand logic RREADY;

	randc bit [1:0]wait_cycle_valid;

	function new(string name="axi_seq_item");
		super.new(name);
	endfunction

	constraint cawprot{
		AWPROT==3'b000;
	}
	constraint carprot{
		ARPROT==3'b000;
	}
endclass

class axi_reset extends axi_seq_item;
	`uvm_object_utils(axi_reset)

	function new(string name="axi_reset");
		super.new(name);
	endfunction

	constraint reset{
		ARESETn==0;
	}
endclass

class axi_write_with_wboth extends axi_seq_item;
	`uvm_object_utils(axi_write_with_wboth)

	function new(string name="axi_write_with_wboth");
		super.new(name);
	endfunction

	constraint reset{
		ARESETn==1;
	}
	constraint both_valid{
		AWVALID==1;
		WVALID==1;
	}
	constraint read_valids{
		ARVALID==0;
		ARADDR==0;
	}
endclass

class axi_write_with_waddr extends axi_seq_item;
	`uvm_object_utils(axi_write_with_waddr)

	function new(string name="axi_write_with_waddr");
		super.new(name);
	endfunction

	constraint reset{
		ARESETn==1;
	}
	constraint waddr_valid{
		AWVALID==1;
	}
	constraint wvalid{
		if(wait_cycle_valid==0)
			WVALID==1;
		else
			WVALID==0;
	}
	constraint read_valids{
		ARVALID==0;
		ARADDR==0;
	}
endclass

class axi_write_with_wdata extends axi_seq_item;
	`uvm_object_utils(axi_write_with_wdata)

	function new(string name="axi_write_with_wdata");
		super.new(name);
	endfunction

	constraint reset{
		ARESETn==1;
	}
	constraint wvalid{
		WVALID==1;
	}
	constraint waddr_valid{
		if(wait_cycle_valid==0)
			AWVALID==1;
		else
			AWVALID==0;
	}
	constraint read_valids{
		ARVALID==0;
		ARADDR==0;
	}
endclass

class axi_random_write extends axi_seq_item;
	`uvm_object_utils(axi_random_write)

	function new(string name="axi_random_write");
		super.new(name);
	endfunction

	constraint reset{
		ARESETn==1;
	}
	constraint read_valids{
		ARVALID==0;
		ARADDR==0;
	}
endclass

class axi_read_without_wait extends axi_seq_item;
	`uvm_object_utils(axi_read_without_wait)

	function new(string name="axi_read_without_wait");
		super.new(name);
	endfunction

	constraint reset{
		ARESETn==1;
	}
	constraint rvalid{
		ARVALID==1;
	}
	constraint write_valids{
		AWVALID==0;
		WVALID==0;
		AWADDR==0;
		WDATA==0;
	}
endclass

class axi_read_with_wait extends axi_seq_item;
	`uvm_object_utils(axi_read_with_wait)

	function new(string name="axi_read_with_wait");
		super.new(name);
	endfunction

	constraint reset{
		ARESETn==1;
	}
	constraint rvalid{
		if(wait_cycle_valid==0)
			ARVALID==1;
		else
			ARVALID==0;
	}
	constraint write_valids{
		AWVALID==0;
		WVALID==0;
		AWADDR==0;
		WDATA==0;
	}
endclass

class axi_simultaneous_read_and_write extends axi_seq_item;
	`uvm_object_utils(axi_simultaneous_read_and_write)

	function new(string name="axi_simultaneous_read_and_write");
		super.new(name);
	endfunction

	constraint reset{
		ARESETn==1;
	}
	constraint both_valid{
		AWVALID==1;
		ARVALID==1;
		WVALID==1;
		AWADDR==ARADDR;
	}
endclass

class axi_read_on_next_cycle_of_write extends axi_seq_item;
	`uvm_object_utils(axi_read_on_next_cycle_of_write)

	static logic [`ADDR_WIDTH-1:0]prev_addr;
	static logic prev_awvalid;
	static logic prev_wvalid;

	function new(string name="axi_read_on_next_cycle_of_write");
		super.new(name);
	endfunction

	constraint reset{
		ARESETn==1;
	}
	constraint both_valid{
		AWVALID==1;
		WVALID==1;
	}
	constraint read_valid{
		((prev_wvalid && prev_awvalid) -> ((ARVALID==1)&&(ARADDR==prev_addr)));
	}

	function void post_randomize();
		prev_wvalid=WVALID;
		prev_awvalid=AWVALID;
		if(WVALID)
			prev_addr=AWADDR;
	endfunction
endclass
