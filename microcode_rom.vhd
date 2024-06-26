-- 14-bit uInstr Format 
---------------------------------------------------------------------------------------------
--| IE | OP(2)| OP(1) | OP(0) | Byp(1) | Byp(0) | Write | ReadA | ReadB | OE | select | R/Wn |
---------------------------------------------------------------------------------------------

-- select: 000-> address
--         001-> data
--         010-> inst
--         011-> flags
--         111-> do nothing  

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity microcode_rom is 
    port(
        uAddr: IN std_logic_vector(6 downto 0);
        uInstr: OUT std_logic_vector(13 downto 0)
    );
end microcode_rom; 

architecture behave of microcode_rom is
    type mem is array (0 to 127) of std_logic_vector(13 downto 0);
    constant uRom: mem :=       
    (
        --ADD--IE,OP,Byp,Write,ReadA,ReadB,OE,Sel,RW--
        0 => "01100000000101",  -- LI
        1 => "00000011100111",  -- FO
        2 => "01011011010001",  -- EX
        3 => "00000000001111",  -- WA
        4 => "01100000000101",  -- don't care flag bit,
        5 => "00000011100111",  -- repeat same uInstr as above.
        6 => "01011011010001",  --
        7 => "00000000001111",  --
        --------------------------

        --iSUB--IE,OP,Byp,Write,ReadA,ReadB,OE,Sel,RW--
        8  => "01100000000101",  -- LI
        9  => "00010011100111",  -- FO
        10 => "01011011010001",  -- EX
        11 => "00000000001111",  -- WA
        12 => "01100000000101",  -- don't care flag bit,
        13 => "00010011100111",  -- repeat same uInstr as above.
        14 => "01011011010001",  --
        15 => "00000000001111",  --
        ---------------------------

        --iAND--IE,OP,Byp,Write,ReadA,ReadB,OE,Sel,RW--
        16 => "01100000000101",  -- LI
        17 => "00100011100111",  -- FO
        18 => "01011011010001",  -- EX
        19 => "00000000001111",  -- WA
        20 => "01100000000101",  -- don't care flag bit,
        21 => "00100011100111",  -- repeat same uInstr as above.
        22 => "01011011010001",  --
        23 => "00000000001111",  --
        --------------------------

        --iOR--IE,OP,Byp,Write,ReadA,ReadB,OE,Sel,RW--
        24 => "01100000000101",  -- LI
        25 => "00110011100111",  -- FO
        26 => "01011011010001",  -- EX
        27 => "00000000001111",  -- WA
        28 => "01100000000101",  -- don't care flag bit,
        29 => "00110011100111",  -- repeat same uInstr as above.
        30 => "01011011010001",  --
        31 => "00000000001111",  --
        -------------------------- 

        --iXOR--IE,OP,Byp,Write,ReadA,ReadB,OE,Sel,RW--
        32 => "01100000000101",  -- LI
        33 => "01000011100111",  -- FO
        34 => "01011011010001",  -- EX
        35 => "00000000001111",  -- WA
        36 => "01100000000101",  -- don't care flag bit,
        37 => "01000011100111",  -- repeat same uInstr as above.
        38 => "01011011010001",  --
        39 => "00000000001111",  --
        --------------------------       

        --iNOT--IE,OP,Byp,Write,ReadA,ReadB,OE,Sel,RW--
        40 => "01100000000101",  -- LI
        41 => "01110011100111",  -- FO
        42 => "01011011010001",  -- EX
        43 => "00000000001111",  -- WA
        44 => "01100000000101",  -- don't care flag bit,
        45 => "01110011100111",  -- repeat same uInstr as above.
        46 => "01011011010001",  --
        47 => "00000000001111",  --
        ---------------------------

        --MOV--IE,OP,Byp,Write,ReadA,ReadB,OE,Sel,RW--
        48 => "01100000000101",  -- LI
        49 => "01100011001111",  -- FO
        50 => "01011011010001",  -- EX
        51 => "00000000001111",  -- WA
        52 => "01100000000101",  -- don't care flag bit,
        53 => "01100011001111",  -- repeat same uInstr as above.
        54 => "01011011010001",  -- 
        55 => "00000000001111",  --
        ---------------------------

        --NOP--IE,OP,Byp,Write,ReadA,ReadB,OE,Sel,RW--
        56 => "01100000000101",  -- LI
        57 => "00000000001111",  -- FO
        58 => "01011011010001",  -- EX
        59 => "00000000001111",  -- WA
        60 => "01100000000101",  -- don't care flag bit,
        61 => "01011011010001",  -- repeat same uInstr as above.
        62 => "00000000001111",  --
        63 => "00000000001111",  --
        ---------------------------

        --LD----IE,OP,Byp,Write,ReadA,ReadB,OE,Sel,RW--
        64 => "01100000000101",  -- LI
        65 => "01100001010001",  -- FO
        66 => "01011011010001",  -- EX
        67 => "11100010001111",  -- WA
        68 => "01100000000101",  -- don't care flag bit,
        69 => "01100001010001",  -- repeat same uInstr as above.
        70 => "01011011010001",  --
        71 => "11100010001111",  --
        -----------------------
        
        --ST----IE,OP,Byp,Write,ReadA,ReadB,OE,Sel,RW-- ??????????????????
        72 => "01100000000101",  -- LI
        73 => "00000000110011",  -- FO
        74 => "01011011010001",  --"01011011010000",  -- EX
        75 => "01100001010000",  -- WA
        76 => "01100000000101",  -- don't care flag bit,
        77 => "00000000110011",  -- repeat same uInstr as above.
        78 => "01011011010000",  --
        79 => "01100001010001",  --
        -----------------------

        --LDI--IE,OP,Byp,Write,ReadA,ReadB,OE,Sel,RW--
        80 => "01100000000101",  -- LI
        81 => "11100010001111",  -- FO
        82 => "01011011010001",  -- EX
        83 => "00000000001111",  -- WA
        84 => "01100000000101",  -- don't care flag bit,
        85 => "11100010001111",  -- repeat same uInstr as above.
        86 => "01011011010001",  --
        87 => "00000000001111",  --
        ---------------------------
    
        --NOT_USED--IE,OP,Byp,Write,ReadA,ReadB,OE,Sel,RW--
        88 => "01100000000101",  -- LI
        89 => "00000000001111",  -- FO
        90 => "01011011010001",  -- EX
        91 => "00000000001111",  -- WA
        92 => "01100000000101",  -- don't care flag bit,
        93 => "00000000001111",  -- repeat same uInstr as above.
        94 => "01011011010001",  --
        95 => "00000000001111",  --
        ---------------------------
 
        --BRZ-Z=0--IE,OP,Byp,Write,ReadA,ReadB,OE,Sel,RW--
        96  => "01100000000101",  -- LI
        97  => "00000000001111",  -- FO
        98  => "01011011010001",  -- EX
        99  => "00000000001111",  -- WA
        --BRZ-Z=1--
        100 => "01100000000101",  -- LI
        101 => "00000000001111",  -- FO
        102 => "00001011010001",  -- EX
        103 => "00000000001111",  -- WA
        ---------------------------   

        --BRN-N=0--IE,OP,Byp,Write,ReadA,ReadB,OE,Sel,RW--
        104 => "01100000000101",  -- LI
        105 => "00000000001111",  -- FO
        106 => "01011011010001",  -- EX
        107 => "00000000001111",  -- WA
        --BRN-N=1--
        108 => "01100000000101",  -- LI
        109 => "00000000001111",  -- FO
        110 => "00001011010001",  -- EX
        111 => "00000000001111",  -- WA
        ---------------------------

        --BRO-O=0--IE,OP,Byp,Write,ReadA,ReadB,OE,Sel,RW--
        112 => "01100000000101",  -- LI
        113 => "00000000001111",  -- FO
        114 => "01011011010001",  -- EX
        115 => "00000000001111",  -- WA
        --BRO-O=1--
        116 => "01100000000101",  -- LI
        117 => "00000000001111",  -- FO
        118 => "00001011010001",  -- EX
        119 => "00000000001111",  -- WA
        ---------------------------

        --BRA---IE,OP,Byp,Write,ReadA,ReadB,OE,Sel,RW--
        120 => "01100000000101",  -- LI
        121 => "00000000001111",  -- FO
        122 => "00001011010001",  -- EX
        123 => "00000000001111",  -- WA
        124 => "01100000000101",  -- don't care flag bit,
        125 => "00000000001111",  -- repeat same uInstr as above.
        126 => "00001011010001",  -- 
        127 => "00000000001111",  -- 
        ---------------------------

        others => (others => '0')
    );
begin

    uInstr <= uRom(to_integer(unsigned(uAddr)));

end behave;
