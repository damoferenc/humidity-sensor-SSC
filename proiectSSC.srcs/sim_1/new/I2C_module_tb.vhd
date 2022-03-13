----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/09/2022 07:15:28 PM
-- Design Name: 
-- Module Name: I2C_module_tb - Behavioral
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

entity I2C_module_tb is
--  Port ( );
end I2C_module_tb;

architecture Behavioral of I2C_module_tb is

constant CLK_PERIOD : TIME := 10 ns;

signal Clk : STD_LOGIC := '0';
signal rst : STD_LOGIC := '0';
signal sck : STD_LOGIC := '0';
signal sda : STD_LOGIC := '0';
signal humidity : STD_LOGIC_VECTOR (15 downto 0) := x"0000";

begin

gen_clk: process
 begin
  Clk <= '0';
  wait for (CLK_PERIOD/2);
  Clk <= '1';
  wait for (CLK_PERIOD/2);
 end process gen_clk;

DUT0: entity WORK.I2C_module port map (
 Clk => Clk,
 rst => rst,
 scl => sck,
 humidity => humidity,
 sda => sda);
 
 test: process
 begin
    rst <= '1';
    wait for CLK_PERIOD * 100;
    rst <= '0';
    wait for CLK_PERIOD; --st = wait1
    wait for 20 ms; --wait for 20 ms
    wait for 370 us;
    wait for 10 ms;
    wait for 190 us;
    wait for 10 ms;
    wait for 95 us;
    --sda <= '1';
    wait for 30 us;
    --sda <= 'Z';
    wait for 155 us;
    wait for 30 ms;
    
    
    
    wait;
 end process;

end Behavioral;
