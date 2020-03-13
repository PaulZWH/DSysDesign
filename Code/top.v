module top(
	input				clk,
	input				reset,
	input				key1,
	input				key2,
	input				key3,
	
	inout				cmos_scl,		//cmos i2c clock
	inout				cmos_sda,		//cmos i2c data
	input				cmos_vsync,		//cmos vsync
	input				cmos_href,		//cmos hsync refrence,data valid
	input				cmos_pclk,		//cmos pxiel clock
	input[7:0]			cmos_db,		//cmos data
	
	
	output				vga_out_hs,		//vga horizontal synchronization
	output				vga_out_vs,		//vga vertical synchronization
	output[4:0]			vga_out_r,		//vga red
	output[5:0]			vga_out_g,		//vga green
	output[4:0]			vga_out_b,		//vga blue
	
	output				cmos_xclk,		//cmos externl clock
	output				cmos_rst_n,		//cmos reset
	output				cmos_pwdn,		//cmos power down
	
	output				sdram_clk,		//sdram clock
	output				sdram_cke,		//sdram clock enable
	output				sdram_cs_n,		//sdram chip select
	output				sdram_we_n,		//sdram write enable
	output				sdram_cas_n,	//sdram column address strobe
	output				sdram_ras_n,	//sdram row address strobe
	output[1:0]			sdram_dqm,		//sdram data enable
	output[1:0]			sdram_ba,		//sdram bank address
	output[12:0]		sdram_addr,		//sdram address
	inout[15:0]			sdram_dq,		//sdram data
	
	output				SD_nCS,			//SD card chip select (SPI mode)
	output				SD_DCLK,		//SD card clock
	output				SD_MOSI,		//SD card controller data output
	input				SD_MISO			//SD card controller data input
	
//	output [5:0]		seg_sel,
//	output [7:0]		seg_data
);

wire			rst_n;
wire			saved;

wire			page_up;
wire			page_down;
wire			photo_save;

wire			hs;
wire			vs;
wire			video_clk;		//video pixel clock
wire[15:0]		vout_data;


wire[15:0]		cmos_16bit_data;
wire			cmos_16bit_wr;
wire			cmos_wr_req;
wire			cmos_wr_req_ack;
wire[1:0]		cmos_wr_addr_index;
wire[1:0]		cmos_r_addr_index;

wire			ext_mem_clk;	//external memory clock
wire			addr_0;
wire			addr_1;
wire			addr_2;
wire			addr_3;

wire			wr_burst_data_req;
wire			wr_burst_finish;
wire			rd_burst_finish;
wire			rd_burst_req;
wire			wr_burst_req;
wire[9:0]		rd_burst_len;	//external memory user interface data width 10
wire[9:0]		wr_burst_len;
wire[23:0]		rd_burst_addr;	//external memory user interface address width 24
wire[23:0]		wr_burst_addr;
wire			rd_burst_data_valid;
wire[15: 0]		rd_burst_data;	//external memory user interface burst width 15
wire[15: 0]		wr_burst_data;
wire			read_req;
wire			read_req_ack;
wire			read_en;
wire[15:0]		read_data;
wire			write_en;
wire[15:0]		write_data;
wire			write_req;
wire			write_req_ack;

wire			sd_card_clk;	//SD card controller clock

wire[15:0]		sd_write_data;
wire			sd_write_en;
wire			sd_write_req;

wire			sd_wr_req_ack;

wire[3:0]		state_code;
//wire[6:0]		seg_data_0;

wire			save_read_req_ack;
wire			save_read_req;
wire[15:0]		save_read_data;
wire			vga_read_req;
wire			vga_read_req_ack;
wire			vga_read_en;
wire[15:0]		vga_read_data;

assign	vga_out_hs	=	hs;
assign	vga_out_vs	=	vs;
assign	vga_out_r	=	vout_data[15:11];
assign	vga_out_g	=	vout_data[10:5];
assign	vga_out_b	=	vout_data[4:0];

assign	sdram_clk	=	ext_mem_clk;

