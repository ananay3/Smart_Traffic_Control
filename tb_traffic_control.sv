`timescale 1ns / 1ps

module tb_traffic_control;

    logic clk, rst_a;
    logic ped_request;
    logic [3:0] emergency_dir;
    logic [2:0] n_lights, s_lights, e_lights, w_lights;

    traffic_control dut (
        .clk(clk),
        .rst_a(rst_a),
        .ped_request(ped_request),
        .emergency_dir(emergency_dir),
        .n_lights(n_lights),
        .s_lights(s_lights),
        .e_lights(e_lights),
        .w_lights(w_lights)
    );

    // Clock generation: 100 MHz (10ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    // Initial reset and stimulus
    initial begin
        // Waveform dump
        $dumpfile("traffic_wave.vcd");
        $dumpvars(0, tb_traffic_control);

        // Init
        rst_a = 1;
        ped_request = 0;
        emergency_dir = 4'b0000;

        #20;
        rst_a = 0;

        // Normal operation
        #100;

        // Pedestrian request
        $display("===> Pedestrian presses button at time %0t", $time);
        ped_request = 1;
        #10;
        ped_request = 0;

        #200;

        // Emergency from South
        $display("===> Emergency vehicle detected at SOUTH at time %0t", $time);
        emergency_dir = 4'b0010;
        #30;
        emergency_dir = 4'b0000;

        #300;

        // Emergency from East
        $display("===> Emergency vehicle detected at EAST at time %0t", $time);
        emergency_dir = 4'b0100;
        #30;
        emergency_dir = 4'b0000;

        #300;
        $finish;
    end

    // Console waveform tracing
    always @(posedge clk) begin
        string dir = "None";
        if (n_lights == 3'b100) dir = "North-GREEN";
        else if (n_lights == 3'b010) dir = "North-YELLOW";
        else if (s_lights == 3'b100) dir = "South-GREEN";
        else if (s_lights == 3'b010) dir = "South-YELLOW";
        else if (e_lights == 3'b100) dir = "East-GREEN";
        else if (e_lights == 3'b010) dir = "East-YELLOW";
        else if (w_lights == 3'b100) dir = "West-GREEN";
        else if (w_lights == 3'b010) dir = "West-YELLOW";
        else dir = "ALL RED (Pedestrian or transition)";

        $display("[Time %0t]  Direction: %s | N: %b S: %b E: %b W: %b | Ped: %b | Emergency: %b",
                  $time, dir, n_lights, s_lights, e_lights, w_lights, ped_request, emergency_dir);
    end

endmodule
