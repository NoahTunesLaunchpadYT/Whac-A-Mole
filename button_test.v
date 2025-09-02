module button_test (
    input         CLOCK_50,              // DE2-115's 50MHz clock signal
    input  [3:0]  KEY,                   // The 4 push buttons on the board
    output [17:0] LEDR,                  // 18 red LEDs
    output [6:0]  HEX0, HEX1, HEX2, HEX3 // Four 7-segment displays
);

	assign LEDR[0] = KEY[0];


endmodule