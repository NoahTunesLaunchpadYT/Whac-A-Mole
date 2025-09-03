module mole_generator #(
    parameter NUMBER_OF_MOLES = 3,
    parameter NUMBER_OF_HOLES = 18
) (
    input clk,
    input mole_clk,
    output reg [NUMBER_OF_HOLES-1:0] mole_positions,
	 output reg [$clog2(NUMBER_OF_HOLES) - 1 : 0] mole_position1,
	 output reg [$clog2(NUMBER_OF_HOLES) - 1 : 0] mole_position2,
	 output reg [$clog2(NUMBER_OF_HOLES) - 1 : 0] mole_position3
);

	wire [$clog2(NUMBER_OF_HOLES) - 1 : 0] mole_positions_array [NUMBER_OF_MOLES];
	reg prev_mole_clk;
 
	assign mole_position1 = mole_positions_array[0];
	assign mole_position2 = mole_positions_array[1];
	assign mole_position3 = mole_positions_array[2];

	genvar i;
	generate
		for (i = 0; i < NUMBER_OF_MOLES; i = i + 1) begin : rng_modules_generation
			rng #(
				 .OFFSET(0),
				 .MAX_VALUE(NUMBER_OF_HOLES - 1),
				 .SEED(123 + (i * 5))
			) u_rng (
				 .clk(clk),
				 .random_value(mole_positions_array[i])
			);
		end
	endgenerate

	always_ff @(posedge clk) begin
		prev_mole_clk <= mole_clk;

		if ((prev_mole_clk == 0) && (mole_clk == 1)) begin
			for (int j = 0; j < NUMBER_OF_MOLES; j++) begin
				 mole_positions[mole_positions_array[j]] <= 1'b1;
			end
		end
		else if ((prev_mole_clk == 1) && (mole_clk == 0)) begin
			mole_positions <= {NUMBER_OF_HOLES{1'b0}};
		end
		else begin
			mole_positions <= mole_positions;
		end
	end
endmodule
    