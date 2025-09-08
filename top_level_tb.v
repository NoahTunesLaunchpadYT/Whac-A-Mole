`timescale 1ns/1ps

module top_level_tb;

   reg         CLOCK_50;
   reg  [1:0]  KEY;
	reg  [17:0] SW;
   wire [17:0] LEDR;
   wire [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
	reg [$clog2(20)-1:0] 	cycles_per_clock;

	parameter CLKS_PER_MS_TB   = 5;
   top_level #(
	  .CLKS_PER_MS(CLKS_PER_MS_TB),
	  .DEBOUNCE_DELAY_COUNTS(2),
	  .MOLE_UP_MS(5),
	  .MOLE_DOWN_MS(5)
	) DUT (
      .CLOCK_50(CLOCK_50),
      .KEY(KEY),
      .SW(SW),
      .LEDR(LEDR),
      .HEX0(HEX0),
      .HEX1(HEX1),
      .HEX2(HEX2),
      .HEX3(HEX3),
      .HEX4(HEX4),
      .HEX5(HEX5),
      .HEX6(HEX6),
      .HEX7(HEX7)
   );	
	
   initial begin : clock_block
        CLOCK_50 = 1'b0;
        forever begin
            #10;
            CLOCK_50 = ~CLOCK_50;
        end
    end

   initial begin
		cycles_per_clock = 20;
//      $display("=== Simulation started ===");
//
//      $monitor("t=%0t ns | KEY=%b | timer_ms=%b | fsm_state_v=%b | phase_ms=%b | mole_up_window=%b | SW=%b | mole_clk=%b | mole_positions=%b | mole1=%0d mole2=%0d mole3=%0d | Score=%0d | Combo=%0d",
//               $time, KEY, timer_ms, fsm_state_v, phase_ms, mole_up_window, SW, mole_clk, mole_positions, mole_position1, mole_position2, mole_position3,
//               DUT.score, DUT.combo_count);

      KEY = 2'b11;
      SW  = 18'b0;

      #(30*cycles_per_clock);
      KEY[0] = 1'b0;
      #(30*cycles_per_clock);
      KEY[0] = 1'b1;

      // Start the game
      #(30*cycles_per_clock);
      KEY[1] = 1'b0;
      #(5*cycles_per_clock);
      KEY[1] = 1'b1;
		
      #(6*cycles_per_clock);
      SW[13] = 1'b1;
		#(6*cycles_per_clock);
		SW[12] = 1'b1;
		#(3*cycles_per_clock);
		
      #(40*cycles_per_clock);
      SW[16] = 1'b1;
      #(6*cycles_per_clock);
      SW[14] = 1'b1;
      #(6*cycles_per_clock);
      SW[11] = 1'b1;

      #(10*cycles_per_clock);
      SW[5] = 1'b1;
      #(10*cycles_per_clock);
      SW[14] = 1'b0;
		
		// Reset the game
		#(60*cycles_per_clock);
      KEY[0] = 1'b0;
      #(10*cycles_per_clock);
      KEY[0] = 1'b1;

      // Start the game
      #(10*cycles_per_clock);
      KEY[1] = 1'b0;
      #(10*cycles_per_clock);
      KEY[1] = 1'b1;

      $finish;
   end

endmodule
