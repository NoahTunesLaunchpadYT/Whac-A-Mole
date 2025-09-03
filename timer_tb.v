`timescale 1ns/1ns

module timer_tb;
	reg         CLOCK_50;              	// DE2-115's 50MHz clock
	reg 			rst;
	reg			enable;

	reg [7:0] 	cycles_per_clock;
	reg [7:0] 	clocks_per_ms;
	
	wire [$clog2(20)-1:0]	count_down_seconds;
	wire [$clog2(1000)-1:0]	count_down_milliseconds;
	
	timer #(.GAME_LENGTH_SECONDS(20), .CLKS_PER_MS(50000)) DUT (
	  .clk(CLOCK_50),
	  .rst(rst),
	  .enable(enable),
	  .count_down_seconds(count_down_seconds),
	  .count_down_milliseconds(count_down_milliseconds),
	);
	

	initial begin : clock_block
	  CLOCK_50 = 1'b0;
	  forever #10 CLOCK_50 = ~CLOCK_50;
	end
	
	initial begin  					// Run the following code starting from the beginning of the simulation:
		cycles_per_clock = 20;
		clocks_per_ms = 50000;

		$dumpfile("waveform.vcd");  // Tell the simulator to dump variables into the 'waveform.vcd' file during the simulation. Required to produce a waveform .vcd file.
		$dumpvars();                // Also required to tell simulator to dump variables into a waveform (with filename specified above).
		
		enable = 0;
		
		#(200*clocks_per_ms*cycles_per_clock)
		#(200*clocks_per_ms*cycles_per_clock)
		
		enable = 1;

		#(200*clocks_per_ms*cycles_per_clock)
		#(200*clocks_per_ms*cycles_per_clock)
		
		enable = 0;
		
		#(200*clocks_per_ms*cycles_per_clock)
		#(200*clocks_per_ms*cycles_per_clock)
		
		enable = 1;
		#(200*clocks_per_ms*cycles_per_clock)
		#(200*clocks_per_ms*cycles_per_clock)
		
		rst = 1;
		#(200*clocks_per_ms*cycles_per_clock)
		
		rst = 0;
		#(200*clocks_per_ms*cycles_per_clock)
		
		enable = 1;
		#(1200*clocks_per_ms*cycles_per_clock)

		$finish();

	end
endmodule 
