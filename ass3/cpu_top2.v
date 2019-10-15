`timescale 1ns / 1ps
//Implementation Testbench for DMEM

module top(
    input clk
    ); //Only input from the outside is clock
	
	reg man_clk,reset;
    reg gate_cpu,gate_dmem;
    reg clk_cpu,clk_dmem;
    reg idata_input;
    reg idata_temp;
    reg 

    wire [31:0] iaddr, idata;
    wire [31:0] daddr, drdata, dwdata;
    wire [3:0] we;
    wire [31:0] x31, pc;

    always @(*) begin
        clk_cpu <= gate_cpu&man_clk;
        clk_dmem <= gate_dmem&man_clk;
        idata_temp <= idata_input>0 ? idata_input:idata;
    end

    CPU dut (
        .clk(clk_cpu),
        .reset(reset),
        .iaddr(iaddr),
        .idata(idata_temp),
        .daddr(daddr),
        .drdata(drdata),
        .dwdata(dwdata),
        .we(we),
        .x31(x31),
        .pc(pc)
    );
	 
	 DMEM dmem(
		.clk(clk_dmem),
		.daddr(daddr),
		.dwdata(dwdata),
		.drdata(drdata),
		.we(we)
		);
	 
	 IMEM imem(
		.iaddr(iaddr), 
		.idata(idata)
	);

wire [35:0] VIO_CONTROL;

icon0 instanceB (
	 //Input-output ports controlled by VIO and ILA
	//Control wires used by ICON to control VIO and ILA
	//.CONTROL0(ILA_CONTROL), // INOUT BUS [35:0]
    .CONTROL0(VIO_CONTROL) // INOUT BUS [35:0]
);

vio0 instanceC(
    .CONTROL(VIO_CONTROL), // INOUT BUS [35:0]
	.CLK(clk),
    .SYNC_OUT({man_clk,reset}),
    .SYNC_IN({we,iaddr,idata,daddr,drdata,dwdata,x31,pc})//BUS[224+3:0]
);

/*
ila0 instanceE (
    .CONTROL(ILA_CONTROL), // INOUT BUS [35:0]
    .CLK(clk), // IN
    .TRIG0(outdata)// IN BUS [31:0]	
	
);
*/
endmodule

/*
UCF statement to be added in constraints file-
NET "clk" LOC = "C9"  | IOSTANDARD = LVCMOS33 ;
*/
 