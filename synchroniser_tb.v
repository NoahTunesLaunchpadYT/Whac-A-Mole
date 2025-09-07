`timescale 1ns/1ns

module synchroniser_tb;
	reg         CLOCK_50;              	// DE2-115's 50MHz clock
	reg 			x;
	wire y;
	
   reg [7:0] cycles_per_clock;
	
	synchroniser DUT (
	  .clk(CLOCK_50),
	  .x(x),
	  .y(y)
	);
	

	initial begin : clock_block
	  CLOCK_50 = 1'b0;
	  forever #10 CLOCK_50 = ~CLOCK_50;
	end
	
	initial begin  					// Run the following code starting from the beginning of the simulation:
		cycles_per_clock = 20;
		x = 0;

		$dumpfile("waveform.vcd");  // Tell the simulator to dump variables into the 'waveform.vcd' file during the simulation. Required to produce a waveform .vcd file.
		$dumpvars();                // Also required to tell simulator to dump variables into a waveform (with filename specified above).
		
		#(cycles_per_clock)			// Wait 1 clock cycle
		#(3)								// Become asynchronous
		
		x = 1;
		
		#(cycles_per_clock)			// Wait 1 clock cycle
		
		x = 0;							// Turn the signal off (validate the signal only drops at the next rising clk edge)
		
		#(2*cycles_per_clock)			// Wait 2 clock cycles

		#(cycles_per_clock-3)								// become synchronous

		x = 1;							// Test edge case of signal change on clock edge
		
		#(3*cycles_per_clock)		// Hold signal for 3 cycles
		
		x = 0;							// Turn off signal
		
		#(3*cycles_per_clock)
		
		x = 0;
	end
endmodule 
