
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;

entity displ7seg is
    Port ( Clk  : in  STD_LOGIC;
           Rst  : in  STD_LOGIC;
           Data : in  STD_LOGIC_VECTOR (15 downto 0);   -- datele pentru 8 cifre (cifra 1 din stanga: biti 31..28)
           An   : out STD_LOGIC_VECTOR (3 downto 0);    -- selectia anodului activ
           Dp : out STD_LOGIC;
           Seg  : out STD_LOGIC_VECTOR (6 downto 0));   -- selectia catozilor (segmentelor) cifrei active
end displ7seg;

architecture Behavioral of displ7seg is

constant CNT_100HZ : integer := 2**20;                  -- divizor pentru rata de reimprospatare de ~100 Hz (cu un ceas de 100 MHz)
signal Num         : integer range 0 to CNT_100HZ - 1 := 0;
signal NumV        : STD_LOGIC_VECTOR (19 downto 0) := (others => '0');    
signal LedSel      : STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
signal Hex         : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');

begin

-- Proces pentru divizarea ceasului
divclk: process (Clk)
    begin
    if (Clk'event and Clk = '1') then
        if (Rst = '1') then
            Num <= 0;
        elsif (Num = CNT_100HZ - 1) then
            Num <= 0;
        else
            Num <= Num + 1;
        end if;
    end if;
    end process;

    NumV <= CONV_STD_LOGIC_VECTOR (Num, 20);
    LedSel <= NumV (19 downto 18);

-- Selectia anodului activ
    An <= "1110" when LedSel = "00" else
          "1101" when LedSel = "01" else
          "1011" when LedSel = "10" else
          "0111" when LedSel = "11" else
          "1111";

-- Selectia cifrei active
    Hex <= Data (3  downto  0) when LedSel = "00" else
           Data (7  downto  4) when LedSel = "01" else
           Data (11 downto  8) when LedSel = "10" else
           Data (15 downto 12) when LedSel = "11" else
           X"0";
    
    Dp <= '0' when LedSel = "10" else '1';

-- Activarea/dezactivarea segmentelor cifrei active
    Seg <= "1111001" when Hex = "0001" else            -- 1
           "0100100" when Hex = "0010" else            -- 2
           "0110000" when Hex = "0011" else            -- 3
           "0011001" when Hex = "0100" else            -- 4
           "0010010" when Hex = "0101" else            -- 5
           "0000010" when Hex = "0110" else            -- 6
           "1111000" when Hex = "0111" else            -- 7
           "0000000" when Hex = "1000" else            -- 8
           "0010000" when Hex = "1001" else            -- 9
           "0001000" when Hex = "1010" else            -- A
           "0000011" when Hex = "1011" else            -- b
           "1000110" when Hex = "1100" else            -- C
           "0100001" when Hex = "1101" else            -- d
           "0000110" when Hex = "1110" else            -- E
           "0001110" when Hex = "1111" else            -- F
           "1000000";                                  -- 0

end Behavioral;
