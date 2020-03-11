module sd_card_bmp(
	input			sd_card_clk,
	input			rst_n,
	input			page_up,
	input			page_down,
	output[3:0]		state_code,
	output			write_req,
	input			write_req_ack,
	output			bmp_data_wr_en,
	output[23:0]	bmp_data,
	
	input			video_clk,
	input			photo_save,
	input[15:0]		photo_data,
	input			read_req_ack,
	output			read_req,
	output			saved,
	
	input			SD_MISO,
	output			SD_DCLK,
	output			SD_MOSI,
	output			SD_nCS
);

wire			sd_sec_read;
wire[31:0]		sd_sec_read_addr;
wire[7:0]		sd_sec_read_data;
wire			sd_sec_read_data_valid;
wire			sd_sec_read_end;
wire			sd_init_done;
wire			sd_sec_write_data_req;
wire			sd_sec_write_end;
wire			sd_sec_write;
wire[31:0]		sd_sec_write_addr;
wire[7:0]		sd_sec_write_data;


//SD card BMP file read
bmp_read bmp_read_m0(
	.clk						(sd_card_clk			),
	.rst						(~rst_n					),
	.ready						(						),
	.page_up					(page_up				),
	.page_down					(page_down				),
	.sd_init_done				(sd_init_done			),	
	.state_code					(state_code				),
	.bmp_width					(16'h400				),
	.write_req					(write_req				),
	.write_req_ack				(write_req_ack			),
	.sd_sec_read				(sd_sec_read			),
	.sd_sec_read_addr			(sd_sec_read_addr		),
	.sd_sec_read_data			(sd_sec_read_data		),
	.sd_sec_read_data_valid		(sd_sec_read_data_valid	),
	.sd_sec_read_end			(sd_sec_read_end		),
	.bmp_data_wr_en				(bmp_data_wr_en			),
	.bmp_data					(bmp_data				)
);

bmp_write bmp_write_m0(
	.clk						(video_clk				),
	.rst						(~rst_n					),
	.photo_save					(photo_save				),
	.photo_data					(photo_data				),
	.sd_init_done				(sd_init_done			),
	.sd_sec_write_data_req		(sd_sec_write_data_req	),
	.sd_sec_write_end			(sd_sec_write_end		),
	.sd_sec_write				(sd_sec_write			),
	.sd_sec_write_addr			(sd_sec_write_addr		),
	.sd_sec_write_data			(sd_sec_write_data		),
	.read_req_ack				(read_req_ack			),
	.read_req					(read_req				),
	.saved						(saved					)
);


sd_card_top  sd_card_top_m0(
	.clk						(sd_card_clk			),
	.rst						(~rst_n					),
	.SD_nCS						(SD_nCS					),
	.SD_DCLK					(SD_DCLK				),
	.SD_MOSI					(SD_MOSI				),
	.SD_MISO					(SD_MISO				),
	.sd_init_done				(sd_init_done			),
	.sd_sec_read				(sd_sec_read			),
	.sd_sec_read_addr			(sd_sec_read_addr		),
	.sd_sec_read_data			(sd_sec_read_data		),
	.sd_sec_read_data_valid		(sd_sec_read_data_valid	),
	.sd_sec_read_end			(sd_sec_read_end		),
	.sd_sec_write				(sd_sec_write			),
	.sd_sec_write_addr			(sd_sec_write_addr		),
	.sd_sec_write_data			(sd_sec_write_data		),
	.sd_sec_write_data_req		(sd_sec_write_data_req	),
	.sd_sec_write_end			(sd_sec_write_end		)
);

endmodule 