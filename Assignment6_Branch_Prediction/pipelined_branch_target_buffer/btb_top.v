module btb_top();
	wire found;
	wire [31:0] rvalue;
	reg clk,we;
	reg [31:0] key,wvalue;

	cam dut(.clk(clk),
			.we(we),
			.key(key),
			.instr_found(found),
			.wvalue(wvalue),
			.rvalue(rvalue)
		);

	always #5 clk = ~ clk;

	integer i;
	reg [3:0] temp1;

	initial begin 
	temp1 = 0;

	clk = 0;
	we = 0;
	key = 0;
	wvalue = 32;

	#20;
	for (i=0;i<8;i=i+1) begin
		key = {8{temp1}};
		temp1 = temp1 + 1;
		# 10;
	end
	
	#10;
	we = 1;
	key = 31;
	wvalue = 31;
	
	#10;
	we = 1;
	key = 32;
	wvalue = 32;
	
	#10;
	we = 1;
	key = 34;
	wvalue = 34;
	
	#10;
	we = 1;
	key = 33;
	wvalue = 33;
	
	#10;
	we = 1;
	key = 31;
	wvalue = 961;
	
	//$finish;
	end

endmodule
