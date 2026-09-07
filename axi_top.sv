`include "uvm_macros.svh"
`include "defines.svh"
import uvm_pkg::*;
import axi_pkg::*;

module axi_top;
	logic clk;
	logic rstn;

	always #5 clk=~clk;

	axi_if axi_vif(.ACLK(clk),.ARESETn(rstn));

	axi4_lite_slave #(
		.DATA_WIDTH(`DATA_WIDTH),
		.ADDR_WIDTH(`ADDR_WIDTH),
		.MEM_DEPTH(`MEM_DEPTH),
		.DEFAULT_PROT(3'b000)
	) dut (
		.ACLK(axi_vif.ACLK),
		.ARESETn(axi_vif.ARESETn),
		.AWADDR(axi_vif.AWADDR),
		.AWPROT(axi_vif.AWPROT),
		.AWVALID(axi_vif.AWVALID),
		.AWREADY(axi_vif.AWREADY),
		.WDATA(axi_vif.WDATA),
		.WSTRB(axi_vif.WSTRB),
		.WVALID(axi_vif.WVALID),
		.WREADY(axi_vif.WREADY),
		.BRESP(axi_vif.BRESP),
		.BVALID(axi_vif.BVALID),
		.BREADY(axi_vif.BREADY),
		.ARADDR(axi_vif.ARADDR),
		.ARPROT(axi_vif.ARPROT),
		.ARVALID(axi_vif.ARVALID),
		.ARREADY(axi_vif.ARREADY),
		.RDATA(axi_vif.RDATA),
		.RRESP(axi_vif.RRESP),
		.RVALID(axi_vif.RVALID),
		.RREADY(axi_vif.RREADY)
	);

	initial begin
		clk=0;
		rstn=0;
		repeat(3)@(posedge clk);
		rstn=1;
	end

	initial begin
		uvm_config_db#(virtual axi_if)::set(null,"*","axi_vif",axi_vif);
		run_test();
	end
endmodule
