----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/25/2026 04:06:48 AM
-- Design Name: 
-- Module Name: ComplexMultiplierCore - Behavioral
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

-- This is the "Core" relative to the rest of the system but in reality:
-- Its just a wrapper with a constant Bitwidth and valid I/O signals
library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use work.fft_types.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ComplexMultiplierCore is
    Port (
        clk         : in std_logic;
        rst         : in std_logic;
        valid_in    : in std_logic  := '0';
        valid_out   : out std_logic := '0';
        ready       : out std_logic;
        in1_R       : in std_logic_vector(23 downto 0);
        in1_I       : in std_logic_vector(23 downto 0);
        in2_R       : in std_logic_vector(23 downto 0);
        in2_I       : in std_logic_vector(23 downto 0);
        ACTV_PWR    : IN STD_LOGIC;
        ACTV_GRDJ   : IN STD_LOGIC := '0';
        GRDJ_SHFT   : IN INTEGER range 0 to 23 := 0;  -- floor(log2 P) in GRADJ, 12 in FILTER
        OUT_R       : out std_logic_vector(23 downto 0);
        OUT_I       : out std_logic_vector(23 downto 0);
        
        -- Ports for debugging
        vpipe       : out std_logic_vector(4 downto 0)

     );

end ComplexMultiplierCore;

architecture Behavioral of ComplexMultiplierCore is
--signal process_on   : std_logic := '0';
signal complin1     : complex;
signal complin2     : complex;
signal compout      : complex;
signal valid_pipe : std_logic_vector(4 downto 0) := (others => '0');

component complexMultiplyCMC is
	generic(in1Bits,in2Bits  : INTEGER :=24; 
            outBits: integer :=24;
			round: boolean := true);
	port(clk: in std_logic;
			in1,in2: in complex;
            actv_pwr: in std_logic;
            actv_grdj: in std_logic;
            grdj_shift: in integer range 0 to 23;
			out1: out complex
			);
end component;


begin
ready <= not(rst); --not(process_on);
valid_out <= valid_pipe(4);
complin1 <= to_complex(SIGNED(in1_R), SIGNED(in1_I));
complin2 <= to_complex(SIGNED(in2_R), SIGNED(in2_I));
OUT_R <= std_logic_vector(compout.re(23 downto 0)); 
OUT_I <= std_logic_vector(compout.im(23 downto 0)); 

-- Debug port outputs
vpipe <= valid_pipe;

compmultinst: complexMultiplyCMC 

	generic map(
        in1Bits => 24,
        in2Bits => 24,
        outBits => 24,
		round   => TRUE
        )
	port map(
        clk     => clk,
		in1     => complin1,
        in2     => complin2,
        actv_pwr=> ACTV_PWR,
        actv_grdj  => ACTV_GRDJ,
        grdj_shift => GRDJ_SHFT,
		out1    => compout
		);

    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                --valid_out <= '0';
                --ready <= '0';
                valid_pipe <= (others => '0'); 
            else   
                valid_pipe <= valid_pipe(3 downto 0) & valid_in;
            end if;
        end if;
    end process;
    
end Behavioral;
