----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/02/2022 01:39:15 PM
-- Design Name: 
-- Module Name: I2C_master - Behavioral
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
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity I2C_master is
    Generic(clk_freq : INTEGER := 100_000_000; --input clock frequency
            i2c_freq : INTEGER := 100_000);    --i2c clock frequency
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           rw : in STD_LOGIC;                  --rw signal 0 when write 1 when read
           en : in STD_LOGIC;                  --enable signal
           address : in STD_LOGIC_VECTOR(6 downto 0);
           data_in : in STD_LOGIC_VECTOR (7 downto 0);
           data_out : out STD_LOGIC_VECTOR (7 downto 0);
           scl : inout STD_LOGIC;
           term : out STD_LOGIC;               --1 when a task is terminated
           sda : inout STD_LOGIC);
end I2C_master;

architecture Behavioral of I2C_master is

-- save the address to see if it changed
signal old_address : STD_LOGIC_VECTOR(6 downto 0);
--internal signals for clock, sda and scl
signal clk_i2c : STD_LOGIC := '1';
signal sda_inter : STD_LOGIC := '1';
signal scl_inter : STD_LOGIC := '1';
-- type and signal for fsm
type TIP_STARE is (ready, start, command, slave_ack, write, read, written, red, stop);
signal st : TIP_STARE := ready;
-- signals for clock dividing
signal count : INTEGER := 0;
signal en_p : STD_LOGIC := '0';
signal en_n : STD_LOGIC := '0';
signal second_quarter : STD_LOGIC := '0';
signal fourth_quarter : STD_LOGIC :='0';
signal stop_clk : STD_LOGIC := '1';
-- internal registers
signal sda_inter_reg : STD_LOGIC := '1';
signal in_reg : STD_LOGIC_VECTOR(7 downto 0);
signal out_reg : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
signal red_value : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
-- division factor
constant div : INTEGER := clk_freq / i2c_freq;
--signals for registers
signal ld: STD_LOGIC := '0';
signal sh : STD_LOGIC := '0';
signal addr_ld : STD_LOGIC := '0';
--fsm help signal
signal first_red : STD_LOGIC := '0';
--clock enable signal
signal clk_en : STD_LOGIC := '0';

begin

--register for storing the address
addr_reg : process(clk) is
begin
    if rising_edge(clk) then
        if addr_ld = '1' then
            old_address <= address;
        else
            old_address <= old_address;
        end if;
    end if;
end process;

--register for storing the input
input_reg : process(clk)
begin
    if rising_edge(clk) then
        if ld = '1' then
            in_reg <= data_in;
        elsif sh = '1' then
            in_reg <= in_reg(6 downto 0) & sda;
        end if;
    end if;
end process;

-- flip flop for internal sda signal
sda_flip_flop: process(clk)
begin
    if rising_edge(clk) then
        if (st = start or st = ready) and second_quarter = '1' then
            sda_inter_reg <= sda_inter;
        elsif st = stop and second_quarter = '1' then
            sda_inter_reg <= '1';
        elsif fourth_quarter = '1' then
            sda_inter_reg <= sda_inter;
        else
            sda_inter_reg <= sda_inter_reg;
        end if;
    end if;
end process;

--register for storing the input from the slave device
value_read: process(clk)
begin
    if rising_edge(clk) then
        if st = read and en_p = '1' then
            red_value <= red_value(6 downto 0) & sda;
        else
            red_value <= red_value;
        end if;
    end if;
end process;

-- register for storing the output value
output: process(clk)
begin
    if rising_edge(clk) then
        if st = red then
            out_reg <= red_value;
        else
            out_reg <= out_reg;
        end if;
    end if;
end process;

