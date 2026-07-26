// Self-checking testbench for counter4sync.
// Checks: sync reset (including that a mid-cycle rst assert does NOT reset until the
// next posedge), rst priority over en, en-gated increment, hold, 15->0 wraparound.
`timescale 1ns/1ps
module counter4sync_tb;

    reg        clk = 0;
    reg        rst = 0;
    reg        en  = 0;
    wire [3:0] count;
    integer    errors = 0;
    integer    i;

    counter4sync dut (.clk(clk), .rst(rst), .en(en), .count(count));

    always #5 clk = ~clk;   // 10 ns period, posedges at 5, 15, 25, ...

    task check(input [3:0] expected, input [127:0] label);
        begin
            if (count !== expected) begin
                $display("FAIL [%0t] %0s: count=%b expected=%b", $time, label, count, expected);
                errors = errors + 1;
            end
        end
    endtask

    // Drive inputs away from clock edges (on negedge) to avoid races.
    initial begin
        // --- 1. Reset from unknown state ---
        @(negedge clk); rst = 1; en = 0;
        @(negedge clk); check(4'd0, "reset clears count");
        @(negedge clk); check(4'd0, "reset holds count at 0");

        // --- 2. Release reset, en=0: hold at 0 ---
        rst = 0;
        @(negedge clk); check(4'd0, "en=0 holds after reset release");

        // --- 3. Enable: increment each cycle ---
        en = 1;
        for (i = 1; i <= 5; i = i + 1) begin
            @(negedge clk); check(i[3:0], "increment");
        end

        // --- 4. Hold: en=0 freezes value ---
        en = 0;
        @(negedge clk); check(4'd5, "hold cycle 1");
        @(negedge clk); check(4'd5, "hold cycle 2");

        // --- 5. Reset is SYNCHRONOUS: assert rst mid-low-phase; count must be
        //        unchanged until the next posedge ---
        en = 1;
        @(negedge clk);            // count now 6 (posedge just passed? no: en set at negedge)
        check(4'd6, "resume increment");
        #2 rst = 1;                // mid-cycle, between edges
        #1 check(4'd6, "sync rst: no effect before clock edge");
        @(negedge clk); check(4'd0, "sync rst: cleared on the clock edge");

        // --- 6. rst has priority over en (both high) ---
        @(negedge clk); check(4'd0, "rst priority over en");
        rst = 0;

        // --- 7. Count 0 -> 15 -> wraparound to 0 ---
        for (i = 1; i <= 15; i = i + 1) begin
            @(negedge clk); check(i[3:0], "count up to 15");
        end
        @(negedge clk); check(4'd0, "wraparound 15->0");
        @(negedge clk); check(4'd1, "count continues after wrap");

        // --- 8. One-cycle reset pulse mid-count, then resume ---
        rst = 1;
        @(negedge clk); check(4'd0, "mid-count reset");
        rst = 0;
        @(negedge clk); check(4'd1, "resume after mid-count reset");

        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TEST(S) FAILED", errors);
        $finish;
    end

endmodule
