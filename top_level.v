module top_level (
	input         CLOCK_50,              // DE2-115's 50MHz clock signal
   input  [1:0]  KEY,                   // The 4 push buttons on the board
	input  [17:0] SW,
   output [17:0] LEDR,                  // 18 red LEDs
   output [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7 // Eight 7-segment displays
);
	
	localparam 	NUM_HOLES = 18,
					NUM_MOLES = 3,
					MOLE_UP_MS = 1000,
					MOLE_DOWN_MS = 1000,
					GAME_LENGTH_SECONDS = 20,
					CLK_PER_MS = 50000,
					DEBOUNCE_DELAY_COUNTS = 2500;

	// Intermediate Wires
	
	wire rst, game_in_progress, mole_clk;														// FSM wires
	wire timer_seconds, timer_milliseconds;													// Timer wires
	wire start_button_pressed, reset_button_pressed, start_button, reset_button;	// Debouncer wires
	wire [NUM_HOLES-1:0] mole_positions;														// Mole Generator
	wire miss, non_full_clear_hit, full_clear_hit;											// Hit logic
	wire combo_count;																					// Combo Counter
	wire score;																							// Score Counter
	
	// Falgun
	whack_a_mole_fsm			#(.MOLE_UP_MS(MOLE_UP_MS), .MOLE_DOWN_MS(MOLE_DOWN_MS)) 
									u_fsm(
									// Inputs
									.clk(CLOCK_50),
									.timer_milliseconds(timer_milliseconds),
									.start_button_pressed(start_button_pressed), // Active Low (Not high)
									.reset_button_pressed(reset_button_pressed), // Active Low (Not high)
									
									// Outputs
									.game_in_progress(game_in_progress),
									.rst(rst),
									.mole_clk(mole_clk)		
									);
	
	debounce       			#(.DELAY_COUNTS(DEBOUNCE_DELAY_COUNTS)) 
									u_start_button_debounce(
									// Inputs
									.clk(CLOCK_50),
									.button(KEY[1]),
									//Output
									.button_pressed(start_button_pressed)
									);
	
	debounce       			#(.DELAY_COUNTS(DEBOUNCE_DELAY_COUNTS)) 
									u_reset_button_debounce(
									// Inputs
									.clk(CLOCK_50),
									.button(KEY[0]),
									//Output
									.button_pressed(reset_button_pressed)
									);
	

	fsm_timer 					#(.GAME_LENGTH_SECONDS(GAME_LENGTH_SECONDS), .CLK_PER_MS(CLK_PER_MS))
									u_fsm_timer(
									// Inputs:
									.clk(CLOCK_50),
									.reset(rst),
									.enable(game_in_progress),
									// Outputs
									.timer_seconds(timer_seconds),
									.timer_milliseconds(timer_milliseconds)
									);

	// Daniel 
	mole_generator 			#(.NUM_HOLES(NUM_HOLES), .NUM_MOLES(NUM_MOLES))
									u_mole_generator(
									// Inputs:
									.clk(CLOCK_50),
									.mole_clk(mole_clk),
									
									// Outputs
									.mole_positions(mole_positions)
									);
	
	// Noah
	hit_logic 					#(.NUM_HOLES(NUM_HOLES))
									u_hit_logic(
									// Inputs:
									.clk(CLOCK_50),
									.mole_positions(mole_positions),
									.switches(SW),
									.game_in_progress(game_in_progress),
									// Outputs:
									.leds(LEDR),
									.miss(miss),
									.non_full_clear_hit(non_full_clear_hit),
									.full_clear_hit(full_clear_hit)
									);
	
	// Lara 
	combo_counter 				u_combo_counter(
									// Inputs
									.clk(CLOCK_50),
									.miss(miss),
									.non_full_clear_hit(non_full_clear_hit),
									.full_clear_hit(full_clear_hit),
									.rst(rst),
									// Output
									.combo_count(combo_count)
									);
	
	// Sahaj
	score_counter 			u_score_counter(
								// Input
								.clk(CLOCK_50),
								.score_increase(combo_count),
								
								// Ouput
								.score(score)
								);
	

	display_2digit 		u_timer_display(
								.clk(CLOCK_50),
								.value(timer_seconds),
								.display0(HEX6),
								.display1(HEX7),
								);
	
	displeray_2digit 		u_combo_display(
								.clk(CLOCK_50),
								.value(combo_count),
								.display0(HEX4),
								.display1(HEX5)
		);
	
	display_4digit 		u_score_display(
								.clk(CLOCK_50),
								.value(score),
								.display0(HEX0),
								.display1(HEX1),
								.display2(HEX2),
								.display3(HEX3),
								);
 

endmodule