-- clock divider, set one signal at the begining of every quarter of an i2c clock period 
divider: process(clk)
variable counter : INTEGER := 0;
begin
    if rising_edge(clk) then
        if clk_en = '1' then
            if counter = div then
                counter := 0;
            else
                counter := counter;
            end if;
            if counter = 0 then
                clk_i2c <= '1';
                en_p <= '1';
                en_n <= '0';
                second_quarter <= '0';
                fourth_quarter <= '0';
            elsif counter = div / 4 then
                clk_i2c <= clk_i2c;
                en_p <= '0';
                en_n <= '0';
                second_quarter <= '1';
                fourth_quarter <= '0';
            elsif counter = div / 2 then
                clk_i2c <= '0';
                en_n <= '1';
                en_p <= '0';
                second_quarter <= '0';
                fourth_quarter <= '0';
            elsif counter = 3 * div / 4 then
                clk_i2c <= clk_i2c;
                en_n <= '0';
                en_p <= '0';
                second_quarter <= '0';
                fourth_quarter <= '1';
            else
                en_p <= '0';
                en_n <= '0';
                clk_i2c <= clk_i2c;
                second_quarter <= '0';
                fourth_quarter <= '0';
            end if;
            counter := counter + 1;
        else
            counter := 0;
        end if;
    end if;    
end process;

--the fsm of the system
fsm: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            st <= ready;
        else   
            case st is
                when ready =>   
                    if en = '1' then   
                        st <= start;
                    else
                        st <= ready;
                    end if;
                when start =>
                    first_red <= '0';
                    stop_clk <= '0';
                    count <= 8;
                    if en_n = '1' then
                        st <= command;
                    else
                        st <= start;
                    end if;
                when command =>
                    if en_n = '1' then 
                        if count = 1 then
                           st <= slave_ack;
                         else
                             count <= count - 1;
                             st <= command;
                         end if;
                     else
                        st <= command;
                     end if; 
                when slave_ack =>
                    count <= 8;
                    if en_n = '1' then
                        if rw = '0' then
                            st <= write;
                        else
                            st <= read;
                        end if;
                    else
                        st <= slave_ack;
                    end if;
                when write => 
                    if en_n = '1' then
                        if count = 1 then
                            st <= written;
                        else
                            count <= count - 1;
                            st <= write;
                        end if; 
                     else
                        st <= write;
                     end if; 
               when read => 
                    if en_n = '1' then
                        if count = 1 then
                            st <= red;
                        else
                            count <= count - 1;
                            st <= read;
                        end if; 
                     else
                        st <= read;
                     end if;
                when written =>
                    count <= 8;
                    if en_n = '1' then
                        if en = '0' then 
                            st <= stop;
                        else
                            if rw = '0' and (address = old_address) then
                                st <= write;
                            else
                                st <= start;
                            end if;
                        end if;
                    else
                        st <= written;
                    end if;
                when red =>
                    count <= 8;
                    if en_n = '1' then
                        if en = '0' then 
                            st <= stop;
                        else
                            if rw = '1' and (address = old_address) then
                                st <= read;
                                first_red <= '1';
                            else
                                st <= start;
                                first_red <= '1';
                            end if;
                        end if;
                    else 
                        st <= red;
                    end if;
                when stop =>
                    if en_n = '1' then
                        st <= ready;
                    elsif en_p = '1' then
                        stop_clk <= '1';
                    else
                        st <= stop;
                    end if;
                when others =>
                    st <= ready;
            end case;
        end if;
    end if;
end process;

--the outputs and control signals
term <= '1' when st = written or st = red or st = slave_ack else '0';
addr_ld <= '1' when st = start else '0';
ld <= '1' when st = start or st = slave_ack or st = written or st = red else '0';
sh <= '1' when (st = command and en_n = '1') or (st = write and en_n = '1') or (st = read and en_p = '1') else '0';
scl_inter <= '1' when st = ready else clk_i2c;
sda_inter <= '1' when st = ready or (st = red and first_red = '1') else
             '0' when st = start or st = stop or ( st = red and first_red = '0')else
             in_reg(7) when st = command or st = write else
             '1';
clk_en <= '0' when st = ready else '1';
scl <= '0' when (scl_inter = '0' and stop_clk = '0') else 'Z';
sda <= '0' when sda_inter_reg = '0' else 'Z';
data_out <= out_reg;

end Behavioral;
