----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2026 01:28:11 PM
-- Design Name: 
-- Module Name: FullWritertttpt - Behavioral
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Fullwritertttpt is
    generic (
        bitwidth      : INTEGER := 16
    );
    port (
        -- System signals
        clk_cc        : in  std_logic;
        rst           : in  std_logic;
        
        -- Hub Control Signals
        start_write   : in  std_logic;
        done          : out std_logic;
        
        -- Incoming Data Stream
        data_in       : in  std_logic_vector(bitwidth-1 downto 0);
        data_valid    : in  std_logic;
        
        -- Interface to the Physical BRAM (Block RAM)
        ram_we        : out std_logic;
        ram_addr      : out std_logic_vector(9 downto 0);
        ram_data      : out std_logic_vector(bitwidth-1 downto 0);

        -- Debug signal ports:
        wactivelabel  : out std_logic
    );
end entity Fullwritertttpt;

architecture Behavioural of Fullwritertttpt is
    constant writelen : INTEGER := 1023; 

    signal      sample_counter : unsigned(9 downto 0) := "0000000000"; 
    signal      writing_active : std_logic;

begin

    ram_addr <= std_logic_vector(sample_counter);
    ram_data <= data_in;
    ram_we   <= '1' when ((writing_active = '1' or start_write = '1') and data_valid = '1') else '0';
    -- Debug port connections:
    wactivelabel <= writing_active;
    process(clk_cc)
    begin
        if rising_edge(clk_cc) then
            -- default assignments
            done <= '0';
            --ram_we <= '0';
            if rst = '1' then
                writing_active <= '0';
                sample_counter <= "0000000000";
                --ram_we <= '0';
            else
                if (start_write = '1') then
                    writing_active <= '1';
                end if;
                if (writing_active = '1') then    
                    if data_valid ='1' then
                        if (sample_counter = writelen) then
                            done <= '1';
                            writing_active <= '0';
                            --ram_we <= '1';
                            sample_counter <= "0000000000";
                        else
                            done <= '0';
                            sample_counter <= sample_counter + 1;
                            --ram_we <='1';
                        end if;
                    else
                        sample_counter <= "0000000000";
                    end if;
                end if;
            end if;
        end if;
    end process;
end architecture Behavioural;