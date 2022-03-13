----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/28/2021 01:08:50 PM
-- Design Name: 
-- Module Name: SimConvert - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SimConvert is
--  Port ( );
end SimConvert;


architecture Behavioral of SimConvert is

signal SensorVal : STD_LOGIC_VECTOR (15 downto 0);
signal EnClk : STD_LOGIC;
signal Clk : STD_LOGIC;
signal Humidity : STD_LOGIC_VECTOR (15 downto 0);

constant CLK_PERIOD : TIME := 10 ns;

begin

DUT0: entity WORK.Convert port map (
 Clk => Clk,
 EnClk => EnClk,
 SensorVal => SensorVal,
 Humidity => Humidity);

gen_clk: process
 begin
  Clk <= '0';
  wait for (CLK_PERIOD/2);
  Clk <= '1';
  wait for (CLK_PERIOD/2);
 end process gen_clk;
 
  SensorVal <= "0110101010001011";

 
 gen_input : process
 variable NrErori : INTEGER := 0; -- numar de erori
 begin
  EnClk <= '0';
  wait for CLK_PERIOD*10;
  
  EnClk <= '1';
  wait for CLK_PERIOD*4;
  EncLK <= '0';
  wait for CLK_PERIOD*2;
  if Humidity /= "0010100110011110" then
    NrErori := NrErori + 1;
  end if;
  
  
 if NrErori /= 0 then
    report "Testare terminata cu " &
        INTEGER'image (NrErori) & " erori";
 else 
    report "Simularea terminata cu success";
 end if;
  
  wait;
  end process;

end Behavioral;
