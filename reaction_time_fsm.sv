module reaction_time_fsm #(
    parameter MAX_MS=2047    
)(
    input                             clk,
    input                             button_pressed,
    input        [$clog2(MAX_MS)-1:0] timer_value,
    output logic                      reset,
    output logic                      up,
    output logic                      enable,
    output logic                      led_on
);

    logic button_q0, button_edge;

    always_ff @(posedge clk) begin : edge_detect
        button_q0 <= button_pressed;
    end : edge_detect
    assign button_edge = (button_pressed > button_q0);

    /* Complete remaining block here */


    // State typedef enum here! (See 3.1 code snippets)
    typedef enum logic [2:0] {Initialise, CountDown, CountUp, PauseTimer} state_type;
    state_type current_state, next_state;
    
    always_comb begin: next_state_logic
        case (current_state)
            Initialise: begin
                next_state = (button_edge) ? CountDown : Initialise;
            end
            CountDown: begin
                next_state = (timer_value == 0) ? CountUp : CountDown;
            end
            CountUp: begin
                next_state = (button_edge) ? PauseTimer : CountUp;
            end
            PauseTimer: begin
                next_state = (button_edge) ? Initialise : PauseTimer;
            end
            default: begin
                next_state = current_state;
            end
        endcase
    end
    // always_comb for next_state_logic here! (See 3.1 code snippets)
    // Set the default next state as the current state
    
    /* Complete code block here */
    
    // always_ff for FSM state variable flip-flops here! (See 3.1 code snippets)
    // Set the current state as the next state (Think about whether a blocking or non-blocking assignment should be used here)

    always_ff @(posedge clk) begin
        current_state <= next_state;
    end
    
    /* Complete code block here */

    // Continuously assign outputs of reset, up, enable and led_on based on the current state here! (See 3.1 code snippets)
    always_comb begin: output_logic
        reset = 0;
        up = 0;
        enable = 0;
        led_on = 0;

        case (current_state)
            Initialise: begin
                reset = 1;
                up = 0;
                enable = 0;
                led_on = 0;
            end
            CountDown: begin
                reset = (timer_value == 0);
                up = 1;
                enable = 1;
                led_on = 0;
            end
            CountUp: begin
                reset = 0;
                up = 0;
                enable = 1;
                led_on = 1;
            end
            PauseTimer: begin
                reset = 0;
                up = 0;
                enable = 0;
                led_on = 0;
            end
            default: begin
                reset = 0;
                up = 0;
                enable = 0;
                led_on = 0;
            end
        endcase
    end    

endmodule
