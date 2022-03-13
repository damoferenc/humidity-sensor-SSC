----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/11/2022 06:26:38 PM
-- Design Name: 
-- Module Name: Principal - Behavioral
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

Library UNISIM;
use UNISIM.vcomponents.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Principal is
    Port ( Clk : in STD_LOGIC;
           Rst : in STD_LOGIC;
           Sda : inout STD_LOGIC;
           Scl : inout STD_LOGIC;
           Dp : out STD_LOGIC;
           An : out STD_LOGIC_VECTOR (3 downto 0);
           Seg : out STD_LOGIC_VECTOR (6 downto 0));
end Principal;

architecture Behavioral of Principal is

signal humidity : STD_LOGIC_VECTOR(15 downto 0);
signal bin : STD_LOGIC_VECTOR(15 downto 0);
signal dataShow : STD_LOGIC_VECTOR(15 downto 0);
signal binfrac : STD_LOGIC_VECTOR(15 downto 0);
signal bcd : STD_LOGIC_VECTOR(23 downto 0);

begin

binfrac <= std_logic_vector(unsigned(bin(7 downto 0))  * 100);

DUT0: entity WORK.I2C_module port map (
 Clk => Clk,
 rst => rst,
 scl => scl,
 humidity => humidity,
 sda => sda);


 DUT1: entity WORK.displ7seg port map (
 Clk => Clk,
 rst => rst,
 data => dataShow,
 Dp => Dp,
 an => an,
 seg => seg);
 
 DUT2: entity WORK.Convert port map (
 Clk => Clk,
 EnClk => '1',
 SensorVal => humidity,
 Humidity => bin);
 
 DUT3: entity WORK.BinaryToBcd port map (
 bin => bin(15 downto 8),
 bcd => bcd(23 downto 12));
 
 DUT4: entity WORK.BinaryToBcd port map (
 bin => binfrac(15 downto 8),
 bcd => bcd(11 downto 0));
 
 dataShow <= bcd(19 downto 12) & bcd(7 downto 0);

end Behavioral;
