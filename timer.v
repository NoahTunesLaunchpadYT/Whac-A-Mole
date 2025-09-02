`timescale 1ns/1ns /* This directive (`) specifies simulation <time unit>/<time precision>. */

module timer #(
    parameter MAX_MS = 2047,            // Maximum millisecond value
    parameter CLKS_PER_MS = 50000 // What is the number of clock cycles in a millisecond?
) (
    input                       clk,
    input                       reset,
    input                       up,
    input  [$clog2(MAX_MS)-1:0] start_value, // What does the $clog2() function do here?
    input                       enable,
    output [$clog2(MAX_MS)-1:0] timer_value
);

    reg [15:0] clk_cycles;
    reg [10:0] ms_timer;
    reg count_up;

    assign timer_value = ms_timer;

    always @(posedge clk) begin
        if (reset) begin
            clk_cycles <= 0;

            if (up) begin
                ms_timer <= 0;
            end 
            else begin 
                ms_timer <= start_value;
            end 
            count_up <= up;
        end 
        else if (enable) begin
            if (clk_cycles >= CLKS_PER_MS-1) begin
                clk_cycles <= 0;
                ms_timer <= (count_up) ? ms_timer + 1: ms_timer - 1;
            end
            else begin 
                clk_cycles <= clk_cycles + 1;
            end
        end 
    end

    // Your code here!

endmodule

    
    /*** Hints (Challenge: delete these hints): ***/
        /*
         * Define 2 count bit vectors, one for counting clock cycles and the other for counting milliseconds.
         * Make sure that these vectors have an appropriate size given their respective maximum values!
         *
         * Define a register `count_up` to remember whether we should be counting up or down.
         *
         * Make a sequential logic always procedure:
         *  If reset then:
         *    Set the clock-cycle counter to zero.
         *    If up is high:
         *      Set the millisecond counter to 0,
         *      Set count_up to high.
         *    Else:
         *      Set the millisecond counter to start_value,
         *      Set count_up to low.
         *  Else if enable then:
         *    If the clock cycle counter is `CLKS_PER_MS - 1` or greater:
         *      Set clock cycle counter back to 0,
         *      If count_up is high:
         *        Increment the millisecond counter.
         *      Else:
         *        Decrement the millisecond counter.
         *    Else:
         *      Increment the clock cycle counter by 1.
         *
         * Continuously assign timer_value to your milliseconds timer.
         *
         * Note: `CLKS_PER_MS` is the number of clock cycles in a millisecond - calculate this number.
         */

