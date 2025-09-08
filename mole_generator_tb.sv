`timescale 1ns/1ns

module mole_generator_tb;

   reg clk, mole_clk;
   wire [17:0] mole_positions;   // FIXED: should be wire

   mole_generator DUT (
      .clk(clk),
      .mole_clk(mole_clk),
      .mole_positions(mole_positions)
   );

   localparam int CLK_PERIOD = 100; // 100 ns => 10 MHz

   // clock
   initial begin
      clk = 1'b0;
      forever #(CLK_PERIOD/2) clk = ~clk;
   end

   // task for mole_clk pulses
   task automatic pulse_mole_clk(input int cycles);
      begin
         mole_clk = 1'b1;
         #(CLK_PERIOD*cycles);
         mole_clk = 1'b0;
         #(CLK_PERIOD*cycles);
      end
   endtask

   initial begin
      mole_clk = 1'b0;

      // run some mole cycles
      repeat (10) pulse_mole_clk(4);

      #1000;  // let things settle
      $finish;
   end

endmodule
