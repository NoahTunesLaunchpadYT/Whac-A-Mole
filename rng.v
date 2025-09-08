module rng #(
   parameter OFFSET = 200,
   parameter MAX_VALUE = 1223,
   parameter SEED = 10'b0000000001 // Random number seed
) (
   input clk,
   output [$clog2(MAX_VALUE)-1:0] random_value // 11-bits for values 200 to 1223.
);
   reg [10:1] lfsr; // The 10-bit Linear Feedback Shift Register

   // Initialise the shift reg to SEED, 
   initial lfsr = SEED;

	// Feedback:
	wire feedback;
   assign feedback = lfsr[10] ^ lfsr[7];

   // Shift left from bit 1 (LSB) towards bit 10 (MSB).
   always @(posedge clk) begin
		lfsr <= {lfsr[9:1], feedback};
   end

   assign random_value = (lfsr % MAX_VALUE) + OFFSET;

endmodule

