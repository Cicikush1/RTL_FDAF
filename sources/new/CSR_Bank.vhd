----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/09/2026 10:28:23 PM
-- Design Name: 
-- Module Name: CSR_Bank - Behavioral
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

entity CSR_Bank is
    port (
        clk             : in std_logic;
        rst             : in std_logic;
        config_valid    : in std_logic;
        config_addr     : in std_logic_vector(7 downto 0);
        config_data_in  : in std_logic_vector(15 downto 0);
        out_mu          : out std_logic_vector(15 downto 0);
        out_lambda      : out std_logic_vector(15 downto 0) := x"799A";
        out_lambdarem   : out std_logic_vector(15 downto 0)
    );
end entity;

architecture Behavioral of CSR_Bank is
    signal reg_mu           : std_logic_vector(15 downto 0) := x"0666";
    signal reg_lambda       : std_logic_vector(15 downto 0) := x"799A";
    --signal reg_lambdarem    : std_logic_vector(14 downto 0) := (others => '0'); 
begin
    out_mu          <= "0" & reg_mu(14 downto 0);
    out_lambda      <= "0" & reg_lambda(14 downto 0);
    out_lambdarem <= std_logic_vector(to_unsigned(2**15, 16) - unsigned("0" & reg_lambda(14 downto 0)));
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                reg_mu     <= x"0666"; 
                reg_lambda <= x"799A";

            else
                if config_valid = '1' then
                    case config_addr is
                        when x"00" => reg_mu     <= config_data_in;
                        when x"01" => reg_lambda <= config_data_in;
                        when others => null;
                    end case;
                end if;
            end if;
        end if;
    end process;
end architecture;