`timescale 1ns/1ns

module top_level_tb;

   reg         CLOCK_50;
   reg  [1:0]  KEY;
	reg  [17:0] SW;
   wire [17:0] LEDR;
   wire [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;

   wire [17:0] mole_positions;
	wire mole_clk;
   wire [3:0]  mole_position1, mole_position2, mole_position3;
	parameter CLKS_PER_MS_TB   = 5;
   top_level #(
	  .CLKS_PER_MS(CLKS_PER_MS_TB)
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

   // Connect mole_generator outputs to wires for monitoring
   assign mole_positions = DUT.u_mole_generator.mole_positions;
   assign mole_position1 = DUT.u_mole_generator.mole_position1;
   assign mole_position2 = DUT.u_mole_generator.mole_position2;
   assign mole_position3 = DUT.u_mole_generator.mole_position3;
	
	assign mole_clk = DUT.u_fsm.mole_clk;
	
	
   initial begin : clock_block
        CLOCK_50 = 1'b0;
        forever begin
            #10;
            CLOCK_50 = ~CLOCK_50;
        end
    end

   initial begin
      $display("=== Simulation started ===");

      $monitor("t=%0t ns | KEY=%b | SW=%b | mole_clk=%b | mole_positions=%b | mole1=%0d mole2=%0d mole3=%0d | Score=%0d | Combo=%0d",
               $time, KEY, SW, mole_clk, mole_positions, mole_position1, mole_position2, mole_position3,
               DUT.score, DUT.combo_count);

      KEY = 2'b11;
      SW  = 18'b0;

      #100;
      KEY[0] = 1'b0;
      #100;
      KEY[0] = 1'b1;

      // Start the game
      #100;
      KEY[1] = 1'b0;
      #100;
      KEY[1] = 1'b1;

      #100;
      SW[4] = 1'b1;
      #50;
      SW[9] = 1'b1;

      #50;
      SW[5] = 1'b1;
      #0;
      SW[14] = 1'b1;
		

      #10000;
		
      KEY[0] = 1'b0;
      #100;
      KEY[0] = 1'b1;
		#100;

//      $display("=== Simulation finishing ===");
//      $display("Final LEDR = %b", LEDR);
//      $display("Final Score = %0d, Combo = %0d", DUT.score, DUT.combo_count);
//      $display("Final Mole positions: %b", mole_positions);
//      $display("Individual mole indices: %0d, %0d, %0d", mole_position1, mole_position2, mole_position3);
      $finish;
   end

endmodule
