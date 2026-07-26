// Self-checking testbench for counter8
`timescale 1ns/1ps
module counter8_tb;

    reg        clk;
    reg        rst_n;
    reg        en;
    wire [7:0] count;

    integer errors = 0;

    counter8 dut (.clk(clk), .rst_n(rst_n), .en(en), .count(count));

    always #5 clk = ~clk;  // 100 MHz

    task check(input [7:0] expected, input [127:0] label);
        begin
            if (count !== expected) begin
                $display("FAIL [%0s]: count=%0d expected=%0d @%0t", label, count, expected, $time);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        clk = 0; rst_n = 0; en = 0;

        // Async reset holds count at 0
        #12 check(8'd0, "reset");

        // Release reset mid-cycle; en=0 so count holds
        rst_n = 1;
        @(negedge clk); @(negedge clk);
        check(8'd0, "hold_en0");

        // Enable: count increments each cycle
        en = 1;
        @(negedge clk); check(8'd1, "inc1");
        @(negedge clk); check(8'd2, "inc2");
        @(negedge clk); check(8'd3, "inc3");

        // Disable: holds value
        en = 0;
        @(negedge clk); @(negedge clk);
        check(8'd3, "hold_mid");

        // Re-enable and run to wraparound: 3 -> 255 needs 252 cycles, +1 wraps to 0
        en = 1;
        repeat (252) @(negedge clk);
        check(8'd255, "max");
        @(negedge clk); check(8'd0, "wrap");
        @(negedge clk); check(8'd1, "post_wrap");

        // Async reset asserted away from clock edge (mid-cycle, en=1)
        #2 rst_n = 0;
        #1 check(8'd0, "async_reset_immediate");
        #4 rst_n = 1;  // release mid clock-high phase, away from any edge
        @(negedge clk); check(8'd0, "zero_after_release");
        @(negedge clk); check(8'd1, "resume_after_reset");

        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TEST(S) FAILED", errors);
        $finish;
    end

endmodule
