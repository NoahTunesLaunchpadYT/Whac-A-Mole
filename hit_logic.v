`timescale 1ns/1ns 
/* This directive (`) specifies simulation <time unit>/<time precision>. */

module hit_logic #(
	parameter NUM_HOLES = 18,
	parameter DEBOUNCE_DELAY = 2500
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
	// Synchronized switches - these are the ones to use in your logic
	wire [NUM_HOLES - 1 : 0] switches_sync;

	// Generate synchronizers for each switch (Adding synchronisation doesn't seem to do anything)
	genvar j;
	generate
	  for (j = 0; j < NUM_HOLES; j = j + 1) begin : sync_gen
			debounce #(.DELAY_COUNTS(DEBOUNCE_DELAY)) switch_sync (
				 .clk(clk),
				 .button(switches[j]),        // Raw switch input
				 .button_pressed(switches_sync[j])    // Synchronized output
			);
	  end
	endgenerate

	reg [NUM_HOLES - 1 : 0] next_leds = {NUM_HOLES{1'b0}};				// LED states next clk cycle
	reg [NUM_HOLES - 1 : 0] prev_switch_states = {NUM_HOLES{1'b0}}; 	// Switch state in previous clk cycle
	reg prev_moles_up = 1'b0;		// In MOLE_UP state in previous clk cycle
	reg hit_flag = 1'b0;				// Async pulse to indicate hit happened
	reg miss_flag = 1'b0; 			// Async pulse to indicate miss happened
	
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
			next_leds = mole_positions;								// Turn on moles
		end
		else if (prev_moles_up && !moles_up_state) begin		// If falling edge
			if (next_leds != {NUM_HOLES{1'b0}}) begin				// If there were some LEDs still on...
				miss_flag = 1'b1;											// Count that as a miss
			end
			next_leds = {NUM_HOLES{1'b0}}; 							// Turn off all LEDS
		end

		for (i = 0; i < NUM_HOLES; i = i + 1) begin
			// If synchronous switches have been flipped
			if (switches_sync[i] != prev_switch_states[i]) begin	// If you hit a hole			
				// Check to see if a mole was there
				if (next_leds[i]) begin										// If a mole was there...
					hit_flag = 1'b1;										// Register a hit
					next_leds[i] = 1'b0;									// Turn off the LED
				end 
				else begin
					miss_flag = 1'b1;										// If there was no mole there, register a miss
				end
			end
		end
	end
	
	always @(posedge clk) begin
		// Set previous values for edge detection 
		prev_moles_up <= moles_up_state;
		prev_switch_states <= switches_sync;
		
		if (game_in_progress) begin
			// Update outputs
			LEDs <= next_leds;
			
			// Sending hit signals
			if (hit_flag) begin
				if (next_leds=={NUM_HOLES{1'b0}}) begin			// If there are no more moles after this hit
					full_clear_hit <= 1'b1;								// Register full clear
					non_full_clear_hit <= 1'b0;						// Don't register non full clear
				end 
				else begin 
					full_clear_hit <= 1'b0;								// If there are moles left after the hit, then not the last hit
					non_full_clear_hit <= 1'b1;
				end
			end
			else begin 														// If not flags, don't register anything
				full_clear_hit <= 1'b0;
				non_full_clear_hit <= 1'b0;
			end
			
			// Sending miss signals
			if (miss_flag) begin											// Miss 
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
