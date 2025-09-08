`timescale 1ns/1ns

module hit_logic_tb;
	localparam NUM_HOLES = 6;
	localparam CYCLES_PER_CLOCK = 20;
	
	reg         					CLOCK_50;              	// DE2-115's 50MHz clock
	reg	[NUM_HOLES - 1 : 0]	SW;                    	// The 4 push buttons
	reg 	[NUM_HOLES - 1 : 0]	mole_positions;			
	reg 	game_in_progress;
	
	wire 	[NUM_HOLES - 1 : 0]	LEDs;
	wire 	miss;
	wire	non_full_clear_hit;
	wire	full_clear_hit;
	
	hit_logic #(.NUM_HOLES(NUM_HOLES), 
					.DEBOUNCE_DELAY(2)
					) DUT (
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
		$dumpfile("waveform.vcd");  // Tell the simulator to dump variables into the 'waveform.vcd' file during the simulation. Required to produce a waveform .vcd file.
		$dumpvars();                // Also required to tell simulator to dump variables into a waveform (with filename specified above).
		
		// Initialise variables 
		SW = {NUM_HOLES{1'b0}};
		mole_positions = {NUM_HOLES{1'b0}};
		game_in_progress = 1'b0;

		#(3*CYCLES_PER_CLOCK)

		// Test while game_in_progress is false, no outputs should change
		mole_positions = 6'b101000; // Set mole positions
		#(3*CYCLES_PER_CLOCK)
		SW = 6'b100000;		// Hit mole
		#(3*CYCLES_PER_CLOCK)
		SW = 6'b110000;		// Miss mole
		#(3*CYCLES_PER_CLOCK)
		SW = 6'b111000;		// Hit last mole
		#(3*CYCLES_PER_CLOCK)
		mole_positions = 6'b000000;		// moles go down
		#(3*CYCLES_PER_CLOCK)

		// Now test with game_in_progress on
		SW = 6'b000000;		// reset switches
		#(10*CYCLES_PER_CLOCK)
		game_in_progress = 1'b1;
		#(10*CYCLES_PER_CLOCK)
		mole_positions = 6'b101000; // Set mole positions
		#(10*CYCLES_PER_CLOCK)
		SW = 6'b100000;		// Hit mole
		#(10*CYCLES_PER_CLOCK)
		SW = 6'b110000;		// Miss mole
		#(10*CYCLES_PER_CLOCK)
		SW = 6'b111000;		// Hit last mole
		#(10*CYCLES_PER_CLOCK)
		mole_positions = 6'b000000;		// moles goes down
		#(10*CYCLES_PER_CLOCK)
		mole_positions = 6'b110000;		// moles comes up
		#(10*CYCLES_PER_CLOCK)
		SW = 6'b011000;						// Checking falling edge works too
		#(10*CYCLES_PER_CLOCK)
		SW = 6'b000000;						// Simultaneous Hit and miss moles
		#(10*CYCLES_PER_CLOCK)
		mole_positions = 6'b000000;		// moles goes down, should trigger a miss

		$finish();
	end
endmodule
