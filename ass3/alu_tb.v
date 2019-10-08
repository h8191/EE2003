// Description     : ALU test bench
// Author          : Nitin Chandrachoodan <nitin@ee.iitm.ac.in>

// Problem statement:
// Write verilog code for an ALU
//   Must be synthesizable
//   Purely combinational
// regs:
//   - instr[31:0] -- the actual instruction that would be read by the processor
//   - in1[31:0]   -- either a wire value or immediate: here you assume it has 
//   - in2[31:0]      been decoded
//   - op[5:0]     -- this is an "op" code - you need to generate a suitable opcode based on the 
//                    instruction.  Note: this is NOT part of the ALU, so write a separate
//                    DummyDecoder module just to generate this.  Later you will implement
//                    the actual decoder to do it.
// Outputs:
//   - out[31:0]   -- computed based on instr and in1, in2

`timescale 1ns/1ns
`define OPWIDTH 6;
`define width 32;
`define NUMTESTS 30;

module alu_tb () ;
	// Opcode to be sent to ALU
	
    reg [31:0] instr;
    reg [31:0] drdata;
    reg [31:0] alu_out;
    reg [31:0] rv2;    // for dmem write and giving reg to alu

    reg [31:0] pc;
    
    wire [31:0] pc1;
    wire [1:0] pc_sel;

    wire [5:0] op; 		// for alu
    wire [31:0] alu_in2;
    
    wire [31:0] rd_dec;
    wire rf_we;
    //wire [1:0] rd_sel,    // select rd b/w decoder and alu_out  optional
   
    wire[3:0] we; 		// for dmem
    wire [31:0] dwdata;
	
	// Device under test - always use named mapping of signals to ports
	
	
	reg [31:0] mem1[31:0];
	Decoder D1(.instr(instr),.drdata(drdata),.alu_out(alu_out),.rv2(rv2),.pc(pc),.pc1(pc1),
	 .pc_sel(pc_sel),.op(op),.alu_in2(alu_in2),.rd_dec(rd_dec),.we(we),.dwdata(dwdata),.rf_we(rf_we));

	integer i;

	initial begin
	$readmemh("instr.txt",mem1);
	rv2=0;
	drdata = 32'hffffffff;
	alu_out = 1;
	pc = 0;
	
	for (i=0;i<32;i=i+1) begin
		instr = mem1[i];
		#100;
	end
	
	
	
	end

endmodule // seq_mult_tb
