`define zero 0
module CPU(
    input clk,
    input reset,
    input [31:0] idata,   // data from instruction memory
    input [31:0] drdata,  // data read from data memory
    output reg [31:0] dwdata, // data to be written to data memory
    output reg [31:0] iaddr,  // address to instruction memory
    output reg [31:0] daddr,  // address to data memory
    output [3:0] we,      // write enable signal for each byte of 32-b word
    // Additional outputs for debugging
    output [31:0] x31,
    output reg [31:0] pc,
	
	output [31:0] imm,
	output [31:0] alu_out,rv1,rv2,
	output [5:0] op
);	
	//decoder
    //wire [31:0] alu_out;
	 wire alu_in2_sel;
	 wire [2:0] rd_sel;

    wire [1:0] pc_sel;
	 reg 	[1:0] pc_sel_reg;
    //wire [5:0] op; 		// for alu
    //wire [31:0] imm;
    wire rf_we;			// we for rf
	 
    wire [3:0] re; 		// for dmem
    wire rd_sign;
	
	//alu
	reg [31:0] alu_in2;

	//RF
	//wire [31:0] rv1,rv2;
	reg [31:0] rwdata;
	reg [31:0] mod_drdata;
	
	Decoder D1(.instr(idata),.alu_out(alu_out),.alu_in2_sel(alu_in2_sel),.rd_sel(rd_sel),
	 .pc_sel(pc_sel),.op(op),.imm(imm),.rf_we(rf_we),.we(we),.re(re),.rd_sign(rd_sign));

	RF mem3(.clk(clk),.rs1(idata[19:15]),.rs2(idata[24:20]),.rd(idata[11:7]),.we(rf_we),.indata(rwdata), .rv1(rv1),
		.rv2(rv2),.x31(x31));

	ALU32 a1 (.in1(rv1),.in2(alu_in2),.op(op),.out(alu_out));
	
	initial begin
		//iaddr<=-1;
		///daddr<=0;
		pc_sel_reg<=0;

		//pc_sel<=0;
	//we<=0;
	//dwdata<=256;
	end
	
	always @(*) begin
		//if (!reset) begin
		iaddr<=pc;
		//end
		pc_sel_reg<=pc_sel;
		
		daddr<=alu_out;
		//pc<=pc1;

		case(we)
			4'b0001: dwdata[7:0]  <=rv2[7:0];
			4'b0010: dwdata[15:8] <=rv2[7:0];
			4'b0100: dwdata[23:15]<=rv2[7:0];
			4'b1000: dwdata[31:24]<=rv2[7:0];
			4'b0011: dwdata[15:0] <=rv2[15:0];
			4'b1100: dwdata[31:16]<=rv2[15:0];
			4'b1111: dwdata<=rv2;
		endcase
		
		case(re)
			4'b0001: mod_drdata <= {{24{rd_sign? 0:drdata[7]}},drdata[7:0]};
			4'b0010: mod_drdata <= {{24{rd_sign? 0:drdata[15]}},drdata[15:8]};
			4'b0100: mod_drdata <= {{24{rd_sign? 0:drdata[23]}},drdata[23:16]};
			4'b1000: mod_drdata <= {{24{rd_sign? 0:drdata[31]}},drdata[31:24]};
			4'b0011: mod_drdata <= {{16{rd_sign? 0:drdata[15]}},drdata[15:0]};
			4'b1100: mod_drdata <= {{16{rd_sign? 0:drdata[31]}},drdata[31:16]};
			4'b1111: mod_drdata <= drdata;
			default: mod_drdata <= 0;
		endcase

		case(alu_in2_sel)
			1'b0: alu_in2<=rv2;
			1'b1: alu_in2<=imm;
		endcase

		case(rd_sel)
			3'b000: rwdata<=alu_out;
			3'b001: rwdata<=mod_drdata;
			3'b010: rwdata<=pc+4;
			3'b011: rwdata<=pc+imm;
			3'b100: rwdata<=imm;
			default: rwdata<=0;
		endcase

	end
	
	always @(posedge clk) begin
		if(reset) begin
			//iaddr<=0;
			pc<=0;
		end else begin
		case(pc_sel_reg)
			2'b00: pc<=pc+4;
			2'b01: pc<=pc+imm;
			2'b10: pc<=rv1+imm;
			//default: iaddr<=pc+1;
		endcase
		end
	end

endmodule
