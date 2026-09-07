class axi_subscriber extends uvm_component;
	`uvm_analysis_imp_decl(_in)
	`uvm_component_utils(axi_subscriber)

	uvm_analysis_imp_in#(axi_seq_item,axi_subscriber) imp_in;

	axi_seq_item in_item;

	covergroup cg_in;
		option.per_instance = 1;

		cp_aresetn: coverpoint in_item.ARESETn {
			bins in_reset     = {0};
			bins out_of_reset = {1};
		}
		cp_awvalid: coverpoint in_item.AWVALID {
			bins low  = {0};
			bins high = {1};
		}
		cp_wvalid: coverpoint in_item.WVALID {
			bins low  = {0};
			bins high = {1};
		}
		cp_arvalid: coverpoint in_item.ARVALID {
			bins low  = {0};
			bins high = {1};
		}
		cp_bready: coverpoint in_item.BREADY {
			bins low  = {0};
			bins high = {1};
		}
		cp_rready: coverpoint in_item.RREADY {
			bins low  = {0};
			bins high = {1};
		}
		cp_wstrb: coverpoint in_item.WSTRB {
			bins none    = {0};
			bins full    = {15};
			bins partial = {[1:14]};
		}
		cp_awaddr_region: coverpoint in_item.AWADDR {
			bins normal_rw   = {[32'h00:32'h24]};
			bins status_ro   = {[32'h28:32'h30]};
			bins command_wo  = {[32'h34:32'h38]};
			bins reserved_rw = {32'h3C};
			bins other       = default;
		}
		cp_araddr_region: coverpoint in_item.ARADDR {
			bins normal_rw   = {[32'h00:32'h24]};
			bins status_ro   = {[32'h28:32'h30]};
			bins command_wo  = {[32'h34:32'h38]};
			bins reserved_rw = {32'h3C};
			bins other       = default;
		}

		cx_aw_w: cross cp_awvalid, cp_wvalid;
	endgroup

	function new(string name="subscriber",uvm_component parent=null);
		super.new(name,parent);
		cg_in  = new();
		imp_in = new("imp_in",this);
	endfunction

	virtual function void write_in(axi_seq_item t);
		in_item = t;
		cg_in.sample();
	endfunction
endclass