assign	cmos_rst_n	=	1'b1;
assign	cmos_pwdn	=	1'b0;

//24bit RGB converts to 16bit rgb565
wire[23:0]		bmp_data;
assign sd_write_data = {bmp_data[23:19],bmp_data[15:10],bmp_data[7:3]};

sys_ctrl sys_ctrl_m0
(
	.clk			(clk		),
	.reset			(reset		),
	.key1			(key1		),
	.key2			(key2		),
	.key3			(key3		),
	.saved			(saved		),
	.page_up		(page_up	),
	.page_down		(page_down	),
	.photo_save		(photo_save	),
	.rst_n			(rst_n		),
	
	.cmos_read_addr_index	(cmos_r_addr_index	),
	.cmos_write_addr_index	(cmos_wr_addr_index	),
	.cmos_write_req			(cmos_wr_req		),
	.cmos_de_O				(cmos_16bit_wr		),
	.cmos_pclk				(cmos_pclk			),
	.cmos_pdata_o			(cmos_16bit_data	),
	.sd_write_data			(sd_write_data		),
	.sd_write_en			(sd_write_en		),
	.sd_write_req			(sd_write_req		),
	.sd_card_clk			(sd_card_clk		),
	.write_req_ack			(write_req_ack		),
	
	.write_data				(write_data			),
	.write_en				(write_en			),
	.write_req				(write_req			),
	.write_clk				(write_clk			),
	.read_addr_index		(read_addr_index	),
	.write_addr_index		(write_addr_index	),
	.cmos_write_req_ack		(cmos_wr_req_ack	),
	.sd_write_req_ack		(sd_wr_req_ack		),
	.addr_0					(addr_0				),
	.addr_1					(addr_1				),
	.addr_2					(addr_2				),
	.addr_3					(addr_3				),
	
	.read_data				(read_data			),
	.read_req_ack			(read_req_ack		),
	.vga_read_req			(vga_read_req		),
	.vga_clk				(video_clk			),
	.vga_read_en			(vga_read_en		),
	.save_read_req			(save_read_req		),
	
	.vga_read_req_ack		(vga_read_req_ack	),
	.save_read_req_ack		(save_read_req_ack	),
	.read_req				(read_req			),
	.vga_read_data			(vga_read_data		),
	.save_read_data			(save_read_data		),
	.read_clk				(read_clk			),
	.read_en				(read_en			)
);

//generate SD card controller clock, SDRAM controller clock and the CMOS sensor clock
sys_pll sys_pll_m0(
	.inclk0			(clk		),
	.c0				(cmos_xclk	),	//24MHz
	.c1				(ext_mem_clk),	//100MHz
	.c2				(sd_card_clk)	//100MHz
);
//generate video pixel clock	
video_pll video_pll_m0(
	.inclk0			(clk		),
	.c0				(video_clk	)	//65MHz
);

//The video output timing generator and generate a frame read data request
video_timing_data video_timing_data_m0
(
	.video_clk		(video_clk			),
	.rst			(~rst_n				),
	.read_req		(vga_read_req		),
	.read_req_ack	(vga_read_req_ack	),
	.read_en		(vga_read_en		),
	.read_data		(vga_read_data		),
	.hs				(hs					),
	.vs				(vs					),
	.de				(					),
	.vout_data		(vout_data			)
);	

cmos_process cmos_process_m0
(
	.rst				(~rst_n				),
	.clk				(clk				),
	.cmos_scl			(cmos_scl			),
	.cmos_sda			(cmos_sda			),
	.pclk				(cmos_pclk			),
	.pdata_i			(cmos_db			),
	.de_i				(cmos_href			),
	.pdata_o			(cmos_16bit_data	),
	.hblank				(					),
	.de_o				(cmos_16bit_wr		),
	.cmos_vsync			(cmos_vsync			),
	.write_req			(cmos_wr_req		),
	.write_addr_index	(cmos_wr_addr_index	),
	.read_addr_index	(cmos_r_addr_index	),
	.write_req_ack		(cmos_wr_req_ack	)
);

