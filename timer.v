`timescale 1ns/1ns /* This directive (`) specifies simulation <time unit>/<time precision>. */

module timer #(
    parameter GAME_LENGTH_SECONDS = 20, 	// Legnth of a game
    parameter CLKS_PER_MS = 50000 			// What is the number of clock cycles in a millisecond?
) (
    input                       					clk,
    input                       					rst,
    input                       					enable,
	 
    output reg [$clog2(GAME_LENGTH_SECONDS)-1:0]	count_down_seconds,
    output [$clog2(1000*GAME_LENGTH_SECONDS)-1:0]	count_down_milliseconds
);

	localparam MS_PER_SECOND = 1000;
   
	reg [15:0] clk_cycles;
   reg [10:0] ms_within_second;
	
	assign count_down_milliseconds = MS_PER_SECOND * count_down_seconds + (MS_PER_SECOND - ms_within_second - 1);

	always @(posedge clk) begin
		if (rst) begin														// If the clock is reset
			clk_cycles <= 0;												// Set cycles to 0
			ms_within_second <= 0;										// Set ms in the second to 0
			count_down_seconds <= GAME_LENGTH_SECONDS;
		end 
		
		else if (enable) begin											// If game is running
			if (clk_cycles >= CLKS_PER_MS-1) begin					// If a millisecond has passed
				clk_cycles <= 0;											// Reset sub-millisecond counter

				if (ms_within_second >= MS_PER_SECOND-1) begin			// If second has elpased
					if (count_down_seconds != 0) begin						// If seconds != 0
						ms_within_second <= 0;									// Reset sub-second counter
						count_down_seconds <= count_down_seconds - 1;	// Decrease Seconds
					end																// Else, keep all values the same
				end 													
				else begin															
					ms_within_second <= ms_within_second + 1;				// If a second hasn't passed, keep counting
				end
			end
			else begin 
				 clk_cycles <= clk_cycles + 1;								// If a millisecond hasn't passed, keep counting
			end
		end
	end
endmodule
