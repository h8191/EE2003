module ALU32 (
    in1, in2, op, out
);
    input [31:0] in1, in2;
    input [5:0] op;
    output reg [31:0] out;

    always @(*) begin
        case(op)
				1: out <= in1+in2;							//ADD
				2: out <= ($signed(in1)<$signed(in2))? 1:0;	//SLT
				3: out <= (in1<in2)? 1:0;					//SLTU
				4: out <= in1^in2;							//XOR
				5: out <= in1|in2;							//OR
				6: out <= in1&in2;							//AND
				7: out <= in1<<in2[4:0];					//SLL
				8: out <= in1>>in2[4:0];					//SRL
				9: out <= $signed(in1)>>>in2[4:0];			//SRA
				10: out <= in1-in2;							//SUB
				11: out <= (in1==in2) ? 1:0; 					//Equal
				12: out <= (in1!=in2) ? 1:0; 					//Not equal
				13: out <= ($signed(in1)>=$signed(in2))? 1:0;	//SGE
				14: out <= (in1>=in2)? 1:0;					//SGEU
				default: out <= 0;
		  endcase
    end

endmodule