//video frame data read-write control
frame_read_write frame_read_write_m0
(
	.rst					(~rst_n				),
	.mem_clk				(ext_mem_clk		),
	.rd_burst_req			(rd_burst_req		),
	.rd_burst_len			(rd_burst_len		),
	.rd_burst_addr			(rd_burst_addr		),
	.rd_burst_data_valid	(rd_burst_data_valid),
	.rd_burst_data			(rd_burst_data		),
	.rd_burst_finish		(rd_burst_finish	),
	.read_clk				(video_clk			),
	.read_req				(read_req			),
	.read_req_ack			(read_req_ack		),
	.read_finish			(					),
	.read_addr_0			(addr_0				), //The first frame address is 0
	.read_addr_1			(addr_1				), //The second frame address is 24'd2073600 ,large enough address space for one frame of video
	.read_addr_2			(addr_2				),
	.read_addr_3			(addr_3				),
	.read_addr_index		(read_addr_index	),
	.read_len				(24'd786432			), //frame size
	.read_en				(read_en			),
	.read_data				(read_data			),

	.wr_burst_req			(wr_burst_req		),
	.wr_burst_len			(wr_burst_len		),
	.wr_burst_addr			(wr_burst_addr		),
	.wr_burst_data_req		(wr_burst_data_req	),
	.wr_burst_data			(wr_burst_data		),
	.wr_burst_finish		(wr_burst_finish	),
	.write_clk				(cmos_pclk			),
	.write_req				(write_req			),
	.write_req_ack			(write_req_ack		),
	.write_finish			(					),
	.write_addr_0			(addr_0				),
	.write_addr_1			(addr_1				),
	.write_addr_2			(addr_2				),
	.write_addr_3			(addr_3				),
	.write_addr_index		(write_addr_index	),
	.write_len				(24'd786432			), //frame size
	.write_en				(write_en			),
	.write_data				(write_data			)
);
//sdram controller
sdram_core sdram_core_m0
(
	.rst					(~rst_n				),
	.clk					(ext_mem_clk		),
	.rd_burst_req			(rd_burst_req		),
	.rd_burst_len			(rd_burst_len		),
	.rd_burst_addr			(rd_burst_addr		),
	.rd_burst_data_valid	(rd_burst_data_valid),
	.rd_burst_data			(rd_burst_data		),
	.rd_burst_finish		(rd_burst_finish	),
	.wr_burst_req			(wr_burst_req		),
	.wr_burst_len			(wr_burst_len		),
	.wr_burst_addr			(wr_burst_addr		),
	.wr_burst_data_req		(wr_burst_data_req	),
	.wr_burst_data			(wr_burst_data		),
	.wr_burst_finish		(wr_burst_finish	),
	.sdram_cke				(sdram_cke			),
	.sdram_cs_n				(sdram_cs_n			),
	.sdram_ras_n			(sdram_ras_n		),
	.sdram_cas_n			(sdram_cas_n		),
	.sdram_we_n				(sdram_we_n			),
	.sdram_dqm				(sdram_dqm			),
	.sdram_ba				(sdram_ba			),
	.sdram_addr				(sdram_addr			),
	.sdram_dq				(sdram_dq			)
);

sd_card_bmp sd_card_bmp_m0(
	.sd_card_clk			(sd_card_clk		),
	.video_clk				(video_clk			),
	.rst_n					(rst_n				),
	.page_up				(page_up			),
	.page_down				(page_down			),
	.state_code				(state_code			),
	.write_req				(sd_write_req		),
	.write_req_ack			(sd_wr_req_ack		),
	.bmp_data_wr_en			(sd_write_en		),
	.bmp_data				(bmp_data			),
	.photo_save				(photo_save			),
	.photo_data				(save_read_data		),
	.read_req_ack			(save_read_req_ack	),
	.read_req				(save_read_req		),
	.saved					(saved				),
	.SD_nCS					(SD_nCS				),
	.SD_DCLK				(SD_DCLK			),
	.SD_MOSI				(SD_MOSI			),
	.SD_MISO				(SD_MISO			)	
);

endmodule