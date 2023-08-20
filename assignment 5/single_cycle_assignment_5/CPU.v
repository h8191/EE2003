`define pc_increment 4

module CPU(
    input clk,
    input reset,
    input [31:0] idata,   // data from instruction memory
    output [31:0] iaddr,  // address to instruction memory
    
    input [31:0] drdata,  // data read from data memory
    output [31:0] daddr,  // address to data memory
    output [31:0] dwdata, // data to be written to data memory
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
    wire rf_we;

    //RF
    reg [31:0] rwdata;
    wire [31:0] rv1,rv2;
    
    //for alu
    reg [31:0] alu_in2;
     
    reg  [1:0] pc_sel_reg;  // to give a initial value to pc_sel
    wire [31:0] mod_drdata;  // for shifter

    wire [4:0] ld_st;
    
    Decoder D1(.idata(idata),.alu_in2_sel(alu_in2_sel),.rd_sel(rd_sel),
     .pc_sel(pc_sel),.op(op),.imm(imm),.rf_we(rf_we),.ld_st(ld_st));

    RF mem3(.clk(clk),.rs1(idata[19:15]),.rs2(idata[24:20]),.rd(idata[11:7]),.we(rf_we),
      .indata(rwdata), .rv1(rv1), .rv2(rv2),.x31(x31));

    ALU32 a1 (.in1(rv1),.in2(alu_in2),.op(op),.out(alu_out));
    
    shifter s1(.drdata(drdata),.rv2(rv2),.ld_st(ld_st),.daddr(alu_out),.we(we),
        .mod_drdata(mod_drdata),.dwdata(dwdata));

    initial begin
        pc_sel_reg<=0; // to select an initial value for pc_sel
    end
    
    assign iaddr = pc;
    assign daddr = alu_out;
    // assign alu_in2 = alu_in2_sel ? imm : rv2;

    always @(*) begin
        pc_sel_reg<=pc_sel;

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
            case(pc_sel)///pc_sel_reg
                2'b00: pc<=pc+`pc_increment;
                2'b01: pc<=pc+imm;
                2'b10: pc<=(rv1+imm)&32'hfffffffe;
                2'b11: pc<=pc+(alu_out ? imm:`pc_increment);
            endcase
        end
    end

endmodule
