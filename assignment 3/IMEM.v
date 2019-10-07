module IMEM (			
	iaddr, idata
);	
	input wire[31:0] iaddr;
	output reg[31:0] idata;
	reg [31:0] instrmem [0:31];
	
    initial begin
    $readmemh("instr.txt", instrmem);
	 //$readmemh("add_imem_simplified.txt", instrmem);
    end
    
    //assign idata = instrmem[iaddr[9:0]]; 

    always @(*) begin
        idata<=instrmem[iaddr[11:2]];
    end

endmodule

/*
module IMEM (
     clk, iaddr, idata
);  
     input clk;
     input wire[31:0] iaddr;
     output reg [31:0] idata;
     reg [31:0] instrmem [31:0];
    
    initial begin
    $readmemh("instr.txt", instrmem);
    end
    
    always @(posedge clk) begin
        idata<= instrmem[iaddr[9:0]];
    end

endmodule
*/