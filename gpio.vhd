library IEEE;
use ieee.std_logic_1164.all;
use work.assembly_instructions.all;

entity gpio is
    generic(N: integer := 8);
    port(clk, reset, IE, OE: IN std_logic;
         Din: IN std_logic_vector(N-1 downto 0);
         Dout: OUT std_logic_vector(N-1 downto 0)
    );
end gpio;

architecture behave of gpio is
    signal r_gpio, r_in, r_out: std_logic_vector(N-1 downto 0); 
begin
    process(clk, reset) begin
        if(reset = '1') then
            r_gpio <= (others => '0');
        elsif rising_edge(clk) then
            r_gpio <= r_in;
        end if;
    end process;
    
    r_in <= Din when IE = '1' else r_out;
    r_out <= r_gpio when OE = '1' else (others => 'Z');
    Dout <= r_out;
end behave;
