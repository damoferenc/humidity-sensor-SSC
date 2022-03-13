----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/05/2022 06:34:40 PM
-- Design Name: 
-- Module Name: i2c_master_tb - Behavioral
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

entity i2c_master_tb is
--  Port ( );
end i2c_master_tb;

architecture Behavioral of i2c_master_tb is

signal Clk : STD_LOGIC := '0';

constant CLK_PERIOD : TIME := 10 ns;
signal rst : STD_LOGIC := '0';
signal rw : STD_LOGIC := '0';
signal en : STD_LOGIC := '0';
signal sck : STD_LOGIC := '0';
signal term : STD_LOGIC := '0';
signal sda : STD_LOGIC := '0';
signal data_in : STD_LOGIC_VECTOR (7 downto 0) := x"00";
signal data_out : STD_LOGIC_VECTOR (7 downto 0) := x"00";
signal address : STD_LOGIC_VECTOR (6 downto 0) := "1000000";

begin

gen_clk: process
 begin
  Clk <= '0';
  wait for (CLK_PERIOD/2);
  Clk <= '1';
  wait for (CLK_PERIOD/2);
 end process gen_clk;

DUT0: entity WORK.I2C_master port map (
 Clk => Clk,
 rst => rst,
 rw => rw,
 en => en,
 address => address,
 data_in => data_in,
 data_out => data_out,
 sck => sck,
 term => term,
 sda => sda);
 
 test : process
 begin
    rst <= '1';
    wait for 20 ns;
    rst <= '0';
    wait for 20 ns;
    rw <= '0';
    en <= '1';
    data_in <= x"80";
    wait for 90 us;
    data_in <= x"02";
    wait for 90 us;
    data_in <= x"04";
    wait for 90 us;
    data_in <= x"00";
    wait for 90 us;
    en <= '0';
    wait for 10 ms;
    
    en <= '1';
    data_in <= x"80";
    wait for 90 us;
    data_in <= x"01";
    wait for 90 us;
    en <= '0';
    wait for 10 ms;
    
    en <= '1';
    data_in <= x"81";
    wait for 90 us;
    rw <= '1';
    wait for 90 us;
    wait for 90 us;
    en <= '0';
    
    wait;
 end process;


end Behavioral;
