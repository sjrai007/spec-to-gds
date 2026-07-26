// counter4sync: 4-bit synchronous binary up-counter.
// - synchronous active-high reset (rst): clears count on the clk edge, priority over en
// - synchronous enable (en): count increments on posedge clk only when en=1 and rst=0
// - holds value when en=0 (and rst=0)
module counter4sync (
    input  wire       clk,
    input  wire       rst,
    input  wire       en,
    output reg  [3:0] count
);

    always @(posedge clk) begin
        if (rst)
            count <= 4'd0;
        else if (en)
            count <= count + 4'd1;
    end

endmodule
