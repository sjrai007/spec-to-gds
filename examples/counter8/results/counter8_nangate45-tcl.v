module counter8 (clk,
    en,
    rst_n,
    count,
    VDD,
    VSS);
 input clk;
 input en;
 input rst_n;
 output [7:0] count;
 inout VDD;
 inout VSS;

 wire _00_;
 wire _01_;
 wire _02_;
 wire _03_;
 wire _04_;
 wire _05_;
 wire _06_;
 wire _07_;
 wire _08_;
 wire _09_;
 wire _10_;
 wire _11_;
 wire _12_;
 wire _13_;
 wire _14_;
 wire _15_;
 wire _17_;
 wire _18_;
 wire _19_;
 wire _20_;
 wire _21_;
 wire _22_;
 wire _23_;
 wire clknet_0_clk;
 wire clknet_1_0__leaf_clk;
 wire clknet_1_1__leaf_clk;
 wire net1;
 wire net2;
 wire net3;
 wire net4;
 wire net5;
 wire net6;
 wire [0:0] _16_;

 TAPCELL_X1 PHY_EDGE_ROW_0_Left_24 ();
 TAPCELL_X1 PHY_EDGE_ROW_0_Right_0 ();
 TAPCELL_X1 PHY_EDGE_ROW_10_Left_34 ();
 TAPCELL_X1 PHY_EDGE_ROW_10_Right_10 ();
 TAPCELL_X1 PHY_EDGE_ROW_11_Left_35 ();
 TAPCELL_X1 PHY_EDGE_ROW_11_Right_11 ();
 TAPCELL_X1 PHY_EDGE_ROW_12_Left_36 ();
 TAPCELL_X1 PHY_EDGE_ROW_12_Right_12 ();
 TAPCELL_X1 PHY_EDGE_ROW_13_Left_37 ();
 TAPCELL_X1 PHY_EDGE_ROW_13_Right_13 ();
 TAPCELL_X1 PHY_EDGE_ROW_14_Left_38 ();
 TAPCELL_X1 PHY_EDGE_ROW_14_Right_14 ();
 TAPCELL_X1 PHY_EDGE_ROW_15_Left_39 ();
 TAPCELL_X1 PHY_EDGE_ROW_15_Right_15 ();
 TAPCELL_X1 PHY_EDGE_ROW_16_Left_40 ();
 TAPCELL_X1 PHY_EDGE_ROW_16_Right_16 ();
 TAPCELL_X1 PHY_EDGE_ROW_17_Left_41 ();
 TAPCELL_X1 PHY_EDGE_ROW_17_Right_17 ();
 TAPCELL_X1 PHY_EDGE_ROW_18_Left_42 ();
 TAPCELL_X1 PHY_EDGE_ROW_18_Right_18 ();
 TAPCELL_X1 PHY_EDGE_ROW_19_Left_43 ();
 TAPCELL_X1 PHY_EDGE_ROW_19_Right_19 ();
 TAPCELL_X1 PHY_EDGE_ROW_1_Left_25 ();
 TAPCELL_X1 PHY_EDGE_ROW_1_Right_1 ();
 TAPCELL_X1 PHY_EDGE_ROW_20_Left_44 ();
 TAPCELL_X1 PHY_EDGE_ROW_20_Right_20 ();
 TAPCELL_X1 PHY_EDGE_ROW_21_Left_45 ();
 TAPCELL_X1 PHY_EDGE_ROW_21_Right_21 ();
 TAPCELL_X1 PHY_EDGE_ROW_22_Left_46 ();
 TAPCELL_X1 PHY_EDGE_ROW_22_Right_22 ();
 TAPCELL_X1 PHY_EDGE_ROW_23_Left_47 ();
 TAPCELL_X1 PHY_EDGE_ROW_23_Right_23 ();
 TAPCELL_X1 PHY_EDGE_ROW_2_Left_26 ();
 TAPCELL_X1 PHY_EDGE_ROW_2_Right_2 ();
 TAPCELL_X1 PHY_EDGE_ROW_3_Left_27 ();
 TAPCELL_X1 PHY_EDGE_ROW_3_Right_3 ();
 TAPCELL_X1 PHY_EDGE_ROW_4_Left_28 ();
 TAPCELL_X1 PHY_EDGE_ROW_4_Right_4 ();
 TAPCELL_X1 PHY_EDGE_ROW_5_Left_29 ();
 TAPCELL_X1 PHY_EDGE_ROW_5_Right_5 ();
 TAPCELL_X1 PHY_EDGE_ROW_6_Left_30 ();
 TAPCELL_X1 PHY_EDGE_ROW_6_Right_6 ();
 TAPCELL_X1 PHY_EDGE_ROW_7_Left_31 ();
 TAPCELL_X1 PHY_EDGE_ROW_7_Right_7 ();
 TAPCELL_X1 PHY_EDGE_ROW_8_Left_32 ();
 TAPCELL_X1 PHY_EDGE_ROW_8_Right_8 ();
 TAPCELL_X1 PHY_EDGE_ROW_9_Left_33 ();
 TAPCELL_X1 PHY_EDGE_ROW_9_Right_9 ();
 INV_X1 _24_ (.A(count[6]),
    .ZN(_08_));
 NAND2_X1 _25_ (.A1(count[0]),
    .A2(en),
    .ZN(_09_));
 NAND3_X1 _26_ (.A1(count[0]),
    .A2(count[1]),
    .A3(en),
    .ZN(_10_));
 AND4_X1 _27_ (.A1(count[0]),
    .A2(count[1]),
    .A3(count[2]),
    .A4(en),
    .ZN(_11_));
 NAND2_X1 _28_ (.A1(count[3]),
    .A2(_11_),
    .ZN(_12_));
 NAND3_X1 _29_ (.A1(count[3]),
    .A2(count[4]),
    .A3(_11_),
    .ZN(_13_));
 NAND4_X1 _30_ (.A1(count[3]),
    .A2(count[4]),
    .A3(count[5]),
    .A4(_11_),
    .ZN(_14_));
 NOR2_X1 _31_ (.A1(_08_),
    .A2(_14_),
    .ZN(_15_));
 XNOR2_X1 _32_ (.A(count[6]),
    .B(_14_),
    .ZN(_00_));
 XNOR2_X1 _33_ (.A(count[5]),
    .B(_13_),
    .ZN(_01_));
 XNOR2_X1 _34_ (.A(count[4]),
    .B(_12_),
    .ZN(_02_));
 XOR2_X1 _35_ (.A(count[3]),
    .B(_11_),
    .Z(_03_));
 XNOR2_X1 _36_ (.A(count[2]),
    .B(_10_),
    .ZN(_04_));
 XNOR2_X1 _37_ (.A(count[1]),
    .B(_09_),
    .ZN(_05_));
 MUX2_X1 _38_ (.A(count[0]),
    .B(_16_[0]),
    .S(en),
    .Z(_06_));
 XOR2_X1 _39_ (.A(count[7]),
    .B(_15_),
    .Z(_07_));
 DFFR_X1 _40_ (.D(_06_),
    .RN(net3),
    .CK(clknet_1_0__leaf_clk),
    .Q(count[0]),
    .QN(_16_[0]));
 DFFR_X1 _41_ (.D(_05_),
    .RN(net3),
    .CK(clknet_1_0__leaf_clk),
    .Q(count[1]),
    .QN(_18_));
 DFFR_X1 _42_ (.D(_04_),
    .RN(net3),
    .CK(clknet_1_0__leaf_clk),
    .Q(count[2]),
    .QN(_19_));
 DFFR_X1 _43_ (.D(_03_),
    .RN(net3),
    .CK(clknet_1_0__leaf_clk),
    .Q(count[3]),
    .QN(_20_));
 DFFR_X1 _44_ (.D(_02_),
    .RN(net3),
    .CK(clknet_1_1__leaf_clk),
    .Q(count[4]),
    .QN(_21_));
 DFFR_X1 _45_ (.D(_01_),
    .RN(net3),
    .CK(clknet_1_1__leaf_clk),
    .Q(count[5]),
    .QN(_22_));
 DFFR_X1 _46_ (.D(_00_),
    .RN(net3),
    .CK(clknet_1_1__leaf_clk),
    .Q(count[6]),
    .QN(_23_));
 DFFR_X1 _47_ (.D(_07_),
    .RN(net3),
    .CK(clknet_1_1__leaf_clk),
    .Q(count[7]),
    .QN(_17_));
 BUF_X4 clkbuf_0_clk (.A(clk),
    .Z(clknet_0_clk));
 BUF_X4 clkbuf_1_0__f_clk (.A(clknet_0_clk),
    .Z(clknet_1_0__leaf_clk));
 BUF_X4 clkbuf_1_1__f_clk (.A(clknet_0_clk),
    .Z(clknet_1_1__leaf_clk));
 BUF_X1 hold1 (.A(net5),
    .Z(net1));
 BUF_X1 hold2 (.A(net4),
    .Z(net2));
 BUF_X1 hold3 (.A(net6),
    .Z(net3));
 BUF_X1 hold4 (.A(rst_n),
    .Z(net4));
 BUF_X1 hold5 (.A(net2),
    .Z(net5));
 BUF_X1 hold6 (.A(net1),
    .Z(net6));
endmodule
