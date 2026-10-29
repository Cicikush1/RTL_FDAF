----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/14/2026 09:29:19 AM
-- Design Name: 
-- Module Name: RMWPipeline - Behavioral
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

entity RMWPipeline is
  
    generic (
        PIPELINE_DEPTH      : INTEGER   := 4;
        PIPELINE_WIDTH      : INTEGER   := 48
    );

    Port (
    clk                     : IN    std_logic;
    DATA_IN                 : IN    STD_LOGIC_VECTOR(PIPELINE_WIDTH-1 DOWNTO 0);
    DATA_OUT                : OUT   STD_LOGIC_VECTOR(PIPELINE_WIDTH-1 DOWNTO 0);
    EN_IN                   : IN    std_logic   := '0';
    EN_OUT_PIPE             : OUT   STD_LOGIC_VECTOR(PIPELINE_DEPTH-1 DOWNTO 0)

   );
end RMWPipeline;

architecture Behavioral of RMWPipeline is
    type RMWpipe_t is array (PIPELINE_DEPTH-1 DOWNTO 0) of std_logic_vector(PIPELINE_WIDTH-1 downto 0);    

    signal RMWDTPipe        : RMWpipe_t := (others => (others => '0') ) ;
    signal RMWENPipe        : std_logic_vector(PIPELINE_DEPTH-1 DOWNTO 0);
    
begin

    process(clk)
    begin
        if rising_edge(clk) then
            RMWDTPipe(0)    <= DATA_IN;
            RMWENPipe(0)    <= EN_IN;
            for i in PIPELINE_DEPTH-1 downto 1 loop
                RMWDTPipe(i) <= RMWDTPipe(i-1);
                RMWENPipe(i) <= RMWENPipe(i-1);
            end loop;

        end if;
    end process;
    
    
    DATA_OUT    <= RMWDTPipe(PIPELINE_DEPTH-1);
    EN_OUT_PIPE <= RMWENPipe;
    
end Behavioral;
