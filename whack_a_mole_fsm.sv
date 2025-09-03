module whack_a_mole_fsm #(
	parameter MOLE_UP_MS 	= 1000,
	parameter MOLE_DOWN_MS 	= 1000,
	parameter MAX_TIMER_SEC	= 20,
	parameter MAX_TIMER_MS 	= 20000
)(
	input 										clk,
	input [$clog2(MAX_TIMER_SEC)-1:0]	timer_seconds,
	input [$clog2(MAX_TIMER_MS)-1:0]		timer_milliseconds,
	input 										reset_button_pressed,
	input 										start_button_pressed,
	
	
	output logic  								rst,
	output logic 								game_in_progress,
	output logic 								mole_clk
);
	
	localparam int unsigned PERIOD_MS = MOLE_UP_MS + MOLE_DOWN_MS;
	
	logic phase_ms = PERIOD_MS;
	always_ff @(posedge timer_milliseconds) begin: phase_counter
			if (phase_ms <= 0)
				phase_ms <= PERIOD_MS;
			else
				phase_ms <= phase_ms - 1;
	end: 
	
	
		
	// Button Edge Detection ----------------
	logic start_button_q0;
	logic reset_button_q0;
	
	always_ff @(posedge clk) begin: edge_detect
		start_button_q0 <= start_button_pressed;
		reset_button_q0 <= reset_button_pressed;
	end: edge_detect
	
//	wire start_btn_edge 	 = (start_button_pressed > start_button_q0);
	wire reset_btn_edge; 
	wire start_btn_edge; 
	assign start_btn_edge = start_button_pressed & ~start_button_q0;
	assign reset_btn_edge = reset_button_pressed & ~reset_button_q0;
		// Mealy rst output
	assign rst = reset_btn_edge;
	
	// States -------------------------------
	typedef enum logic [1:0] {INIT, MOLE_UP, MOLE_DOWN, GAMEOVER} state_type;
	state_type curr_state, next_state;
	
	
	// Logic --------------------------------
		// reset handling and curr->next states
	always_ff @(posedge clk) begin: reset_and_state_logic
		if (reset_btn_edge)
			curr_state <= INIT;
		else
			curr_state<= next_state;	
	end: reset_and_state_logic
	
		// Mole up and down window calc (slang for calculator gang)
	logic mole_up;
	assign mole_up = (phase > MOLE_DOWN_MS);
		
	
		// Next state logic
	always_comb begin: next_state_logic
		unique case(curr_state)
			INIT: begin
				next_state = (start_btn_edge) MOLE_UP ? INIT;
			end
			
			MOLE_UP: begin
				next_state = mole_up ? MOLE_UP : MOLE_DOWN
			end
			
			MOLE_DOWN: begin
				if (timer_milliseconds == 0)
					next_state = GAMEOVER;
				
				else
					next_state = mole_up ? MOLE_UP : MOLE_DOWN
			end
			
			
			GAMEOVER: begin
				next_state = (start_btn_edge || reset_btn_edge) ? INIT : GAMEOVER;
			end
			
			default: begin
				next_state = curr_state;
			end
		endcase
	end: next_state_logic
	
 	
	// FSM Output Logic ---------------------------
	always_comb begin: output_logic
		case(curr_state)
			INIT: begin
				game_in_progress = 1'b0;
				mole_clk			  = 1'b0;
			end
			
			MOLE_UP: begin
				game_in_progress = 1'b1;
				mole_clk 		  = 1'b1;
			end
			
			MOLE_DOWN: begin
				game_in_progress = 1'b1;
				mole_clk			  = 1'b0;
			end
			
			GAMEOVER: begin
				game_in_progress = 1'b0;
				mole_clk		     = 1'b0;
			end
			default: begin
				game_in_progress = 1'b0;
				mole_clk 		  = 1'b0;
			end
		endcase
	end
	
endmodule