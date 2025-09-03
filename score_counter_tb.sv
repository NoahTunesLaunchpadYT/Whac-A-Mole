`timescale 1ms/1ps
module score_counter_tb;

    // Parameters
    localparam int MAX_SCORE = 9999;
    localparam int SCORE_WIDTH = $clog2(MAX_SCORE);

    // DUT signals
    logic clk;
    logic rst;
    logic [6:0] combo_count;
    logic [SCORE_WIDTH-1:0] score_count;

    // Instantiate DUT
    score_counter #(.MAX_SCORE(MAX_SCORE)) DUT (
        .clk(clk),
        .rst(rst),
        .combo_count(combo_count),
        .score_count(score_count)
    );

    // Clock generation: toggle every 1ns
    initial clk = 0;
    always #1 clk = ~clk;

    // Stimulus
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, score_counter_tb);

        // Initial reset
        rst = 1;
        combo_count = 0;
        @(posedge clk);
        rst = 0;

        // Apply stimulus
        repeat (2000) begin
            @(posedge clk);
            combo_count = combo_count + 1;

            // Wrap combo counter manually
            if (combo_count == 100)
                combo_count = 0;
            
            if (score_count == 10000)
                score_count = 0;

            // Apply reset mid-way
            if ((score_count > 2000)) begin
                rst = 1;
            end
            if (combo_count > 90) begin
                rst = 0;
            end

            // Log values
            $display("%0t: score = %0d, combo_count = %0d, reset status = %b", $time, score_count, combo_count, rst);
        end

        $finish;
    end

endmodule



