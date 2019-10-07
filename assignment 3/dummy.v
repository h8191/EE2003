module adder( 
	input clk,
	input reset,
	output reg [31:0] a,
	output [31:0] b,
	output [31:0] c
);
	initial begin
		a<=0;
		//b<=0;
	end
	
	assign b = a;
	assign c = a+1;
	
	always @(posedge clk) begin
		a <= a+1;
	end

endmodule

`timescale 1ns/1ns

module adder_tb();
	reg clk;
	reg reset;
	wire [31:0] a,b,c;
	
	adder a1(.clk(clk),
				.reset(reset),
				.a(a),
				.b(b),
				.c(c));
	
	
	always #5 clk = ~clk;
	initial begin
	clk<=0;
	reset<=0;
	#10;
	#10;
	end
	
		
endmodule
