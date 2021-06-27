library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity serializer_tb is
	generic(runner_cfg : string);
end entity;

architecture RTL of serializer_tb is
	constant CLK_PERIOD  : time    := 100 ns;
	constant G_WIDTH_IN  : natural := 8;
	constant G_WIDTH_OUT : natural := 1;

	signal i_clk : std_logic := '1';
	signal i_rst : std_logic := '1';

	signal i_in_dat : std_logic_vector(G_WIDTH_IN - 1 downto 0);
	signal i_in_val : std_logic := '0';
	signal o_in_rdy : std_logic;

	signal o_out_dat : std_logic_vector(G_WIDTH_OUT - 1 downto 0);
	signal o_out_val : std_logic;
	signal i_out_rdy : std_logic := '1';
begin
	i_clk <= not i_clk after CLK_PERIOD / 2;

	p_in_val : process
	begin
		while true loop
			i_out_rdy <= '1';
			wait for CLK_PERIOD * 1;
			i_out_rdy <= '0';
			wait for CLK_PERIOD * 3;
		end loop;
	end process;

	serializer : entity work.serializer
		generic map(
			G_WIDTH_IN  => G_WIDTH_IN,
			G_WIDTH_OUT => G_WIDTH_OUT,
			G_FIRST     => "MSB"
		)
		port map(
			i_clk     => i_clk,
			i_rst     => i_rst,
			i_in_dat  => i_in_dat,
			i_in_val  => i_in_val,
			o_in_rdy  => o_in_rdy,
			o_out_dat => o_out_dat,
			o_out_val => o_out_val,
			i_out_rdy => i_out_rdy
		);

	main : process
		procedure serialize(p_dat : i_in_dat'subtype) is
		begin
			i_in_dat <= p_dat;
			i_in_val <= '1';
			wait until rising_edge(i_clk) and o_in_rdy = '1' for CLK_PERIOD * 100;
			i_in_val <= '0';
		end procedure;
	begin
		test_runner_setup(runner, runner_cfg);

		i_rst <= '1';
		wait for CLK_PERIOD * 10;
		i_rst <= '0';
		wait for CLK_PERIOD * 50;

		serialize(x"80");
		serialize(x"55");
		serialize(x"aa");
		serialize(x"87");

		wait for CLK_PERIOD * 50;
		serialize(x"46");
		wait for CLK_PERIOD * 50;
		serialize(x"77");

		wait for CLK_PERIOD * 200;

		test_runner_cleanup(runner);
	end process;
end architecture RTL;
