library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is 
    generic(N: integer := 16;
            M: integer := 3);
    port(
        clk, reset: IN std_logic;
        Din: IN std_logic_vector(N-1 downto 0);
        address: OUT std_logic_vector(N-1 downto 0);
        Dout: OUT std_logic_vector(N-1 downto 0);
        RW: OUT std_logic
    );
end cpu;

architecture behave of cpu is

    component datapath_mod 
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
    end component;

    component microcode_rom
        port(
            uAddr: IN std_logic_vector(6 downto 0);
            uInstr: OUT std_logic_vector(13 downto 0)
        );
    end component;

    signal instr_reg: std_logic_vector(N-1 downto 0) := (others => '0');
    signal dout_reg: std_logic_vector(N-1 downto 0) := (others => '0');
    signal uPC: std_logic_vector(1 downto 0) := "00";
    signal uInstr: std_logic_vector(13 downto 0) := (others => '0');
    signal uAddr: std_logic_vector(6 downto 0) := (others => '0');
    signal r_Z_Flag, r_N_Flag, r_O_Flag: std_logic := '0';
    signal Z_Flag, N_Flag, O_Flag: std_logic := '0';
    signal input_sign_extended: std_logic_vector(N-1 downto 0) := (others => '0');
    signal flag_bit: std_logic := '0';
    signal r_Offset: std_logic_vector(N-1 downto 0) := (others => '0');
    signal r_RW: std_logic := '1';
     

begin

    dp: datapath_mod generic map(N, M)
                 port map(
                         Input => input_sign_extended,
                         Offset => r_Offset,
                         WAddr => instr_reg(11 downto 9), 
                         RA => instr_reg(8 downto 6), 
                         RB => instr_reg(5 downto 3),
                         IE => uInstr(13), 
                         OE => uInstr(4), 
                         Write => uInstr(7), 
                         ReadA => uInstr(6), 
                         ReadB => uInstr(5), 
                         reset => reset, 
                         clk => clk,
                         Bypass => uInstr(9 downto 8),
                         OP => uInstr(12 downto 10),
                         Output => dout_reg,
                         Z_Flag => r_Z_Flag, 
                         N_Flag => r_N_Flag, 
                         O_Flag => r_O_Flag
                 );        
    
    u_rom: microcode_rom port map(uAddr, uInstr);              
                 
	u_PC: process(clk, reset)
	begin
		if(reset = '1') then
			uPC <= "00";
		elsif rising_edge(clk) then
			uPC <= std_logic_vector(unsigned(uPC)+1); --resets to 0 after "11"
		end if;
	end process u_PC;
	
	main: process(clk, reset)
	begin
		if(reset = '1') then
			address <= (others => '0');
		elsif rising_edge(clk) then
            case uInstr(3 downto 1) is
                when "000" => address <= dout_reg;   -- select address out
                when "001" => Dout <= dout_reg;      -- select data out
                when "010" => instr_reg <= Din;      -- latch instruction
                when "011" => Z_Flag <= r_Z_Flag;    -- latch flags
                              N_Flag <= r_N_Flag;
                              O_Flag <= r_O_Flag;            
                when others => null;
            end case;
            r_RW <= uInstr(0);
        end if;
	end process main;

    uAddr <= instr_reg(15 downto 12) & flag_bit & uPC;

    --Sign extended offset: 
    r_Offset <= std_logic_vector(resize(signed(instr_reg(11 downto 0)), r_Offset'length));

    with instr_reg(15 downto 12) select input_sign_extended <= Din when "1000",
        std_logic_vector(resize(signed(instr_reg(8 downto 0)), N)) when "1010",
        (others => '0') when others;

    flag_bit <= Z_flag when instr_reg(15 downto 12) = "1100" else
                N_flag when instr_reg(15 downto 12) = "1101" else
                O_flag when instr_reg(15 downto 12) = "1110" else '0';
    
    
    RW <= r_RW;

end behave;
