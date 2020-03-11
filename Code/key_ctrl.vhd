library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity key_ctrl is
port(
	clk:in std_logic;
	reset,key1,key2,key3:in std_logic;
	saved:in std_logic;
	page_up,page_down,photo_save:out std_logic;
	mode_sel:out std_logic_vector(2 downto 0);
	rst_n:out std_logic
);
end entity;

architecture behav of key_ctrl is
	signal key1_r1:std_logic;
	signal key1_r2:std_logic;
	signal key1_an:std_logic;
	signal key2_r1:std_logic;
	signal key2_r2:std_logic;
	signal key2_an:std_logic;
	signal key3_r1:std_logic;
	signal key3_r2:std_logic;
	signal key3_an:std_logic;
	signal rst1:std_logic;
	signal rst2:std_logic;
	signal rst_n_an:std_logic;
begin
	process(clk)
		type state_type is(k0,k1,k2);
		variable state:state_type;
	begin 
		if (rst_n_an='0') then
			state:=k0;
			photo_save<='0';
			page_up<='0';
			page_down<='0';
		elsif (clk'event and clk='1') then
		case state is
			when k0=>
				mode_sel<="001";
				if (key1_an='1') then
					state:=k2;
				elsif (key3_an='1') then
					state:=k1;
				end if;
      
			when k1=>
				mode_sel<="010";
				if (key1_an='1') then
					page_up<='1';
				else
					page_up<='0';
				end if;
				if (key2_an='1') then
					page_down<='1';
				else
					page_down<='0';
				end if;
				if (key3_an='1') then
					state:=k0;
				end if;
			when k2=>
				mode_sel<="100";
				if (key1_an='1') then
					photo_save<='1';
				else
					photo_save<='0';
				end if;
				if ((key2_an or key3_an or saved)='1') then
					state:=k0;
				end if;
		end case;
		end if;
	end process;
	
	rst_n<=rst_n_an;
	
	--key debounce
	process(clk)
	begin
		if (clk'event and clk='1') then
			key1_r1<=key1;
			key2_r1<=key2;
			key3_r1<=key3;
			rst1<=reset;
		end if;
	end process;
	process(clk)
	begin
		if (clk'event and clk='1') then
			key1_r2<=key1_r1;
			key2_r2<=key2_r1;
			key3_r2<=key3_r1;
			rst2<=rst1;
		end if;
	end process;
	key1_an<=key1_r2 and not key1_r1;
	key2_an<=key2_r2 and not key2_r1;
	key3_an<=key3_r2 and not key3_r1;
	rst_n_an<=rst1 or not rst2;
	
end behav;