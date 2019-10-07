/*module IMEM(
    input [31:0] iaddr,
    output [31:0] idata
);
    reg [31:0] m[0:31];
    initial begin $readmemh("instr2.txt",m); end

    assign idata = m[iaddr];
	 
endmodule
*/
`define length_i 5

module IMEM (			
	iaddr, idata
);	
	input wire[31:0] iaddr;
	output reg[31:0] idata;
	reg [31:0] instrmem [0:31];
	
    initial begin
    $readmemh("instr1.txt", instrmem);
    end
    
    //assign idata = instrmem[iaddr[9:0]]; 

    always @(*) begin
        idata<=instrmem[iaddr[2+`length_i:2]];
    end

endmodule
