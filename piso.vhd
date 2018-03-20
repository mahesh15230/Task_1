library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity piso is
    generic(
        constant BIT_SIZE := 8
    );
     port(
         piso_clk   : in std_logic;
         piso_reset : in std_logic;
         --piso_load  : in std_logic;
         piso_in   : in std_logic_vector( BIT_SIZE - 1 downto 0 );
         piso_out  : out std_logic
         );
end piso;


architecture RTL of piso is
begin

    piso_proc : process (clk,reset,load,in) is
    variable temp : std_logic_vector( BIT_SIZE - 1 downto 0 );
    begin
        if reset='1' then
            temp := (others=>'0');
        elsif rising_edge (clk) then
            temp := in;
            wait for 1 ns; -- I need the below lines to be executed only after above line is executed
            out <= temp( BIT_SIZE - 1 );
            temp := temp( BIT_SIZE - 2 downto 0 ) & '0';
        end if;
    end process piso_proc;
end RTL;
