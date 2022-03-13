----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/28/2021 12:14:26 PM
-- Design Name: 
-- Module Name: Convert - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Convert is
    Port ( SensorVal : in STD_LOGIC_VECTOR (15 downto 0);
           EnClk : in STD_LOGIC;
           Clk : in STD_LOGIC;
           Humidity : out STD_LOGIC_VECTOR (15 downto 0));
end Convert;

architecture Behavioral of Convert is

signal X : STD_LOGIC_VECTOR(20 downto 0);
signal Sum : STD_LOGIC_VECTOR(20 downto 0);
signal State : STD_LOGIC_VECTOR(1 downto 0) := "00";
signal X8 : STD_LOGIC_VECTOR(20 downto 0);

begin

X <= "00000" & SensorVal;
X8 <= "00" & SensorVal & "000";

conversion: process(Clk) is
begin
    if EnClk = '1' then 
        if rising_edge(Clk) then  
            case State is 
                when "00" =>
                    Sum <= X8 + X8;
                    State <= "01";
                when "01" =>
                    Sum <= Sum + X8;
                    State <= "10";
                when "10" =>
                    Sum <= Sum + X;
                    State <= "11";
                when others =>
                    Sum <= Sum;
                    State <= "00";
            end case;
        end if;
    else
        State <= "00";
    end if;
end process;

process(clk) is
begin
    if rising_edge(clk) then
        if state = "11" then
            Humidity <= "0" & Sum(20 downto 6);
        end if;
    end if;
end process;

end Behavioral;
