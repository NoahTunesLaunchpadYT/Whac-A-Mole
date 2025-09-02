`timescale 1us/1ns

module system_tb;

    reg         CLOCK_50;               // DE2-115's 50MHz clock
    reg  [3:0]  KEY;                    // The 4 push buttons
    wire [17:0] LEDR;                   // 18 red LEDs
    wire [6:0]  HEX0, HEX1, HEX2, HEX3; // Four 7-segment displays
    /* DO NOT MODIFY THE ABOVE */

    reg [7:0] cycles_per_clock;
    top_level DUT (
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .LEDR(LEDR),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3)
    );

    initial begin : clock_block
        CLOCK_50 = 1'b0;
        forever #25 CLOCK_50 = ~CLOCK_50;
    end


    initial begin  // Run the following code starting from the beginning of the simulation:
        cycles_per_clock = 50;

        $dumpfile("waveform.vcd");  // Tell the simulator to dump variables into the 'waveform.vcd' file during the simulation. Required to produce a waveform .vcd file.
        $dumpvars();                // Also required to tell simulator to dump variables into a waveform (with filename specified above).
        KEY[0] = 1;
        #(10*cycles_per_clock)
        KEY[0] = 0;
        #(5*cycles_per_clock)
        KEY[0] = 1;
        #(1499_000)
        $display("LEDR: %b", LEDR);
        KEY[0] = 0;
        #(5*cycles_per_clock)
        KEY[0] = 1;
        #(100_000)
        $display("7Segs: %b, %b, %b, %b",HEX3,HEX2,HEX1,HEX0);
        
        $finish();
    end


    // Clock
    // dumpfile
    // Initialise clock to 0
    // Initialise KEY[0] = 1
    // Wait 10 clock periods
    // User presses push button 


    // Your testbench code here!

endmodule
