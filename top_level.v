module top_level (
	input         CLOCK_50,              // DE2-115's 50MHz clock signal
   input  [1:0]  KEY,                   // The 4 push buttons on the board
	input  [17:0] SW,
   output [17:0] LEDR,                  // 18 red LEDs
   output [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7 // Eight 7-segment displays
);
	
	localparam 	NUM_HOLES = 18,
					NUM_MOLES = 3,
					MOLE_UP_MS = 2000,
					MOLE_DOWN_MS = 1000,
					GAME_LENGTH_SECONDS = 20,
					CLKS_PER_MS = 50000,
					DEBOUNCE_DELAY_COUNTS = 2500,
					MS_PER_SECOND = 1000,
					MAX_COMBO_COUNT = 99,
					MAX_SCORE = 9999;

	// Intermediate Wires
	
	wire rst, game_in_progress, mole_clk;														// FSM wires
	wire [$clog2(GAME_LENGTH_SECONDS)-1:0] timer_seconds;
	wire [$clog2(GAME_LENGTH_SECONDS*MS_PER_SECOND)-1:0] timer_milliseconds;		// Timer wires
	wire start_button_pressed;
	wire [NUM_HOLES-1:0] mole_positions;														// Mole Generator
	wire miss, non_full_clear_hit, full_clear_hit;											// Hit logic
	wire [$clog2(MAX_COMBO_COUNT)-1:0] combo_count;											// Combo Counter
	wire [$clog2(MAX_SCORE)-1:0] score;																							// Score Counter
	
	// Falgun
	whack_a_mole_fsm			#(	.MOLE_UP_MS(MOLE_UP_MS), 
										.MOLE_DOWN_MS(MOLE_DOWN_MS),
										.MAX_TIMER_MS(GAME_LENGTH_SECONDS*1000),
										.CLKS_PER_MS(CLKS_PER_MS)
										) 
									u_fsm(
									// Inputs
									.clk(CLOCK_50),
									.timer_milliseconds(timer_milliseconds),
									.start_button_pressed(start_button_pressed), // Active Low (Not high)
									.reset_button_pressed(rst), // Active Low (Not high)
									
									// Outputs
									.game_in_progress(game_in_progress),
									.mole_clk(mole_clk)
									);
									
	
	debounce       			#(.DELAY_COUNTS(DEBOUNCE_DELAY_COUNTS)) 
									u_start_button_debounce(
									// Inputs
									.clk(CLOCK_50),
									.button(~KEY[1]),
									//Output
									.button_pressed(start_button_pressed)
									);
	
	debounce       			#(.DELAY_COUNTS(DEBOUNCE_DELAY_COUNTS)) 
									u_reset_button_debounce(
									// Inputs
									.clk(CLOCK_50),
									.button(~KEY[0]),
									//Output
									.button_pressed(rst)
									);
	
	// Noah
	timer 						#(.GAME_LENGTH_SECONDS(GAME_LENGTH_SECONDS), .CLKS_PER_MS(CLKS_PER_MS))
									u_timer(
									// Inputs:
									.clk(CLOCK_50),
									.rst(rst),
									.enable(game_in_progress),
									// Outputs
									.count_down_seconds(timer_seconds),
									.count_down_milliseconds(timer_milliseconds)
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
									.LEDs(LEDR),
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
								.rst(rst),
								
								// Ouput
								.score_count(score)
								);
	

	display_two_digits 	u_timer_display(
								.clk(CLOCK_50),
								.value(timer_seconds),
								.display0(HEX6),
								.display1(HEX7)
								);
	
	display_two_digits 	u_combo_display(
								.clk(CLOCK_50),
								.value(combo_count),
								.display0(HEX4),
								.display1(HEX5)
								);
	
	display_four_digits  u_score_display(
								.clk(CLOCK_50),
								.value(score),
								.display0(HEX0),
								.display1(HEX1),
								.display2(HEX2),
								.display3(HEX3)
								);
 

endmodule
