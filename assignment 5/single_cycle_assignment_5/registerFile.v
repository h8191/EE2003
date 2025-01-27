module RF (
	input wire [4:0] rs1,rs2,rd,
	input wire we,
	input clk,
	input wire [31:0] indata,
	output wire [31:0] rv1,rv2,x31
);
	reg[31:0] m [0:31];
		
	integer i;
	initial begin
	for(i=0;i<32;i=i+1)
		m[i] = 0;
	end 
	
	assign x31 = m[5'b11111];
	assign rv1 = m[rs1];
   assign rv2 = m[rs2];
	/*
	always @(rs1 or rs2) begin
		x31 <= m[31];
		rv1 <= m[rs1];
		rv2 <= m[rs2];
	end
	*/
	 
    always @(posedge clk) begin
        //if((we==1) && (rd!=0))
		  //	m[rd] <= indata;
		  // end
		  if (we==1) begin
				if(rd)
					m[rd]<=indata;
				else
					m[rd]<=0;
		  end
    end

endmodule
