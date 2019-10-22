// `include "parameters.v"

`define pc_increment 4

module CPU(
    input clk,
    input reset,
    input [31:0] idata,   // data from instruction memory
    output [31:0] iaddr,  // address to instruction memory
    
    input [31:0] drdata,  // data read from data memory
    output [31:0] daddr,  // address to data memory
    output reg [31:0] dwdata, // data to be written to data memory
    output [3:0] we,      // write enable signal for each byte of 32-b word
    
    // Additional outputs for debugging
    output [31:0] x31,
    output reg [31:0] pc    
);  
    //decoder
    wire [31:0] alu_out;
    wire alu_in2_sel;
    wire [1:0] rd_sel;
    wire [1:0] pc_sel;
    wire [5:0] op;
    wire [31:0] imm;
    wire rf_we;         // we for rf
    wire [3:0] re;      // for dmem
    wire rd_sign;

    //RF
    reg [31:0] rwdata;
    wire [31:0] rv1,rv2;
    
    //for alu
    reg [31:0] alu_in2;
     
    reg  [1:0] pc_sel_reg;  // to give a initial value to pc_sel
    reg [31:0] mod_drdata;  // for writing to dmem
    
    Decoder D1(.instr(idata),.alu_out(alu_out),.alu_in2_sel(alu_in2_sel),.rd_sel(rd_sel),
     .pc_sel(pc_sel),.op(op),.imm(imm),.rf_we(rf_we),.we(we),.re(re),.rd_sign(rd_sign));

    RF mem3(.clk(clk),.rs1(idata[19:15]),.rs2(idata[24:20]),.rd(idata[11:7]),.we(rf_we),
      .indata(rwdata), .rv1(rv1), .rv2(rv2),.x31(x31));

    ALU32 a1 (.in1(rv1),.in2(alu_in2),.op(op),.out(alu_out));
    
    initial begin
        pc_sel_reg<=0; // to select an initial value for pc_sel
    end
    
    assign iaddr = pc;
    assign daddr = alu_out;

    always @(*) begin
        //if (!reset) begin
        //iaddr<=pc;
        //end
        
        pc_sel_reg<=pc_sel;
		dwdata<=0;

        case(we)
            4'b0001: dwdata[7:0]  <=rv2[7:0];
            4'b0010: dwdata[15:8] <=rv2[7:0];
            4'b0100: dwdata[23:16]<=rv2[7:0];
            4'b1000: dwdata[31:24]<=rv2[7:0];
            4'b0011: dwdata[15:0] <=rv2[15:0];
            4'b1100: dwdata[31:16]<=rv2[15:0];
            4'b1111: dwdata<=rv2;
        endcase
        
        case(re)
            //rd_sign = 1 implies unsigned 
            4'b0001: mod_drdata <= {{24{rd_sign? 1'b0:drdata[7]}},drdata[7:0]};
            4'b0010: mod_drdata <= {{24{rd_sign? 1'b0:drdata[15]}},drdata[15:8]};
            4'b0100: mod_drdata <= {{24{rd_sign? 1'b0:drdata[23]}},drdata[23:16]};
            4'b1000: mod_drdata <= {{24{rd_sign? 1'b0:drdata[31]}},drdata[31:24]};
            4'b0011: mod_drdata <= {{16{rd_sign? 1'b0:drdata[15]}},drdata[15:0]};
            4'b1100: mod_drdata <= {{16{rd_sign? 1'b0:drdata[31]}},drdata[31:16]};
            4'b1111: mod_drdata <= drdata;
            default: mod_drdata <= 0;
        endcase

        case(alu_in2_sel)
            1'b0: alu_in2<=rv2;
            1'b1: alu_in2<=imm;
        endcase

        case(rd_sel)
            2'b00: rwdata<=alu_out;
            2'b01: rwdata<=mod_drdata;
            2'b10: rwdata<=pc+`pc_increment; // jump per clock cycle
            2'b11: rwdata<=pc+imm;
        endcase

    end
    
    always @(posedge clk) begin
        if(reset) begin
            pc<=0;
        end else begin
            case(pc_sel_reg)
                2'b00: pc<=pc+`pc_increment;
                2'b01: pc<=pc+imm;
                2'b10: pc<=(rv1+imm)&32'hfffffffe;
                default: pc<=32;//pc+`pc_increment;
            endcase
        end
    end

endmodule
