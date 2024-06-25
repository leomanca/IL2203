library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.assembly_instructions.all;

architecture test_memory of test is
    component memory is
        PORT
        (
            address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            clock		: IN STD_LOGIC  := '1';
            data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
            rden		: IN STD_LOGIC  := '1';
            wren		: IN STD_LOGIC ;
            q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
        );
    end component;

    signal clk, rden, wren: std_logic := '0';
    signal address: std_logic_vector(7 downto 0);
    signal data, q: std_logic_vector(15 downto 0) := (others => '0');
    
begin
    fake_mem: entity work.memory(SYN)
                port map(address, clk, data, rden, wren, q);

    clk <= not(clk) after 5 ns;
    rden <= '1';

    process 
        variable i: integer := 0;
    begin
        for i in 0 to 20 loop
            wait until rising_edge(clk);
            address <= std_logic_vector(to_unsigned(i, 8));
        end loop;
    end process;

end test_memory;