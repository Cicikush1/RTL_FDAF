----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/10/2026 04:30:05 AM
-- Design Name: 
-- Module Name: LeadingOneDetector - Behavioral
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

entity LeadingOneDetector is
    generic (
        WIDTH : integer := 24
    );
    port (
        data_in  : in  std_logic_vector(WIDTH-1 downto 0);
        position : out integer range 0 to WIDTH-1 
    );
end entity;

architecture Behavioral of LeadingOneDetector is
begin
    process(data_in)
    begin
        position <= 0;
        for i in WIDTH-1 downto 0 loop
            if data_in(i) = '1' then
                position <= i;
                exit;
            end if;
        end loop;
    end process;
end architecture;