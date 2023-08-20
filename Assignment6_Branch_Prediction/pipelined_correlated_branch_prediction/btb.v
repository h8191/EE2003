module cam(
	input clk,ce,
	input reset,
	input branch_wrong,
	input [3:0] wkey, rkey,
	output rvalue//where to jump
);

parameter PC_LSB = 4;
parameter n = 2;
parameter LENGTH_btb = 1<<PC_LSB;

reg [n-1:0] btb [0:LENGTH_btb-1];

integer i=0;

wire [1:0] next_state;
statemachine S1(.state(btb[wkey]),
	.x(branch_wrong),
	.next_state(next_state)
	);

initial begin
	for(i=0;i<LENGTH_btb;i=i+1) begin
		btb[i]<=0 ;
	end
end

assign rvalue = btb[rkey][1];
always @(posedge clk) begin
	casez ({reset,ce})
		2'b1z: begin 
				for(i=0;i<LENGTH_btb;i=i+1) begin
					btb[i]<=0 ;
					end
			  end
		2'b01: btb[wkey] <= next_state;
	endcase
end
endmodule

module statemachine(
	input [1:0] state,
	input x,//prediction wrong
	output reg [1:0] next_state
);
/*
01 =>  last 2 or more branches taken
00 =>  last branch taken
10 =>  last branch not taken
11 =>  last 2 or more branches not taken

*/
always@ (*) begin 
	case({x,state})
		3'b101: next_state <= 2'b00;
		3'b100: next_state <= 2'b10;
		3'b110: next_state <= 2'b00;
		3'b111: next_state <= 2'b10;
		3'b001: next_state <= 2'b01;
		3'b000: next_state <= 2'b01;
		3'b010: next_state <= 2'b11;
		3'b011: next_state <= 2'b11;
	endcase
end

endmodule
