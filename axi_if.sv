`include "defines.svh"
interface axi_if(input bit ACLK,input bit ARESETn);
	logic [`ADDR_WIDTH-1:0]AWADDR;
	logic [2:0]AWPROT;
	logic AWVALID;
	logic AWREADY;

	logic [`DATA_WIDTH-1:0]WDATA;
	logic [(`DATA_WIDTH/8)-1:0]WSTRB;
	logic WVALID;
	logic WREADY;

	logic [1:0]BRESP;
	logic BVALID;
	logic BREADY;

	logic [`ADDR_WIDTH-1:0]ARADDR;
	logic [2:0]ARPROT;
	logic ARVALID;
	logic ARREADY;

	logic [`DATA_WIDTH-1:0]RDATA;
	logic [1:0]RRESP;
	logic RVALID;
	logic RREADY;

	clocking cb_monitor@(posedge ACLK);
		default input #0ns output #1ns;
		input ARESETn;
		input AWADDR;
		input AWPROT;
		input AWVALID;
		input WDATA;
		input WSTRB;
		input WVALID;
		input BREADY;
		input ARADDR;
		input ARPROT;
		input ARVALID;
		input RREADY;
		input AWREADY;
		input WREADY;
		input BRESP;
		input BVALID;
		input ARREADY;
		input RDATA;
		input RRESP;
		input RVALID;
	endclocking

	clocking cb_driver@(posedge ACLK);
		default input #0ns output #1ns;
		output AWADDR;
		output AWPROT;
		output AWVALID;
		output WDATA;
		output WSTRB;
		output WVALID;
		output BREADY;
		output ARADDR;
		output ARPROT;
		output ARVALID;
		output RREADY;
		input AWREADY;
		input WREADY;
		input BRESP;
		input BVALID;
		input ARREADY;
		input RDATA;
		input RRESP;
		input RVALID;
	endclocking

	modport mon_cb(clocking cb_monitor,input ACLK,ARESETn);
	modport drv_cb(clocking cb_driver,input ACLK,ARESETn);
endinterface
