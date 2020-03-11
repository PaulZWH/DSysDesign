LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY sdram_source_sel IS
PORT(
	en_cam_view:IN				std_logic;
	en_gallery:IN				std_logic;
	en_photo_take:IN			std_logic;
	rst_n:IN					std_logic;
	cmos_read_addr_index:IN		std_logic_vector(1 DOWNTO 0);
	cmos_write_addr_index:IN	std_logic_vector(1 DOWNTO 0);
	cmos_write_req:IN			std_logic;
	cmos_de_O:IN				std_logic;
	cmos_pclk:IN				std_logic;
	cmos_pdata_o:IN				std_logic_vector(15 DOWNTO 0);
	sd_write_data:IN			std_logic_vector(15 DOWNTO 0);
	sd_write_en:IN				std_logic;
	sd_write_req:IN				std_logic;
	sd_write_clk:IN				std_logic;
	write_req_ack:IN			std_logic;
	read_data:IN				std_logic_vector(15 DOWNTO 0);
	
	write_data:OUT				std_logic_vector(15 DOWNTO 0);
	write_en:OUT				std_logic;
	write_req:OUT				std_logic;
	write_clk:OUT				std_logic;
	read_addr_index:OUT			std_logic_vector(1 DOWNTO 0);
	write_addr_index:OUT		std_logic_vector(1 DOWNTO 0);
	cmos_write_req_ack:OUT		std_logic;
	sd_write_req_ack:OUT		std_logic;
	addr_0:OUT					std_logic_vector(23 DOWNTO 0);
	addr_1:OUT					std_logic_vector(23 DOWNTO 0);
	addr_2:OUT					std_logic_vector(23 DOWNTO 0);
	addr_3:OUT					std_logic_vector(23 DOWNTO 0)
);
END ENTITY;

ARCHITECTURE behav OF sdram_source_sel IS
BEGIN
	addr_0<="000000000000000000000000";
	
	PROCESS(en_cam_view,en_gallery,en_photo_take,rst_n)
	BEGIN
		IF(rst_n = '0')THEN
			write_data			<="0000000000000000";
			write_en			<='0';
			write_req			<='0';
			write_clk			<='0';
			read_addr_index		<="00";
			write_addr_index	<="00";
			cmos_write_req_ack	<='0';
			sd_write_req_ack	<='0';
			addr_1				<="000000000000000000000000";
			addr_2				<="000000000000000000000000";
			addr_3				<="000000000000000000000000";
		ELSIF(en_cam_view = '1')THEN
			write_data			<=cmos_pdata_o;
			write_en			<=cmos_de_O;
			write_req			<=cmos_write_req;
			write_clk			<=cmos_pclk;
			read_addr_index		<=cmos_read_addr_index;
			write_addr_index	<=cmos_write_addr_index;
			cmos_write_req_ack	<=write_req_ack;
			sd_write_req_ack	<='0';
			addr_1				<="000111111010010000000000";	-- 24'd2073600
			addr_2				<="001111110100100000000000";	-- 24'd4147200
			addr_3				<="010111101110110000000000";	-- 24'd6220800
		ELSIF(en_gallery = '1')THEN
			write_data			<=sd_write_data;
			write_en			<=sd_write_en;
			write_req			<=sd_write_req;
			write_clk			<=sd_write_clk;
			read_addr_index		<="00";
			write_addr_index	<="00";
			cmos_write_req_ack	<='0';
			sd_write_req_ack	<=write_req_ack;
			addr_1				<="000000000000000000000000";
			addr_2				<="000000000000000000000000";
			addr_3				<="000000000000000000000000";
		ELSIF(en_photo_take = '1')THEN
			write_data			<=read_data;
			write_en			<=cmos_de_O;
			write_req			<=cmos_write_req;
			write_clk			<=cmos_pclk;
			read_addr_index		<=cmos_read_addr_index;
			write_addr_index	<=cmos_write_addr_index;
			cmos_write_req_ack	<=write_req_ack;
			sd_write_req_ack	<='0';
			addr_1				<="000111111010010000000000";	-- 24'd2073600
			addr_2				<="001111110100100000000000";	-- 24'd4147200
			addr_3				<="010111101110110000000000";	-- 24'd6220800
		ELSE
			write_req			<='0';
			write_en			<='0';
			write_clk			<='0';
		END IF;
	END PROCESS;
END behav;
		
			