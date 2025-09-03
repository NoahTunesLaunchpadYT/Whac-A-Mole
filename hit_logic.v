`timescale 1ns/1ns 
/* This directive (`) specifies simulation <time unit>/<time precision>. */

module hit_logic #(
	parameter NUM_HOLES = 18
)	(
	input clk,
	input [NUM_HOLES - 1 : 0] mole_positions,
	input [NUM_HOLES - 1 : 0] switches,
	input game_in_progress,
		
	output reg [NUM_HOLES - 1 : 0] LEDs,
	output reg miss,
	output reg non_full_clear_hit,
	output reg full_clear_hit
);			
	reg [NUM_HOLES - 1 : 0] next_leds = {NUM_HOLES{1'b0}};				// LED states next clk cycle
	reg [NUM_HOLES - 1 : 0] prev_switch_states = {NUM_HOLES{1'b0}}; 	// Switch state in previous clk cycle
	reg prev_moles_up = 1'b0;		// In MOLE_UP state in previous clk cycle
	reg hit_flag = 1'b0;				// Async pulse to indicate hit happened
	reg miss_flag = 1'b0; 			// Async pulse to indicate miss happened
	reg sync_switches = {NUM_HOLES{1'b0}};
	
	// Check if we're current in the MOLE_UP state
	wire moles_up_state = (mole_positions != {NUM_HOLES{1'b0}});
	
	// For for loop
	integer i;
	
	// Combinational logic
	always @* begin
		// Detect hits and misses
		hit_flag = 1'b0;
		miss_flag = 1'b0;
		next_leds = LEDs;
		
		// Get the next LED state according to mole_positions
		if (!prev_moles_up && moles_up_state) begin				// If rising edge
			next_leds = mole_positions;									// Turn on moles
		end
		else if (prev_moles_up && !moles_up_state) begin		// If falling edge
			next_leds = {NUM_HOLES{1'b0}}; 								// Turn off all LEDS
		end

		for (i = 0; i < NUM_HOLES; i = i + 1) begin
			// If switches have been flipped
			if (switches[i] != prev_switch_states[i]) begin				
				// Check to see if a mole was there
				if (LEDs[i]) begin
					hit_flag = 1'b1;
					next_leds[i] = 1'b0;
				end 
				else begin
					miss_flag = 1'b1;
				end
			end
		end
	end
	
	always @(posedge clk) begin
		// Set previous values for edge detection 
		prev_moles_up <= moles_up_state;
		prev_switch_states <= switches;
		
		if (game_in_progress) begin
			// Update outputs
			LEDs <= next_leds;
			
			// Sending hit signals
			if (hit_flag) begin
				if (next_leds=={NUM_HOLES{1'b0}}) begin			// If there are no more moles after this hit
					full_clear_hit <= 1'b1;
					non_full_clear_hit <= 1'b0;
				end 
				else begin 
					full_clear_hit <= 1'b0;
					non_full_clear_hit <= 1'b1;
				end
			end
			else begin 
				full_clear_hit <= 1'b0;
				non_full_clear_hit <= 1'b0;
			end
			
			// Sending miss signals
			if (miss_flag) begin
				miss <= 1'b1;
			end
			else begin
				miss <= 1'b0;
			end
		end
		else begin 
			// When game is not in progress (game over)
			LEDs <= {NUM_HOLES{1'b0}};				// Turn off all LEDs
			prev_moles_up <= 1'b0; // Pretend that we're in a mole down state
			full_clear_hit <= 1'b0;						// Output nothing
			non_full_clear_hit <= 1'b0;
			miss <= 1'b0;
		end 
	end
endmodule
