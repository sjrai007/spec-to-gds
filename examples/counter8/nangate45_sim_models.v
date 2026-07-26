// Behavioral models for the Nangate45 cells used in counter8_final.v.
// Functions taken verbatim from Nangate45_typ.lib.
module INV_X1 (input A, output ZN);          assign ZN = !A;                  endmodule
module BUF_X1 (input A, output Z);           assign Z = A;                    endmodule
module BUF_X4 (input A, output Z);           assign Z = A;                    endmodule
module AND4_X1 (input A1, A2, A3, A4, output ZN); assign ZN = A1 & A2 & A3 & A4; endmodule
module NAND2_X1 (input A1, A2, output ZN);   assign ZN = !(A1 & A2);          endmodule
module NAND3_X1 (input A1, A2, A3, output ZN); assign ZN = !(A1 & A2 & A3);   endmodule
module NAND4_X1 (input A1, A2, A3, A4, output ZN); assign ZN = !(A1 & A2 & A3 & A4); endmodule
module NOR2_X1 (input A1, A2, output ZN);    assign ZN = !(A1 | A2);          endmodule
module XOR2_X1 (input A, B, output Z);       assign Z = A ^ B;                endmodule
module XNOR2_X1 (input A, B, output ZN);     assign ZN = !(A ^ B);            endmodule
module MUX2_X1 (input A, B, S, output Z);    assign Z = (S & B) | (A & !S);   endmodule

module DFFR_X1 (input D, RN, CK, output reg Q, output QN);
    assign QN = ~Q;
    always @(posedge CK or negedge RN)
        if (!RN) Q <= 1'b0;
        else     Q <= D;
endmodule

// Physical-only cells (no logic)
module TAPCELL_X1 ();    endmodule
module FILLCELL_X1 ();   endmodule
module FILLCELL_X2 ();   endmodule
module FILLCELL_X4 ();   endmodule
module FILLCELL_X8 ();   endmodule
module FILLCELL_X16 ();  endmodule
module FILLCELL_X32 ();  endmodule
