library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity enable_delay is
	generic(
		G_PRE_CYCLES  : natural   := 127;
		G_POST_CYCLES : natural   := 127;
		G_INIT        : std_logic := '0'
	);
	port(
		i_clk     : in  std_logic;
		i_rst     : in  std_logic;
		-- input
		i_request : in  std_logic;
		-- output
		o_enabled : out std_logic;      -- goes high immediately and stays high for POST_CYCLES
		o_active  : out std_logic       -- goes high after PRE_CYCLES and goes low immediately
	);
end entity enable_delay;

architecture RTL of enable_delay is
	constant CTR_MAX    : natural := maximum(G_PRE_CYCLES, G_POST_CYCLES);
	signal counter      : natural range 0 to CTR_MAX - 1;
	signal request_last : std_logic;
	signal active       : std_logic;
	signal enabled      : std_logic;
begin

	p_count : process(i_clk)
	begin
		if rising_edge(i_clk) then
			request_last <= i_request;
			if i_rst = '1' then
				counter <= 0;
			else
				if i_request /= request_last then
					if i_request = '0' then
						counter <= G_POST_CYCLES - 1;
					else
						counter <= G_PRE_CYCLES - 1;
					end if;
				elsif counter > 0 then
					counter <= counter - 1;
				end if;
			end if;
		end if;
	end process;

	o_active  <= active and i_request;
	o_enabled <= enabled or i_request;

	p_main : process(i_clk)
	begin
		if rising_edge(i_clk) then
			if i_rst = '1' then
				enabled <= G_INIT;
				active  <= G_INIT;
			else
				if i_request = '1' then
					enabled <= '1';
					if counter = 0 and enabled = '1' then
						active <= '1';
					end if;
				else
					active <= '0';
					if counter = 0 and active = '0' then
						enabled <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;

end architecture RTL;
