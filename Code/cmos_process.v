module cmos_process(
	input				rst,
	input				clk,
	
	inout				cmos_scl,		//cmos i2c clock
	inout				cmos_sda,		//cmos i2c data
	

	input				pclk,
	input[7:0]			pdata_i,
	input				de_i,
	output[15:0]		pdata_o,
	output				hblank,
	output				de_o,
	
	input				cmos_vsync,
	output				write_req,
	output[1:0]			write_addr_index,
	output[1:0]			read_addr_index,
	input				write_req_ack
);

wire[9:0]		lut_index;
wire[31:0]		lut_data;




//I2C master controller
i2c_config i2c_config_m0(
	.rst			(rst			),
	.clk			(clk			),
	.clk_div_cnt	(16'd500		),
	.i2c_addr_2byte	(1'b1			),
	.lut_index		(lut_index		),
	.lut_dev_addr	(lut_data[31:24]),
	.lut_reg_addr	(lut_data[23:8]	),
	.lut_reg_data	(lut_data[7:0]	),
	.error			(				),
	.done			(				),
	.i2c_scl		(cmos_scl		),
	.i2c_sda		(cmos_sda		)
);
//configure look-up table
lut_ov5640_rgb565_1024_768 lut_ov5640_rgb565_1024_768_m0(
	.lut_index		(lut_index		),
	.lut_data		(lut_data		)
);

//CMOS sensor 8bit data is converted to 16bit data
cmos_8_16bit cmos_8_16bit_m0(
	.rst			(rst			),
	.pclk			(pclk			),
	.pdata_i		(pdata_i		),
	.de_i			(de_i			),
	.pdata_o		(pdata_o		),
	.hblank			(hblank			),
	.de_o			(de_o			)
);
//CMOS sensor writes the request and generates the read and write address index
cmos_write_req_gen cmos_write_req_gen_m0(
	.rst				(rst				),
	.pclk				(pclk				),
	.cmos_vsync			(cmos_vsync			),
	.write_req			(write_req			),
	.write_addr_index	(write_addr_index	),
	.read_addr_index	(read_addr_index	),
	.write_req_ack		(write_req_ack		)
);

endmodule