library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity ALU is 
    generic(N: integer := 4);
    port(
        A, B: IN std_logic_vector(N-1 downto 0);
        OP: IN std_logic_vector(2 downto 0);
        Sum: OUT std_logic_vector(N-1 downto 0);
        Z_Flag, N_Flag, O_Flag: OUT std_logic
    );
end ALU;

architecture rtl of ALU is
    signal result, zeroes: std_logic_vector(N-1 downto 0) := (others => '0');
begin
    process(A, B, OP)
    begin
        case OP is
            when "000" => result <= A + B;     --ADD
            when "001" => result <= A - B;     --SUB
            when "010" => result <= A and B;   --AND
            when "011" => result <= A or B;    --OR
            when "100" => result <= A xor B;   --XOR
            when "101" => result <= A + 1;     --INCR
            when "110" => result <= A;         --MOVA
            when "111" => result <= not(A);    --NOTA
            when others => result <= (others => 'X'); --DEFAULT
        end case;
    end process;
    Sum <= result;
    Z_Flag <= '1' when (result = zeroes) else '0';
    N_Flag <= '1' when (result(N-1) = '1') else '0';    
    O_Flag <= '1' when( OP = "000" and A(N-1) = B(N-1) and A(N-1) /= result(N-1) ) else '1' 
                  when( OP = "001" and A(N-1) /= B(N-1) and A(N-1) /= result(N-1) ) 
                  else  '0';
end rtl;    