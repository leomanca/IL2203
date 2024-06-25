library ieee;
use ieee.std_logic_1164.all;

architecture test_microcontroller of test is
    component microcontroller is
        generic(N: integer := 8);
        port(
            OE, clk, reset: IN std_logic;
            gpio_out: OUT std_logic_vector(N-1 downto 0)
       );
    end component;

    signal reset, OE: std_logic := '1';
    signal clk: std_logic := '1';
    signal gpio_out: std_logic_vector(7 downto 0);

begin   
    u_mic: microcontroller generic map(N => 8) 
                           port map (OE, clk, reset, gpio_out);

clk <= not(clk) after 5 ns;
OE <= '1';
reset <= '0' after 20 ns;

end test_microcontroller;
