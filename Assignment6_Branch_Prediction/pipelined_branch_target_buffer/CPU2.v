
`define pc_increment 4


module CPU(
    input clk,
    input reset,reset_btb,
    input [31:0] idata,   // data from instruction memory
    output [31:0] iaddr,  // address to instruction memory
    
    // input dmem_ready,
    input [31:0] drdata,  // data read from data memory
    output [31:0] daddr,  // address to data memory
    output [31:0] dwdata, // data to be written to data memory
    output [3:0] we,      // write enable signal for each byte of 32-b word
    
    // Additional outputs for debugging
    output [31:0] x31,
    output [31:0] pc    

);  

wire stall;
wire [2:0] pc_sel_ex;

    wire [95:0] wire1;
    wire [193:0] wire2;
    wire [142:0] wire3;
    wire [37:0] wire4;
    reg [95:0] buf1;
    reg [193:0] buf2;
    reg [109:0] buf3;
    reg [37:0] buf4;

assign daddr = buf3[alu_out];

    stage1 I1(.clk(clk),.reset(reset),.idata(idata),.idata_out(wire1[idata]),.reset_btb(reset_btb), 
        .address_predicted(wire1[address_predicted]),.branch_taken(wire3[branch_taken]),.pc_ex(buf2[pc]),
        .branch_addr(wire3[branch_addr]),.iaddr(iaddr),.pc(wire1[pc]),.stall(stall),
        .pc_sel_ex(buf2[pc_sel]));

    stage2 I2 (.idata(buf1[idata]),.branch_taken(wire3[branch_taken]),.state1(buf2[state1]),
        .rd_sel(wire2[rd_sel]),.pc_sel(wire2[pc_sel]),.alu_in2_sel(wire2[alu_in2_sel]),.op(wire2[op]),
        .imm(wire2[imm]),.ld_st(wire2[ld_st]),.rs1(wire2[rs1]),.rs2(wire2[rs2]),.rd(wire2[rd]),
        .we_rf(wire2[we_rf]),.next_state1(wire2[state1]),
        .we_rf_prev(buf2[we_rf]),.rd_sel_prev(buf2[rd_sel]),.rd_prev(buf2[rd]),.stall(stall));

    RF R1(.rs1(wire2[rs1]),.rs2(wire2[rs2]),
        .clk(clk),.rv1(wire2[rv1]),.rv2(wire2[rv2]),.x31(x31),
        .rd(wire4[rd]),.we(wire4[we_rf]),.rwdata(wire4[rwdata]));
    
    stage3 I3(.op(buf2[op]),
              .alu_in2_sel(buf2[alu_in2_sel]),
              .imm(buf2[imm]),
              .alu_out(wire3[alu_out]),
              .rv1(buf2[rv1]),
              .rv2(buf2[rv2]),
              .rs1(buf2[rs1]),
              .rs2(buf2[rs2]),
              .rd_em(buf3[rd]),
              .rwdata_em(buf3[rwdata]),
              .rd_valid_em(buf3[rd_valid]),
              .rd_mw(buf4[rd]),
              .rwdata_mw(buf4[rwdata]),
              .rd_valid_mw(buf4[we_rf]),
              .frv2(wire3[rv2]),
              .we_rf(buf2[we_rf]),
              .rd_sel(buf2[rd_sel]),
              .rd_valid(wire3[rd_valid]),
              .rwdata(wire3[rwdata]),
              .pc(buf2[pc]),
              .pc_sel(buf2[pc_sel]),
              .branch_taken(wire3[branch_taken]),
              .branch_address(wire3[branch_addr]),
              .address_predicted(buf2[address_predicted])
              );

    stage4 I4(.rd_sel(buf3[rd_sel]),
              .rwdata_em(buf3[rwdata]),
              .rv2(buf3[rv2]),
              .rwdata(wire4[rwdata]),
              .ld_st(buf3[ld_st]),
              .drdata(drdata),
              .we(we),
              .daddr(buf3[alu_out]),
              .dwdata(dwdata)
              );

assign pc = wire1[pc];

//propagation outside registers
assign wire2[address_predicted] = buf1[address_predicted];//idata
assign wire2[pc] = buf1[pc];//pc

assign wire3[rd] = buf2[rd];//rd
assign wire3[we_rf] = buf2[we_rf];//we_rf
assign wire3[ld_st] = buf2[ld_st];//ld_st
assign wire3[rd_sel] = buf2[rd_sel];//rd_sel

assign wire4[rd] = buf3[rd];//rd
assign wire4[we_rf] = buf3[we_rf];//we_rf

always @(posedge clk) begin
    if(reset) begin
        // buf1 <= 0;
        // buf2 <= 0;
        buf3 <= 0;
        buf4 <= 0;
    end else begin
        if(stall) begin//stall = 1 is normal operation
            buf1 <= wire1;
        end
            buf2 <= wire2;
            buf3 <= wire3[109:0];
            buf4 <= wire4;
    end
end

endmodule
