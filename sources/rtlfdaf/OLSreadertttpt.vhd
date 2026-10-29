----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/11/2026 06:43:01 PM
-- Design Name: 
-- Module Name: OLSreadertttpt - Behavioral
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

entity OLSreadertttpt is
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
        ping_pong_sel : in  std_logic; -- 0 for Ping, 1 for Pong
            
        -- Interface TO/FROM the Physical BRAM
        ram_addr      : out std_logic_vector(9 downto 0);
        ram_data      : in  std_logic_vector(bitwidth-1 downto 0);
        ram_en        : out std_logic;
        
        -- Outgoing Data Stream (to FFT / Multiplier)
        data_out      : out std_logic_vector(bitwidth-1 downto 0);
        out_valid     : out std_logic := '0'
    );
end OLSreadertttpt;

architecture Behavioral of OLSreadertttpt is

    constant readlen : INTEGER := 511; 
    signal read_counter : unsigned(8 downto 0) := "000000000"; 
    signal reading_active : std_logic := '0';
    signal done_predelay : STD_LOGIC := '0';
    signal reading_active_delayed : std_logic := '0'; 
    signal internal_switch : std_logic := '0';
    signal ping_ponginternal : std_logic := '0';
begin

ping_ponginternal <= ping_pong_sel xor internal_switch;
ram_addr <= ping_ponginternal & std_logic_vector(read_counter);
data_out <= ram_data;


process(clk_cc)

-- Phase 1
begin
    if (rising_edge(clk_cc)) then
        done_predelay <= '0';
        -- internal_switch <= '0'; will cause digital oscillation 
        reading_active_delayed <= reading_active;
        --out_valid <= reading_active_delayed;
        out_valid <= reading_active;
        done <= done_predelay;
        ram_en <= '0';
        if rst = '1' then
            reading_active <= '0';
            read_counter <= "000000000";
            ram_en <= '0';
            out_valid <= '0';
            reading_active_delayed <= '0';
            internal_switch <= '0';
        else
            if (start_read = '1') then
                reading_active <= '1';
            end if;
            if (reading_active = '1') then
                if (internal_switch = '0') then    
                    if (read_counter = readlen) then
                        internal_switch <= '1';
                        -- reading_active <= '0'; to not shutdown
                        ram_en <= '1';
                        read_counter <= "000000000";
                        done_predelay <= '0';
                    else
                        read_counter <= read_counter +1;
                        ram_en <= '1';
                        done_predelay <= '0';
                    end if;
                else 
                    if (read_counter = readlen) then
                        internal_switch <= '0';
                        reading_active <= '0';
                        ram_en <= '1';
                        read_counter <= "000000000";
                        done_predelay <= '1';
                    else
                        read_counter <= read_counter +1;
                        ram_en <= '1';
                        done_predelay <= '0';
                    end if;
                end if;
            end if;
        end if;
    end if;    
end process;

end Behavioral;
