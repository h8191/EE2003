`include "parameters.v"

module Decoder (
    input [31:0] instr,
    input [31:0] alu_out,
    
    output reg [5:0] op,        // for alu
    output reg alu_in2_sel,
    output reg [31:0] imm,

    output reg [1:0] rd_sel,
    output reg rf_we,           // we for rf
    output reg rd_sign,
    
    output reg [1:0] pc_sel,
     
    output reg [3:0] we,re         // for dmem
);
        
    always @(*) begin
        imm<=0;
        we<=0;
        re<=0;

        op<=0;
        alu_in2_sel<=1;//default input is imm
        
        rd_sel<=0;  // def output of alu
        rf_we<=0;   // def for rf_write
        
        pc_sel<=0;  //by default normal increment
        rd_sign<=0;

        casez (instr[6:0])
            7'b0110111: begin // LUI
                            imm <= instr&32'hfffff000;
                            op <= 15;
                            rf_we<=1;
                        end
            7'b0010111: begin // AUIPC
                            imm <= instr&32'hfffff000;
                            rd_sel <= 3;
                            rf_we<=1;
                        end 
            7'b1101111: begin  // JAL
                            rf_we <= 1;
                            rd_sel <= 2;
                            pc_sel <= 1;
                            imm <= {{12{instr[31]}},instr[19:12],instr[20],instr[30:21],1'b0};
                        end
            7'b1100111: begin // JALR
                            rf_we <= 1;
                            rd_sel <= 2;
                            pc_sel <= 2; // pc+off can be from alu
                            op<=1;       // if pc is set from alu
                            imm <= {{20{instr[31]}},instr[31:20]};
                        end
            7'b1100011: begin
                            imm <= {{20{instr[31]}},instr[7],instr[30:25],instr[11:8],1'b0};
                            case (instr[14:12])
                                3'b000 : op<=11;    //BEQ
                                3'b001 : op<=12;    //BNE
                                3'b100 : op<=9;     //BLT
                                3'b101 : op<=13;    //BGE
                                3'b110 : op<=10;     //BLTU
                                3'b111 : op<=14;    //BGEU
                                default: op<=0;
                            endcase
                            alu_in2_sel<=0; //selecting rs1 instead of imm
                            if (alu_out) begin
                                pc_sel <= 1;
                            end
                        end
            7'b0000011: begin
                        imm <= {{20{instr[31]}},instr[31:20]};
                        op<=1 ; // add rs1+alu_in2(imm);
                        rd_sel<=1; // from dmem
                        rf_we<=1;

                        casez (instr[14:12])
                            3'bz00: begin //LB(0)&LBU(1)
                                    rd_sign <= instr[14]; //1=> unsigned
                                    case (alu_out[1:0])
                                    2'b00:  re<=1;
                                    2'b01:  re<=2;
                                    2'b10:  re<=4;
                                    2'b11:  re<=8;
                                    endcase
                                    end
                                    
                            3'bz01: begin //LH(0)&LHU(1)
                                    rd_sign <= instr[14];
                                    case(alu_out[1:0])
                                        2'b00: re<=3;
                                        2'b10: re<=12;
                                        default: rf_we<=0; //invalid load
                                    endcase
                                    end

                            3'b010: begin
                                    re<=15;
                                    imm <= {{20{instr[31]}},instr[31:20]}<<2;
                                    //imm <= {{18{instr[31]}},instr[31:20],2'b0}; 
                                    //imm <= {{20{instr[31]}},instr[31:20]};
                                    /*if(alu_out[1:0]==0) begin
                                        rf_we<=1;
                                    end else begin
                                        rf_we<=0;
                                    end*/
                                    end
                            default: rf_we<=0;
                        endcase
                        end

            7'b0100011: begin 
                        imm <= {{20{instr[31]}},instr[31:25],instr[11:7]};
                        op<=1;
                        //we<=0;
                        case (instr[14:12])
                            3'b000: case (alu_out[1:0])//SB
                                    2'b00: we<=1;
                                    2'b01: we<=2;
                                    2'b10: we<=4;
                                    2'b11: we<=8;
                                    endcase
                            3'b001: case (alu_out[1:0])//SH
                                    2'b00: we<=3; 
                                    2'b10: we<=12;
                                    default: we<=0;
                                    endcase
                            3'b010: begin //SW
                                    imm <= {{20{instr[31]}},instr[31:25],instr[11:7]}<<2;
                                    /*if (alu_out[1:0]==0)
                                        we<=15; 
                                    else
                                        we<=0;
                                    */
                                    we<=15;
                                end
                            default: we<=0;
                        endcase                     
                        end

            7'b0010011: begin
                rf_we <= 1; // can shift this to every case for more certainity
                rd_sel <= 0; // redn
                alu_in2_sel <=1;///redn
                casez({instr[31:25],instr[14:12]})
                    10'bzzzzzzz000: begin op<=1; // ADDI
                                        imm <= {{20{instr[31]}},instr[31:20]};
                                    end
                    10'bzzzzzzz010: begin op<=9; // SLTI
                                        imm <= {{20{instr[31]}},instr[31:20]};
                                    end
                    10'bzzzzzzz011: begin op<=10; // SLTIU
                                        imm <= {20'b0,instr[31:20]};  
                                    end
                    10'bzzzzzzz100: begin op<=5; // XORI
                                        imm <= {20'b0,instr[31:20]};  
                                    end
                    10'bzzzzzzz110: begin op<=4; // ORI
                                        imm <= {20'b0,instr[31:20]};
                                    end
                    10'bzzzzzzz111: begin op<=3; // ANDI
                                        imm <= {20'b0,instr[31:20]};
                                    end
                    10'b0000000001: begin op<=6; // SLLI
                                        imm <= {27'b0,instr[24:20]};
                                    end 
                    10'b0000000101: begin op<=7; // SRLI
                                        imm <= {27'b0,instr[24:20]};
                                    end
                    10'b0100000101: begin op<=8; // SRAI
                                        imm <= {27'b0,instr[24:20]};
                                    end
                    default: rf_we <= 0;//for safety
                endcase
                end
            7'b0110011: begin
                rf_we <= 1;
                rd_sel <= 0; // redn
                alu_in2_sel <=0;
                
                case({instr[31:25],instr[14:12]})
                    10'b0000000000: op<=1; // ADD
                    10'b0100000000: op<=2; // SUB
                    17'b0000000001: op<=6; // SLL
                    17'b0000000010: op<=9; // SLT
                    17'b0000000011: op<=10; // SLTU
                    17'b0000000100: op<=5; // XOR
                    17'b0000000101: op<=7; // SRL
                    17'b0100000101: op<=8; // SRA
                    17'b0000000110: op<=4; // OR
                    17'b0000000111: op<=3; // AND
                    default: rf_we<=0;
                    //17'bzzzzzzz0000001111: op<=38; // FENCE
                    //17'b00000000001110011: op<=39; // ECALL
                    //17'b00000010001110011: op<=40; // EBREAK
                endcase
                end
            default: op<=0;
        endcase
    end

endmodule