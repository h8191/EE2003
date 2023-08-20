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
    wire instr_found;
    wire [31:0] btb_prediction;

    cam btb(
    .clk(clk),
    .reset(reset_btb),
    .we(branch_taken&&(pc_sel_ex==3'b011)),//1 if wrong prediction
    .rkey(pc),
    .wkey(pc_ex),
    .wvalue(branch_addr),
    .instr_found(instr_found),
    .rvalue(btb_prediction)
);
    assign iaddr = pc;
    assign idata_out = idata;
    assign address_predicted = (instr_found&&idata[6:0]==7'b1100011) ? btb_prediction : pc + imm;

    //decoding immediate to predict branch
    always @(*) begin
        case(idata[6:0])
            7'b1101111 : imm <= {{12{idata[31]}},idata[19:12],idata[20],idata[30:21],1'b0};//JAL
            7'b1100011 : imm <= {{20{idata[31]}},idata[7],idata[30:25],idata[11:8],1'b0};//Branch
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
