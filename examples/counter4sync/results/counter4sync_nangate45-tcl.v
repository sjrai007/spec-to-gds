module counter4sync (clk,
    en,
    rst,
    count,
    VDD,
    VSS);
 input clk;
 input en;
 input rst;
 output [3:0] count;
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
 wire _12_;
 wire _13_;
 wire _14_;
 wire clknet_0_clk;
 wire clknet_1_0__leaf_clk;
 wire clknet_1_1__leaf_clk;
 wire [0:0] _11_;

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
 INV_X1 _15_ (.A(_11_[0]),
    .ZN(_04_));
 NOR2_X1 _16_ (.A1(en),
    .A2(count[0]),
    .ZN(_05_));
 AOI211_X1 _17_ (.A(rst),
    .B(_05_),
    .C1(en),
    .C2(_04_),
    .ZN(_00_));
 AND3_X1 _18_ (.A1(en),
    .A2(count[1]),
    .A3(count[0]),
    .ZN(_06_));
 AOI21_X1 _19_ (.A(count[1]),
    .B1(count[0]),
    .B2(en),
    .ZN(_07_));
 NOR3_X1 _20_ (.A1(rst),
    .A2(_06_),
    .A3(_07_),
    .ZN(_01_));
 AND4_X1 _21_ (.A1(count[2]),
    .A2(en),
    .A3(count[1]),
    .A4(count[0]),
    .ZN(_08_));
 XNOR2_X1 _22_ (.A(count[3]),
    .B(_08_),
    .ZN(_09_));
 NOR2_X1 _23_ (.A1(rst),
    .A2(_09_),
    .ZN(_02_));
 NOR2_X1 _24_ (.A1(count[2]),
    .A2(_06_),
    .ZN(_10_));
 NOR3_X1 _25_ (.A1(rst),
    .A2(_08_),
    .A3(_10_),
    .ZN(_03_));
 DFF_X1 _26_ (.D(_00_),
    .CK(clknet_1_0__leaf_clk),
    .Q(count[0]),
    .QN(_11_[0]));
 DFF_X1 _27_ (.D(_01_),
    .CK(clknet_1_1__leaf_clk),
    .Q(count[1]),
    .QN(_14_));
 DFF_X1 _28_ (.D(_03_),
    .CK(clknet_1_1__leaf_clk),
    .Q(count[2]),
    .QN(_12_));
 DFF_X1 _29_ (.D(_02_),
    .CK(clknet_1_0__leaf_clk),
    .Q(count[3]),
    .QN(_13_));
 BUF_X4 clkbuf_0_clk (.A(clk),
    .Z(clknet_0_clk));
 BUF_X4 clkbuf_1_0__f_clk (.A(clknet_0_clk),
    .Z(clknet_1_0__leaf_clk));
 BUF_X4 clkbuf_1_1__f_clk (.A(clknet_0_clk),
    .Z(clknet_1_1__leaf_clk));
endmodule
