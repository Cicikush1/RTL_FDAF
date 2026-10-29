----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2026 04:11:35 PM
-- Design Name: 
-- Module Name: Halfreadertttpn - Behavioral
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

entity Halfreadtttpn is
    generic (
        bitwidth      : INTEGER := 16
    );
    port (
        -- System signals
        clk_cc        : in  std_logic;
        rst           : in  std_logic;
        
        -- Hub Control Signals
        start_read    : in  std_logic;
        done          : out std_logic;
        
        -- Interface TO/FROM the Physical BRAM
        ram_addr      : out std_logic_vector(8 downto 0);
        ram_data      : in  std_logic_vector(bitwidth-1 downto 0);
        ram_en        : out std_logic;
        
        -- Outgoing Data Stream (to FFT / Multiplier)
        data_out      : out std_logic_vector(bitwidth-1 downto 0);
        out_valid     : out std_logic := '0'
    );
end entity Halfreadtttpn;

architecture Behavioural of Halfreadtttpn is
    constant readlen : INTEGER := 511; 
    signal read_counter : unsigned(8 downto 0) := "000000000"; 
    signal reading_active : std_logic := '0';
    signal done_predelay : STD_LOGIC := '0';
    signal reading_active_delayed : std_logic := '0'; 

begin
    
    ram_addr <= std_logic_vector(read_counter);
    data_out <= ram_data;
  
    
    process(clk_cc)
    begin
        if rising_edge(clk_cc) then
            -- default assignments
            done_predelay <= '0';
            ram_en <= '0';
            reading_active_delayed <= reading_active;
            out_valid <= reading_active_delayed;
            done <= done_predelay;
            if rst = '1' then
                reading_active <= '0';
                read_counter <= "000000000";
                ram_en <= '0';
                reading_active_delayed <= '0';
                out_valid <= '0';
            else
                if (start_read = '1') then
                    reading_active <= '1';
                end if;
                    if (reading_active = '1') then
                        if (read_counter = readlen) then
                            done_predelay <= '1';
                            reading_active <= '0';
                            ram_en <= '1';
                            read_counter <= "000000000";
                        else
                            done_predelay <= '0';
                            read_counter <= read_counter + 1;
                            ram_en <='1';
                        end if;
                    else
                        read_counter <= "000000000";
                    end if;
            end if;
        end if;
    end process;

end architecture Behavioural;
