module sys_ctrl(
	input			clk,
	input			reset,
	input			key1,
	input			key2,
	input			key3,
	input			saved,
	
	input[1:0]		cmos_read_addr_index,
	input[1:0]		cmos_write_addr_index,
	input			cmos_write_req,
	input			cmos_de_O,
	input			cmos_pclk,
	input[15:0]		cmos_pdata_o,
	input[15:0]		sd_write_data,
	input			sd_write_en,
	input			sd_write_req,
	input			sd_card_clk,
	input			write_req_ack,
	
	output			page_up,
	output			page_down,
	output			photo_save,
	
	output[15:0]	write_data,
	output			write_en,
	output			write_req,
	output			write_clk,
	output[1:0]		read_addr_index,
	output[1:0]		write_addr_index,
	output			cmos_write_req_ack,
	output			sd_write_req_ack,
	output[23:0]	addr_0,
	output[23:0]	addr_1,
	output[23:0]	addr_2,
	output[23:0]	addr_3,
	
	input[15:0]		read_data,
	input			read_req_ack,
	input			vga_read_req,
	input			vga_clk,
	input			vga_read_en,
	input			save_read_req,
	
	output			vga_read_req_ack,
	output			save_read_req_ack,
	output			read_req,
	output[15:0]	vga_read_data,
	output[15:0]	save_read_data,
	output			read_clk,
	output			read_en,
	
	output			rst_n
);

wire[2:0]		mode;
wire			en_cam_view;
wire			en_gallery;
wire			en_photo_take;
wire			rst_not;



assign	rst_n			=	rst_not;
assign	en_cam_view		=	mode[0];
assign	en_gallery		=	mode[1];
assign	en_photo_take	=	mode[2];


key_ctrl key_ctrl_m0(
	.clk			(clk		),
	.reset			(reset		),
	.key1			(key1		),
	.key2			(key2		),
	.key3			(key3		),
	.saved			(saved		),
	.page_up		(page_up	),
	.page_down		(page_down	),
	.photo_save		(photo_save	),
	.mode_sel		(mode		),
	.rst_n			(rst_not	)
);
sdram_source_sel sdram_source_sel_m0(
	.en_cam_view			(en_cam_view			),
	.en_gallery				(en_gallery				),
	.en_photo_take			(en_photo_take			),
	.rst_n					(rst_not				),
	
	.cmos_read_addr_index	(cmos_read_addr_index	),
	.cmos_write_addr_index	(cmos_write_addr_index	),
	.cmos_write_req			(cmos_write_req		),
	.cmos_de_O				(cmos_de_O			),
	.cmos_pclk				(cmos_pclk			),
	.cmos_pdata_o			(cmos_pdata_o		),
	.sd_write_data			(sd_write_data		),
	.sd_write_en			(sd_write_en		),
	.sd_write_req			(sd_write_req		),
	.sd_write_clk			(sd_card_clk		),
	.write_req_ack			(write_req_ack		),
	.read_data				(read_data			),
	
	.write_data				(write_data			),
	.write_en				(write_en			),
	.write_req				(write_req			),
	.write_clk				(write_clk			),
	.read_addr_index		(read_addr_index	),
	.write_addr_index		(write_addr_index	),
	.cmos_write_req_ack		(cmos_write_req_ack	),
	.sd_write_req_ack		(sd_write_req_ack	),
	.addr_0					(addr_0				),
	.addr_1					(addr_1				),
	.addr_2					(addr_2				),
	.addr_3					(addr_3				),
);
sdram_target_sel sdram_target_sel_m0(
	.en_cam_view			(en_cam_view		),
	.en_gallery				(en_gallery			),
	.en_photo_take			(en_photo_take		),
	.rst_n					(rst_not			),
	.read_data				(read_data			),
	.read_req_ack			(read_req_ack		),
	.vga_read_req			(vga_read_req		),
	.vga_clk				(vga_clk			),
	.vga_read_en			(vga_read_en		),
	.save_read_req			(save_read_req		),
	.save_clk				(sd_card_clk		),
	
	.vga_read_req_ack		(vga_read_req_ack	),
	.save_read_req_ack		(save_read_req_ack	),
	.read_req				(read_req			),
	.vga_read_data			(vga_read_data		),
	.save_read_data			(save_read_data		),
	.read_clk				(read_clk			),
	.read_en				(read_en			)
);

endmodule