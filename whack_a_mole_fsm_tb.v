`timescale 1ns/1ps

module whack_a_mole_fsm_tb;

  // TB parameters
  parameter MOLE_UP_MS_TB    = 2;
  parameter MOLE_DOWN_MS_TB  = 1;
  parameter PERIOD_MS_TB     = MOLE_UP_MS_TB + MOLE_DOWN_MS_TB;
  parameter MAX_TIMER_MS_TB  = 20;
  parameter CLKS_PER_MS_TB   = 5;


  parameter TMW = $clog2(MAX_TIMER_MS_TB+1);
  parameter PHW = $clog2(PERIOD_MS_TB);

  // Clock
  reg clk;
  initial clk = 0;
  always #10 clk = ~clk; // 50 MHz
  
  reg clk_cycles = 0;

	// DUT IO
		//In
	reg  [TMW-1:0] timer_milliseconds;
	reg            start_button_pressed, reset_button_pressed;
		//Out
	wire           game_in_progress, mole_clk;
  
  // DUT
	whack_a_mole_fsm #(
		.MOLE_UP_MS(MOLE_UP_MS_TB),
		.MOLE_DOWN_MS(MOLE_DOWN_MS_TB),
		.MAX_TIMER_MS(MAX_TIMER_MS_TB),
		.CLKS_PER_MS(CLKS_PER_MS_TB)

	) dut (
		.clk(clk),
		.reset_button_pressed(reset_button_pressed),
		.start_button_pressed(start_button_pressed),
		.timer_milliseconds(timer_milliseconds),
		.game_in_progress(game_in_progress),
		.mole_clk(mole_clk)
	 
	);

	// Button pulses
	task pulse_start; begin
		start_button_pressed = 1; 
		@(posedge clk); 
		start_button_pressed = 0;
	end endtask

	task pulse_reset; begin
		reset_button_pressed = 1; 
		@(posedge clk); 
		reset_button_pressed = 0;
	end 
	endtask

	// 1 ms step
	task step_1ms;
	begin
		repeat (CLKS_PER_MS_TB-1) 
		@(posedge clk);

		if (timer_milliseconds != 0)
			timer_milliseconds = timer_milliseconds - 1;
			
		@(posedge clk);

		// Debug print
		$display("t=%0t, clk=%0t, timer_ms=%0d, game_in_prog=%0b, mole_clk=%0b",
					  $time, clk, timer_milliseconds, game_in_progress, mole_clk);
		end
	endtask


	task run_ms;
		input integer n;
		integer i;
		begin
			for (i=0; i<n; i=i+1) step_1ms();
		end
	endtask

  // Waves
	initial begin
		$dumpfile("whack_tb.vcd");
		$dumpvars(0, whack_a_mole_fsm_tb);
	end

	// Test sequence
	integer errors;
	initial begin
		errors = 0;
		start_button_pressed = 0;
		reset_button_pressed = 0;
		timer_milliseconds = 20; 

		pulse_reset();
		#10
		pulse_start();

		// Run a few ms and print mole_clk
		run_ms(20);

		// Another game
		timer_milliseconds = 30;
		pulse_reset();
		#10
		pulse_start();
		run_ms(30);

		$display("TB finished (errors=%0d)", errors);
		$finish;
	end

endmodule
