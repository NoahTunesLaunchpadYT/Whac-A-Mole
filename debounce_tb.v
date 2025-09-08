`timescale 1ns/1ns

module debounce_tb;
  // Params
  localparam DEBOUNCE_CYCLES   = 4;
  localparam CYCLES_PER_CLOCK  = 20;

  // Clock & DUT I/O
  reg  CLOCK_50;
  reg  button;
  wire button_pressed;

  // DUT
  debounce #(
    .DELAY_COUNTS(DEBOUNCE_CYCLES)
  ) DUT (
    .clk(CLOCK_50),
    .button(button),
    .button_pressed(button_pressed)
  );

  // 50 MHz clock
  initial begin : clock_block
    CLOCK_50 = 1'b0;
    forever #10 CLOCK_50 = ~CLOCK_50;
  end


  initial begin
    // Init
    button = 1'b0;

    // VCD dump (for GTKWave); ModelSim users can still add waves/log
    $dumpfile("waveform.vcd");
    $dumpvars(0, debounce_tb);

    // 1) Asynchronous press just after a clock edge ===
    #(CYCLES_PER_CLOCK);      // wait 1 clock period
    #3;                       // go async relative to clock
    button = 1'b1;            // press
    // Not enough time yet to pass debounce threshold
    #(DEBOUNCE_CYCLES*CYCLES_PER_CLOCK);      // wait 1 clock period

    // Expect: button_pressed still 0

    // Now hold long enough to satisfy debounce
    #(CYCLES_PER_CLOCK * (DEBOUNCE_CYCLES - (DEBOUNCE_CYCLES/2)));
    // Expect: button_pressed becomes 1 exactly when counter hits DELAY_COUNTS

    // 2) Short glitch: should be ignored ===
    #3; button = 1'b0;        // brief drop (bounce)
    #(2*CYCLES_PER_CLOCK);             // shorter than DEBOUNCE_CYCLES
    button = 1'b1;            // back high
    #(CYCLES_PER_CLOCK * DEBOUNCE_CYCLES/2);
    // Expect: button_pressed stays 1 (no change due to short glitch)

    // 3) Edge-case: change exactly near a clock edge ===
    #(CYCLES_PER_CLOCK - 3);  // align close to rising edge
    button = 1'b1;            // press near edge
    #(CYCLES_PER_CLOCK*DEBOUNCE_CYCLES);
    // Expect: button_pressed -> 1

    #2; button = 1'b0;        // another async offset
    #(2 * CYCLES_PER_CLOCK * DEBOUNCE_CYCLES);
    // Expect: button_pressed -> 0

    $finish();
  end
endmodule
