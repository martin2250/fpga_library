library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity serializer is
	generic(
		G_WIDTH_IN  : natural                                    := 8;
		G_WIDTH_OUT : natural                                    := 1;
		G_FIRST     : string                                     := "MSB";
		G_IDLE      : std_logic_vector(G_WIDTH_OUT - 1 downto 0) := (others => '0')
	);
	port(
		i_clk     : in  std_logic;
		i_rst     : in  std_logic;
		-- input port
		i_in_dat  : in  std_logic_vector(G_WIDTH_IN - 1 downto 0);
		i_in_val  : in  std_logic;
		o_in_rdy  : out std_logic;
		-- output port
		o_out_dat : out std_logic_vector(G_WIDTH_OUT - 1 downto 0);
		o_out_val : out std_logic;
		i_out_rdy : in  std_logic
	);
end entity;

architecture rtl of serializer is
	constant COUNT     : natural                          := G_WIDTH_IN / G_WIDTH_OUT;
	signal s_shift_reg : std_logic_vector(i_in_dat'range) := (others => '0');
	signal s_shift_cnt : natural range 0 to COUNT         := 0;
begin
	assert (G_WIDTH_IN mod G_WIDTH_OUT) = 0 report "input width not divisible by output width" severity failure;
	assert G_FIRST = "MSB" or G_FIRST = "LSB" report "unsupported shift direction G_FIRST" severity failure;

	o_in_rdy <= '1' when (s_shift_cnt = 0) or (i_out_rdy = '1' and s_shift_cnt = 1) else '0';

	p_comb_data : process(s_shift_reg)
	begin
		if G_FIRST = "MSB" then
			o_out_dat <= s_shift_reg(G_WIDTH_IN - 1 downto G_WIDTH_IN - G_WIDTH_OUT);
		else
			o_out_dat <= s_shift_reg(G_WIDTH_OUT - 1 downto 0);
		end if;
	end process;

	p_cnt : process(i_clk)
		variable cnt_next : s_shift_cnt'subtype;
	begin
		if rising_edge(i_clk) then
			if i_rst = '1' then
				s_shift_reg <= (others => '0');
				s_shift_cnt <= 0;
				o_out_val   <= '0';
			else
				cnt_next    := s_shift_cnt;
				-- shift out data if available
				if s_shift_cnt > 0 and i_out_rdy = '1' then
					cnt_next := s_shift_cnt - 1;
					if G_FIRST = "MSB" then
						s_shift_reg <= s_shift_reg(G_WIDTH_IN - G_WIDTH_OUT - 1 downto 0) & G_IDLE;
					else
						s_shift_reg <= G_IDLE & s_shift_reg(G_WIDTH_IN - G_WIDTH_OUT - 1 downto 0);
					end if;
				end if;
				-- shift in new data if available
				if s_shift_cnt = 0 or (s_shift_cnt = 1 and i_out_rdy = '1') then
					if i_in_val = '1' then
						cnt_next    := COUNT;
						s_shift_reg <= i_in_dat;
					end if;
				end if;
				-- update variables
				s_shift_cnt <= cnt_next;
				o_out_val   <= '0' when cnt_next = 0 else '1';
			end if;
		end if;
	end process;
end architecture;
