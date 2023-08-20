module cam(
	input clk,
	input reset,
	input we,
	input [31:0] wkey, rkey,
	input [31:0] wvalue,
	output reg instr_found,// if we have seen this jump
	output reg [31:0] rvalue//where to jump
);
parameter ADDR_WIDTH = 3;
parameter LENGTH = 1<<ADDR_WIDTH;

reg instr_found_w;
reg [0:0] is_valid [0:LENGTH-1];

reg [31:0] cam_key [0:LENGTH-1];
reg [31:0] cam_val [0:LENGTH-1];
//write ptr is where to write if key is not already in cam
//hit_addr_w is where we found match in btb
reg [ADDR_WIDTH-1:0] write_ptr,hit_addr_w;
wire [ADDR_WIDTH-1:0] write_addr;
// reg can_write_now;
//reg instr_found;

assign write_addr = (instr_found_w)? hit_addr_w : write_ptr;

integer i;
initial begin
	write_ptr <= 1;
	$readmemh("cam_key.txt",cam_key);
	$readmemh("cam_val.txt",cam_val);
	for(i=0; i<LENGTH;i= i+1)
		is_valid[i] <= 0;
end

always @(rkey or wkey) begin
	instr_found <= 0;
	rvalue <= 0;
	for (i = 0; i < LENGTH; i = i + 1) begin
		if(is_valid[i]&&(cam_key[i] == rkey)) begin
			instr_found <= 1;
			rvalue <= cam_val[i];
			// hit_addr_w <= i;
		end
	end
	instr_found_w <=0;
	hit_addr_w <= 0;
	for (i = 0; i < LENGTH; i = i + 1) begin
		if(is_valid[i]&&(cam_key[i] == wkey)) begin
			instr_found_w <= 1;
			// rvalue <= cam_val[i];
			hit_addr_w <= i;
		end
	end
end

always @(posedge clk) begin
	casez ({reset,we})
		2'b1z: begin
				for(i=0;i<LENGTH;i=i+1) begin
					is_valid[i] <=0 ;
				end
			end 
		2'b01: begin
				cam_key[write_addr] <= wkey;
				cam_val[write_addr] <= wvalue;
				is_valid[write_addr] <= 1;
		
				if(!instr_found_w) begin 
					write_ptr <= write_ptr + 1;
				end
			end
	endcase
end
endmodule