----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/05/2022 07:52:40 PM
-- Design Name: 
-- Module Name: I2C_module - Behavioral
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

entity I2C_module is
    Port ( clk : in STD_LOGIC;                              --system clock
           rst : in STD_LOGIC;                              --system reset
           sda : inout STD_LOGIC;                           --sda signal
           scl : inout STD_LOGIC;                           --scl signal
           humidity : out STD_LOGIC_VECTOR (15 downto 0));  --relative humidity measured
end I2C_module;

architecture Behavioral of I2C_module is

--the i2c address of the PMOD HYGRO
constant SENSOR_ADDR : STD_LOGIC_VECTOR(6 downto 0) := "1000000";
--internal signals for fsm and interconnection
signal rw : STD_LOGIC := '0';
signal en : STD_LOGIC := '0';
signal term : STD_LOGIC := '0';
--registers for in, out data and address
signal data_in : STD_LOGIC_VECTOR (7 downto 0) := x"00";
signal data_out : STD_LOGIC_VECTOR (7 downto 0) := x"00";
signal address : STD_LOGIC_VECTOR (6 downto 0) := "1000000";
-- type and signal for fsm state
type TIP_STARE is (start, wait1, wait2, wait3, wait4, stat_reg_wr0, stat_reg_wr1, stat_reg_wr2, stat_reg_wr3,
                   addr_point_reg_wr0, addr_point_reg_wr1, recieve_data0, recieve_data1, recieve_data2);
signal st : TIP_STARE := start;
--signals for timing
signal counter : INTEGER := 0;
signal to_count : INTEGER := 0;
signal wait_en : STD_LOGIC := '0';
signal wait_term : STD_LOGIC := '0';
--constants for waiting states (in ms)
constant CONS_30_MS : INTEGER := 3_000_000;
constant CONS_20_MS : INTEGER := 2_000_000;
constant CONS_10_MS : INTEGER := 1_000_000;
--signal for reading the ms or ls part of the humidity
signal sign : STD_LOGIC := '0';
--signals for humidity register
signal ld_hum_reg : STD_LOGIC := '0';
signal humidity_reg : STD_LOGIC_VECTOR(15 downto 0) := x"0000";
--help signal for fsm
signal term_delayed : STD_LOGIC := '0';

begin

-- flipflp for delaying the term signal with one period
flip_flop: process(clk)
begin
    if rising_edge(clk) then
        term_delayed <= term;
    end if;
end process;

-- counter for generating the time periods for waiting
wait_counter: process(clk)
begin
    if rising_edge(Clk) then
        if wait_en = '1' then 
            if counter = to_count - 1 then
                wait_term <= '1';
                counter <= 0;
            else
                counter <= counter + 1;
                wait_term <= '0';
            end if;
        else
            counter <= 0;
            wait_term <= '0';
        end if;
    end if;
end process;

-- register for the humidity value
hum_reg: process(clk)
begin
    if rising_edge(clk) then
        if ld_hum_reg = '1' then
            if sign = '0' then
                humidity_reg(15 downto 8) <= data_out;
            else
                humidity_reg(7 downto 0) <= data_out;
            end if;
        else
            humidity_reg <= humidity_reg;
        end if;
    end if;
end process;

-- the i2c master controller
DUT0: entity WORK.I2C_master port map (
 clk => clk,
 rst => rst,
 rw => rw,
 en => en,
 address => address,
 data_in => data_in,
 data_out => data_out,
 scl => scl,
 term => term,
 sda => sda);
 
--the main fsm of the system
fsm: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            st <= start;
        else
            case st is
                when start =>
                    st <= wait1;
                when wait1 =>
                    if wait_term = '1' then
                        st <= stat_reg_wr0;
                    else
                        st <= wait1;
                    end if;
                when stat_reg_wr0 =>
                    if term = '1' and term_delayed = '0' then
                        st <= stat_reg_wr1;
                    else
                        st <= stat_reg_wr0;
                    end if;
                when stat_reg_wr1 =>
                    if term = '1' and term_delayed = '0' then
                        st <= stat_reg_wr2;
                    else
                        st <= stat_reg_wr1;
                    end if;
                when stat_reg_wr2 =>
                    if term = '1' and term_delayed = '0' then
                        st <= stat_reg_wr3;
                    else
                        st <= stat_reg_wr2;
                    end if;
                when stat_reg_wr3 =>
                    if term = '1' and term_delayed = '0' then
                        st <= wait2;
                    else
                        st <= stat_reg_wr3;
                    end if;
                 when wait2 =>
                    if wait_term = '1' then
                        st <= addr_point_reg_wr0;
                    else
                        st <= wait2;
                    end if;
                when addr_point_reg_wr0 =>
                    if term = '1' and term_delayed = '0' then
                        st <= addr_point_reg_wr1;
                    else
                        st <= addr_point_reg_wr0;
                    end if;
                when addr_point_reg_wr1 =>
                    if term = '1' and term_delayed = '0' then
                        st <= wait3;
                    else
                        st <= addr_point_reg_wr1;
                    end if;
                when wait3 =>
                    if wait_term = '1' then
                        st <= recieve_data0;
                    else
                        st <= wait3;
                    end if;
                when recieve_data0 =>
                    if term = '1' and term_delayed = '0' then
                        st <= recieve_data1;
                    else
                        st <= recieve_data0;
                    end if;
                when recieve_data1 =>
                    if term = '1' and term_delayed = '0' then
                        st <= recieve_data2;
                    else
                        st <= recieve_data1;
                    end if;
                when recieve_data2 =>
                    if term = '1' and term_delayed = '0' then
                        st <= wait4;
                    else
                        st <= recieve_data2;
                    end if;
                when wait4 =>
                    if wait_term = '1' then
                        st <= addr_point_reg_wr0;
                    else
                        st <= wait4;
                    end if;
                when others =>
                    st <= start;
            end case;
        end if;
    end if;
end process;

--the outputs and internal signals
address <= SENSOR_ADDR;
wait_en <= '1' when st = wait1 or st = wait2 or st = wait3 or st = wait4 else '0';
to_count <= CONS_20_MS when st = wait1 else
            CONS_10_MS when st = wait2 else
            CONS_10_MS when st = wait3 else
            CONS_30_MS when st = wait4 else 0;
rw <= '1' when st = recieve_data0 or st = recieve_data1 or st = recieve_data2 else '0';
en <= '0' when st = start or st = wait1 or st = wait2 or st = wait3 or st = wait4 else '1';
data_in <= x"02" when st = stat_reg_wr1 else
           x"00" when st = stat_reg_wr2 else
           x"00" when st = stat_reg_wr3 else
           x"01" when st = addr_point_reg_wr1 else
           "1000000" & rw when st = stat_reg_wr0 or st = addr_point_reg_wr0 or st = recieve_data0 else
           x"00";
sign <= '1' when st = recieve_data1 else '0';
ld_hum_reg <= '1' when st = recieve_data1 or st = recieve_data2 else '0';
humidity <= humidity_reg;

end Behavioral;
