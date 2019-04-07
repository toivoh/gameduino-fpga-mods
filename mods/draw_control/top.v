`define YES
`include "revision.v"

module lfsre(
    input clk,
    output reg [16:0] lfsr);
wire d0;

xnor(d0,lfsr[16],lfsr[13]);

always @(posedge clk) begin
    lfsr <= {lfsr[15:0],d0};
end
endmodule

module oldram256x1s(
  input d,
  input we,
  input wclk,
  input [7:0] a,
  output o);

  wire sel0 = (a[7:6] == 0);
  wire o0;
  RAM64X1S r0(.O(o0), .A0(a[0]), .A1(a[1]), .A2(a[2]), .A3(a[3]), .A4(a[4]), .A5(a[5]), .D(d), .WCLK(wclk), .WE(sel0 & we));

  wire sel1 = (a[7:6] == 1);
  wire o1;
  RAM64X1S r1(.O(o1), .A0(a[0]), .A1(a[1]), .A2(a[2]), .A3(a[3]), .A4(a[4]), .A5(a[5]), .D(d), .WCLK(wclk), .WE(sel1 & we));

  wire sel2 = (a[7:6] == 2);
  wire o2;
  RAM64X1S r2(.O(o2), .A0(a[0]), .A1(a[1]), .A2(a[2]), .A3(a[3]), .A4(a[4]), .A5(a[5]), .D(d), .WCLK(wclk), .WE(sel2 & we));

  wire sel3 = (a[7:6] == 3);
  wire o3;
  RAM64X1S r3(.O(o3), .A0(a[0]), .A1(a[1]), .A2(a[2]), .A3(a[3]), .A4(a[4]), .A5(a[5]), .D(d), .WCLK(wclk), .WE(sel3 & we));

  assign o = (a[7] == 0) ? ((a[6] == 0) ? o0 : o1) : ((a[6] == 0) ? o2 : o3);
endmodule

module ring64(
  input clk,
  input i,
  output o);

  wire o0, o1, o2;
  SRL16E ring0( .CLK(clk), .CE(1), .D(i),  .A0(1), .A1(1), .A2(1), .A3(1), .Q(o0));
  SRL16E ring1( .CLK(clk), .CE(1), .D(o0), .A0(1), .A1(1), .A2(1), .A3(1), .Q(o1));
  SRL16E ring2( .CLK(clk), .CE(1), .D(o1), .A0(1), .A1(1), .A2(1), .A3(1), .Q(o2));
  SRL16E ring3( .CLK(clk), .CE(1), .D(o2), .A0(1), .A1(1), .A2(1), .A3(1), .Q(o));
endmodule

module ram256x1s(
  input d,
  input we,
  input wclk,
  input [7:0] a,
  output o);

  wire [1:0] rsel = a[7:6];
  wire [3:0] oo;
  genvar i;
  generate 
    for (i = 0; i < 4; i=i+1) begin : ramx
    RAM64X1S r0(.O(oo[i]), .A0(a[0]), .A1(a[1]), .A2(a[2]), .A3(a[3]), .A4(a[4]), .A5(a[5]), .D(d), .WCLK(wclk), .WE((rsel == i) & we));
    end
  endgenerate

  assign o = oo[rsel];
endmodule

module ram448x1s(
  input d,
  input we,
  input wclk,
  input [8:0] a,
  output o);

  wire [2:0] rsel = a[8:6];
  wire [7:0] oo;
  genvar i;
  generate 
    for (i = 0; i < 7; i=i+1) begin : ramx
      RAM64X1S r0(.O(oo[i]), .A0(a[0]), .A1(a[1]), .A2(a[2]), .A3(a[3]), .A4(a[4]), .A5(a[5]), .D(d), .WCLK(wclk), .WE((rsel == i) & we));
    end
  endgenerate

  assign o = oo[rsel];
endmodule

module ram400x1s(
  input d,
  input we,
  input wclk,
  input [8:0] a,
  output o);

  wire [2:0] rsel = a[8:6];
  wire [6:0] oo;
  genvar i;
  generate 
    for (i = 0; i < 6; i=i+1) begin : ramx
      RAM64X1S r0(.O(oo[i]), .A0(a[0]), .A1(a[1]), .A2(a[2]), .A3(a[3]), .A4(a[4]), .A5(a[5]), .D(d), .WCLK(wclk), .WE((rsel == i) & we));
    end
  endgenerate
  RAM16X1S r6(.O(oo[6]), .A0(a[0]), .A1(a[1]), .A2(a[2]), .A3(a[3]), .D(d), .WCLK(wclk), .WE((rsel == 6) & we));

  assign o = oo[rsel];
endmodule

module ram256x8s(
  input [7:0] d,
  input we,
  input wclk,
  input [7:0] a,
  output [7:0] o);
  genvar i;
  generate 
    for (i = 0; i < 8; i=i+1) begin : ramx
      ram256x1s ramx(
        .d(d[i]),
        .we(we),
        .wclk(wclk),
        .a(a),
        .o(o[i]));
    end
  endgenerate
endmodule

module ram32x8s(
  input [7:0] d,
  input we,
  input wclk,
  input [4:0] a,
  output [7:0] o);
  genvar i;
  generate 
    for (i = 0; i < 8; i=i+1) begin : ramx
      RAM32X1S r0(.O(o[i]), .A0(a[0]), .A1(a[1]), .A2(a[2]), .A3(a[3]), .A4(a[4]), .D(d[i]), .WCLK(wclk), .WE(we));
    end
  endgenerate
endmodule

module ram16x8d_init #(parameter [127:0] INIT=0) (
  input [7:0] da,
  input wea,
  input wclk,
  input [3:0] addra,
  input [3:0] addrb,
  output [7:0] outa,
  output [7:0] outb
  );
  genvar i;
  generate 
    for (i = 0; i < 8; i=i+1) begin : ramx
      RAM16X1D #(.INIT({
        INIT[8*15+i], INIT[8*14+i], INIT[8*13+i], INIT[8*12+i], INIT[8*11+i], INIT[8*10+i], INIT[8* 9+i], INIT[8* 8+i],
        INIT[8* 7+i], INIT[8* 6+i], INIT[8* 5+i], INIT[8* 4+i], INIT[8* 3+i], INIT[8* 2+i], INIT[8* 1+i], INIT[8* 0+i]
      })) ram(
        .D(da[i]), .WE(wea), .WCLK(wclk),
        .A0(addra[0]), .A1(addra[1]), .A2(addra[2]), .A3(addra[3]),
        .DPRA0(addrb[0]), .DPRA1(addrb[1]), .DPRA2(addrb[2]), .DPRA3(addrb[3]),
        .SPO(outa[i]), .DPO(outb[i])
      );
    end
  endgenerate
endmodule

module ram32x8s_init #(parameter [255:0] INIT=0) (
  input [7:0] d,
  input we,
  input wclk,
  input [4:0] a,
  output [7:0] o);
  genvar i;
  generate 
    for (i = 0; i < 8; i=i+1) begin : ramx
      RAM32X1S #(.INIT({
        INIT[8*31+i], INIT[8*30+i], INIT[8*29+i], INIT[8*28+i], INIT[8*27+i], INIT[8*26+i], INIT[8*25+i], INIT[8*24+i],
        INIT[8*23+i], INIT[8*22+i], INIT[8*21+i], INIT[8*20+i], INIT[8*19+i], INIT[8*18+i], INIT[8*17+i], INIT[8*16+i],
        INIT[8*15+i], INIT[8*14+i], INIT[8*13+i], INIT[8*12+i], INIT[8*11+i], INIT[8*10+i], INIT[8* 9+i], INIT[8* 8+i],
        INIT[8* 7+i], INIT[8* 6+i], INIT[8* 5+i], INIT[8* 4+i], INIT[8* 3+i], INIT[8* 2+i], INIT[8* 1+i], INIT[8* 0+i]
      })) r0(.O(o[i]), .A0(a[0]), .A1(a[1]), .A2(a[2]), .A3(a[3]), .A4(a[4]), .D(d[i]), .WCLK(wclk), .WE(we));
    end
  endgenerate
endmodule

module ram64x8s(
  input [7:0] d,
  input we,
  input wclk,
  input [5:0] a,
  output [7:0] o);
  genvar i;
  generate 
    for (i = 0; i < 8; i=i+1) begin : ramx
      RAM64X1S r0(.O(o[i]), .A0(a[0]), .A1(a[1]), .A2(a[2]), .A3(a[3]), .A4(a[4]), .A5(a[5]), .D(d[i]), .WCLK(wclk), .WE(we));
    end
  endgenerate
endmodule

module mRAM32X1D(
  input D,
  input WE,
  input WCLK,
  input A0,     // port A
  input A1,
  input A2,
  input A3,
  input A4,
  input DPRA0,  // port B
  input DPRA1,
  input DPRA2,
  input DPRA3,
  input DPRA4,
  output DPO,   // port A out
  output SPO);  // port B out

  parameter INIT = 32'b0;
  wire hDPO;
  wire lDPO;
  wire hSPO;
  wire lSPO;
  RAM16X1D
    #( .INIT(INIT[15:0]) ) 
    lo(
    .D(D),
    .WE(WE & !A4),
    .WCLK(WCLK),
    .A0(A0),
    .A1(A1),
    .A2(A2),
    .A3(A3),
    .DPRA0(DPRA0),
    .DPRA1(DPRA1),
    .DPRA2(DPRA2),
    .DPRA3(DPRA3),
    .DPO(lDPO),
    .SPO(lSPO));
  RAM16X1D
    #( .INIT(INIT[31:16]) ) 
  hi(
    .D(D),
    .WE(WE & A4),
    .WCLK(WCLK),
    .A0(A0),
    .A1(A1),
    .A2(A2),
    .A3(A3),
    .DPRA0(DPRA0),
    .DPRA1(DPRA1),
    .DPRA2(DPRA2),
    .DPRA3(DPRA3),
    .DPO(hDPO),
    .SPO(hSPO));
  assign DPO = DPRA4 ? hDPO : lDPO;
  assign SPO = A4 ? hSPO : lSPO;
endmodule

module mRAM64X1D(
  input D,
  input WE,
  input WCLK,
  input A0,     // port A
  input A1,
  input A2,
  input A3,
  input A4,
  input A5,
  input DPRA0,  // port B
  input DPRA1,
  input DPRA2,
  input DPRA3,
  input DPRA4,
  input DPRA5,
  output DPO,   // port A out
  output SPO);  // port B out

  parameter INIT = 64'b0;
  wire hDPO;
  wire lDPO;
  wire hSPO;
  wire lSPO;
  mRAM32X1D
    #( .INIT(INIT[31:0]) ) 
    lo(
    .D(D),
    .WE(WE & !A5),
    .WCLK(WCLK),
    .A0(A0),
    .A1(A1),
    .A2(A2),
    .A3(A3),
    .A4(A4),
    .DPRA0(DPRA0),
    .DPRA1(DPRA1),
    .DPRA2(DPRA2),
    .DPRA3(DPRA3),
    .DPRA4(DPRA4),
    .DPO(lDPO),
    .SPO(lSPO));
  mRAM32X1D
    #( .INIT(INIT[63:32]) ) 
  hi(
    .D(D),
    .WE(WE & A5),
    .WCLK(WCLK),
    .A0(A0),
    .A1(A1),
    .A2(A2),
    .A3(A3),
    .A4(A4),
    .DPRA0(DPRA0),
    .DPRA1(DPRA1),
    .DPRA2(DPRA2),
    .DPRA3(DPRA3),
    .DPRA4(DPRA4),
    .DPO(hDPO),
    .SPO(hSPO));
  assign DPO = DPRA5 ? hDPO : lDPO;
  assign SPO = A5 ? hSPO : lSPO;
endmodule

module mRAM128X1D(
  input D,
  input WE,
  input WCLK,
  input A0,     // port A
  input A1,
  input A2,
  input A3,
  input A4,
  input A5,
  input A6,
  input DPRA0,  // port B
  input DPRA1,
  input DPRA2,
  input DPRA3,
  input DPRA4,
  input DPRA5,
  input DPRA6,
  output DPO,   // port A out
  output SPO);  // port B out
  parameter INIT = 128'b0;

  wire hDPO;
  wire lDPO;
  wire hSPO;
  wire lSPO;
  mRAM64X1D
    #( .INIT(INIT[63:0]) ) 
    lo(
    .D(D),
    .WE(WE & !A6),
    .WCLK(WCLK),
    .A0(A0),
    .A1(A1),
    .A2(A2),
    .A3(A3),
    .A4(A4),
    .A5(A5),
    .DPRA0(DPRA0),
    .DPRA1(DPRA1),
    .DPRA2(DPRA2),
    .DPRA3(DPRA3),
    .DPRA4(DPRA4),
    .DPRA5(DPRA5),
    .DPO(lDPO),
    .SPO(lSPO));
  mRAM64X1D
    #( .INIT(INIT[127:64]) ) 
    hi(
    .D(D),
    .WE(WE & A6),
    .WCLK(WCLK),
    .A0(A0),
    .A1(A1),
    .A2(A2),
    .A3(A3),
    .A4(A4),
    .A5(A5),
    .DPRA0(DPRA0),
    .DPRA1(DPRA1),
    .DPRA2(DPRA2),
    .DPRA3(DPRA3),
    .DPRA4(DPRA4),
    .DPRA5(DPRA5),
    .DPO(hDPO),
    .SPO(hSPO));
  assign DPO = DPRA6 ? hDPO : lDPO;
  assign SPO = A6 ? hSPO : lSPO;
endmodule


