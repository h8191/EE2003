`define length_d 32
`define addr_d 6

module DMEM (
	clk, daddr, we, drdata, dwdata
);	
	input wire clk;
	input wire[31:0] dwdata;
	input wire[31:0] daddr;
	input wire [3:0] we;
 	output [31:0] drdata;

 	reg [7:0]bram0[0:`length_d-1];	//LSB
 	reg [7:0]bram1[0:`length_d-1];
 	reg [7:0]bram2[0:`length_d-1];
 	reg [7:0]bram3[0:`length_d-1];	//MSB
	
	integer i;
	initial begin
		for(i=0;i<`length_d;i=i+1) begin
		bram0[i]=255;//i;
		bram1[i]=0;//i;
		bram2[i]=255;//i;
		bram3[i]=0;//i;
		end
	end

  	assign drdata = {bram3[daddr[`addr_d+1:2]],bram2[daddr[`addr_d+1:2]],bram1[daddr[`addr_d+1:2]],bram0[daddr[`addr_d+1:2]]};
	
   	//assign outdata[31:24] = bram3[daddr[`addr_d+1:2]];
   	//assign outdata[23:16] = bram2[daddr[`addr_d+1:2]];
   	//assign outdata[15:8]  = bram1[daddr[`addr_d+1:2]];
   	//assign outdata[7:0]   = bram0[daddr[`addr_d+1:2]];

   	always @(posedge clk) begin
   		if(we[3]==1)
   			bram3[daddr[`addr_d+1:2]] <= dwdata[31:24];
   		if(we[2]==1)
   			bram2[daddr[`addr_d+1:2]] <= dwdata[23:16];
   		if(we[1]==1)
   			bram1[daddr[`addr_d+1:2]] <= dwdata[15:8];
   		if(we[0]==1)
   			bram0[daddr[`addr_d+1:2]] <= dwdata[7:0];
    end
endmodule
