
module Computer_System (
	avalon_telemetre_0_telemetre_trig,
	avalon_telemetre_0_telemetre_echo,
	avalon_telemetre_0_telemetre_readdata,
	hex3_hex0_export,
	hex5_hex4_export,
	leds_export,
	pushbuttons_export,
	sdram_addr,
	sdram_ba,
	sdram_cas_n,
	sdram_cke,
	sdram_cs_n,
	sdram_dq,
	sdram_dqm,
	sdram_ras_n,
	sdram_we_n,
	sdram_clk_clk,
	slider_switches_export,
	system_pll_ref_clk_clk,
	system_pll_ref_reset_reset,
	video_pll_ref_clk_clk,
	video_pll_ref_reset_reset);	

	output		avalon_telemetre_0_telemetre_trig;
	input		avalon_telemetre_0_telemetre_echo;
	output	[9:0]	avalon_telemetre_0_telemetre_readdata;
	output	[31:0]	hex3_hex0_export;
	output	[15:0]	hex5_hex4_export;
	output	[9:0]	leds_export;
	input	[1:0]	pushbuttons_export;
	output	[12:0]	sdram_addr;
	output	[1:0]	sdram_ba;
	output		sdram_cas_n;
	output		sdram_cke;
	output		sdram_cs_n;
	inout	[15:0]	sdram_dq;
	output	[1:0]	sdram_dqm;
	output		sdram_ras_n;
	output		sdram_we_n;
	output		sdram_clk_clk;
	input	[9:0]	slider_switches_export;
	input		system_pll_ref_clk_clk;
	input		system_pll_ref_reset_reset;
	input		video_pll_ref_clk_clk;
	input		video_pll_ref_reset_reset;
endmodule
