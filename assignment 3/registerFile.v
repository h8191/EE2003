
module RF (
	clk, rs1, rs2, rd, we, indata, rv1, rv2, x31
);	
	input[4:0] rs1,rs2,rd;
	input we;
	input clk;
	input[31:0] indata;
	output wire[31:0] rv1,rv2,x31;
	
	reg[31:0] reg_mem [0:31];

	integer i;
	initial begin
	for(i=0;i<32;i=i+1)
	reg_mem[i] = 0;
	end 
	
	assign x31 = reg_mem[31];
	assign rv1 = reg_mem[rs1];
   assign rv2 = reg_mem[rs2];	  
	 
    always @(posedge clk) begin
        if(we==1 && rd!=0)
          reg_mem[rd] <= indata;	
    end

endmodule
