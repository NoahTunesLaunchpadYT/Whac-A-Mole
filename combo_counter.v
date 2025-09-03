module combo_counter(
    input         clk,                  // DE2-115's 50MHz clock signal
    input         miss,                 // HIGH if a mole has been missed or incorrectly hit
    input         non_full_clear_hit,   // HIGH if a mole has been hit (not the last mole on the board)
    input         full_clear_hit,       // HIGH if the mole hit was the last one on the boards
    input         reset,                // HIGH when restarting the game - clears the current count
    output [6:0]  combo_val             // The current combo count value
	);
    reg [6:0] reg_combo_val = 0;
    localparam max_combo = 7'd99;
	 
    always @(posedge clk) begin
        if (reset || miss) begin
            reg_combo_val <= 7'd0;
        end
        else if (full_clear_hit) begin
            reg_combo_val <= ((reg_combo_val + 7'd2) > max_combo) ? max_combo : reg_combo_val + 7'd2;
        end
        else if (non_full_clear_hit) begin
            reg_combo_val <= ((reg_combo_val + 7'd1) > max_combo) ? max_combo : reg_combo_val + 7'd1;
        end
    end

    assign combo_val = reg_combo_val;
endmodule
