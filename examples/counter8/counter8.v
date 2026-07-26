// 8-bit binary up-counter
// - clk:   clock input
// - rst_n: asynchronous, active-low reset (count -> 0 immediately)
// - en:    synchronous enable (increment on rising clk edge when en=1)
// - count: 8-bit registered output (wraps 255 -> 0)
module counter8 (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       en,
    output reg  [7:0] count
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 8'd0;
        else if (en)
            count <= count + 8'd1;
    end

endmodule
