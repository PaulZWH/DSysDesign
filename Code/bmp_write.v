module bmp_write(
	input				clk,
	input				rst,
	input				photo_save,
	input[15:0]			photo_data,
	input				sd_init_done,			//SD card initialization completed
	
	input				sd_sec_write_data_req,	//SD card sector write data next clock is valid
	input				sd_sec_write_end,		//SD card sector write end
	output reg			sd_sec_write,			//SD card sector write
	output reg[31:0]	sd_sec_write_addr,		//SD card sector write address
	output reg[7:0]		sd_sec_write_data,		//SD card sector write data
	
	input				read_req_ack,
	output reg			read_req,
	
	output reg			saved
);
localparam S_IDLE		= 0;
localparam S_WRITE_HEAD	= 1;
localparam S_WRITE		= 2;
localparam S_END		= 3;

localparam HEADER_SIZE	= 54;

reg[3:0]		state;
reg[9:0]		head_cnt;			//sector write length counter
reg[24:0]		bmp_len_cnt;		//bmp file length counter
reg[1:0]		bmp_len_cnt_tmp;	//bmp RGB counter 0 1 2
reg				head_end;
reg				data_end;


always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		head_cnt <= 10'd0;
	else if(state == S_WRITE_HEAD)
	begin	
		if(sd_sec_write_data_req == 1'b1)
			head_cnt <= head_cnt + 10'd1;
	end
	else
		head_cnt <= 10'd0;
end

//bmp file length counter
always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		bmp_len_cnt <= 24'd0;
	else if(state == S_WRITE)
	begin
		if(sd_sec_write_data_req == 1'b1)
			bmp_len_cnt <= bmp_len_cnt + 24'd1;
	end
	else if(state == S_END)
		bmp_len_cnt <= 24'd0;
end

//bmp RGB counter
always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		bmp_len_cnt_tmp <= 2'd0;
	else if(state == S_WRITE)
	begin
		if(sd_sec_write_data_req == 1'b1)
			bmp_len_cnt_tmp <= bmp_len_cnt_tmp == 2'd2 ? 2'd0 : bmp_len_cnt_tmp + 2'd1;
	end
	else
		bmp_len_cnt_tmp <= 2'd0;
end


always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
	begin
		head_end <= 1'b0;
		data_end <= 1'b0;
		sd_sec_write_data <= 8'd0;
	end
	else if(sd_sec_write_data_req)
	begin
		if(state == S_WRITE_HEAD)
		begin
			if(head_cnt >= 10'd54)
				head_end <= 1'b1;
			else
			begin
				head_end <= 1'b0;
				//file header
				if(head_cnt == 10'd0)
					sd_sec_write_data <= "B";
				if(head_cnt == 10'd1)
					sd_sec_write_data <= "M";
				//file length--1024*768*3+54
				if(head_cnt == 10'd2)
					sd_sec_write_data <= 8'b110110;
				if(head_cnt == 10'd3)
					sd_sec_write_data <= 8'b0;
				if(head_cnt == 10'd4)
					sd_sec_write_data <= 8'b100100;
				if(head_cnt == 10'd5)
					sd_sec_write_data <= 8'b0;
				//hold
				if(head_cnt == 10'd6)
					sd_sec_write_data <= 8'b0;
				if(head_cnt == 10'd7)
					sd_sec_write_data <= 8'b0;
				if(head_cnt == 10'd8)
					sd_sec_write_data <= 8'b0;
				if(head_cnt == 10'd9)
					sd_sec_write_data <= 8'b0;
				//offset--54
				if(head_cnt == 10'd10)
					sd_sec_write_data <= 8'b110110;
				if(head_cnt == 10'd11)
					sd_sec_write_data <= 8'b0;
				if(head_cnt == 10'd12)
					sd_sec_write_data <= 8'b0;
				if(head_cnt == 10'd13)
					sd_sec_write_data <= 8'b0;
				if(head_cnt == 10'd14)
					sd_sec_write_data <= 8'b101000;
				if(head_cnt == 10'd15)
					sd_sec_write_data <= 8'b0;	
				if(head_cnt == 10'd16)
					sd_sec_write_data <= 8'b0;
				if(head_cnt == 10'd17)
					sd_sec_write_data <= 8'b0;
				//image width--1024
				if(head_cnt == 10'd18)
					sd_sec_write_data <= 8'b0;
				if(head_cnt == 10'd19)
					sd_sec_write_data <= 8'b100;
				if(head_cnt == 10'd20)
					sd_sec_write_data <= 8'b0;
				if(head_cnt == 10'd21)
					sd_sec_write_data <= 8'b0;
				//image height--768
				if(head_cnt == 10'd22)
					sd_sec_write_data <= 8'b0;
				if(head_cnt == 10'd23)
					sd_sec_write_data <= 8'b11;
				if(head_cnt == 10'd24)
					sd_sec_write_data <= 8'b0;
				if(head_cnt == 10'd25)
					sd_sec_write_data <= 8'b0;
				//bit plane--1
				if(head_cnt == 10'd26)
					sd_sec_write_data <= 8'b1;
				if(head_cnt == 10'd27)
					sd_sec_write_data <= 8'b0;
				//bit per pixel--24
				if(head_cnt == 10'd28)
					sd_sec_write_data <= 8'b11000;
				if(head_cnt == 10'd29)
					sd_sec_write_data <= 8'b0;
				//pack
				if(head_cnt == 10'd30)
					sd_sec_write_data <= 8'b0;
				if(head_cnt == 10'd31)
					sd_sec_write_data <= 8'b0;
				if(head_cnt == 10'd32)
					sd_sec_write_data <= 8'b0;
				if(head_cnt == 10'd33)
					sd_sec_write_data <= 8'b0;
				//byte size
				if(head_cnt == 10'd34)
					sd_sec_write_data <= 8'b0;
				if(head_cnt == 10'd35)
					sd_sec_write_data <= 8'b0;
				if(head_cnt == 10'd36)
					sd_sec_write_data <= 8'b100100;
				if(head_cnt == 10'd37)
					sd_sec_write_data <= 8'b0;
				//resolution ratio
				if(head_cnt == 10'd38)
					sd_sec_write_data <= 8'b10000000;
				if(head_cnt == 10'd39)
					sd_sec_write_data <= 8'b10000100;
				if(head_cnt == 10'd40)
					sd_sec_write_data <= 8'b11110;
				if(head_cnt == 10'd41)
					sd_sec_write_data <= 8'b0;
				if(head_cnt == 10'd42)
					sd_sec_write_data <= 8'b10000000;
				if(head_cnt == 10'd43)
					sd_sec_write_data <= 8'b10000100;
				if(head_cnt == 10'd44)
					sd_sec_write_data <= 8'b11110;
				if(head_cnt == 10'd45)
					sd_sec_write_data <= 8'b0;
				if(head_cnt >= 10'd46 && head_cnt <= 10'd52)
					sd_sec_write_data <= 8'b0;
				if(head_cnt == 10'd53)
					sd_sec_write_data <= 8'b0;
			end
		end
		else if(state == S_WRITE)
		begin
			if(bmp_len_cnt >= 24'h240000)
			begin
				data_end <= 1'b1;
			end
			else if(bmp_len_cnt_tmp == 2'd2)
			begin
				sd_sec_write_data[7:3] <= photo_data[15:11];
				sd_sec_write_data[2:0] <= 3'b0;
			end
			else if(bmp_len_cnt_tmp == 2'd1)
			begin
				sd_sec_write_data[7:2] <= photo_data[10:5];
				sd_sec_write_data[1:0] <= 2'b0;
			end
			else if(bmp_len_cnt_tmp == 2'd0)
			begin
				read_req <= 1'b1;
				sd_sec_write_data[7:3] <= photo_data[4:0];
				sd_sec_write_data[2:0] <= 3'b0;
			end
			else if(read_req_ack == 1'b1)
				read_req <= 1'b0;
		end
	end
end


always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
	begin
		state <= S_IDLE;
		sd_sec_write <= 1'b0;
		sd_sec_write_addr <= 32'd32000;
		saved <= 1'b0;
	end
	else if(sd_init_done == 1'b0)
	begin
		state <= S_IDLE;
	end
	else
		case(state)
			S_IDLE:
			begin
				saved <= 1'b0;
				if(photo_save == 1'b1)
				begin
					state <= S_WRITE_HEAD;
				end
				sd_sec_write_addr <= {sd_sec_write_addr[31:3],3'd0};//address 8 aligned
			end
			S_WRITE_HEAD:
			begin
				if(sd_sec_write_end == 1'b1)
				begin
					sd_sec_write <= 1'b0;
					state <= S_END;
				end
				else if(head_end == 1'b1)
				begin
					state <= S_WRITE;
				end
				else
				begin
					sd_sec_write_addr <= sd_sec_write_addr + 32'd8;
					sd_sec_write <= 1'b1;
				end
			end
			
			S_WRITE:
			begin
				if(sd_sec_write_end == 1'b1)
				begin
					sd_sec_write <= 1'b0;
					state <= S_END;
				end
				else if(data_end == 1'b1)
				begin
					state <= S_END;
				end
				else
				begin
					sd_sec_write_addr <= sd_sec_write_addr + 32'd8;
					sd_sec_write <= 1'b1;
				end
			end
			
			S_END:
			begin
				saved <= 1'b1;
				state <= S_IDLE;
			end
			default:
				state <= S_IDLE;
		endcase
end

endmodule

