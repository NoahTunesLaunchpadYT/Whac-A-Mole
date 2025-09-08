`timescale 1ms/1ps
module score_counter_tb;

    // Parameters
    localparam int MAX_SCORE = 9999;
    localparam int SCORE_WIDTH = $clog2(MAX_SCORE);

    // DUT signals
    logic clk;
    logic rst;
    logic [6:0] score_increase;
    logic [SCORE_WIDTH-1:0] score_count;

    // Instantiate DUT
    score_counter #(.MAX_SCORE(MAX_SCORE)) DUT (
        .clk(clk),
        .rst(rst),
        .score_increase(score_increase),
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
        score_increase = 0;
        @(posedge clk);
        rst = 0;

        // Apply stimulus
        repeat (2000) begin
            @(posedge clk);
            score_increase = score_increase + 1;

            // Wrap combo counter manually
            if (score_increase == 100)
                score_increase = 0;
            
            if (score_count == 10000)
                score_count = 0;

            // Apply reset mid-way
            if ((score_count > 2000)) begin
                rst = 1;
            end
            if (score_increase > 90) begin
                rst = 0;
            end

            // Log values
            $display("%0t: score = %0d, score_increase = %0d, reset status = %b", $time, score_count, score_increase, rst);
        end

        $finish;
    end

endmodule



