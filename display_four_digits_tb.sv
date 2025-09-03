`timescale 1ms/1ps
module display_four_digits_tb;
    logic rst;
    logic clk;
    logic [10:0] value;
    logic [6:0] display3, display2, display1, display0;

    display_four_digits DUT (.*);

    initial begin : clock_gen
        clk = 1'b0;
        forever #10 clk = ~clk;
	 end

    // initial forever #1 clk = ~clk; 

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars();
        rst = 1;
        value = 0;
        @(posedge clk);
        rst = 0;
        repeat(2000) begin
            @(posedge DUT.done);
            // #(2*25);
            $display("time is %0t, value is: %b, 7Segs: %b, %b, %b, %b",$time, value, display3, display2, display1,display0);
            value = value + 1;
            if(value == 11'(1000)) begin
                rst = 1;
            end
            if (value > 11'(1200)) begin
                rst = 0;
            end
            @(posedge clk);
        end
        $finish();

    end
endmodule
