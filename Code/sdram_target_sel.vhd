LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY sdram_target_sel IS
PORT(
	en_cam_view:IN				std_logic;
	en_gallery:IN				std_logic;
	en_photo_take:IN			std_logic;
	rst_n:IN					std_logic;
	read_data:IN				std_logic_vector(15 DOWNTO 0);
	read_req_ack:IN				std_logic;
	vga_read_req:IN				std_logic;
	vga_clk:IN					std_logic;
	vga_read_en:IN				std_logic;
	save_read_req:IN			std_logic;
	save_clk:IN					std_logic;
	
	vga_read_req_ack:OUT		std_logic;
	save_read_req_ack:OUT		std_logic;
	read_req:OUT				std_logic;
	vga_read_data:OUT			std_logic_vector(15 DOWNTO 0);
	save_read_data:OUT			std_logic_vector(15 DOWNTO 0);
	read_clk:OUT				std_logic;
	read_en:OUT					std_logic
);
END ENTITY;

ARCHITECTURE behav OF sdram_target_sel IS
BEGIN
	PROCESS(en_cam_view,en_gallery,en_photo_take,rst_n)
	BEGIN
		IF(rst_n = '0')THEN
			vga_read_req_ack	<='0';
			save_read_req_ack	<='0';
			read_req			<='0';
			vga_read_data		<="0000000000000000";
			save_read_data		<="0000000000000000";
			read_clk			<='0';
			read_en				<='0';
		ELSIF(en_cam_view = '1' or en_gallery = '1')THEN
			vga_read_req_ack	<=read_req_ack;
			save_read_req_ack	<='0';
			read_req			<=vga_read_req;
			vga_read_data		<=read_data;
			save_read_data		<="0000000000000000";
			read_clk			<=vga_clk;
			read_en				<=vga_read_en;
		ELSIF(en_photo_take = '1')THEN
			vga_read_req_ack	<='0';
			save_read_req_ack	<=read_req_ack;
			read_req			<=save_read_req;
			vga_read_data		<="0000000000000000";
			save_read_data		<=read_data;
			read_clk			<=save_clk;
			read_en				<='1';
		ELSE
			read_req			<='0';
			read_en				<='0';
			read_clk			<='0';
		
		END IF;
	
	END PROCESS;

END behav;

