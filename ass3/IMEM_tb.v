`timescale 1ns/1ns


module dmem_tb () ;
	reg [31:0] daddr;
	reg [31:0] dwdata;
	reg [3:0] we;
	//reg [31:0] datamem[1023:0];
	reg clk;
	
	wire [31:0] drdata;

	DMEM data_mem0( 
		.clk(clk),
		.daddr(daddr),
		.we(we),
		.dwdata(dwdata),
		.drdata(drdata)
	);

	always #5 clk = !clk;
	
	
	initial begin
	clk <= 0;//re<=15;
	daddr<=32'h1c;
	we<=0;
	dwdata<=32'haaaabbbb;
	
	#14;
	we<=15;
	#1
	
	#9;
	we<=3;
	dwdata<=32'hccccdddd;
	#1
	
	#9;
	we<=12;
	#1;
	
	#9;
	we<=0;
	dwdata<=32'h11112222;
	#1;
	end

endmodule

/*
module imem_tb () ;
	reg [31:0] iaddr;
	wire [31:0] idata;
	reg [31:0] imem_data[31:0];

	IMEM instr_mem0(
		.iaddr(iaddr),
		.idata(idata)
	);

	// Set up 10ns clock
	//always #5 clk = !clk;

	task apply_and_check;
		input integer i;
		begin
			iaddr = i;
			if (idata != imem_data[i]) begin
				$display($time," Fail read=%08x,iaddr=%08x", idata,iaddr);
			 	//err = err+ 1;
			end else begin
				$display($time," Pass read=%08x,iaddr=%08x", idata,iaddr);
			end
			#10;
		end
	endtask // apply_and_check
	integer i;
	initial begin
		$readmemh("instr.txt", imem_data);
		
		for (i=0; i<32; i=i+1) begin
			apply_and_check(i);//	
		end
		
	end

endmodule
*/