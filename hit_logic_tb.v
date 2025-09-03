`timescale 1ns/1ns

module hit_logic_tb;
	localparam NUM_HOLES = 18;
	
	reg         					CLOCK_50;              	// DE2-115's 50MHz clock
	reg	[NUM_HOLES - 1 : 0]	SW;                    	// The 4 push buttons
	reg 	[NUM_HOLES - 1 : 0]	mole_positions;			
	reg 	game_in_progress;
   reg [7:0] cycles_per_clock;
	
	wire 	[NUM_HOLES - 1 : 0]	LEDs;
	wire 	miss;
	wire	non_full_clear_hit;
	wire	full_clear_hit;
	
	
	hit_logic #(.NUM_HOLES(NUM_HOLES)) DUT (
	  .clk(CLOCK_50),
	  .mole_positions(mole_positions),
	  .switches(SW),
	  .game_in_progress(game_in_progress),
	  .LEDs(LEDs),
	  .miss(miss),
	  .non_full_clear_hit(non_full_clear_hit),
	  .full_clear_hit(full_clear_hit)
	);
	

	initial begin : clock_block
	  CLOCK_50 = 1'b0;
	  forever #10 CLOCK_50 = ~CLOCK_50;
	end
	
	initial begin  					// Run the following code starting from the beginning of the simulation:
		cycles_per_clock = 20;

		$dumpfile("waveform.vcd");  // Tell the simulator to dump variables into the 'waveform.vcd' file during the simulation. Required to produce a waveform .vcd file.
		$dumpvars();                // Also required to tell simulator to dump variables into a waveform (with filename specified above).
		
		#(10*cycles_per_clock)		
		
		game_in_progress = 1'b1;
		mole_positions = 18'b101010000000000000;
		SW = {18{1'b0}};
		
		#(10*cycles_per_clock)
		SW[17] = 1;
	
		#(10*cycles_per_clock)
		SW[15] = 1;
		
		#(10*cycles_per_clock)
		SW[13] = 1;
		
		#(10*cycles_per_clock)
		SW[16] = 1;
		
		#(20*cycles_per_clock)
		mole_positions = 18'b000000000000000000;

		#(20*cycles_per_clock)
		mole_positions = 18'b111000000000000000;	
	
		#(10*cycles_per_clock)
		SW[17] = 0;
		
		#(10*cycles_per_clock)
		SW[17] = 1;
		
		#(10*cycles_per_clock)
		SW[16] = 0;

		#(10*cycles_per_clock)
		SW[15] = 0;
		
		#(20*cycles_per_clock)
		mole_positions = 18'b000000000000000000;

		#(20*cycles_per_clock)
		mole_positions = 18'b001110000000000000;

		#(10*cycles_per_clock)
		SW[17] = 0;

		$finish();
	end
endmodule