library IEEE;
use ieee.std_logic_1164.all;
use work.assembly_instructions.all;
use ieee.numeric_std.all;

entity microcontroller is
      generic(N: integer := 8);
      port(
           OE, clk, reset: IN std_logic;
           gpio_out: OUT std_logic_vector(N-1 downto 0)
      );
end microcontroller;

architecture behave of microcontroller is
    component cpu is
        generic(N: integer := 16;
                M: integer := 3);
        port(
            clk, reset: IN std_logic;
            Din: IN std_logic_vector(N-1 downto 0);
            address: OUT std_logic_vector(N-1 downto 0);
            Dout: OUT std_logic_vector(N-1 downto 0);
            RW: OUT std_logic
        );
    end component;

    component memory is
        port(
            address: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            clock: IN STD_LOGIC;
            data: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
            rden: IN STD_LOGIC;
            wren: IN STD_LOGIC ;
            q: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
        );
    end component;

    component GPIO is
        generic(N: integer := 8);
        port(
             clk, reset, IE, OE: IN std_logic;
             Din: IN std_logic_vector(N-1 downto 0);
             Dout: OUT std_logic_vector(N-1 downto 0)
        );  
    end component;

    signal r_IE, wren: std_logic := '0';
    signal rden: std_logic := '1';
    signal ram_dout, ram_din, address: std_logic_vector(15 downto 0) := (others => '0');

begin

    u_cpu: cpu generic map(N => 16, M => 3)
               port map(clk, reset, ram_dout, address, ram_din, rden);

    u_mem: entity work.memory(SYN) 
                 port map(address(7 downto 0), clk, ram_din, rden, wren, ram_dout);

    u_gpio: gpio generic map(N => 8)
                 port map (clk, reset, r_IE, OE, ram_din(7 downto 0), gpio_out);
    
    
    wren <= '0' when unsigned(address) > 255 else not(rden);
    r_IE <= '1' when address = x"F000" else '0';

end behave;
