module cpu_tb();
    reg clk, reset;
    wire [31:0] iaddr, idata;
    wire [31:0] daddr, drdata, dwdata;
    wire [3:0] we;
    wire [31:0] x31, pc;
	 wire [31:0] alu_out,rv1,rv2,imm;
	 wire [5:0] op;

    IMEM mem1 (.iaddr(iaddr),.idata(idata));

    DMEM mem2 (.clk(~clk),.daddr(daddr),.we(we),.drdata(drdata),.dwdata(dwdata));

    CPU dut (
        .clk(clk),
        .reset(reset),
        .iaddr(iaddr),
        .idata(idata),
        .daddr(daddr),
        .drdata(drdata),
        .dwdata(dwdata),
        .we(we),
        .x31(x31),
        .pc(pc),
		  .alu_out(alu_out),
		  .rv1(rv1),
		  .rv2(rv2),
		  .op(op),
		  .imm(imm)
    );

    always #5 clk = !clk;
	 integer i;
    initial begin
        clk = 0;
        reset = 1;
        #10;
        reset = 0;
	 for(i=0;i<40;i=i+1) begin
			#10;
	 end
	 $finish;
    end

endmodule

