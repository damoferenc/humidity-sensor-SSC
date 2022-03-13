----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/10/2022 10:25:45 PM
-- Design Name: 
-- Module Name: bin_bcd_tb - Behavioral
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

entity bin_bcd_tb is
--  Port ( );
end bin_bcd_tb;

architecture Behavioral of bin_bcd_tb is

signal binary : STD_LOGIC_VECTOR (7 downto 0);
signal bcd : STD_LOGIC_VECTOR (7 downto 0);

begin

DUT0: entity WORK.BinaryToBCD port map (
 binary => binary,
 bcd => bcd);
 
 
  binary <= "00101011";

 
 gen_input : process
 variable NrErori : INTEGER := 0; -- numar de erori
 begin
  if bcd /= "01000011" then
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
