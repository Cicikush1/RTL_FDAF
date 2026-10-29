----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/09/2026 01:05:32 AM
-- Design Name: 
-- Module Name: ramwritetwottpnine - Behavioral
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
use IEEE.NUMERIC_STD.ALL;


-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ramwritetwottpnine is
    generic (
        bitwidth      : INTEGER := 16
    );
    port (
        -- System signals
        clk_cc        : in  std_logic;
        rst           : in  std_logic;
        
        -- Hub Control Signals
        start_ac      : in  std_logic; 
        ping_pong_sel : in  std_logic; -- 0 for Ping, 1 for Pong || Latch to 0 for simple 512 sample writer
        done          : out std_logic;
        
        -- Incoming Audio Data Stream
        data_in       : in  std_logic_vector(bitwidth-1 downto 0);
        data_valid    : in  std_logic;
        
        -- Interface to the Physical BRAM (Block RAM)
        ram_we        : out std_logic;
        ram_addr      : out std_logic_vector(9 downto 0);
        ram_data      : out std_logic_vector(bitwidth-1 downto 0)
    );
end entity ramwritetwottpnine;

architecture Behavioural of ramwritetwottpnine is
    constant writelen : INTEGER := 511;
    signal sample_counter : unsigned(8 downto 0) := "000000000"; 

    
begin

    ram_addr <= ping_pong_sel & std_logic_vector(sample_counter);
    ram_data <= data_in;
    process(clk_cc)
        variable writing_active : std_logic;
    begin
        if rising_edge(clk_cc) then
            -- default assignments
            done <= '0';
            ram_we <= '0';
            if rst = '1' then
                writing_active := '0';
                sample_counter <= "000000000";
                ram_we <= '0';
            else
                if (start_ac = '1') then
                    writing_active := '1';
                end if;
                if data_valid ='1' then
                    if (writing_active = '1') then
                        if (sample_counter = writelen) then
                            done <= '1';
                            writing_active := '0';
                            ram_we <= '1';
                            sample_counter <= "000000000";
                        else
                            done <= '0';
                            sample_counter <= sample_counter + 1;
                            ram_we <='1';
                        end if;
                    else
                        sample_counter <= "000000000";
                    end if;
                end if;
            end if;
        end if;
    end process;

end architecture Behavioural;
