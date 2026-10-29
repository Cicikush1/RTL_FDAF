----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/28/2026 02:27:15 AM
-- Design Name: 
-- Module Name: Generic_SDP_RAM - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
-- synthesis translate_off
use STD.textio.ALL;
use IEEE.std_logic_textio.ALL;
-- synthesis translate_on

entity Generic_SDP_RAM is
    Generic (
        DATA_WIDTH      : integer := 24;  -- Bit Width of the Ram
        ADDR_WIDTH      : integer := 10;   -- Ram Word Count
        
        DUMP_FILE_NAME  : string  := ""
    );
    Port (
        clk             : in  std_logic;
        
        -- Write Port
        we              : in  std_logic;
        waddr           : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        din             : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        
        -- Read Port
        raddr           : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        dout            : out std_logic_vector(DATA_WIDTH-1 downto 0);
        dump_trigger    : in std_logic
    );
end Generic_SDP_RAM;

architecture Behavioral of Generic_SDP_RAM is

    type ram_type is array (0 to (2**ADDR_WIDTH)-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    
    signal ram_block : ram_type := (others => (others => '0'));

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                ram_block(to_integer(unsigned(waddr))) <= din;
            end if;
            
            dout <= ram_block(to_integer(unsigned(raddr)));
        end if;
    end process;
    -- synthesis translate_off
    dump_proc: process(dump_trigger)
    file out_file    : text;
    variable row     : line;
    variable dump_nr : natural := 1;
    begin
        if rising_edge(dump_trigger) and DUMP_FILE_NAME /= "" then
            file_open(out_file, DUMP_FILE_NAME & "_F" & integer'image(dump_nr) & ".txt", write_mode);
            for i in 0 to (2**ADDR_WIDTH)-1 loop
                write(row, ram_block(i));
                writeline(out_file, row);
            end loop;
            file_close(out_file);
            report "RAM DUMP COMPLETE: " & DUMP_FILE_NAME & "_F" & integer'image(dump_nr);
            dump_nr := dump_nr + 1;
        elsif rising_edge(dump_trigger) then
            report "RAM DUMP SKIPPED: DUMP_FILE_NAME is empty" severity warning;
        end if;
    end process;
    -- synthesis translate_on
end Behavioral;