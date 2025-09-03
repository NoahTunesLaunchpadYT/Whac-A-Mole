`timescale 1ns/1ns

module mole_generator_tb;

   reg clk, mole_clk;
   reg [17 : 0] mole_positions;
	reg [4:0] mole_position1;
	reg[4:0] mole_position2;
	reg [4:0] mole_position3;

	mole_generator DUT (
	  .clk(clk), .mole_clk(mole_clk), .mole_positions(mole_positions), 
	  .mole_position1(mole_position1), .mole_position2(mole_position2), .mole_position3(mole_position3)
	);

	localparam int CLK_PERIOD = 100; // 100 ns => 10 MHz
	initial begin
		clk = 1'b0;                     
		forever #(CLK_PERIOD/2) clk = ~clk;
	end
	
	task automatic pulse_mole_clk(input int cycles);
		begin
			 mole_clk = 1'b1;
			 #(CLK_PERIOD*cycles);
			 mole_clk = 1'b0;
			 #(CLK_PERIOD*cycles);
		end
	endtask

   initial begin
		$dumpfile("waveform.vcd");
		$dumpvars();

		mole_clk = 1'b0;
		repeat (10) pulse_mole_clk(4);

		$finish();
   end

endmodule