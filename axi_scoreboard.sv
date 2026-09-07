class axi_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(axi_scoreboard)

	`uvm_analysis_imp_decl(_in)
	`uvm_analysis_imp_decl(_out)

	uvm_analysis_imp_in#(axi_seq_item,axi_scoreboard)  imp_in;
	uvm_analysis_imp_out#(axi_seq_item,axi_scoreboard) imp_out;

	int pass_count, fail_count;
	axi_seq_item last_in;

	bit [`ADDR_WIDTH-1:0] pend_waddr;
	bit                   waddr_pending;
	bit [`ADDR_WIDTH-1:0] pend_raddr;
	bit                   raddr_pending;

	function new(string name="axi_scoreboard",uvm_component parent=null);
		super.new(name,parent);
		imp_in  = new("imp_in",this);
		imp_out = new("imp_out",this);
	endfunction

	function bit [1:0] expected_resp(bit [`ADDR_WIDTH-1:0] addr, bit is_write);
		bit [3:0] word_idx;
		if (addr[1:0] != 2'b00)
			return 2'b10;
		if (addr >= (`MEM_DEPTH*4))
			return 2'b11;
		word_idx = addr[5:2];
		if (word_idx <= 9)
			return 2'b00;
		else if (word_idx <= 12)
			return is_write ? 2'b10 : 2'b00;
		else if (word_idx <= 14)
			return is_write ? 2'b00 : 2'b10;
		else
			return 2'b00;
	endfunction

	function void check_resp(bit [`ADDR_WIDTH-1:0] addr, bit is_write, bit [1:0] actual);
		bit [1:0] exp = expected_resp(addr, is_write);
		if (actual === exp) begin
			pass_count++;
			`uvm_info("SCB", $sformatf("%s addr=0x%0h resp=%0d -- PASS",
				is_write ? "WR" : "RD", addr, actual), UVM_HIGH)
		end else begin
			fail_count++;
			`uvm_error("SCB", $sformatf("%s addr=0x%0h expected resp=%0d got=%0d",
				is_write ? "WR" : "RD", addr, exp, actual))
		end
	endfunction

	virtual function void write_in(axi_seq_item t);
		last_in = t;
	endfunction

	virtual function void write_out(axi_seq_item t);
		if (last_in == null)
			return;

		if (t.AWREADY && last_in.AWVALID) begin
			pend_waddr    = last_in.AWADDR;
			waddr_pending = 1;
		end
		if (t.ARREADY && last_in.ARVALID) begin
			pend_raddr    = last_in.ARADDR;
			raddr_pending = 1;
		end
		if (t.BVALID && waddr_pending) begin
			check_resp(pend_waddr, 1'b1, t.BRESP);
			waddr_pending = 0;
		end
		if (t.RVALID && raddr_pending) begin
			check_resp(pend_raddr, 1'b0, t.RRESP);
			raddr_pending = 0;
		end
	endfunction

	function void final_response();
		`uvm_info("SCB", $sformatf("---- scoreboard summary: %0d passed, %0d failed ----",
			pass_count, fail_count), UVM_NONE)
	endfunction

	function void report_phase(uvm_phase phase);
		final_response();
	endfunction
endclass
