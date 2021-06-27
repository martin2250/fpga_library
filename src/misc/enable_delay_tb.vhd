library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity enable_delay_tb is
	generic(runner_cfg : string);
end entity;

architecture RTL of enable_delay_tb is
	constant CLK_PERIOD : time := 100 ns;

	signal i_clk : std_logic := '1';
	signal i_rst : std_logic := '1';

	signal i_request : std_logic := '0';
begin
	i_clk <= not i_clk after CLK_PERIOD / 2;

	enable_delay : entity work.enable_delay
		generic map(
			G_PRE_CYCLES  => 15,
			G_POST_CYCLES => 20,
			G_INIT        => '0'
		)
		port map(
			i_clk     => i_clk,
			i_rst     => i_rst,
			i_request => i_request
		);

	main : process
	begin
		test_runner_setup(runner, runner_cfg);

		i_rst <= '1';
		wait for CLK_PERIOD * 10;
		i_rst <= '0';

		wait for CLK_PERIOD * 50;
		i_request <= '1';
		wait for CLK_PERIOD * 50;
		i_request <= '0';
		wait for CLK_PERIOD * 10;
		i_request <= '1';
		wait for CLK_PERIOD * 50;

		test_runner_cleanup(runner);
	end process;
end architecture RTL;
