------------------------- Specification Inconsistencies -------------------------
--
-- 1. Bypass B signal should set ReadA to '1' and Read Address A to "111". 
--    Offset should go to ALU B input and PC goes to ALU A input.
--    Then we can do an ALU ADD(branch))/INCR and write back the PC value to reg7.
--
-- 2. We need to store the Z, N and O flags from the previous instruction
--    and mux it to the microcode control for BRZ, BRN and BRO. 
--    Currently Z, N and O flags are just ALU outputs and need to be registered. 
--
---------------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- sw1 - OE
-- sw5 - RA
-- sw6 - RB
-- sw7 - IE
-- sw8 - WAddr
-- sw17 - ReadA
-- sw18 - ReadB
-- sw19 - Write
-- sw20 - Reset

entity datapath_mod is 
    generic(N: integer := 16;
            M: integer := 3);
    port(
        Input: IN std_logic_vector(N-1 downto 0);
        Offset: IN std_logic_vector(N-1 downto 0);
        WAddr, RA, RB: IN std_logic_vector(M-1 downto 0);
        IE, OE, Write, ReadA, ReadB, reset, clk: IN std_logic;
        Bypass: IN std_logic_vector(1 downto 0);
        OP: IN std_logic_vector(2 downto 0);
        Output: OUT std_logic_vector(N-1 downto 0);
        Z_Flag, N_Flag, O_Flag: OUT std_logic
    );
end datapath_mod;

architecture behave of datapath_mod is
    component ALU
        generic(N: integer := 16);
        port(
            A, B: IN std_logic_vector(N-1 downto 0);
            OP: IN std_logic_vector(2 downto 0);
            Sum: OUT std_logic_vector(N-1 downto 0);
            Z_Flag, N_Flag, O_Flag: OUT std_logic
        );
    end component;

    component register_file
        generic(N: integer := 16;
                M: integer := 3);
        port(
            WD: IN std_logic_vector(N-1 downto 0);
            WAddr, RA, RB: IN std_logic_vector(M-1 downto 0);
            Write, ReadA, ReadB, reset, clk: IN std_logic;
            QA, QB: OUT std_logic_vector(N-1 downto 0)
        );
    end component;

    signal tmp_sum, ALU_A, ALU_B, tmp_WD: std_logic_vector(N-1 downto 0) := (others => '0');
    signal RF_A, RF_B: std_logic_vector(N-1 downto 0) := (others => '0');
    signal r_Waddr, r_RA, r_RB: std_logic_vector(M-1 downto 0) := (others => '0');
    signal r_ReadA, r_ReadB, r_Write: std_logic := '0';
   
begin

    uALU: ALU generic map(N) 
            port map(ALU_A, ALU_B, OP, tmp_sum, Z_Flag, N_Flag, O_Flag);

    rf: register_file generic map(N, M)
                      port map(tmp_WD, r_WAddr, r_RA, r_RB, Write, 
                               ReadA, ReadB, reset, clk, 
                               RF_A, RF_B);

    process(Input, IE, OE, clk)
    begin

--        case IE is
--            when '0' => tmp_WD <= tmp_Sum ;
--            when '1' => tmp_WD <= Input ;
--            when others => null ;
--        end case;
--
--        case OE is
--            when '0' => Output <= (others => 'Z');
--            when '1' => Output <= tmp_sum;
--            when others => null ;
--        end case;

--       if(IE = '1') then
--           tmp_WD <= Input;
--       else tmp_WD <= tmp_sum;
--       end if;
--
--       if(OE = '1') then
--           Output <= tmp_sum;
--       else Output <= (others => 'Z');
--       end if;
--
--        if(Bypass(0) = '1') then -- Bypass A ????
--            ALU_A <= (others => '1');
--            r_RB <= (others => '1');
--        else 
--            ALU_A <= RF_A;
--            r_RB <= RB;     
--        end if;

        if(Bypass(1) = '1') then -- Bypass B, force PC on A
            ALU_B <= Offset;
            --r_ReadA <= '1';
            r_RA <= (others => '1');
            r_WAddr <= (others => '1');
            --r_Write <= '1';
        else 
            ALU_B <= RF_B;
            --r_ReadA <= ReadA;
            r_RA <= RA; 
            r_WAddr <= WAddr;
           -- r_Write <= Write; 
        end if;
    end process; 
    
    tmp_WD <= Input when IE = '1' else tmp_Sum;
    Output <= tmp_Sum when OE = '1' else (others => 'Z');
    ALU_A <= RF_A;
    r_RB <= RB; 
   
end behave;

    