module mRAM256X1D(
  input D,
  input WE,
  input WCLK,
  input A0,     // port A
  input A1,
  input A2,
  input A3,
  input A4,
  input A5,
  input A6,
  input A7,
  input DPRA0,  // port B
  input DPRA1,
  input DPRA2,
  input DPRA3,
  input DPRA4,
  input DPRA5,
  input DPRA6,
  input DPRA7,
  output DPO,   // port A out
  output SPO);  // port B out

  wire hDPO;
  wire lDPO;
  wire hSPO;
  wire lSPO;
  mRAM128X1D
    lo(
    .D(D),
    .WE(WE & !A7),
    .WCLK(WCLK),
    .A0(A0),
    .A1(A1),
    .A2(A2),
    .A3(A3),
    .A4(A4),
    .A5(A5),
    .A6(A6),
    .DPRA0(DPRA0),
    .DPRA1(DPRA1),
    .DPRA2(DPRA2),
    .DPRA3(DPRA3),
    .DPRA4(DPRA4),
    .DPRA5(DPRA5),
    .DPRA6(DPRA6),
    .DPO(lDPO),
    .SPO(lSPO));
  mRAM128X1D
  hi(
    .D(D),
    .WE(WE & A7),
    .WCLK(WCLK),
    .A0(A0),
    .A1(A1),
    .A2(A2),
    .A3(A3),
    .A4(A4),
    .A5(A5),
    .A6(A6),
    .DPRA0(DPRA0),
    .DPRA1(DPRA1),
    .DPRA2(DPRA2),
    .DPRA3(DPRA3),
    .DPRA4(DPRA4),
    .DPRA5(DPRA5),
    .DPRA6(DPRA6),
    .DPO(hDPO),
    .SPO(hSPO));
  assign DPO = DPRA7 ? hDPO : lDPO;
  assign SPO = A7 ? hSPO : lSPO;
endmodule

module ram32x8d(
  input [7:0] ad,
  input wea,
  input wclk,
  input [4:0] a,
  input [4:0] b,
  output [7:0] ao,
  output [7:0] bo
  );
  genvar i;
  generate 
    for (i = 0; i < 8; i=i+1) begin : ramx
      mRAM32X1D ramx(
        .D(ad[i]),
        .WE(wea),
        .WCLK(wclk),
        .A0(a[0]),
        .A1(a[1]),
        .A2(a[2]),
        .A3(a[3]),
        .A4(a[4]),
        .DPRA0(b[0]),
        .DPRA1(b[1]),
        .DPRA2(b[2]),
        .DPRA3(b[3]),
        .DPRA4(b[4]),
        .SPO(ao[i]),
        .DPO(bo[i]));
    end
  endgenerate
endmodule

module ram64x8d(
  input [7:0] ad,
  input wea,
  input wclk,
  input [5:0] a,
  input [5:0] b,
  output [7:0] ao,
  output [7:0] bo
  );
  genvar i;
  generate 
    for (i = 0; i < 8; i=i+1) begin : ramx
      mRAM64X1D ramx(
        .D(ad[i]),
        .WE(wea),
        .WCLK(wclk),
        .A0(a[0]),
        .A1(a[1]),
        .A2(a[2]),
        .A3(a[3]),
        .A4(a[4]),
        .A5(a[5]),
        .DPRA0(b[0]),
        .DPRA1(b[1]),
        .DPRA2(b[2]),
        .DPRA3(b[3]),
        .DPRA4(b[4]),
        .DPRA5(b[5]),
        .SPO(ao[i]),
        .DPO(bo[i]));
    end
  endgenerate
endmodule

// Same but latched read port, for CPU
module ram32x8rd(
  input wclk,
  input [15:0] ad,
  input wea,
  input [4:0] a,
  input [4:0] b,
  output reg [15:0] ao,
  output reg [15:0] bo
  );
  wire [15:0] _ao;
  wire [15:0] _bo;
  always @(posedge wclk)
  begin
    ao <= _ao;
    bo <= _bo;
  end
  genvar i;
  generate 
    for (i = 0; i < 16; i=i+1) begin : ramx
      mRAM32X1D ramx(
        .D(ad[i]),
        .WE(wea),
        .WCLK(wclk),
        .A0(a[0]),
        .A1(a[1]),
        .A2(a[2]),
        .A3(a[3]),
        .A4(a[4]),
        .DPRA0(b[0]),
        .DPRA1(b[1]),
        .DPRA2(b[2]),
        .DPRA3(b[3]),
        .DPRA4(b[4]),
        .SPO(_ao[i]),
        .DPO(_bo[i]));
    end
  endgenerate
endmodule

module ram128x8rd(
  input wclk,
  input [15:0] ad,
  input wea,
  input [6:0] a,
  input [6:0] b,
  output reg [15:0] ao,
  output reg [15:0] bo
  );
  wire [15:0] _ao;
  wire [15:0] _bo;
  always @(posedge wclk)
  begin
    ao <= _ao;
    bo <= _bo;
  end
  genvar i;
  generate 
    for (i = 0; i < 8; i=i+1) begin : ramx
      mRAM128X1D ramx(
        .D(ad[i]),
        .WE(wea),
        .WCLK(wclk),
        .A0(a[0]),
        .A1(a[1]),
        .A2(a[2]),
        .A3(a[3]),
        .A4(a[4]),
        .A5(a[5]),
        .A6(a[6]),
        .DPRA0(b[0]),
        .DPRA1(b[1]),
        .DPRA2(b[2]),
        .DPRA3(b[3]),
        .DPRA4(b[4]),
        .DPRA5(b[5]),
        .DPRA6(b[6]),
        .SPO(_ao[i]),
        .DPO(_bo[i]));
    end
  endgenerate
endmodule

module ram256x8rd(
  input wclk,
  input [7:0] ad,
  input wea,
  input [7:0] a,
  input [7:0] b,
  output reg [7:0] ao,
  output reg [7:0] bo
  );
  wire [7:0] _ao;
  wire [7:0] _bo;
  always @(posedge wclk)
  begin
    ao <= _ao;
    bo <= _bo;
  end
  genvar i;
  generate 
    for (i = 0; i < 8; i=i+1) begin : ramx
      mRAM256X1D ramx(
        .D(ad[i]),
        .WE(wea),
        .WCLK(wclk),
        .A0(a[0]),
        .A1(a[1]),
        .A2(a[2]),
        .A3(a[3]),
        .A4(a[4]),
        .A5(a[5]),
        .A6(a[6]),
        .A7(a[7]),
        .DPRA0(b[0]),
        .DPRA1(b[1]),
        .DPRA2(b[2]),
        .DPRA3(b[3]),
        .DPRA4(b[4]),
        .DPRA5(b[5]),
        .DPRA6(b[6]),
        .DPRA7(b[7]),
        .SPO(_ao[i]),
        .DPO(_bo[i]));
    end
  endgenerate
endmodule

module ram448x9s(
  input [8:0] d,
  input we,
  input wclk,
  input [8:0] a,
  output [8:0] o);
  genvar i;
  generate 
    for (i = 0; i < 9; i=i+1) begin : ramx
      ram448x1s ramx(
        .d(d[i]),
        .we(we),
        .wclk(wclk),
        .a(a),
        .o(o[i]));
    end
  endgenerate
endmodule

module ram400x9s(
  input [8:0] d,
  input we,
  input wclk,
  input [8:0] a,
  output [8:0] o);
  genvar i;
  generate 
    for (i = 0; i < 9; i=i+1) begin : ramx
      ram400x1s ramx(
        .d(d[i]),
        .we(we),
        .wclk(wclk),
        .a(a),
        .o(o[i]));
    end
  endgenerate
endmodule

module ram400x8s(
  input [7:0] d,
  input we,
  input wclk,
  input [8:0] a,
  output [7:0] o);
  genvar i;
  generate 
    for (i = 0; i < 8; i=i+1) begin : ramx
      ram400x1s ramx(
        .d(d[i]),
        .we(we),
        .wclk(wclk),
        .a(a),
        .o(o[i]));
    end
  endgenerate
endmodule

module ram400x7s(
  input [6:0] d,
  input we,
  input wclk,
  input [8:0] a,
  output [6:0] o);
  genvar i;
  generate 
    for (i = 0; i < 7; i=i+1) begin : ramx
      ram400x1s ramx(
        .d(d[i]),
        .we(we),
        .wclk(wclk),
        .a(a),
        .o(o[i]));
    end
  endgenerate
endmodule

// SPI can be many things, so to be clear, this implementation:
//   MSB first
//   CPOL 0, leading edge when SCK rises
//   CPHA 0, sample on leading, setup on trailing

