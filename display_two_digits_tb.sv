`timescale 1ms/1ps
module display_two_digits_tb;
    logic rst;
    logic clk;
    logic [6:0] value;
    logic [6:0]  display1, display0;

    display_two_digits DUT (.*);

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
        repeat(99) begin
            @(posedge DUT.done);
            // #(2*25);
            $display("time is %0t, value is: %b, 7Segs: %b, %b",$time, value, display1,display0);
            value = value + 1;
            if(value == 40) begin
                rst = 1;
                $display("RESET IS NOW HIGH");
            end
            if (value > 60) begin
                rst = 0;
                $display("RESET IS NOW LOW");
            end
            @(posedge clk);
        end
        $finish();

    end
endmodule
