// -------------------------------------------------------------------------------
// Copyright 2024 Koos du Preez (kdupreez@hotmail.com) - License SPDX BSD-2-Clause
// -------------------------------------------------------------------------------

//NOTES
//THIS PACKAGE (GW1NSR-LV4CQN48P) GCLK IS PIN 41, but the board has a 27Mhz xtal on pin 45 :(
// --- HARDWARE CONSTRAINTS:
//  IO_LOC "clk" 45;
//  IO_PORT "clk" IO_TYPE=LVCMOS33 PULL_MODE=NONE PCI_CLAMP=OFF BANK_VCCIO=3.3;
// --- TIMING CONSTRAINTS:
//  create_clock -name clk -period 37.037 -waveform {0 18.518} [get_ports {clk}]
// --- CLOCK CONSIDERATIONS:
/// Use a PLLVR with 27Mhz input to generate an output clock for "always @(posedge clkout)"

module tang4k_top (
    input wire clk_xtal,
    output wire led,
    input wire key1,
    input wire key2,
    output wire uart0_txd,
    input wire uart0_rxd
);

    // SETUP PLL
    wire clk_324; //0% tolerance PLLVR output for 324Mhz
    wire clk_54; //0% tolerance PLLVR output-d for 54Mhz
    Gowin_PLLVR my_pllvr(
        .clkout(clk_324),  // 324 MHz for FPGA
        .clkoutd(clk_54),  // 54 MHz for ARM Cortex M3
        .clkin(clk_xtal)   // Input clock
    );

    // GPIO wires/regs
    reg [15:0] gpio_m3;
    wire [15:0] gpio_m3_in;
    wire [15:0] gpio_m3_out;
    wire [15:0] gpio_m3_en;

    // gpio buffer will always send the current GPIO state to M3
    assign gpio_m3_in = gpio_m3;

    // Timer will reset after every 40.5M ticks..
    // Clock = 324Mhz / 40.5M = 8x togggles per second = 4x flashes per second.. 
    // i.e 324Mhz = 3.08642uS per tick * 40.M ticks = 125ms per toggle..
    reg [26:0] timer;
    localparam TIMER_MAX = 27'd40500000;
    reg led_d;

    //Initialize
    initial begin
        gpio_m3 <= 0;
        timer <= 0;
        led_d <= 0;
    end

    // Enable ARM Cortex M3 and assign FPGA resources
	Gowin_EMPU_Top my_m3(
		.sys_clk(clk_54),       //input sys_clk @ 54Mhz
		.gpioin(gpio_m3_in),    //input [15:0] gpio in to M3
		.gpioout(gpio_m3_out),  //output [15:0] gpio out from M3
		.gpioouten(gpio_m3_en), //output [15:0] gpio out enable bt M3
		.uart0_rxd(uart0_rxd),  //input uart0_rxd
		.uart0_txd(uart0_txd),  //output uart0_txd
		.reset_n(key1)          //input reset_n
	);

    //hard assign led to led_d buffer when key2 is pressed, else assign to gpio_m3[0]
    assign led = (~key2) ? led_d : gpio_m3[0];

    always @(posedge clk_324) 
    begin
        
        // For all GPIO_ENABLE[n] = 1, Copy GPIO_OUT[n] values to GPIO[n] buffer.
        // i.e. M3 out values always win..
        gpio_m3 <= (gpio_m3 & ~gpio_m3_en) | (gpio_m3_out & gpio_m3_en); 

        //timer logic to toggle a LED buffer
        if (timer == TIMER_MAX) begin
            led_d <= ~led_d;
            timer <= 0;
        end else begin
            timer <= timer + 1'b1;
        end

    end

endmodule
