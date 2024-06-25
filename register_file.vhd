library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is 
    generic(N: integer := 16;
            M: integer := 3);
    port(
        WD: IN std_logic_vector(N-1 downto 0);
        WAddr, RA, RB: IN std_logic_vector(M-1 downto 0);
        Write, ReadA, ReadB, reset, clk: IN std_logic;
        QA, QB: OUT std_logic_vector(N-1 downto 0)
    );
end register_file;

architecture behave of register_file is
    type reg_array is array(0 to ((2**M)-1)) of std_logic_vector(N-1 downto 0); 
    signal regFile : reg_array := (others => (others => '0'));

begin
    process(clk, reset)
    begin
        if(reset = '1') then    
            --set all reg data to 0
            regFile <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if (Write = '1') then
                --write data
                regFile(to_integer(unsigned(WAddr))) <= WD;            
            end if;
        end if;


    end process;

    QA <= regFile(to_integer(unsigned(RA))) when (ReadA = '1') else (others => '0');
    QB <= regFile(to_integer(unsigned(RB))) when (ReadB = '1') else (others => '0');
    
end behave;
