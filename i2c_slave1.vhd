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

entity i2c_slave is
    generic(
        ADDR      : std_logic_vector( 6 downto 0 );
        REG1_ADDR : std_logic_vector( 7 downto 0 );
        REG2_ADDR : std_logic_vector( 7 downto 0 )
    );
    port(
        clk   : in std_logic;
        reset : in std_logic;
        sda   : inout std_logic;
        scl   : inout std_logic;
        ack   : inout std_logic
    );
end i2c_slave;

architecture RTL of i2c_slave is
    signal slave_addr     : std_logic_vector( 6 downto 0 );
    signal rw_bit         : std_logic;
    signal reg_slave_full : std_logic_vector( 7 downto 0 );
    signal reg_addr       : std_logic_vector( 7 downto 0 );
    signal data_reg       : std_logic_vector( 7 downto 0 ); -- Address of data_reg is reg_addr
    signal addr_check     : std_logic := '0';
    signal reg_check      : std_logic := '0';
    slave_addr_shiftreg : entity work.sipo
    generic map (
        BIT_SIZE := 7
    );
    port map (
        sipo_out   => slave_addr;
        sipo_in    => sda;
        sipo_clk   => clk;
        sipo_reset => reset
    );
    red_addr_shiftreg : entity work.sipo
    generic map (
        BIT_SIZE := 8
    );
    port map (
        sipo_out   => reg_addr;
        sipo_in    => sda;
        sipo_clk   => clk;
        sipo_reset => reset
    );
    data_reg_shiftreg : entity work.sipo
    generic map (
        BIT_SIZE := 8
    );
    port map (
        sipo_out   => data_addr;
        sipo_in    => sda;
        sipo_clk   => clk;
        sipo_reset => reset
    );
    piso_data_reg : entity work.piso
    generic map (
        BIT_SIZE := 8
    );
    port map (
        piso_clk   => clk;
        piso_reset => reset;
        piso_in    => data_reg;
        piso_out   => sda
    );
begin
    reg_slave_full <= slave_addr & rw_bit;
    ack <= '1';
    slave_selection_proc : process(clk, reset)
    begin
		if reset = '0' then
			if falling_edge(sda) and scl = '1' then
				slave_addr <= sda;
				if slave_addr = ADDR then
					addr_check <= '1';
					ack <= '0' when scl = '0';
					wait until rising_edge(scl);
					ack <= '1';
				else
					addr_check <= '0';
				end if;
			else
				end process slave_selection_proc;
			end if;
		else
			slave_addr <= ( others => '0' );
			addr_check <= '0';
		end if;
	end process i2c_selection_proc;

	reg_selection_proc : process (clk, reset)
	begin
		if reset = '0' then
			if addr_check = '1' then
				reg_addr <= sda;
				if reg_addr = REG1_ADDR then
					reg_check = '1';
					ack <= '0' when scl = '0';
					wait until rising_edge(scl);
					ack <= '1';
				else
					reg_check <= '0';
					reg_addr <= ( others => '0' );
				end if;
			else
				end process reg_selection_proc;
			end if;
		else
			reg_check <= '0';
			reg_addr <= ( others => '0' );
		end if;
	end process reg_selection_proc;

	write_proc : process(clk, reset)
	begin
		if reset = '0' then
			if reg_check = '1' and rw_bit = '0' then
				data_reg <= sda;
				ack <= '0' when scl = '0';
				wait until rising_edge(scl);
				ack <= '1';
			else
				end process write_proc;
			end if;
		else
			data_reg <= ( others => '0' );
		end if;
	end process write_proc;
end RTL;

	--read_proc : process(clk, reset)
	--begin
    --    if reset = '0' then
    --        if reg_check = '1' and rw_bit = '1' then
    --            sda <= data_reg;
                --wait for ack from master
