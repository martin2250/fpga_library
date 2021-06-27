library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
	generic(
		G_BITS      : natural := 8;
		G_STOP_BITS : natural := 1;
		G_DIVIDER   : natural := 10
	);
	port(
		i_clk    : in  std_logic;
		i_rst    : in  std_logic;
		-- input port
		i_in_dat : in  std_logic_vector(G_BITS - 1 downto 0);
		i_in_val : in  std_logic;
		o_in_rdy : out std_logic;
		-- serial
		o_serial : out std_logic
	);
end entity uart_tx;

architecture RTL of uart_tx is
	signal s_data    : std_logic_vector(G_BITS + G_STOP_BITS downto 0);
	signal s_serial  : std_logic_vector(0 downto 0);
	signal s_out_val : std_logic;
	signal s_in_rdy  : std_logic;
	signal s_out_rdy : std_logic;
	signal s_counter : natural range 0 to G_DIVIDER;
begin
	--	s_data <= (
	--		s_data'left                             => '0', -- start bit
	--		G_BITS + G_STOP_BITS downto G_STOP_BITS => i_in_dat,
	--		others                                  => '1' -- stop bits
	--	);
	--
	--	o_serial <= s_serial(0);
	--
	--	serializer : entity work.serializer
	--		generic map(
	--			G_WIDTH_IN  => s_data'length,
	--			G_WIDTH_OUT => 1,
	--			G_FIRST     => "MSB",
	--			G_IDLE      => "1"
	--		)
	--		port map(
	--			i_clk     => i_clk,
	--			i_rst     => i_rst,
	--			i_in_dat  => s_data,
	--			i_in_val  => i_in_val,
	--			o_in_rdy  => s_in_rdy,
	--			o_out_dat => s_serial,
	--			o_out_val => s_out_val,
	--			i_out_rdy => s_out_rdy
	--		);
	--
	--	s_out_rdy <= '1' when s_counter = 0 else '0';
	--	o_in_rdy  <= s_in_rdy;

	--	p_counter : process(i_clk)
	--	begin
	--		if rising_edge(i_clk) then
	--			if i_rst = '1' then
	--				v_counter := 0;
	--			else
	--				if v_counter > 0 then
	--					v_counter := v_counter - 1;
	--				end if;
	--				if (i_in_val and s_in_rdy) then
	--					v_counter := G_DIVIDER;
	--				end if;
	--			end if;
	--		end if;
	--	end process;
end architecture RTL;
