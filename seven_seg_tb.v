`timescale 1ns/1ns

module seven_seg_tb;
  reg  [3:0] bcd;
  wire [6:0] segments;

  seven_seg DUT (
    .bcd(bcd),
    .segments(segments)
  );

  initial begin
    $dumpfile("sevenseg.vcd");
    $dumpvars(0, seven_seg_tb);

    bcd = 4'd0; #10;
    bcd = 4'd1; #10;
    bcd = 4'd2; #10;
    bcd = 4'd3; #10;
    bcd = 4'd4; #10;
    bcd = 4'd5; #10;
    bcd = 4'd6; #10;
    bcd = 4'd7; #10;
    bcd = 4'd8; #10;
    bcd = 4'd9; #10;
    bcd = 4'd10; #10;

    $finish;
  end
endmodule
