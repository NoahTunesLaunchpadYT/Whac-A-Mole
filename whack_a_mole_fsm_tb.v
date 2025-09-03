`timescale 1ns/1ps

module whack_a_mole_fsm_tb;

  // TB parameters
  parameter MOLE_UP_MS_TB    = 7;
  parameter MOLE_DOWN_MS_TB  = 5;
  parameter PERIOD_MS_TB     = MOLE_UP_MS_TB + MOLE_DOWN_MS_TB;
  parameter MAX_TIMER_MS_TB  = 200;
  parameter CYCLES_PER_MS    = 50;   // fixed time mapping

  // clog2 helper (Verilog-2001)
  function integer clog2;
    input integer value;
    integer v, i;
    begin
      v = value-1;
      for (i=0; v>0; i=i+1) v = v>>1;
      clog2 = i;
    end
  endfunction

  parameter TMW = clog2(MAX_TIMER_MS_TB+1);
  parameter PHW = clog2(PERIOD_MS_TB);

  // Clock
  reg clk;
  initial clk = 0;
  always #10 clk = ~clk; // 50 MHz

  // DUT I/O
  reg  [TMW-1:0] timer_milliseconds;
  reg            start_button_pressed, reset_button_pressed;
  wire           rst, game_in_progress, mole_clk;
  wire [1:0] 	  dbg_state;
  wire 			  mole_up_window;
  wire [4:0]	  phase_ms;
  // DUT
  whack_a_mole_fsm #(
    .MOLE_UP_MS    (MOLE_UP_MS_TB),
    .MOLE_DOWN_MS  (MOLE_DOWN_MS_TB),
    .MAX_TIMER_MS  (MAX_TIMER_MS_TB)
  ) dut (
    .clk(clk),
    .timer_milliseconds(timer_milliseconds),
    .reset_button_pressed(reset_button_pressed),
    .start_button_pressed(start_button_pressed),
    .game_in_progress(game_in_progress),
    .mole_clk(mole_clk),
	 .dbg_state(dbg_state),
	 .mole_up_window(mole_up_window),
	 .phase_ms(phase_ms)
  );

  // Phase counter (counts down)
  reg [PHW-1:0] phase_tb;

  function exp_mole_up;
    input [PHW-1:0] phase;
    begin
      exp_mole_up = (phase >= MOLE_DOWN_MS_TB);
    end
  endfunction

  // Button pulses
  task pulse_start; begin
    start_button_pressed = 1; @(posedge clk); start_button_pressed = 0;
  end endtask

  task pulse_reset; begin
    reset_button_pressed = 1; @(posedge clk); reset_button_pressed = 0;
  end endtask

  // 1 ms step
	task step_1ms;
	  begin
		 repeat (CYCLES_PER_MS-1) @(posedge clk);

		 if (timer_milliseconds != 0)
			timer_milliseconds = timer_milliseconds - 1;

		 if (phase_tb == 0)
			phase_tb = PERIOD_MS_TB - 1;
		 else
			phase_tb = phase_tb - 1;

		 @(posedge clk);

		 // Debug print
		 $display("t=%0t  timer_ms=%0d  phase=%0d  state=%0d  gip=%0b  mole_clk=%0b",
					  $time, timer_milliseconds, phase_tb, dbg_state, game_in_progress, mole_clk, mole_up_window, phase_ms);
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
		 timer_milliseconds = 20;  // enough for a few 
		 phase_tb = PERIOD_MS_TB - 1;

		 pulse_reset();
		 pulse_start();

		 // Run a few ms and print mole_clk
		 run_ms(20);

		 // Another game
		 timer_milliseconds = 30;
		 pulse_start();
		 run_ms(30);

		 $display("TB finished (errors=%0d)", errors);
		 $finish;
	end

endmodule
