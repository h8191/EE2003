`include "parameters.v"

module IMEM(
    input [31:0] iaddr,
    output [31:0] idata
);
    reg [31:0] m[0:`length_imem-1];
    initial begin $readmemh("instr3.txt",m); end

    assign idata = m[iaddr[31:`offset_iaddr]];
	 
endmodule