module SPI_memory(
  input clk,
  input SCK, input MOSI, output MISO, input SSEL,
  output wire [15:0] raddr,   // read address
  output reg [15:0] waddr,    // write address
  output reg [7:0] data_w,
  input [7:0] data_r,
  output reg we,
  output reg re,
  output mem_clk
);
  reg [15:0] paddr;
  reg [4:0] count;
  wire [4:0] _count = (count == 23) ? 16 : (count + 1);

  assign mem_clk = clk;

  // sync SCK to the FPGA clock using a 3-bits shift register
  reg [2:0] SCKr;  always @(posedge clk) SCKr <= {SCKr[1:0], SCK};
  wire SCK_risingedge = (SCKr[2:1]==2'b01);  // now we can detect SCK rising edges
  wire SCK_fallingedge = (SCKr[2:1]==2'b10);  // and falling edges

  // same thing for SSEL
  reg [2:0] SSELr;  always @(posedge clk) SSELr <= {SSELr[1:0], SSEL};
  wire SSEL_active = ~SSELr[1];  // SSEL is active low
  wire SSEL_startmessage = (SSELr[2:1]==2'b10);  // message starts at falling edge
  wire SSEL_endmessage = (SSELr[2:1]==2'b01);  // message stops at rising edge

// and for MOSI
  reg [1:0] MOSIr;  always @(posedge clk) MOSIr <= {MOSIr[0], MOSI};
  wire MOSI_data = MOSIr[1];

  assign raddr = (count[4] == 0) ? {paddr[14:0], MOSI} : paddr;

  always @(posedge clk)
  begin
    if (~SSEL_active) begin
      count <= 0;
      re <= 0;
      we <= 0;
    end else
      if (SCK_risingedge) begin
        if (count[4] == 0) begin
          we <= 0;
          paddr <= raddr;
          re <= (count == 15);
        end else begin
          data_w <= {data_w[6:0], MOSI_data};
          if (count == 23) begin
            we <= paddr[15];
            re <= !paddr[15];
            waddr <= paddr;
            paddr <= paddr + 1;
          end else begin
            we <= 0;
            re <= 0;
          end
        end
        count <= _count;
      end
      if (SCK_fallingedge) begin
        re <= 0;
        we <= 0;
      end
  end

  reg readbit;
  always @*
  begin
    case (count[2:0])
    3'd0: readbit <= data_r[7];
    3'd1: readbit <= data_r[6];
    3'd2: readbit <= data_r[5];
    3'd3: readbit <= data_r[4];
    3'd4: readbit <= data_r[3];
    3'd5: readbit <= data_r[2];
    3'd6: readbit <= data_r[1];
    3'd7: readbit <= data_r[0];
    endcase
  end
  assign MISO = readbit;

endmodule

// This is a Delta-Sigma Digital to Analog Converter
`define MSBI 12 // Most significant Bit of DAC input, 12 means 13-bit

module dac(DACout, DACin, Clk, Reset);
output DACout;         // This is the average output that feeds low pass filter
reg DACout;            // for optimum performance, ensure that this ff is in IOB
input [`MSBI:0] DACin; // DAC input (excess 2**MSBI)
input Clk;
input Reset;
reg [`MSBI+2:0] DeltaAdder; // Output of Delta adder
reg [`MSBI+2:0] SigmaAdder; // Output of Sigma adder
reg [`MSBI+2:0] SigmaLatch; // Latches output of Sigma adder
reg [`MSBI+2:0] DeltaB; // B input of Delta adder

always @(SigmaLatch) DeltaB = {SigmaLatch[`MSBI+2], SigmaLatch[`MSBI+2]} << (`MSBI+1);
always @(DACin or DeltaB) DeltaAdder = DACin + DeltaB;
always @(DeltaAdder or SigmaLatch) SigmaAdder = DeltaAdder + SigmaLatch;
always @(posedge Clk or posedge Reset)
begin
  if (Reset) begin
    SigmaLatch <= #1 1'b1 << (`MSBI+1);
    DACout <= #1 1'b0;
  end else begin
    SigmaLatch <= #1 SigmaAdder;
    DACout <= #1 SigmaLatch[`MSBI+2];
  end
end
endmodule

module top(
        input clka,

        output [2:0] vga_red,
        output [2:0] vga_green,
        output [2:0] vga_blue,
        output vga_hsync_n,
        output vga_vsync_n,

        input SCK,  // arduino 13
        input MOSI, // arduino 11
        inout MISO, // arduino 12
        input SSEL, // arduino 9
        inout AUX,  // arduino 2

        output AUDIOL,
        output AUDIOR,

        output flashMOSI,
        input  flashMISO,
        output flashSCK,
        output flashSSEL
    );

    wire vga_clk;
    ck_div #(.DIV_BY(2), .MULT_BY(4)) vga_ck_gen(.ck_in(clka), .ck_out(vga_clk));

    wire vga_hsync, vga_vsync;
    wire gdMISO;
    wire AUX_in, AUX_out, AUX_tristate;

    wire [7:0] host_mem_data_wr;
    wire [14:0] host_mem_w_addr;
    wire [14:0] host_mem_r_addr;
    wire host_mem_wr;
    wire host_mem_rd;
    wire [7:0] host_mem_data_rd;
    wire mem_clk;

    wire pin2f, pin2j;
    wire j1_flashMOSI;
    wire j1_flashSCK;
    wire j1_flashSSEL;

    gameduino_main gd(
        .vga_clk(vga_clk),
        .vga_red(vga_red), .vga_green(vga_green), .vga_blue(vga_blue),
        .vga_hsync(vga_hsync), .vga_vsync(vga_vsync),
        .mem_clk(mem_clk), .host_mem_data_wr(host_mem_data_wr), .host_mem_w_addr(host_mem_w_addr), .host_mem_r_addr(host_mem_r_addr), .host_mem_wr(host_mem_wr), .host_mem_rd(host_mem_rd), .host_mem_data_rd(host_mem_data_rd),
        .AUX_in(AUX_in), .AUX_out(AUX_out), .AUX_tristate(AUX_tristate),
        .AUDIOL(AUDIOL), .AUDIOR(AUDIOR),
        .pin2f(pin2f), .pin2j(pin2j), .j1_flashMOSI(j1_flashMOSI), .j1_flashSCK(j1_flashSCK), .j1_flashSSEL(j1_flashSSEL), .flashMISO(flashMISO)
    );

    reg [7:0] latched_mem_data_rd;    
    always @(posedge vga_clk) if (host_mem_rd) latched_mem_data_rd <= host_mem_data_rd;

    SPI_memory spi1(
        .clk(vga_clk),
        .SCK(SCK), .MOSI(MOSI), .MISO(gdMISO), .SSEL(SSEL),
        .raddr(host_mem_r_addr),
        .waddr(host_mem_w_addr),
        .data_w(host_mem_data_wr),
        .data_r(latched_mem_data_rd),
        .we(host_mem_wr),
        .re(host_mem_rd),
        .mem_clk(mem_clk)
    );

    wire flashsel = (AUX == 0) & pin2f;
    assign MISO = SSEL ? (flashsel ? flashMISO : 1'bz) : gdMISO;

    assign flashMOSI = pin2j ? j1_flashMOSI : MOSI;
    assign flashSCK = pin2j ? j1_flashSCK : SCK;
    assign flashSSEL = pin2f ? AUX : (pin2j ? j1_flashSSEL : 1);

    assign AUX = AUX_tristate ? 1'bz : AUX_out;
    assign AUX_in = AUX;

    assign vga_hsync_n = !vga_hsync;
    assign vga_vsync_n = !vga_vsync;
endmodule

module gameduino_main(
  input vga_clk, // Twice the frequency of the original clka board clock
  output [2:0] vga_red,
  output [2:0] vga_green,
  output [2:0] vga_blue,
  output vga_hsync,
  output vga_vsync,
  output reg vga_active,

  input mem_clk, // Should probably be same as vga_clk
  input host_mem_wr,             // set to zero if not used
  input [14:0] host_mem_w_addr,  // set to zero if not used
  input [7:0] host_mem_data_wr,  // set to zero if not used
  input host_mem_rd,             // set to zero if not used
  input [14:0] host_mem_r_addr,  // set to zero if not used
  output [7:0] host_mem_data_rd,

  input AUX_in, // set to zero if not used
  output AUX_out,
  output AUX_tristate,

  output AUDIOL,
  output AUDIOR,

  output pin2f,
  output pin2j,
  output reg j1_flashMOSI,
  output reg j1_flashSCK,
  output reg j1_flashSSEL,
  input flashMISO  // set to zero if not used

  );
  wire AUX;

// Options: defines
// ----------------

// Replace RAM_SPRVAL with RAM_SPRVAL_inferred, for better compatibility but possibly higher block RAM usage?
//`define RAM_SPRVAL_INFERRED

// Include audio support? USE_AUDIO implies USE_PCM_AUDIO
//`define USE_AUDIO
`define USE_PCM_AUDIO

// Include the 0x2890 - 0x289f region of the COMM register? (repeated at 0x2880 - 0x288f)
`define USE_COMM1
// Include the 0x28a0 - 0x28bf region of the COMM register?
`define USE_COMM2

// Include support for original RAM_PIC format with one byte per entry?
`define SUPPORT_8BIT_RAM_PIC
// Include support for the CHR_TEXT_MODE_MASK register to mark some tiles a two-color with attribute composed of 4 foreground and 4 background color bits?
`define SUPPORT_TEXT_MODE_TILES

`ifdef USE_AUDIO
`define USE_PCM_AUDIO
`endif

// Options: parameters
// -------------------

  // Memory map start adresses, in 2k blocks
  localparam [3:0] MEM_PAGE_ADDR_RAM_PIC = 0; // Must be even
  localparam [3:0] MEM_PAGE_ADDR_RAM_CHR = 2; // Must be even

  // Alternate configuration to place RAM_PIC right before RAM_PAL, for 6k of contiguous tile map space  
  //localparam [3:0] MEM_PAGE_ADDR_RAM_PIC = 2; // Must be even
  //localparam [3:0] MEM_PAGE_ADDR_RAM_CHR = 0; // Must be even

  localparam WIDE_LINE_BUFFER = 1; // Reserve space for 640 pixels per line?
  localparam ROT_FORMAT_HVD = 0; // Interpret the sprite's rot field as (horizontal, vertical, diagonal flip) instead of (v, h, d)?

// Add a register to change the attr_ninths_are_pal_bits option at runtime?
`define ATTR_NINTH_PAL_BITS_REG
  // Tile map entry format in attribute mode (ninth_bits high_byte low_byte)
  // 0: tt pppppppp tttttttt - two highest tile index bits in ninth bits
  // 1: pp pppppptt tttttttt - two highest palette bits in ninth bits
  // This is the default value, stored in a register if ATTR_NINTH_PAL_BITS_REG is defined
  localparam ATTR_NINTH_PAL_BITS_DEFAULT = 0;

  // 0: Only tile ids 0-255 (and 512-767) can be used for text mode tiles; the bits in CHR_TEXT_MODE_MASK denote blocks of 32 tile ids
  // 1: Tile ids 0-511 (and 512-1023) can be used for text mode tiles; the bits in CHR_TEXT_MODE_MASK denote blocks of 64 tile ids
  localparam TEXT_MODE_TILES_BIG_CHUNKS = 0;

// Constants
// ---------

  localparam X_BITS = 10; // 9 in the original
  localparam VGA_X_BITS = 11;
  localparam VGA_Y_BITS = 10;

  reg [1:0] graphics_mode = 0;

  wire vga_1280x480 = graphics_mode[0]; 
  wire widen_output = graphics_mode[1];
  wire sprite_10bit_x = (vga_1280x480 && !widen_output); // Steal one bit from sprites' y position to get a 10 bit x position?

  // Original 800x600 mode:
  //localparam VGA_MODE1_WIDTH = 800, VGA_MODE1_XTOT = 1040 + 1, VGA_MODE1_XFP = 60, VGA_MODE1_XSYNC = 120;
  //localparam VGA_MODE1_HEIGHT = 600, VGA_MODE1_YTOT = 666, VGA_MODE1_YFP = 38, VGA_MODE1_YSYNC = 6;

  // Standard 800x600@72Hz:
  localparam VGA_MODE1_WIDTH = 800, VGA_MODE1_XTOT = 1040, VGA_MODE1_XFP = 60, VGA_MODE1_XSYNC = 120;
  localparam VGA_MODE1_HEIGHT = 600, VGA_MODE1_YTOT = 666, VGA_MODE1_YFP = 37, VGA_MODE1_YSYNC = 6;
  localparam VGA_MODE1_YBP = VGA_MODE1_YTOT - (VGA_MODE1_HEIGHT + VGA_MODE1_YFP + VGA_MODE1_YSYNC);

  localparam VGA_MODE2_WIDTH = 2*640, VGA_MODE2_XTOT = 2*800, VGA_MODE2_XFP = 2*16, VGA_MODE2_XSYNC = 2*96;
  localparam VGA_MODE2_HEIGHT = 480, VGA_MODE2_YTOT = 525, VGA_MODE2_YFP = 10, VGA_MODE2_YSYNC = 2;
  localparam VGA_MODE2_YBP = VGA_MODE2_YTOT - (VGA_MODE2_HEIGHT + VGA_MODE2_YFP + VGA_MODE2_YSYNC);

  reg [VGA_X_BITS-1:0] vga_width = VGA_MODE1_WIDTH, vga_xtot_minus_1 = VGA_MODE1_XTOT - 1, vga_hs_x0, vga_hs_x1;
  reg [VGA_Y_BITS-1:0] vga_height = VGA_MODE1_HEIGHT, vga_ytot_minus_1, vga_vs_y0, vga_vs_y1, vga_active_y0, vga_active_y1; 

  always @(posedge vga_clk) begin
    // Only change mode parameters at certain times?
    if (vga_1280x480) begin
      vga_width <= VGA_MODE2_WIDTH;
      vga_xtot_minus_1 <= VGA_MODE2_XTOT - 1;
      vga_hs_x0 <= VGA_MODE2_WIDTH + VGA_MODE2_XFP;
      vga_hs_x1 <= VGA_MODE2_WIDTH + VGA_MODE2_XFP + VGA_MODE2_XSYNC;

      vga_height <= VGA_MODE2_HEIGHT;
      vga_ytot_minus_1 <= VGA_MODE2_YTOT - 1;
      vga_vs_y0 <= VGA_MODE2_YFP - 3;
      vga_vs_y1 <= VGA_MODE2_YFP - 3 + VGA_MODE2_YSYNC;
      vga_active_y0 <= VGA_MODE2_YFP - 3 + VGA_MODE2_YSYNC + VGA_MODE2_YBP;
      vga_active_y1 <= VGA_MODE2_YFP - 3 + VGA_MODE2_YSYNC + VGA_MODE2_YBP + VGA_MODE2_HEIGHT;
    end else begin
      vga_width <= VGA_MODE1_WIDTH;
      vga_xtot_minus_1 <= VGA_MODE1_XTOT - 1;
      vga_hs_x0 <= VGA_MODE1_WIDTH + VGA_MODE1_XFP;
      vga_hs_x1 <= VGA_MODE1_WIDTH + VGA_MODE1_XFP + VGA_MODE1_XSYNC;

      vga_height <= VGA_MODE1_HEIGHT;
      vga_ytot_minus_1 <= VGA_MODE1_YTOT - 1;
      vga_vs_y0 <= VGA_MODE1_YFP - 3;
      vga_vs_y1 <= VGA_MODE1_YFP - 3 + VGA_MODE1_YSYNC;
      vga_active_y0 <= VGA_MODE1_YFP - 3 + VGA_MODE1_YSYNC + VGA_MODE1_YBP;
      vga_active_y1 <= VGA_MODE1_YFP - 3 + VGA_MODE1_YSYNC + VGA_MODE1_YBP + VGA_MODE1_HEIGHT;      
    end
  end

  reg [VGA_X_BITS-1-1:0] render_width = VGA_MODE1_WIDTH >> 1;
  always @(posedge vga_clk) render_width <= (vga_width >> widen_output) >> 1;


  reg [8:0] mem_data_rd;
  assign host_mem_data_rd = mem_data_rd;


  wire [14:0] mem_w_addr;   // Combined write address
  wire [14:0] mem_r_addr;   // Combined read address

  wire [15:0] j1_insn;
  wire [12:0] j1_insn_addr;
  wire [15:0] j1_mem_addr;
  wire [15:0] j1_mem_dout;
  wire j1_mem_wr;

  wire [7:0] j1insnl_read;
  wire [7:0] j1insnh_read;
  wire [8:0] mem_data_rd0; // picture
  wire [7:0] mem_data_rd1;
  wire [8:0] mem_data_rd2; // pal = last part of picture
  wire [8:0] mem_data_rd3; // sprval
  wire [7:0] mem_data_rd4;
  wire [7:0] mem_data_rd5;

  // ninth bit access registers
  reg [7:0] ninth_read_bits = 0;
  reg [7:0] ninth_write_bits = 0;

  wire host_busy = host_mem_wr | host_mem_rd;
  wire mem_wr =            host_busy ? host_mem_wr : j1_mem_wr;
  wire [8:0] mem_data_wr = host_busy ? {ninth_write_bits[0], host_mem_data_wr} : j1_mem_dout[8:0];
  wire [14:0] mem_addr =   host_busy ? (host_mem_wr ? host_mem_w_addr : host_mem_r_addr) : j1_mem_addr;
  assign mem_w_addr =      host_busy ? host_mem_w_addr : j1_mem_addr;
  assign mem_r_addr =      host_busy ? host_mem_r_addr : j1_mem_addr;

  // Used to make sure that ninth_read_bits is only updated once in a read cycle
  reg _host_mem_rd_ram, __host_mem_rd_ram;
  always @(posedge vga_clk) begin
    _host_mem_rd_ram <= host_mem_rd && (host_mem_r_addr[14:11] != 5);
    __host_mem_rd_ram <= _host_mem_rd_ram;
  end

  // Used to make sure that ninth_read_bits and ninth_write_bits are only updated once in one read/write. Are these needed? 
  reg [14:0] _mem_addr;
  wire mem_addr_changed = (mem_addr != _mem_addr);
  reg _mem_addr_changed;
  reg _host_mem_wr;
  always @(posedge vga_clk) begin
    _mem_addr <= mem_addr;
    _mem_addr_changed <= mem_addr_changed;
    _host_mem_wr <= host_mem_wr;
  end

`ifdef USE_PCM_AUDIO
  reg signed [15:0] sample_l;
  reg signed [15:0] sample_r;
`endif
`ifdef USE_AUDIO
  reg [6:0] modvoice = 64;
`endif

  reg [14:0] bg_color = 4 << 10;
  reg [7:0] pin2mode = 0;
  assign pin2f = (pin2mode == 8'h46);
  assign pin2j = (pin2mode == 8'h4A);

  // assign MISO = SSEL ? (1'bz ) : gdMISO;
  // PULLUP MISO_pullup(.O(MISO));
  // IOBUF MISO_iobuf(
  //   .I(gdMISO),
  //   .IO(MISO),
  //   .T(SSEL));


  // user-visible registers
  reg [7:0] frames;
  reg [X_BITS-1:0] scrollx;
  reg [8:0] scrolly;
  reg jkmode;

  // Initial values and memory offsets for shadowed registers to be initialized to something != 0
  localparam INITIAL_J1_RESET = 1;
  localparam [10:0] SHADOW1_INDEX_J1_RESET = 11'h009;
  localparam INITIAL_PIC_MODE = {1'b0, 2'd2, 2'd2, 3'd0};
  localparam [10:0] SHADOW1_INDEX_PIC_MODE = 11'h019;
  localparam INITIAL_WINDOW_X1 = 2**X_BITS-1;
  localparam [10:0] SHADOW1_INDEX_WINDOW_X1 = 11'h01c; // 16 bits
  localparam INITIAL_SPRITES_END = 255;
  localparam [10:0] SHADOW1_INDEX_SPRITES_END = 11'h016;

  localparam INITIAL_CHR_BASE = (7 << 12) >> 8;
  localparam [10:0] PALBASES_SHADOW_INDEX_CHR_BASE = 11'h0c0;
  localparam INITIAL_CHR_ATTR_MASK = 'hff;
  localparam [10:0] PALBASES_SHADOW_INDEX_CHR_ATTR_MASK = 11'h0c3;
  localparam [10:0] PALBASES_SHADOW_INDEX_ATTR_NINTH_PB = 11'h0c5; // for register attr_ninths_are_pal_bits

  reg j1_reset = INITIAL_J1_RESET;

  reg [7:0] pic_mode = INITIAL_PIC_MODE;
  wire [2:0] pic_base = pic_mode[2:0];
  wire [1:0] pic_width_mode = pic_mode[4:3];
  wire [1:0] pic_height_mode = pic_mode[6:5];
`ifdef SUPPORT_8BIT_RAM_PIC
  wire pic_with_attr = pic_mode[7];
`else
  wire pic_with_attr = 1;
`endif  

  reg [2:0] draw_mode;
  wire spr_disable = draw_mode[0]; 
  wire bg_disable = draw_mode[1];
  wire sprites_behind_bg = draw_mode[2];

  reg [X_BITS-1:0] window_x0 = 0; // Should be < render_width
  reg [X_BITS-1:0] window_x1 = INITIAL_WINDOW_X1; // Should be >= window_x0
  reg [8:0] sprites_base = 0;
  reg [7:0] sprites_end = INITIAL_SPRITES_END; // The last sprite to draw is the one that has an index whose LSB matches sprites_end

  reg [6:0] chr_base = INITIAL_CHR_BASE;
  //reg [6:0] sprimg_base = 0;

  reg [3:0] spr_palrot_mask;
`ifdef SUPPORT_8BIT_RAM_PIC
  reg [7:0] chr_attr_mask = INITIAL_CHR_ATTR_MASK;
`else
  wire [7:0] chr_attr_mask = INITIAL_CHR_ATTR_MASK;
`endif
`ifdef SUPPORT_TEXT_MODE_TILES
  reg [7:0] chr_text_mode_mask = 0;
`else
  wire [7:0] chr_text_mode_mask = 0;
`endif

  /*
  // Inferred distributed RAM with initializer doesn't synthesize right in ise, so we use a ram16x8d_init instead, below
  (* ram_style = "distributed" *) reg [7:0] palbases[0:7];
  initial begin
    palbases[1] = 252; // spr_palbase_16  
  end
  */

  wire [3:0] palbases_addr;
  wire [7:0] palbases_out;

  wire [7:0] palbases_read;
  
  //wire palbases_sel = (mem_addr[14:11] == 5) && (mem_addr[10:3] == ('hd0 >> 3));
  // map 0x28d0 - 0x28d7 to palbases[0:7]
  // map 0x28c0 - 0x28c7 to palbases[8:15] (as shadow registers)
  wire palbases_sel = (mem_addr[14:11] == 5) && (mem_addr[10:5] == ('hc0 >> 5)) && (mem_addr[3] == 0);
  wire [3:0] palbases_mem_addr = {!mem_addr[4], mem_addr[2:0]};

  // Entries:
  // 0: spr_palbase_4, 1: spr_palbase_16, 2: spr_palbase_256, 3: chr_palbase, 4: chr_palbase_fg, 5: chr_palbase_bg
  localparam [7:0] INITIAL_SPR_PALBASE_16 = 252;
  localparam [127:0] PALBASES_INIT = 
    {INITIAL_SPR_PALBASE_16, {1{8'b0}}} |
    {INITIAL_CHR_BASE,            {(PALBASES_SHADOW_INDEX_CHR_BASE      - 'hc0 + 8){8'b0}}} |
    {INITIAL_CHR_ATTR_MASK,       {(PALBASES_SHADOW_INDEX_CHR_ATTR_MASK - 'hc0 + 8){8'b0}}} |
    {ATTR_NINTH_PAL_BITS_DEFAULT, {(PALBASES_SHADOW_INDEX_ATTR_NINTH_PB - 'hc0 + 8){8'b0}}};
  ram16x8d_init #(.INIT(PALBASES_INIT)) palbases(
    .wclk(vga_clk),
    .wea(palbases_sel && mem_wr), .da(mem_data_wr), .addra(palbases_mem_addr), .outa(palbases_read),
    .addrb(palbases_addr), .outb(palbases_out)
  );

`ifdef ATTR_NINTH_PAL_BITS_REG
  reg attr_ninths_are_pal_bits = ATTR_NINTH_PAL_BITS_DEFAULT;
`else
  wire attr_ninths_are_pal_bits = ATTR_NINTH_PAL_BITS_DEFAULT;
`endif 

  // Generate CounterX and CounterY
  // A single line is 1040 (vga_xtot_minus_1 + 1) clocks.  Line pair is 2080 clocks.

  reg [10:0] CounterX;
  reg [9:0] CounterY;
  wire CounterXmaxed = (CounterX == vga_xtot_minus_1);

  always @(posedge vga_clk)
  if(CounterXmaxed)
    CounterX <= 0;
  else
    CounterX <= CounterX + 1;
  wire lastline = (CounterY == vga_ytot_minus_1);
  wire [9:0] _CounterY = lastline ? 0 : (CounterY + 1);

  wire frame_finish = CounterXmaxed && lastline; 
  always @(posedge vga_clk)
  if (CounterXmaxed) begin
    CounterY <= _CounterY;
    if (lastline)
      frames <= frames + 1;
  end

  // Is background drawing active (in a given pipeline stage)
  // bg_active[0] is the state, bg_active[n] is n cycles delayed (for pipelining)
  reg [4:0] bg_active = 0; // TODO: how many bits?
  always @(posedge vga_clk) bg_active[4:1] <= bg_active[3:0];
  // Do we want to start drawing sprites as soon as the background drawing is done?
  reg sprite_draw_enabled = 0;
  wire sprite_draw_active; // is any part of the sprite pipeline currently active?
  reg sprite_scan_active = 0;

  reg [12:0] comp_workcnt; // Compositor work address; the x coordinate where the tile background is currently being written
  wire [12:0] comp_workcnt_plus_1 = comp_workcnt + 1;
  
  reg [12:0] comp_workcnt_m1, comp_workcnt_m2, comp_workcnt_m3; // Delay chain for later stages
  always @(posedge vga_clk) begin  comp_workcnt_m3 <= comp_workcnt_m2; comp_workcnt_m2 <= comp_workcnt_m1; comp_workcnt_m1 <= comp_workcnt;  end

  // When one of these goes high, it's ok to start a new rendering activity in the next cycle
  wire bg_draw_finish = bg_active[0] && (comp_workcnt_plus_1 >= render_width || comp_workcnt == window_x1);
  wire sprite_draw_finish = sprite_draw_enabled && !sprite_draw_active;

  wire j1_start_draw;
  // When start_draw_line goes high, a new line will start on the next pixel
  wire start_draw_line = (CounterXmaxed & (CounterY[0] == !vga_active_y0[0]));
  wire start_draw = start_draw_line || j1_start_draw;

  wire start_bg_draw =     ( (!sprites_behind_bg || spr_disable) ? start_draw : sprite_draw_finish ) && !bg_disable;
  wire start_sprite_draw = (  (sprites_behind_bg || bg_disable)  ? start_draw : bg_draw_finish     ) && !spr_disable;
  wire start_sprite_scan = start_draw && !spr_disable;

  always @(posedge vga_clk) begin
    if (start_sprite_draw) sprite_draw_enabled <= 1;
    else if (sprite_draw_finish) sprite_draw_enabled <= 0;
  end

  always @(posedge vga_clk)
  begin
    if (start_bg_draw) begin
      comp_workcnt <= window_x0;
      bg_active[0] <= 1;
    end else if (bg_active[0]) begin
      comp_workcnt <= comp_workcnt_plus_1;
      if (bg_draw_finish) bg_active[0] <= 0;
    end
  end

// horizontal
//   Front porch  56
//   Sync         120
//   Back porch   64

// vertical
//   Front porch  37 lines
//   Sync         6
//   Back porch   23

// `define HSTART (53 + 120 + 61)
`define HSTART 0

  reg vga_HS, vga_VS;
  always @(posedge vga_clk)
  begin
    vga_HS <= (vga_hs_x0 <= CounterX) & (CounterX < vga_hs_x1);
    vga_VS <= (vga_vs_y0 <= CounterY) & (CounterY < vga_vs_y1);
    vga_active = ((`HSTART) <= CounterX) & (CounterX < (`HSTART + vga_width)) & (vga_active_y0 <= CounterY) & (CounterY < vga_active_y1);
  end

  wire [10:0] xx = (CounterX - `HSTART);
  wire [10:0] xx_1 = (CounterX - `HSTART + 1);
  wire [10:0] yy = (CounterY + 2 - vga_active_y0);    // yy range 0-665

  // column0, row0: before wrapping to tile map width/height
  wire [10:0] column0 = comp_workcnt + scrollx;
  wire [9:0] row0     = yy[10:1] + scrolly;

  // Wrap column: subtract wrap_width once if column0 >= wrap_width 
  reg [9:0] wrap_width;
  always @* begin
    case (pic_width_mode[1:0])
      2'd0: wrap_width = 8*32;
      2'd1: wrap_width = 8*48;
      2'd2: wrap_width = 8*64;
      2'd3: wrap_width = 8*96;
      endcase
  end
  wire [10:0] column1 = column0 - wrap_width;
  wire [9:0] column = column1[10] ? column0 : column1;

  // Wrap row: subtract wrap_height once if column0 >= wrap_width
  wire [9:0] wrap_height = pic_height_mode[0] == 0 ? 8*32 : 8*48; // Not used if pic_height_mode[1] == 1 (wrap height = 64)
  wire [9:0] row1 = row0 - wrap_height;
  wire [8:0] row = (pic_height_mode[1] | row1[9]) ? row0 : row1;

  // # Calculate tile map address from wrapped coordinates
  // Extract tile map coordinates
  wire [6:0] pic_col = column >> 3;
  wire [5:0] pic_row = row >> 3;

  // Multiply pic_row by 2 or 3
  wire [7:0] pic_row_x2x3 = {1'b0, pic_row, 1'b0} + (pic_width_mode[0] ? pic_row : 0); // pic_row*2 or pic_row*3, depending on pic_width_mode[0]
  // Multiply pic_row by 16 or 32
  wire [11:0] pic_row_x_pic_width = pic_width_mode[1] ? pic_row_x2x3 << 5 : pic_row_x2x3 << 4;

  // picaddr = pic_row*wrap_width + pic_col + pic_base*512
  wire [12:0] picaddr = pic_row_x_pic_width + pic_col + (pic_base << 9);

  reg _picaddr0;
  always @(posedge vga_clk) _picaddr0 <= picaddr;  

  wire en_pic = (mem_addr[14:12] == (MEM_PAGE_ADDR_RAM_PIC >> 1));
  wire [17:0] pic_out, pic_out1, pic_out2;

  wire [11:0] picaddr_final = pic_with_attr ? picaddr : picaddr >> 1;
  wire [9:0] glyph;

  RAM_PICTURE18_primitive picture(
    .dib(0),
	 .dob(pic_out1),
	 .web(0),
	 .enb(1),
	 .clkb(vga_clk),
	 .addrb(picaddr_final),
    .dia(mem_data_wr),
	 .doa(mem_data_rd0),      
	 .wea(mem_wr),
	 .ena(en_pic),
	 .clka(mem_clk),
	 .addra(mem_addr)
  );

  wire en_pic2 = (mem_addr[14:11] == 4'b0100);
  RAMB16_S9_S18 picture2 (
    .DIPA(mem_data_wr[8]),
    .DIA(mem_data_wr),
    .WEA(mem_wr),
    .ENA(en_pic2),
    .CLKA(mem_clk),
    .ADDRA(mem_addr),
    .DOPA(mem_data_rd2[8]),
    .DOA(mem_data_rd2[7:0]),
    .SSRA(0),

    .DIPB(0),
    .DIB(0),
    .WEB(0),
    .ENB(1),
    .CLKB(vga_clk),
    .ADDRB(picaddr_final),
    .DOPB(pic_out2[17:16]),
    .DOB(pic_out2[15:0]),
    .SSRB(0)
  );

  reg _picaddr_final_msb;
  always @(posedge vga_clk) _picaddr_final_msb <= picaddr_final[11];

  assign pic_out = _picaddr_final_msb ? pic_out2 : pic_out1;

  assign glyph = pic_with_attr ? (attr_ninths_are_pal_bits ? pic_out[9:0] : {pic_out[17:16], pic_out[7:0]}) : ((_picaddr0 == 0) ? {pic_out[16], pic_out[7:0]} : {pic_out[17], pic_out[15:8]});

  reg [2:0] _column;
  always @(posedge vga_clk)
    _column = column;

`ifdef SUPPORT_TEXT_MODE_TILES
  wire is_text_mode_char = TEXT_MODE_TILES_BIG_CHUNKS ? chr_text_mode_mask[glyph[8:6]] : chr_text_mode_mask[glyph[7:5]] && (glyph[8] == 0);
`else
  wire is_text_mode_char = 0; 
`endif
  wire [9:0] masked_glyph = {glyph[9] && !is_text_mode_char, glyph[8:0]};
  wire [15:0] chars_readaddr = {masked_glyph, row[2:0], _column[2], ~_column[1:0]};
  wire [1:0] charout;

  wire [7:0] attr = pic_with_attr ? (attr_ninths_are_pal_bits ? pic_out[17:10] : pic_out[15:8]) : glyph & chr_attr_mask;

  reg [9:0] _glyph;
  reg [7:0] _attr;
  reg _is_text_mode_char;
  always @(posedge vga_clk) begin
    _glyph <= glyph;
    _attr <= attr;
    _is_text_mode_char <= is_text_mode_char;
  end

  wire [4:0] bg_r;
  wire [4:0] bg_g;
  wire [4:0] bg_b;

  wire [15:0] char_matte;

  wire text_char_pixel = charout[_glyph[9]];
  wire [3:0] text_charpal_addr = text_char_pixel ? _attr[3:0] : _attr[7:4];
  wire [2:0] char_palbase_index = _is_text_mode_char ? (text_char_pixel ? 4 : 5) : 3;
  wire [9:0] charpal_addr = _is_text_mode_char ? text_charpal_addr : {_attr, charout};

  // wire [4:0] bg_mix_r = bg_color[14:10] + char_matte[14:10];
  // wire [4:0] bg_mix_g = bg_color[9:5]   + char_matte[9:5];
  // wire [4:0] bg_mix_b = bg_color[4:0]   + char_matte[4:0];
  // wire [14:0] char_final = char_matte[15] ? {bg_mix_r, bg_mix_g, bg_mix_b} : char_matte[14:0];
  // wire [14:0] char_final = char_matte[15] ? bg_color : char_matte[14:0];
  wire [15:0] char_final = char_matte;

  reg [7:0] mem_data_rd_reg;

  // Collision detection RAM is readable during vblank
  // writes coll_d to coll_w_addr during render
  wire coll_rd = (yy >= vga_height); // 1 means reading
  wire [7:0] coll_d;
  wire [7:0] coll_w_addr;
  wire coll_we;
  wire [7:0] coll_addr = coll_rd ? mem_r_addr[7:0] : coll_w_addr;
  wire [7:0] coll_o;
  ram256x8s coll(.o(coll_o), .a(coll_addr), .d(coll_d), .wclk(vga_clk), .we(~coll_rd & coll_we));
  wire [7:0] screenshot_rd;

`ifdef USE_AUDIO
  wire [7:0] voicefl_read;
  wire [7:0] voicefh_read;
  wire [7:0] voicela_read;
  wire [7:0] voicera_read;
`endif

  // Screenshot notes
  // three states, controlled by screenshot_primed, _done:
  //  primed done                         composer.A
  //  0      0     screenshot disabled    write(comp_write)
  //  1      0     screenshot primed      write(comp_write)
  //  1      1     screenshot done        read(mem_r_addr[9:1])

  reg [8:0] screenshot_yy;  // 9 bits, 0-400
  reg screenshot_primed;
  reg screenshot_done;
  wire screenshot_reset;
  wire [8:0] public_yy = coll_rd ? 300 : yy[10:1];

  always @(posedge vga_clk)
  begin
    if (screenshot_reset)
      screenshot_done <= 0;
    else if (CounterXmaxed & screenshot_primed & !screenshot_done & (public_yy == screenshot_yy)) begin
      screenshot_done <= 1;
    end
  end

  wire comm_sel = (mem_addr[14:11] == 5) && (mem_addr[10:6] == 2);

`ifdef USE_COMM1
  (* ram_style = "distributed" *) reg [7:0] comm1[0:15];
  wire [3:0] comm1_addr = mem_addr[3:0];
  wire comm1_sel = comm_sel && (mem_addr[5] == 0);
  wire [7:0] comm1_read = comm1[comm1_addr];
  always @(posedge vga_clk) if (mem_wr && comm1_sel) comm1[comm1_addr] <= mem_data_wr;
`endif
`ifdef USE_COMM2
  (* ram_style = "distributed" *) reg [7:0] comm2[0:31];
  wire [4:0] comm2_addr = mem_addr[4:0];
  wire comm2_sel = comm_sel && (mem_addr[5] == 1);
  wire [7:0] comm2_read = comm2[comm2_addr];
  always @(posedge vga_clk) if (mem_wr && comm2_sel) comm2[comm2_addr] <= mem_data_wr;
`endif

  // Shadow registers, to save LUTs compared to reading back from flip flops.
  // Works for registers that are read+write from host, read only from the Gameduino (except j1).
  // The value is stored both in flip flops, for reading by the Gameduino, and distributed RAM, for reading by host.
  // Must make sure that the two values are initialized in sync; writing will make sure that they stay in sync. 

  // Shadow registers for 0x2800 - 0x281f
  wire shadow1_sel = (mem_addr[14:11] == 5) && (mem_addr[10:5] == 0);
  wire [7:0] shadow1_read;
/*
  // Inferred distributed RAM with initializer doesn't synthesize right in ise, so we use a ram32x8s_init instead, below
  (* ram_style = "distributed" *) reg [7:0] shadow1_regs[0:31];
  initial begin : init_shadow_regs1
    integer i;
    for (i = 0; i < 32; i = i + 1) shadow1[i] = 0;
    shadow1[SHADOW1_INDEX_PIC_MODE] = INITIAL_PIC_MODE;
    shadow1[SHADOW1_INDEX_WINDOW_X1] = INITIAL_WINDOW_X1;
    shadow1[SHADOW1_INDEX_SPRITES_END] = INITIAL_SPRITES_END;
  end

  wire [4:0] shadow1_addr = mem_addr[4:0];
  assign shadow1_read = shadow1_regs[shadow1_addr];
  always @(posedge vga_clk) if (mem_wr && shadow1_sel) shadow1_regs[shadow1_addr] <= mem_data_wr;
*/

  localparam [255:0] SHADOW1_INIT = 
    {INITIAL_J1_RESET, {SHADOW1_INDEX_J1_RESET{8'b0}}} |
    {INITIAL_PIC_MODE, {SHADOW1_INDEX_PIC_MODE{8'b0}}} |
    {INITIAL_WINDOW_X1, {SHADOW1_INDEX_WINDOW_X1{8'b0}}} | 
    {INITIAL_SPRITES_END, {SHADOW1_INDEX_SPRITES_END{8'b0}}};
  ram32x8s_init #(.INIT(SHADOW1_INIT)) shadow1_regs (
    .d(mem_data_wr), .we(mem_wr && shadow1_sel), .wclk(vga_clk), .a(mem_addr[4:0]), .o(shadow1_read)
  );

  always @*
  begin
    casex (mem_r_addr[10:0])
    11'h000: mem_data_rd_reg <= 8'h6d;  // Gameduino ident
    11'h001: mem_data_rd_reg <= `REVISION;
    11'h002: mem_data_rd_reg <= frames;
    11'h003: mem_data_rd_reg <= coll_rd;  // called VBLANK, but really "is coll readable?"
/*
    // Plain rw registers: reads provided by shadow1_read below instead
    11'h004: mem_data_rd_reg <= scrollx[7:0];
    11'h005: mem_data_rd_reg <= scrollx[8 +: X_BITS-8];
    11'h006: mem_data_rd_reg <= scrolly[7:0];
    11'h007: mem_data_rd_reg <= scrolly[8];
    11'h008: mem_data_rd_reg <= jkmode;
    SHADOW1_INDEX_J1_RESET: mem_data_rd_reg <= j1_reset;

    11'h00a: mem_data_rd_reg <= sprites_base[7:0]; // spr_disable was here 
    11'h00b: mem_data_rd_reg <= sprites_base[8];   // was: spr_page; sprites_base[8] can be used the same way

    11'h00c: mem_data_rd_reg <= pin2mode;
    11'h00d: mem_data_rd_reg <= draw_mode; // contains spr_disable flag
    11'h00e: mem_data_rd_reg <= bg_color[7:0];
    11'h00f: mem_data_rd_reg <= bg_color[14:8];
`ifdef USE_PCM_AUDIO
    11'h010: mem_data_rd_reg <= sample_l[7:0];
    11'h011: mem_data_rd_reg <= sample_l[15:8];
    11'h012: mem_data_rd_reg <= sample_r[7:0];
    11'h013: mem_data_rd_reg <= sample_r[15:8];
`endif
`ifdef USE_AUDIO
    11'h014: mem_data_rd_reg <= modvoice;
`endif

    11'h016: mem_data_rd_reg <= sprites_end;
    11'h018: mem_data_rd_reg <= graphics_mode;
    11'h019: mem_data_rd_reg <= pic_mode;
    11'h01a: mem_data_rd_reg <= window_x0[7:0];
    11'h01b: mem_data_rd_reg <= window_x0[8 +: X_BITS-8];
    11'h01c: mem_data_rd_reg <= window_x1[7:0];
    11'h01d: mem_data_rd_reg <= window_x1[8 +: X_BITS-8];
*/

    11'h01e: mem_data_rd_reg <= public_yy[7:0];
    11'h01f: mem_data_rd_reg <= {screenshot_done, 6'b000000, public_yy[8]};

    // Catch-all for shadow reads
    // NOTE: All special cased reads for region 0x2800 - 0x281f must come before this in the case statement!
    11'b000000xxxxx: mem_data_rd_reg <= shadow1_read;

`ifdef USE_COMM1
    11'b000100xxxxx: mem_data_rd_reg <= comm1_read;
`endif
`ifdef USE_COMM2
    11'b000101xxxxx: mem_data_rd_reg <= comm2_read;
`endif

/*
    // Plain rw registers: reads provided as shadow reads by palbases_read below
    11'h0c0: mem_data_rd_reg <= chr_base[6:0];
    //11'h0c1: mem_data_rd_reg <= sprimg_base[6:0];
    11'h0c2: mem_data_rd_reg <= spr_palrot_mask;
`ifdef SUPPORT_8BIT_RAM_PIC
    11'h0c3: mem_data_rd_reg <= chr_attr_mask;
`endif
`ifdef SUPPORT_TEXT_MODE_TILES
    11'h0c4: mem_data_rd_reg <= chr_text_mode_mask;
`endif
`ifdef ATTR_NINTH_PAL_BITS_REG
    11'h0c5: mem_data_rd_reg <= attr_ninths_are_pal_bits;
`endif
*/

    11'h0c8: mem_data_rd_reg <= ninth_read_bits;
    11'h0c9: mem_data_rd_reg <= ninth_write_bits;

    // 11'h0c0 - 11'h0c7: Catch-all for shadow reads (stored in palbases)
    11'b00011000xxx: mem_data_rd_reg <= palbases_read;
    // 11'h0d0 - 11'h0d7
    11'b00011010xxx: mem_data_rd_reg <= palbases_read;

    11'b001xxxxxxxx:
      mem_data_rd_reg <= coll_rd ? coll_o : 8'hff;
`ifdef USE_AUDIO    
    11'b010xxxxxx00: mem_data_rd_reg <= voicefl_read;
    11'b010xxxxxx01: mem_data_rd_reg <= voicefh_read;
    11'b010xxxxxx10: mem_data_rd_reg <= voicela_read;
    11'b010xxxxxx11: mem_data_rd_reg <= voicera_read;
`endif    
    11'b011xxxxxxx0: mem_data_rd_reg <= j1insnl_read;
    11'b011xxxxxxx1: mem_data_rd_reg <= j1insnh_read;
    11'b1xxxxxxxxxx: mem_data_rd_reg <= screenshot_rd;
    // default: mem_data_rd_reg <= 0;
    endcase
  end

`ifdef USE_AUDIO    
  reg [17:0] soundcounter;
  always @(posedge vga_clk)
    soundcounter <= soundcounter + 1;
  wire [5:0] viN = soundcounter + 1;
  wire [5:0] vi = soundcounter;

  wire voice_wr = mem_wr & (mem_w_addr[14:11] == 5) & (mem_w_addr[10:8] == 3'b010);
  wire voicefl_wr = voice_wr & (mem_w_addr[1:0] == 2'b00);
  wire voicefh_wr = voice_wr & (mem_w_addr[1:0] == 2'b01);
  wire voicela_wr = voice_wr & (mem_w_addr[1:0] == 2'b10);
  wire voicera_wr = voice_wr & (mem_w_addr[1:0] == 2'b11);

  wire [7:0] voicela_data;
  wire [7:0] voicera_data;
  wire [7:0] voicefl_data;
  wire [7:0] voicefh_data;
  wire [5:0] voice_addr = mem_addr[7:2];

  ram64x8d voicefl(
    .a(voice_addr),
    .wclk(mem_clk),
    .wea(voicefl_wr),
    .ad(mem_data_wr),
    .ao(voicefl_read),
    .b(viN),
    .bo(voicefl_data));

  ram64x8d voicefh(
    .a(voice_addr),
    .wclk(mem_clk),
    .wea(voicefh_wr),
    .ad(mem_data_wr),
    .ao(voicefh_read),
    .b(viN),
    .bo(voicefh_data));

  ram64x8d voicela(
    .a(voice_addr),
    .wclk(mem_clk),
    .wea(voicela_wr),
    .ad(mem_data_wr),
    .ao(voicela_read),
    .b(viN),
    .bo(voicela_data));

  ram64x8d voicera(
    .a(voice_addr),
    .wclk(mem_clk),
    .wea(voicera_wr),
    .ad(mem_data_wr),
    .ao(voicera_read),
    .b(viN),
    .bo(voicera_data));
`endif    

  assign screenshot_reset = mem_wr & (mem_w_addr[14:11] == 5) & (mem_w_addr[10:0] == 11'h01f);
  wire mem_reg_wr = (mem_wr && mem_w_addr[14:11] == 5); 
  always @(posedge mem_clk)
  begin
    if (mem_reg_wr) begin
      casex (mem_w_addr[10:0])
      11'h004: scrollx[7:0]   <= mem_data_wr;
      11'h005: scrollx[8 +: X_BITS-8] <= mem_data_wr;
      11'h006: scrolly[7:0]   <= mem_data_wr;
      11'h007: scrolly[8]     <= mem_data_wr;
      11'h008: jkmode         <= mem_data_wr;
      SHADOW1_INDEX_J1_RESET: j1_reset <= mem_data_wr;

      11'h00a: sprites_base[7:0] <= mem_data_wr; // spr_disable was here
      11'h00b: sprites_base[8] <= mem_data_wr;   // was: spr_page; sprites_base[8] can be used the same way 
      
      11'h00c: pin2mode       <= mem_data_wr;
      11'h00d: draw_mode      <= mem_data_wr;  // contains spr_disable flag
      11'h00e: bg_color[7:0]  <= mem_data_wr;
      11'h00f: bg_color[14:8] <= mem_data_wr;
`ifdef USE_PCM_AUDIO
      11'h010: sample_l[7:0]  <= mem_data_wr;
      11'h011: sample_l[15:8] <= mem_data_wr;
      11'h012: sample_r[7:0]  <= mem_data_wr;
      11'h013: sample_r[15:8] <= mem_data_wr;
`endif
`ifdef USE_AUDIO
      11'h014: modvoice       <= mem_data_wr;
`endif

      11'h016: sprites_end    <= mem_data_wr;
      11'h018: graphics_mode  <= mem_data_wr;
      11'h019: pic_mode       <= mem_data_wr;
      11'h01a: window_x0[7:0] <= mem_data_wr;
      11'h01b: window_x0[8 +: X_BITS-8] <= mem_data_wr;
      11'h01c: window_x1[7:0] <= mem_data_wr;
      11'h01d: window_x1[8 +: X_BITS-8] <= mem_data_wr;

      11'h01e: screenshot_yy[7:0] <= mem_data_wr;
      11'h01f: begin screenshot_primed <= mem_data_wr[7];
               screenshot_yy[8] <= mem_data_wr; end

      PALBASES_SHADOW_INDEX_CHR_BASE: chr_base[6:0] <= mem_data_wr;
      //11'h0c1: sprimg_base[6:0]  <= mem_data_wr;
      11'h0c2: spr_palrot_mask <= mem_data_wr;
`ifdef SUPPORT_8BIT_RAM_PIC
      PALBASES_SHADOW_INDEX_CHR_ATTR_MASK: chr_attr_mask <= mem_data_wr;
`endif
`ifdef SUPPORT_TEXT_MODE_TILES
      11'h0c4: chr_text_mode_mask <= mem_data_wr;
`endif
`ifdef ATTR_NINTH_PAL_BITS_REG
      PALBASES_SHADOW_INDEX_ATTR_NINTH_PB: attr_ninths_are_pal_bits <= mem_data_wr;
`endif

      //11'h0c8: ninth_read_bits   <= mem_data_wr; // handled below
      11'h0c9: ninth_write_bits  <= mem_data_wr;

      // 11'h0d0 - 11'h0d7: in palbases
      endcase
    end else begin
      // When writing from host to a non-register, ninth_write_bits[0] is used to fill in the 9th bit; shift it out
      if (host_mem_wr && (!_host_mem_wr || mem_addr_changed)) ninth_write_bits <= ninth_write_bits >> 1;      
    end

    if (mem_reg_wr && mem_w_addr[10:0] == 11'h0c8) ninth_read_bits <= mem_data_wr;
    else if (_host_mem_rd_ram && (!__host_mem_rd_ram || _mem_addr_changed)) ninth_read_bits <= {mem_data_rd[8], ninth_read_bits[7:1]}; // Ram read previous cycle, shift the 9:th bit into ninth_read_bits.
  end

  /*
    0000-0fff Picture
    1000-1fff Character
    2000-27ff Character
    2800-2fff (Unused)
    3000-37ff Sprite values
    3800-3fff Sprite palette
    4000-7fff Sprite image
  */
  always @*
  begin
    case (mem_addr[14:11]) // 2K pages
    MEM_PAGE_ADDR_RAM_PIC + 4'h0: mem_data_rd <= mem_data_rd0;  // pic
    MEM_PAGE_ADDR_RAM_PIC + 4'h1: mem_data_rd <= mem_data_rd0;
    MEM_PAGE_ADDR_RAM_CHR + 4'h0: mem_data_rd <= mem_data_rd1;  // chr
    MEM_PAGE_ADDR_RAM_CHR + 4'h1: mem_data_rd <= mem_data_rd1;
    4'h4: mem_data_rd <= mem_data_rd2;  // pal
    4'h5: mem_data_rd <= mem_data_rd_reg;
    4'h6: mem_data_rd <= mem_data_rd3;  // sprval
    4'h7: mem_data_rd <= mem_data_rd4;  // sprpal
    4'h8: mem_data_rd <= mem_data_rd5;  // sprimg
    4'h9: mem_data_rd <= mem_data_rd5;  // sprimg
    4'ha: mem_data_rd <= mem_data_rd5;  // sprimg
    4'hb: mem_data_rd <= mem_data_rd5;  // sprimg
    4'hc: mem_data_rd <= mem_data_rd5;  // sprimg
    4'hd: mem_data_rd <= mem_data_rd5;  // sprimg
    4'he: mem_data_rd <= mem_data_rd5;  // sprimg
    4'hf: mem_data_rd <= mem_data_rd5;  // sprimg

    default: mem_data_rd <= 8'h97;
    endcase
  end

  // Sprite memory

  // Stage 1: scan for valid
  reg [8:0] sprite_scan_index;

  wire en_sprval = (mem_addr[14:11] == 4'b0110);
  wire [35:0] sprval_data;

`ifdef RAM_SPRVAL_INFERRED
  RAM_SPRVAL_inferred sprval(
`else
  RAM_SPRVAL sprval(
`endif
    .DIA(mem_data_wr),
    .WEA(mem_wr),
    .ENA(en_sprval),
    .CLKA(mem_clk),
    .ADDRA(mem_addr),
    .DOA(mem_data_rd3),
    .SSRA(0),

    .DIB(0),
    .WEB(0),
    .ENB(1),
    .CLKB(vga_clk),
    .ADDRB(sprite_scan_index),
    .DOB(sprval_data),
    .SSRB(0)
  );
  wire [9:0] sprpal_addr;
  wire [2:0] spr_palbase_index;
  wire [15:0] sprpal_data;
  wire en_sprpal = (mem_addr[14:11] == 4'b0111);

  wire [9:0] pal_addr0 = bg_active[2] ? charpal_addr : sprpal_addr;
  wire [2:0] palbase_index = bg_active[2] ? char_palbase_index : spr_palbase_index;
  assign palbases_addr = palbase_index;
  wire [9:0] pal_addr = pal_addr0 + {palbases_out, 2'b0};

  RAM_SPRPAL sprpal(
    .DIA(mem_data_wr),
    .WEA(mem_wr),
    .ENA(en_sprpal),
    .CLKA(mem_clk),
    .ADDRA(mem_addr),
    .DOA(mem_data_rd4),
    .SSRA(0),

    .DIB(0),
    .WEB(0),
    .ENB(1),
    .CLKB(vga_clk),
    .ADDRB(pal_addr),
    .DOB(sprpal_data),
    .SSRB(0)
  );
  assign char_matte = sprpal_data;

  wire [13:0] sprimg_readaddr;

  //wire [14:0] pixel_readaddr = bg_active[1] ? (chars_readaddr >> 2) + {chr_base, 8'b0} : sprimg_readaddr + {sprimg_base, 8'b0};
  wire [14:0] pixel_readaddr = bg_active[1] ? (chars_readaddr >> 2) + {chr_base, 8'b0} : sprimg_readaddr;

  wire en_chr = (mem_addr[14:12] == (MEM_PAGE_ADDR_RAM_CHR >> 1));
  wire [7:0] chars_out;
  RAM_CHR8 chars(
    .dia(0), .doa(chars_out), .wea(0), .ena(1), .clka(vga_clk), .addra(pixel_readaddr),
    .dib(mem_data_wr), .dob(mem_data_rd1), .web(mem_wr), .enb(en_chr), .clkb(mem_clk), .addrb(mem_addr));

  wire [7:0] sprimg_data;
  wire [7:0] sprimg_out;
  wire en_sprimg = (mem_addr[14] == 1'b1);
//  ram16K_8_8 sprimg(
  RAM_SPRIMG sprimg(
    .dia(mem_data_wr),
    .wea(mem_wr),
    .ena(en_sprimg),
    .clka(mem_clk),
    .addra(mem_addr),
    .doa(mem_data_rd5),
    .ssra(0),

    .dib(0),
    .web(0),
    .enb(1),
    .clkb(vga_clk),
    .addrb(pixel_readaddr),
    .dob(sprimg_out),
    .ssrb(0)
  );

  reg [1:0] _chars_readaddr01;
  reg _pixel_readaddr14;
  always @(posedge vga_clk) begin
    _chars_readaddr01 <= chars_readaddr[1:0];
    _pixel_readaddr14 <= pixel_readaddr[14];
  end

  wire [7:0] pixel_out = _pixel_readaddr14 ? chars_out : sprimg_out; 
  assign charout = pixel_out[2*(_chars_readaddr01) +: 2];
  assign sprimg_data = pixel_out;


  // Stage 1: scan for valid

  reg s1_consider;      // Consider the sprval on the next cycle
  wire s2_room;         // Does s2 fifo have room for one entry?
  always @(posedge vga_clk)
  begin
    if (start_sprite_scan) begin
      sprite_scan_index <= sprites_base;
      sprite_scan_active <= 1;
      s1_consider <= 0;
    end else
      if (sprite_scan_active & s2_room) begin
        if (sprite_scan_index[7:0] == sprites_end) sprite_scan_active <= 0;
        sprite_scan_index <= sprite_scan_index + 1;
        s1_consider <= 1;
      end else begin
        s1_consider <= 0;
      end
  end
  wire [35:0] s1_out = sprval_data;

  wire [8:0] s1_sprite_y = sprite_10bit_x ? {s1_out[23:16] >= 256-16, s1_out[23:16]} : s1_out[24:16];

  wire [8:0] s1_y_offset = yy[9:1] - s1_sprite_y;
  wire s1_visible = (spr_disable == 0) & (s1_y_offset[8:4] == 0);
  wire s1_valid = s1_consider & s1_visible;
  reg [8:0] s1_id;
  always @(posedge vga_clk)
    s1_id <= sprite_scan_index;

  // Stage 2: fifo
  wire [4:0] s2_fullness;
  wire s3_read;
  wire [44:0] s2_out;
  fifo #(44) s2(.clk(vga_clk),
                .wr(s1_valid), .datain({s1_id, s1_out}),
                .rd(s3_read), .dataout(s2_out),
                .fullness(s2_fullness));
  assign s2_room = (s2_fullness < 14);

  wire s2_valid = s2_fullness != 0;

  // 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
  //    [     image     ] [          y             ]       [PAL] [  ROT ] [           x            ]

  /* Stage 3: read sprimg
    consume s2_out on last cycle 
    out: s3_valid, s3_pal, s3_out, s3_compaddr
  */

  reg [4:0] s3_state;
  reg [3:0] s3_pal;
  reg [3:0] s3_pal_extra;
  reg [2:0] s3_rot;
  reg [35:0] s3_in;
  assign s3_read = (s3_state == 15);
  always @(posedge vga_clk)
  begin
    if (!sprite_draw_enabled || bg_active[3])
      s3_state <= 16;
    else if (s3_state == 16) begin
      if (s2_valid) begin
        s3_state <= 0;
        s3_in <= s2_out;
      end
    end else begin
      s3_state <= s3_state + 1;
    end
    s3_pal <= s2_out[15:12];
    s3_pal_extra <= s2_out[35:32];
    s3_rot <= s2_out[11:9];
  end
  wire [3:0] s3_yoffset = yy[4:1] - s2_out[19:16];
  wire [3:0] s3_prev_state = (s3_state == 16) ? 0 : (s3_state + 1);

  wire [3:0] s2_pal = s2_out[15:12];
  wire [2:0] s2_rot = s2_out[11:9] & ~(s2_pal[3] ? spr_palrot_mask[2:0] : ((s2_pal[3:2] == 0) ? 0 : spr_palrot_mask[3]));

  wire s2_flip_d = s2_rot[0];
  wire s2_flip_x = ROT_FORMAT_HVD ? s2_rot[2] : s2_rot[1];
  wire s2_flip_y = ROT_FORMAT_HVD ? s2_rot[1] : s2_rot[2];

  wire [3:0] readx = (s2_flip_d ? s3_yoffset : s3_prev_state) ^ {4{s2_flip_x}};
  wire [3:0] ready = (s2_flip_d ? s3_prev_state : s3_yoffset) ^ {4{s2_flip_y}};

  assign sprimg_readaddr = {s2_out[30:25], ready, readx};
  wire [7:0] s3_out = sprimg_data;

  wire [X_BITS-1:0] s3_sprite_x = sprite_10bit_x ? {s2_out[24], s2_out[8:0]} : {s2_out[8:0] >= 512 - 16, s2_out[8:0]};

  wire [X_BITS-1:0] s3_compaddr = s3_sprite_x + s3_state;  
  wire s3_valid = (s3_state != 16) && (s3_compaddr >= window_x0) && (s3_compaddr <= window_x1);
  reg [8:0] s3_id;
  reg s3_jk;
  always @(posedge vga_clk)
  begin
    s3_id <= s2_out[44:36];
    s3_jk <= s2_out[31];
  end

  /* Stage 4: read sprpal
    out: s4_valid, s4_out, s4_compaddr
  */
  reg [15:0] sprpal4;
  reg [15:0] sprpal16;
  reg [X_BITS-1:0] s4_compaddr;
  reg s4_valid;
  reg [8:0] s4_id;
  reg s4_jk;
  wire [3:0] subfield4 = s3_pal[1] ? s3_out[7:4] : s3_out[3:0];
  wire [1:0] subfield2 = s3_pal[2] ? (s3_pal[1] ? s3_out[7:6] : s3_out[5:4]) : (s3_pal[1] ? s3_out[3:2] : s3_out[1:0]);

  wire [9:0] sprpal_addr_256 = {s3_pal[1:0], s3_out} + {s3_pal_extra, 4'b0000};
  wire [9:0] sprpal_addr_16  = {s3_rot[0] & spr_palrot_mask[3], s3_pal_extra, s3_pal[0], subfield4};
  wire [9:0] sprpal_addr_4   = {s3_rot & spr_palrot_mask[2:0],  s3_pal_extra, s3_pal[0], subfield2};

  assign sprpal_addr = s3_pal[3] ? sprpal_addr_4 : ((s3_pal[3:2] == 0) ? sprpal_addr_256 : sprpal_addr_16);
  assign spr_palbase_index = s3_pal[3] ? 0 : ((s3_pal[3:2] == 0) ? 2 : 1);

  always @(posedge vga_clk)
  begin
    s4_compaddr <= s3_compaddr;
    s4_valid <= s3_valid;
    s4_id <= s3_id;
    s4_jk <= s3_jk;
  end
  wire [15:0] s4_out = sprpal_data;

  assign sprite_draw_active = (sprite_draw_enabled && (sprite_scan_active || s1_consider || s2_valid)) || (s3_state != 16) || s4_valid;

  // Common signals for collision and composite
  wire sprite_write = s4_valid & !s4_out[15];  // transparency

  // Collision detect
  // Have 400x9 occupancy buffer.  If NEW overwrites a fragment OLD
  // (and their groups differ) write OLD to coll[NEW].
  // Reset coll to FF at start of frame.
  // Reset occ to FF at start of line, since sprites drawn 0->ff,
  // ff is impossible and means empty.

  wire coll_scrub = (yy == 0) & (comp_workcnt < 256);
  wire [X_BITS-1:0] occ_addr = bg_active[0] ? comp_workcnt : s4_compaddr;
  wire [8:0] occ_d = bg_active[0] ? 9'hff : {s4_jk, s4_id[7:0]};
  wire [8:0] oldocc;
  wire occ_w = bg_active[0] | sprite_write;
  ram400x9s occ(.o(oldocc), .a(occ_addr), .d(occ_d), .wclk(vga_clk), .we(occ_w));
  assign coll_d = coll_scrub ? 8'hff : oldocc[7:0];
  assign coll_w_addr = coll_scrub ? comp_workcnt : s4_id[7:0];
  // old contents 0xff, never write
  // jkmode=1 and JK's differ, allow write
  wire overwriting = (oldocc[7:0] != 8'hff);
  wire jkpass = (jkmode == 0) | (oldocc[8] ^ s4_jk);
  assign coll_we = coll_scrub | (!bg_active[3] & sprite_write & overwriting & jkpass);

  // Composite

  wire comp_read = yy[1];   // which block is reading
  wire comp_last_read = yy[0];

  //wire [X_BITS-1:0] comp_scanout = (xx >> widen_output) >> 1;
  reg [X_BITS-1:0] comp_scanout;
  reg [1:0] comp_scanout_frac;
  wire inc_comp_scanout = widen_output ? (comp_scanout_frac == 3) : (comp_scanout_frac[0] == 1);
  reg comp_scanout_updated;
  always @(posedge vga_clk) begin
    if (CounterXmaxed) begin
      comp_scanout <= 0;
      comp_scanout_updated <= 1;
      comp_scanout_frac <= 0;
    end else begin
      if (inc_comp_scanout) begin
        comp_scanout <= comp_scanout + 1;
        comp_scanout_frac <= 0;
      end else begin
        comp_scanout_frac <= comp_scanout_frac + 1;
      end
      comp_scanout_updated <= inc_comp_scanout; 
    end
  end

  wire [X_BITS-1:0] comp_write = bg_active[3] ? comp_workcnt_m3 : s4_compaddr;
  wire comp_part1 = bg_active[3];
`ifdef NELLY
  wire [14:0] comp_out0;
  wire [14:0] comp_out1;
  RAMB16_S18_S18 composer(
    .DIPA(0),
    .DIA(comp_part1 ? char_final : s4_out),
    .WEA(comp_read == 1 & (comp_part1 | sprite_write)),
    .ENA(1),
    .CLKA(vga_clk),
    .ADDRA({1'b0, (comp_read == 0) ? comp_scanout[8:0] : comp_write[8:0]}),
    .DOA(comp_out0),
    .SSRA(0),

    .DIPB(0),
    .DIB(comp_part1 ? char_final : s4_out),
    .WEB(comp_read == 0 & (comp_part1 | sprite_write)),
    .ENB(1),
    .CLKB(vga_clk),
    .ADDRB({1'b1, (comp_read == 1) ? comp_scanout[8:0] : comp_write[8:0]}),
    .DOB(comp_out1),
    .SSRB(0)
  );
  wire [14:0] comp_out = comp_read ? comp_out1 : comp_out0;
`else
  wire ss = screenshot_primed & screenshot_done;  // screenshot readout mode
  wire [15:0] screenshot_rdHL;
  wire [14:0] comp_out;
  wire [14:0] comp_out_bram;
  wire [15:0] comp_in = comp_part1 ? char_final : s4_out; 
  wire composer_we = !ss && (comp_part1 | sprite_write) && (comp_in[15] == 0);
  // Port A is the write, or read when screenshot is ready
  // Port B is scanout
  RAMB16_S18_S18 #(.WRITE_MODE_B("READ_FIRST"))
  composer (
    .DIPA(0),
    .DIA(comp_in),
    .WEA(composer_we && !comp_write[9]),
    .ENA(1),
    .CLKA(vga_clk),
    .ADDRA(ss ? {screenshot_yy[0], mem_r_addr[9:1]} : {comp_read, comp_write[8:0]}),
    .DOA(screenshot_rdHL),
    .SSRA(0),

    .DIPB(0),
    .DIB(bg_color),
    .WEB(comp_last_read),
    .ENB(comp_scanout_updated),
    .CLKB(vga_clk),
    .ADDRB({!comp_read, comp_scanout[8:0]}),
    .DOB(comp_out_bram),
    .SSRB(0)
  );
  assign screenshot_rd = mem_r_addr[0] ? screenshot_rdHL[15:8] : screenshot_rdHL[7:0];

  generate
  if (WIDE_LINE_BUFFER) begin
    reg [14:0] comp_out_d;
    (* ram_style = "distributed" *) reg [14:0] composer_2a[0:127];
    (* ram_style = "distributed" *) reg [14:0] composer_2b[0:127];
    wire composer_2_we = composer_we && comp_write[9] && (comp_write[8:7] == 0);
    wire composer_2_erase_we = !comp_scanout_updated && comp_last_read && comp_scanout[9]; 
    wire [6:0] comp_2a_addr =  comp_read ? comp_scanout        : comp_write; 
    wire [14:0] comp_2a_in =   comp_read ? bg_color            : comp_in;
    wire comp_2a_we =          comp_read ? composer_2_erase_we : composer_2_we;  
    wire [6:0] comp_2b_addr = !comp_read ? comp_scanout        : comp_write;
    wire [14:0] comp_2b_in =  !comp_read ? bg_color            : comp_in;
    wire comp_2b_we =         !comp_read ? composer_2_erase_we : composer_2_we;  
    always @(posedge vga_clk) begin
      if (comp_2a_we) composer_2a[comp_2a_addr] <= comp_2a_in;
      if (comp_2b_we) composer_2b[comp_2b_addr] <= comp_2b_in;

      if (comp_scanout_updated) comp_out_d <= comp_read ? composer_2a[comp_2a_addr] : composer_2b[comp_2b_addr];
    end

    reg _comp_scanout9;
    always @(posedge vga_clk) _comp_scanout9 <= comp_scanout[9];

    assign comp_out = _comp_scanout9 ? comp_out_d : comp_out_bram;
  end else begin
    assign comp_out = comp_out_bram;
  end
  endgenerate

`endif
  assign {bg_r,bg_g,bg_b} = comp_out;

  // Figure out from above signals when composite completes
  // by detecting pipeline idle
  wire composite_complete = !bg_active[0] && !bg_active[4] && !sprite_draw_active;

  // Signal generation

  wire [16:0] lfsr;
  lfsre lfsr0(
    .clk(vga_clk),
    .lfsr(lfsr));

  wire [1:0] dith;
  // 0 2
  // 3 1
  assign dith = {(xx[widen_output]^yy[0]), yy[0]};
  wire [5:0] dith_r = (bg_r + dith);
  wire [5:0] dith_g = (bg_g + dith);
  wire [5:0] dith_b = (bg_b + dith);
  wire [2:0] f_r = {3{dith_r[5]}} | dith_r[4:2];
  wire [2:0] f_g = {3{dith_g[5]}} | dith_g[4:2];
  wire [2:0] f_b = {3{dith_b[5]}} | dith_b[4:2];

  wire [2:0] ccc = { charout[1], charout[0], charout[0] };
  assign vga_red =    vga_active ? f_r : 0;
  assign vga_green =  vga_active ? f_g : 0;
  assign vga_blue =   vga_active ? f_b : 0;
  assign vga_hsync = vga_HS;
  assign vga_vsync = vga_VS;

`ifdef USE_AUDIO
  /*
  An 18-bit counter, multiplied by the frequency gives a single bit
  pulse that advances the voice's wave counter.
  Frequency of 4 means 1Hz, 16385 means 4095.75Hz.
  18-bit counter increments every 1/(2**18), or 262144 Hz.
  */
`define MASTERFREQ (1 << 22)
  reg [27:0] d;
  wire [27:0] dInc = d[27] ? (`MASTERFREQ) : (`MASTERFREQ - 50000000);
  wire [27:0] dN = d + dInc;

  reg [16:0] soundmaster;   // This increments at MASTERFREQ Hz
  always @(posedge vga_clk)
  begin
    d = dN;
    // clock B tick whenever d[27] is zero
    if (dN[27] == 0) begin
      soundmaster <= soundmaster + 1;
    end
  end

  wire [6:0] hsin;
  wire [6:0] wavecounter;
  wire [6:0] note = wavecounter[6:0];

`ifdef YES
RAM64X1S #(.INIT(64'b0000000000110101100010001111010010010111100010001101011000000000) /* 0 */
) sin0(.O(hsin[0]), .A0(note[0]), .A1(note[1]), .A2(note[2]), .A3(note[3]), .A4(note[4]), .A5(note[5]), .D(0), .WCLK(vga_clk), .WE(0));
RAM64X1S #(.INIT(64'b0101010101101100011100010101001111100101010001110001101101010101) /* 1 */
) sin1(.O(hsin[1]), .A0(note[0]), .A1(note[1]), .A2(note[2]), .A3(note[3]), .A4(note[4]), .A5(note[5]), .D(0), .WCLK(vga_clk), .WE(0));
RAM64X1S #(.INIT(64'b0110011001001001010101001100111111111001100101010100100100110011) /* 2 */
) sin2(.O(hsin[2]), .A0(note[0]), .A1(note[1]), .A2(note[2]), .A3(note[3]), .A4(note[4]), .A5(note[5]), .D(0), .WCLK(vga_clk), .WE(0));
RAM64X1S #(.INIT(64'b0010110100100100110011000011111111111110000110011001001001011010) /* 3 */
) sin3(.O(hsin[3]), .A0(note[0]), .A1(note[1]), .A2(note[2]), .A3(note[3]), .A4(note[4]), .A5(note[5]), .D(0), .WCLK(vga_clk), .WE(0));
RAM64X1S #(.INIT(64'b0001110011100011110000111111111111111111111000011110001110011100) /* 4 */
) sin4(.O(hsin[4]), .A0(note[0]), .A1(note[1]), .A2(note[2]), .A3(note[3]), .A4(note[4]), .A5(note[5]), .D(0), .WCLK(vga_clk), .WE(0));
RAM64X1S #(.INIT(64'b0000001111100000001111111111111111111111111111100000001111100000) /* 5 */
) sin5(.O(hsin[5]), .A0(note[0]), .A1(note[1]), .A2(note[2]), .A3(note[3]), .A4(note[4]), .A5(note[5]), .D(0), .WCLK(vga_clk), .WE(0));
RAM64X1S #(.INIT(64'b0000000000011111111111111111111111111111111111111111110000000000) /* 6 */
) sin6(.O(hsin[6]), .A0(note[0]), .A1(note[1]), .A2(note[2]), .A3(note[3]), .A4(note[4]), .A5(note[5]), .D(0), .WCLK(vga_clk), .WE(0));
`else
ROM64X1 #(.INIT(64'b0000000000110101100010001111010010010111100010001101011000000000) /* 0 */) sin0(.O(hsin[0]), .A0(note[0]), .A1(note[1]), .A2(note[2]), .A3(note[3]), .A4(note[4]), .A5(note[5]));
ROM64X1 #(.INIT(64'b0101010101101100011100010101001111100101010001110001101101010101) /* 1 */) sin1(.O(hsin[1]), .A0(note[0]), .A1(note[1]), .A2(note[2]), .A3(note[3]), .A4(note[4]), .A5(note[5]));
ROM64X1 #(.INIT(64'b0110011001001001010101001100111111111001100101010100100100110011) /* 2 */) sin2(.O(hsin[2]), .A0(note[0]), .A1(note[1]), .A2(note[2]), .A3(note[3]), .A4(note[4]), .A5(note[5]));
ROM64X1 #(.INIT(64'b0010110100100100110011000011111111111110000110011001001001011010) /* 3 */) sin3(.O(hsin[3]), .A0(note[0]), .A1(note[1]), .A2(note[2]), .A3(note[3]), .A4(note[4]), .A5(note[5]));
ROM64X1 #(.INIT(64'b0001110011100011110000111111111111111111111000011110001110011100) /* 4 */) sin4(.O(hsin[4]), .A0(note[0]), .A1(note[1]), .A2(note[2]), .A3(note[3]), .A4(note[4]), .A5(note[5]));
ROM64X1 #(.INIT(64'b0000001111100000001111111111111111111111111111100000001111100000) /* 5 */) sin5(.O(hsin[5]), .A0(note[0]), .A1(note[1]), .A2(note[2]), .A3(note[3]), .A4(note[4]), .A5(note[5]));
ROM64X1 #(.INIT(64'b0000000000011111111111111111111111111111111111111111110000000000) /* 6 */) sin6(.O(hsin[6]), .A0(note[0]), .A1(note[1]), .A2(note[2]), .A3(note[3]), .A4(note[4]), .A5(note[5]));
`endif

  wire signed [7:0] sin = note[6] ? (8'h00 - hsin) : hsin;

  wire voiceshape = voicefh_data[7];
  wire [14:0] voicefreq = {voicefh_data[6:0], voicefl_data};

  wire [35:0] derived = {1'b0, soundmaster} * voicefreq;

  wire highfreq = voicefreq[14];
  wire newpulse = highfreq ? derived[18] : derived[17]; // pulse is a square wave frequency 64*f
  wire oldpulse;
  wire [6:0] nextwavecounter = voiceshape ? lfsr : (wavecounter + (highfreq ? 2 : 1));
  wire [6:0] _wavecounter = (newpulse != oldpulse) ? nextwavecounter : wavecounter;

`ifdef NELLY
  ram64x8s voicestate(
    .a(viN),
    .we(1),
    .wclk(vga_clk),
    .d({_wavecounter, newpulse}),
    .o({wavecounter, oldpulse}));
`else
  wire [8:0] vsi = {_wavecounter, newpulse};
  wire [8:0] vso;
  ring64 vs0(.clk(vga_clk), .i(vsi[0]), .o(vso[0]));
  ring64 vs1(.clk(vga_clk), .i(vsi[1]), .o(vso[1]));
  ring64 vs2(.clk(vga_clk), .i(vsi[2]), .o(vso[2]));
  ring64 vs3(.clk(vga_clk), .i(vsi[3]), .o(vso[3]));
  ring64 vs4(.clk(vga_clk), .i(vsi[4]), .o(vso[4]));
  ring64 vs5(.clk(vga_clk), .i(vsi[5]), .o(vso[5]));
  ring64 vs6(.clk(vga_clk), .i(vsi[6]), .o(vso[6]));
  ring64 vs7(.clk(vga_clk), .i(vsi[7]), .o(vso[7]));
  assign wavecounter = vso[7:1];
  assign oldpulse = vso[0];
`endif

  wire signed [8:0] lamp = voicela_data;
  wire signed [8:0] ramp = voicera_data;
  reg signed [35:0] lmodulated;
  reg signed [35:0] rmodulated;
  always @(posedge vga_clk)
  begin
    lmodulated = lamp * sin;
    rmodulated = ramp * sin;
  end

  // Have lmodulated and rmodulated

  reg signed [15:0] lacc;
  reg signed [15:0] racc;
  wire signed [15:0] lsum = lacc + lmodulated[15:0];
  wire signed [15:0] rsum = racc + rmodulated[15:0];
  wire signed [31:0] lprod = lacc * lmodulated;
  wire signed [31:0] rprod = racc * rmodulated;
  wire zeroacc = (vi == 63);
  wire [15:0] _lacc = zeroacc ? sample_l : ((vi == modvoice) ? lprod[30:15] : lsum);
  wire [15:0] _racc = zeroacc ? sample_r : ((vi == modvoice) ? rprod[30:15] : rsum);
  reg signed [12:0] lvalue;
  reg signed [12:0] rvalue;
  always @(posedge vga_clk)
  begin
    if (vi == 63) begin
      lvalue <= lsum[15:3] /* + sample_l + 32768 */;
      rvalue <= rsum[15:3] /* + sample_r + 32768 */;
    end
    lacc <= _lacc;
    racc <= _racc;
  end

  wire signed [7:0] dither = soundcounter;
//  wire [15:0] dither = {soundcounter[0],
//                       soundcounter[1],
//                       soundcounter[2],
//                       soundcounter[3],
//                       soundcounter[4],
//                       soundcounter[5],
//                       soundcounter[6],
//                       soundcounter[7],
//                       soundcounter[8],
//                       soundcounter[9],
//                       soundcounter[10],
//                       soundcounter[11],
//                       soundcounter[12],
//                       soundcounter[13],
//                       soundcounter[14],
//                       soundcounter[15]
//                       };
`endif // USE_AUDIO

`ifdef USE_PCM_AUDIO
`ifndef USE_AUDIO
  wire [12:0] lvalue = sample_l[15:3];
  wire [12:0] rvalue = sample_r[15:3];
`endif
`ifdef NELLY
  wire lau_out = lvalue >= dither;
  wire rau_out = rvalue >= dither;

  assign AUDIOL = lau_out;
  assign AUDIOR = rau_out;
`else
  wire [12:0] ulvalue = lvalue ^ 4096;
  wire [12:0] urvalue = rvalue ^ 4096;
  dac ldac(AUDIOL, ulvalue, vga_clk, 0);
  dac rdac(AUDIOR, urvalue, vga_clk, 0);
`endif
`else // USE_PCM_AUDIO
  assign AUDIOL = 0;
  assign AUDIOR = 0;
`endif // USE_PCM_AUDIO

  reg [2:0] busyhh;
  always @(posedge vga_clk) busyhh = { busyhh[1:0], host_busy };

  // J1 Peripherals
  reg [7:0] icap_i;   // ICAP in
  reg icap_write;
  reg icap_ce;
  reg icap_clk;

  wire [7:0] icap_o;  // ICAP out
  wire  icap_busy;

  reg j1_p2_dir = 1;    // pin defaults to input
  reg j1_p2_o = 1;

  ICAP_SPARTAN3A ICAP_SPARTAN3A_inst (
    .O(icap_o),
    .BUSY(icap_busy),
    .I(icap_i),
    .WRITE(icap_write),
    .CE(icap_ce),
    .CLK(icap_clk));

  reg dna_read;
  reg dna_shift;
  reg dna_clk;
  wire dna_dout;
  DNA_PORT dna(
    .DOUT(dna_dout),
    .DIN(0),
    .READ(dna_read),
    .SHIFT(dna_shift),
    .CLK(dna_clk));

  wire j1_wr;

  reg [8:0] YYLINE;
  wire [9:0] yyline = (CounterY + 4 - vga_active_y0);
  always @(posedge vga_clk)
  begin
    // if (xx == 400)
    if (composite_complete)
      YYLINE = yyline[9:1];
  end

  reg [15:0] freqhz = 8000;
  reg [7:0] freqtick;

  reg [26:0] freqd;
  wire [26:0] freqdN = freqd + freqhz - (freqd[26] ? 0 : 50000000);
  always @(posedge vga_clk)
  begin
    freqd = freqdN;
    if (freqd[26] == 0)
      freqtick = freqtick + 1;
  end

  reg [15:0] local_j1_read;
  always @*
  begin
    case ({j1_mem_addr[4:1], 1'b0})
    5'h00: local_j1_read <= YYLINE;
    5'h02: local_j1_read <= icap_o;
    5'h0c: local_j1_read <= freqtick;
    5'h0e: local_j1_read <= AUX;
    5'h12: local_j1_read <= lfsr;
`ifdef USE_AUDIO        
    5'h14: local_j1_read <= soundcounter;
`endif    
    5'h16: local_j1_read <= flashMISO;
    5'h18: local_j1_read <= dna_dout;

    // default: local_j1_read <= 16'hffff;
    endcase
  end

  wire [0:7] j1_mem_dout_be = j1_mem_dout;

  wire [4:0] local_j1_addr = {j1_mem_addr[4:1], 1'b0};
  wire local_j1_we = j1_wr && (j1_mem_addr[15] == 1);  
  always @(posedge vga_clk)
  begin
    if (local_j1_we)
      case (local_j1_addr)
      // 5'h06: icap_i <= j1_mem_dout;
      // 5'h08: icap_write <= j1_mem_dout;
      // 5'h0a: icap_ce <= j1_mem_dout;
      // 5'h0c: icap_clk <= j1_mem_dout;
      5'h06: {icap_write,icap_ce,icap_clk,icap_i} <= j1_mem_dout;
      5'h08: {dna_read, dna_shift, dna_clk} <= j1_mem_dout;
      5'h0a: freqhz <= j1_mem_dout;
      5'h0e: j1_p2_o <= j1_mem_dout;
      5'h10: j1_p2_dir <= j1_mem_dout;
      5'h18: j1_flashMOSI <= j1_mem_dout;
      5'h1a: j1_flashSCK <= j1_mem_dout;
      5'h1c: j1_flashSSEL <= j1_mem_dout;
      // 5'h1e: j1_draw_control_reg, see below
      endcase
  end
  reg [3:0] j1_draw_control_reg = 0;
  always @(posedge vga_clk) begin
    if (local_j1_we && (local_j1_addr == 5'h1e)) begin
      j1_draw_control_reg <= j1_mem_dout;
    end else begin
      j1_draw_control_reg[0] <= 0; // j1_start_draw is a strobe
      if (composite_complete && !j1_start_draw) j1_draw_control_reg[1] <= 0; // wait for drawing finished
      if (start_draw_line) j1_draw_control_reg[2] <= 0; // wait for new line
      if (frame_finish) j1_draw_control_reg[3] <= 0; // wait for frame finished
    end
  end
  assign j1_start_draw = j1_draw_control_reg[0];
  wire j1_wait = |j1_draw_control_reg[3:1];

  assign j1_mem_wr = j1_wr & (j1_mem_addr[15] == 0);
  wire j1_pause = host_busy || (busyhh != 0) || j1_wait;
  wire j1_wr_out;
  assign j1_wr = j1_wr_out && !j1_pause; 

  j0 j(.sys_clk_i(vga_clk),
       .sys_rst_i(j1_reset),
       .insn(j1_insn),
       .insn_addr(j1_insn_addr),
       .mem_wr(j1_wr_out),
       .mem_addr(j1_mem_addr),
       .mem_dout(j1_mem_dout),
       .mem_din(j1_mem_addr[15] ? local_j1_read : mem_data_rd),
       .pause(j1_pause)
       );

  // 0x2b00: j1 insn RAM
  wire jinsn_wr = (mem_wr & (mem_w_addr[14:8] == 6'h2b));
  RAM_CODEL jinsnl(.b(j1_insn_addr), .bo(j1_insn[7:0]),
    .a(mem_addr[7:1]),
    .wclk(vga_clk),
    .wea((mem_w_addr[0] == 0) & jinsn_wr),
    .ad(mem_data_wr),
    .ao(j1insnl_read));
  RAM_CODEH jinsnh(.b(j1_insn_addr), .bo(j1_insn[15:8]),
    .a(mem_addr[7:1]),
    .wclk(vga_clk),
    .wea((mem_w_addr[0] == 1) & jinsn_wr),
    .ad(mem_data_wr),
    .ao(j1insnh_read));

  assign AUX_tristate = (pin2j & (j1_p2_dir == 0)) ? 0 : 1;
  assign AUX_out = j1_p2_o;
  assign AUX = AUX_tristate ? AUX_in : AUX_out;

endmodule // top
