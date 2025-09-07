module rng_tb;
	// Parameters
	localparam MAX_VALUE = 18; 

   // Inputs 
   reg clk;
	
   // Outputs
   wire [$clog2(MAX_VALUE)-1:0] random_value; // 11-bit output, as MAX_VALUE is 1223

	// Instantiate module
	rng #(
		.OFFSET(0),
		.MAX_VALUE(MAX_VALUE),
		.SEED(42) 
	) dut (
		.clk(clk),
		.random_value(random_value)
	);

	// Clock generation
	initial begin
		clk = 0;
		forever #10 clk = ~clk;  // 50 MHz
	end

	// Initial conditions and stimulus
	initial begin
		// Dump the waveform
		$dumpfile("waveform.vcd");
		$dumpvars();

		// Display header
		$display("Time\tRandom Value");
		$monitor("%0d\t%b", $time, random_value);

		// Run the simulation
			#1000 $finish();
	end

endmodule