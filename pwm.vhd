--------------------------------------------------------------------------------------
-- Filename : pwm.vhd
--
--Author : mahesh15230 <mahesh15230@mechyd.ac.in>
--
--Copyright (c) 2018 mahesh15230
--------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
--
entity PWM is
Generic (
	BIT_SIZE	: integer := 8;
	INPUT_CLK	: integer := 50000000;
	FREQ		: integer := 500);
Port (
	pwm_out 	: out std_logic;
	dutycycle	: in std_logic_vector(BIT_SIZE - 1 downto 0);
	clk			: in std_logic;
	reset		: in std_logic);
end PWM;
--
architecture RTL of PWM is

	constant max_freq_count	: integer := INPUT_CLK / FREQ;
	signal pwm_count	    : integer range 0 to max_freq_count := 0;

begin

	max_pwm_count <= to_integer(unsigned(dutycycle));

	proc_pwm : process(clk, reset)

	begin
        if reset = '0' then
            pwm_count <= '0';
            pwm_out <= '0';
        elsif rising_edge(clk) then
			if pwm_count < max_pwm_count then
				pwm_out <= '1';
				pwm_count <= pwm_count + 1;
			else
				if pwm_count = max_freq_count then
					pwm_count <= '0';
                    pwm_out <= '0';
				else
					pwm_out <= '0';
					pwm_count <= pwm_count + 1;
				end if;
			end if;
		end if;
	end process proc_pwm;
end RTL;
