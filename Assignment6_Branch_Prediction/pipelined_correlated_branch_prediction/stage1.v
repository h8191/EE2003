module stage1(
    input clk,reset,reset_btb,
    input stall,// from ID stage if a hazard is detected
    input [31:0] idata,//from IMEM
    output [31:0] idata_out,// to Decode
    input branch_taken,//to know if the branch is predicted wrong from EX
    input [31:0] branch_addr,///from EX
    input [31:0] pc_ex,
    input [2:0] pc_sel_ex,
    output [31:0] iaddr,
    output reg [31:0] pc,
    output [31:0] address_predicted 
);
reg [31:0] imm;
// reg instr_type;//JAL,Branch or something else(alu or JALR or load)

cam btb(.clk(clk),
        .ce(pc_sel_ex==3'b011),
        .reset(reset_btb),
        .branch_wrong(branch_taken),
        .rkey(pc[5:2]),
        .wkey(pc_ex[5:2]),
        .rvalue(rvalue) // rvalue is the prediction of btb 0=> take branch
        //1 => dont take branch
    );

assign iaddr = pc;
assign idata_out = idata;
assign address_predicted = pc + imm;

//decoding immediate to predict branch
always @(*) begin
    casez({rvalue,idata[6:0]})
        8'bz1101111 : imm <= {{12{idata[31]}},idata[19:12],idata[20],idata[30:21],1'b0};//JAL
        8'b01100011 : imm <= {{20{idata[31]}},idata[7],idata[30:25],idata[11:8],1'b0};//Branch
        default : imm <= 32'h00000004;
    endcase
end

always @(posedge clk) begin
    if(reset) begin
        pc <= 0;
    end else begin
        casez ({stall,branch_taken})
            2'b0z : pc <= pc;               //stalling
            2'b11 : pc <= branch_addr;      //corrected address from EX stage
            2'b10 : pc <= address_predicted;//pc + imm;
        endcase
    end
end
endmodule
