`timescale 1ns/1ps

module score_counter #(
    parameter int MAX_SCORE = 9999,
    parameter int MAX_COMBO_COUNT = 99
)(
    input   logic                                   clk,
    input   logic                                   rst,
    input   logic   [$clog2(MAX_COMBO_COUNT)-1:0]   combo_count,
    output  logic   [$clog2(MAX_SCORE)-1:0]         score_count
);

    logic [$clog2(MAX_COMBO_COUNT)-1:0] combo_count_prev;

    initial begin
        score_count = '0;
        combo_count_prev = '0;
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            score_count <= '0;
            combo_count_prev <= '0;
        end
        else begin
            if (combo_count != combo_count_prev) begin
                combo_count_prev <= combo_count;
                score_count <= score_count + {{($clog2(MAX_SCORE)-$clog2(MAX_COMBO_COUNT)){1'b0}},combo_count};  
            end
        end 
    end

endmodule
