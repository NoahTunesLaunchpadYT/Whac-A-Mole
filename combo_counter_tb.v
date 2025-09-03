`timescale 1ns/1ns

module combo_counter_tb;
	reg         CLOCK_50;              	// DE2-115's 50MHz clock
	reg 			miss;
	reg			non_full_clear_hit;
	reg 			full_clear_hit;
	reg 			reset;
   reg [7:0] cycles_per_clock;

	wire [6:0]	combo_val;
	
	combo_counter DUT (
	  .clk(CLOCK_50),
	  .miss(miss),
	  .non_full_clear_hit(non_full_clear_hit),
	  .full_clear_hit(full_clear_hit),
	  .reset(reset),
	  .combo_val(combo_val)
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
		
		non_full_clear_hit = 1;
		#(cycles_per_clock)	
		non_full_clear_hit = 0;	

		#(10*cycles_per_clock)	
		
		non_full_clear_hit = 1;
		#(cycles_per_clock)	
		non_full_clear_hit = 0;	
		
		#(10*cycles_per_clock)	
		
		full_clear_hit = 1;
		#(cycles_per_clock)	
		full_clear_hit = 0;	
		
		#(10*cycles_per_clock)	
		
		full_clear_hit = 1;
		#(cycles_per_clock)	
		full_clear_hit = 0;	
		
		#(10*cycles_per_clock)	
		
		miss = 1;
		#(cycles_per_clock)	
		miss = 0;	
		
		#(10*cycles_per_clock)	
		
		miss = 1;
		full_clear_hit = 1;
		#(cycles_per_clock)	
		miss = 0;	
		full_clear_hit = 0;
		
		#(10*cycles_per_clock)	
		
		miss = 1;
		non_full_clear_hit = 1;
		#(cycles_per_clock)	
		miss = 0;	
		non_full_clear_hit = 0;

		#(10*cycles_per_clock)			
		
		full_clear_hit = 1;
		non_full_clear_hit = 1;
		#(cycles_per_clock)	
		full_clear_hit = 0;
		non_full_clear_hit = 0;
		
		#(10*cycles_per_clock)
		
		full_clear_hit = 1;
		#(2*cycles_per_clock)
		full_clear_hit = 0;
		
		#(10*cycles_per_clock)
		
		reset = 1;
		#(10*cycles_per_clock)
		reset = 0;
		
		non_full_clear_hit = 1;
		#(3*cycles_per_clock)
		non_full_clear_hit = 0;
		
		$finish();
	end
endmodule