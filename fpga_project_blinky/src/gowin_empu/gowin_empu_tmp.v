//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.10.03
//Part Number: GW1NSR-LV4CQN48PC7/I6
//Device: GW1NSR-4C
//Created Time: Sun Dec  8 19:55:27 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	Gowin_EMPU_Top your_instance_name(
		.sys_clk(sys_clk), //input sys_clk
		.gpioin(gpioin), //input [15:0] gpioin
		.gpioout(gpioout), //output [15:0] gpioout
		.gpioouten(gpioouten), //output [15:0] gpioouten
		.uart0_rxd(uart0_rxd), //input uart0_rxd
		.uart0_txd(uart0_txd), //output uart0_txd
		.reset_n(reset_n) //input reset_n
	);

//--------Copy end-------------------
