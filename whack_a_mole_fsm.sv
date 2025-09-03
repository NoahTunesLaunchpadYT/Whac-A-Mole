module whack_a_mole_fsm #(
  parameter int unsigned MOLE_UP_MS    = 1000,
  parameter int unsigned MOLE_DOWN_MS  = 1000,
  parameter int unsigned MAX_TIMER_MS  = 20000,
  parameter int unsigned CLK_FREQ_HZ   = 50_000_000

)(
  input  logic 									clk,
  input  logic 									reset_button_pressed,
  input  logic 									start_button_pressed,
  input 	logic [$clog2(MAX_TIMER_MS):0] 	timer_milliseconds,

  output logic rst,               
  output logic game_in_progress,
  output logic mole_clk,
  
  // debug
  output logic [1:0] dbg_state,
  output logic 		mole_up_window
);

  // ----------------- constants -----------------
  localparam int unsigned PERIOD_MS = MOLE_UP_MS + MOLE_DOWN_MS;
  initial if (PERIOD_MS == 0) $fatal("PERIOD_MS must be > 0");

  localparam int PHW       = $clog2(PERIOD_MS);
  localparam int MS_TICKS  = CLK_FREQ_HZ / 1000;    // cycles per ms
  localparam int MSW_TICKS = $clog2(MS_TICKS);

  // ----------------- button edges -----------------
  logic start_q, reset_q;
  always_ff @(posedge clk) begin
    start_q <= start_button_pressed;
    reset_q <= reset_button_pressed;
  end
  wire start_btn_edge = start_button_pressed & ~start_q;
  wire reset_btn_edge = reset_button_pressed & ~reset_q;

  assign rst = reset_btn_edge;

  // ----------------- 1 ms tick generator -----------------
  logic [MSW_TICKS-1:0] ms_div_cnt;
  logic                 ms_tick;

  always_ff @(posedge clk) begin
    if (rst) begin
      ms_div_cnt <= 0;
      ms_tick    <= 0;
    end else if (ms_div_cnt == MS_TICKS-1) begin
      ms_div_cnt <= 0;
      ms_tick    <= 1;
    end else begin
      ms_div_cnt <= ms_div_cnt + 1;
      ms_tick    <= 0;
    end
  end

  // ----------------- phase counter -----------------
  logic [PHW-1:0] phase_ms;
  always_ff @(posedge clk) begin
    if (rst) begin
      phase_ms <= PERIOD_MS - 1;
    end else if (ms_tick) begin
      if (phase_ms == 0)
        phase_ms <= PERIOD_MS - 1;
      else
        phase_ms <= phase_ms - 1;
    end
  end

  // ----------------- predicates -----------------
	assign mole_up_window = (phase_ms >= MOLE_DOWN_MS[PHW-1:0]);
  wire game_over      = (timer_milliseconds <= 1);  // stop game when one full cycle done

  // ----------------- FSM -----------------
  typedef enum logic [1:0] { INIT, MOLE_UP, MOLE_DOWN, GAMEOVER } state_type;
  state_type curr_state, next_state;
	

  // next-state logic
  always_comb begin
	next_state = curr_state;
    case (curr_state)
      INIT:      next_state = (start_btn_edge) ? MOLE_UP : INIT;
      MOLE_UP:   next_state = game_over ? GAMEOVER : (mole_up_window ? MOLE_UP : MOLE_DOWN);
      MOLE_DOWN: next_state = game_over ? GAMEOVER : (mole_up_window ? MOLE_UP : MOLE_DOWN);
      GAMEOVER:  next_state = (start_btn_edge || reset_btn_edge) ? INIT : GAMEOVER;
		default:   next_state = curr_state; 
    endcase
  end

    // state register
  always_ff @(posedge clk) begin
    if (reset_button_pressed)
      curr_state <= INIT;
    else
      curr_state <= next_state;
  end
  
  // outputs
  always_comb begin
    game_in_progress = (curr_state == MOLE_UP) || (curr_state == MOLE_DOWN);
    mole_clk         = (curr_state == MOLE_UP);
    dbg_state        = curr_state;
  end

endmodule
