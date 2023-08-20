module top6(
    input clk
);
wire man_clk,reset,reset_btb;

wire [31:0] idata,iaddr;
wire [31:0] daddr,wdata;
wire [31:0] rdata,rdata_dmem,rdata_acc;
wire [3:0] we;
wire [31:0] x31,pc;

wire enable_dmem, enable_acc;

CPU instance1(
    .clk(man_clk),
    .reset_btb(reset_btb),
    .reset(reset),
    .idata(idata),
    .iaddr(iaddr),
    .drdata(rdata),
    .daddr(daddr),
    .dwdata(wdata),
    .we(we),
    .x31(x31),
    .pc(pc)
    );

imem instance2(.idata(idata),
            .iaddr(iaddr)
            );

arbiter instance3(.addr(daddr),
                .rdata_dmem(rdata_dmem),//data read from dmem
                .rdata_acc(rdata_acc),
                .rdata_mas(rdata),      // data sent to master
                .enable1(enable_dmem),
                .enable2(enable_acc)
                );

dmem instance4(.clk(~man_clk),
    .daddr(daddr),
    .dwdata(wdata),
    .we(we&{4{enable_dmem}}),
    .drdata(rdata_dmem)
    );

accumulator instance5(
    .clk(~man_clk),
    .reset(reset),
    .ce(enable_acc),
    .we(we!=0),
    .addr(daddr[3:2]),
    .wdata(wdata),
    .rdata(rdata_acc)
    );


wire [35:0] VIO_CONTROL;

icon0 instanceB(
    .CONTROL0(VIO_CONTROL)
);

vio0 instanceC(
    .CONTROL(VIO_CONTROL),
    .CLK(clk),
    .SYNC_IN({we,iaddr,idata,daddr,rdata,wdata,x31,pc}),//228
    .SYNC_OUT({man_clk,reset,reset_btb})//138
);


endmodule