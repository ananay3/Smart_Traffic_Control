//============================================================
// Module: traffic_control
// Description: 4-Way Smart Traffic Light Controller with
//              Pedestrian Override and Emergency Vehicle Priority
//============================================================

`timescale 1ns / 1ps

module traffic_control (
    input  logic        clk,
    input  logic        rst_a,
    input  logic        ped_request,           // Pedestrian button signal
    input  logic [3:0]  emergency_dir,         // [North, South, East, West]
    output logic [2:0]  n_lights,
    output logic [2:0]  s_lights,
    output logic [2:0]  e_lights,
    output logic [2:0]  w_lights
);

    // Light encodings
    localparam RED    = 3'b001;
    localparam YELLOW = 3'b010;
    localparam GREEN  = 3'b100;

    // FSM states
    typedef enum logic [3:0] {
        N_GREEN, N_YELLOW,
        S_GREEN, S_YELLOW,
        E_GREEN, E_YELLOW,
        W_GREEN, W_YELLOW,
        ALL_RED_PEDESTRIAN,
        N_EMERGENCY, S_EMERGENCY, E_EMERGENCY, W_EMERGENCY
    } state_t;

    state_t current_state, next_state;
    logic [3:0] counter;

    // Timing parameters
    localparam GREEN_TIME      = 4'd10;
    localparam YELLOW_TIME     = 4'd3;
    localparam PEDESTRIAN_TIME = 4'd5;
    localparam EMERGENCY_TIME  = 4'd6;

    // Sequential logic
    always_ff @(posedge clk or posedge rst_a) begin
        if (rst_a) begin
            current_state <= N_GREEN;
            counter <= 0;
        end else begin
            case (current_state)
                ALL_RED_PEDESTRIAN: begin
                    if (counter == PEDESTRIAN_TIME) begin
                        current_state <= N_GREEN;
                        counter <= 0;
                    end else counter <= counter + 1;
                end
                N_EMERGENCY, S_EMERGENCY, E_EMERGENCY, W_EMERGENCY: begin
                    if (counter == EMERGENCY_TIME) begin
                        current_state <= N_GREEN; // or rotate based on design
                        counter <= 0;
                    end else counter <= counter + 1;
                end
                default: begin
                    if (((current_state inside {N_GREEN, S_GREEN, E_GREEN, W_GREEN}) && counter == GREEN_TIME) ||
                        ((current_state inside {N_YELLOW, S_YELLOW, E_YELLOW, W_YELLOW}) && counter == YELLOW_TIME)) begin
                        current_state <= next_state;
                        counter <= 0;
                    end else counter <= counter + 1;
                end
            endcase
        end
    end

    // Next state logic
    always_comb begin
        // Emergency priority check
        if (emergency_dir[0]) next_state = N_EMERGENCY;
        else if (emergency_dir[1]) next_state = S_EMERGENCY;
        else if (emergency_dir[2]) next_state = E_EMERGENCY;
        else if (emergency_dir[3]) next_state = W_EMERGENCY;
        else if (ped_request) next_state = ALL_RED_PEDESTRIAN;
        else begin
            case (current_state)
                N_GREEN:   next_state = N_YELLOW;
                N_YELLOW:  next_state = S_GREEN;
                S_GREEN:   next_state = S_YELLOW;
                S_YELLOW:  next_state = E_GREEN;
                E_GREEN:   next_state = E_YELLOW;
                E_YELLOW:  next_state = W_GREEN;
                W_GREEN:   next_state = W_YELLOW;
                W_YELLOW:  next_state = N_GREEN;
                default:   next_state = N_GREEN;
            endcase
        end
    end

    // Output logic (Moore)
    always_comb begin
        n_lights = RED;
        s_lights = RED;
        e_lights = RED;
        w_lights = RED;

        case (current_state)
            N_GREEN, N_EMERGENCY: n_lights = GREEN;
            N_YELLOW:             n_lights = YELLOW;
            S_GREEN, S_EMERGENCY: s_lights = GREEN;
            S_YELLOW:             s_lights = YELLOW;
            E_GREEN, E_EMERGENCY: e_lights = GREEN;
            E_YELLOW:             e_lights = YELLOW;
            W_GREEN, W_EMERGENCY: w_lights = GREEN;
            W_YELLOW:             w_lights = YELLOW;
            ALL_RED_PEDESTRIAN: begin
                n_lights = RED;
                s_lights = RED;
                e_lights = RED;
                w_lights = RED;
            end
        endcase
    end

endmodule
