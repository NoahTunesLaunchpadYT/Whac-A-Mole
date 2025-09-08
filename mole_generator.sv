module mole_generator #(
    parameter NUM_MOLES = 3,
    parameter NUM_HOLES = 18
) (
    input clk,
    input mole_clk,
    output reg [NUM_HOLES-1:0] mole_positions
);
	wire [$clog2(NUM_HOLES) - 1 : 0] mole_position1;
	wire [$clog2(NUM_HOLES) - 1 : 0] mole_position2;
	wire [$clog2(NUM_HOLES) - 1 : 0] mole_position3;
	wire [$clog2(NUM_HOLES) - 1 : 0] mole_positions_array [NUM_MOLES];
	reg prev_mole_clk = 0;
 
//	assign mole_position1 = mole_positions_array[0];
//	assign mole_position2 = mole_positions_array[1];
//	assign mole_position3 = mole_positions_array[2];




	genvar i;
	generate
		for (i=0; i<NUM_MOLES; i=i+1) begin: rng_modules_generation
			rng #(
				 .OFFSET(0),
				 .MAX_VALUE(NUM_HOLES-1),
				 .SEED(123+(i*5))
			) u_rng (
				 .clk(clk),
				 .random_value(mole_positions_array[i])
			);
		end
	endgenerate

	always_ff @(posedge clk) begin
		prev_mole_clk <= mole_clk;
		mole_positions <= {NUM_HOLES{1'b0}};
		if ((prev_mole_clk == 0) && (mole_clk == 1)) begin
			for (int j = 0; j < NUM_MOLES; j++) begin
				mole_positions[mole_positions_array[j]] <= 1'b1;\
			end
		end

		else if ((prev_mole_clk == 1) && (mole_clk == 0)) begin
			mole_positions <= {NUM_HOLES{1'b0}};
		end
		else begin
			mole_positions <= mole_positions;
		end
	end
	
endmodule
