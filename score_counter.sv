`timescale 1ns/1ps

module score_counter #(
    parameter int MAX_SCORE = 9999,
    parameter int MAX_score_increase = 99
)(
    input   logic                                   clk,
    input   logic                                   rst,
    input   logic   [$clog2(MAX_score_increase)-1:0]score_increase,
    output  logic   [$clog2(MAX_SCORE)-1:0]         score_count
);

    logic [$clog2(MAX_score_increase)-1:0] score_increase_prev;

//    initial begin
//        score_count = '0;
//        score_increase_prev = '0;
//    end

    always_ff @(posedge clk) begin
        if (rst) begin
            score_count <= '0;
            score_increase_prev <= '0;
        end
        else begin
				
            if (score_increase != score_increase_prev) begin
					 score_increase_prev <= score_increase;
                score_count <= score_count + {{($clog2(MAX_SCORE)-$clog2(MAX_score_increase)){1'b0}},score_increase};  
            end
				
        end 
    end

endmodule
