----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/28/2026 02:03:17 AM
-- Design Name: 
-- Module Name: FiniteStateMachine - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: This project uses some of the VHDL 2008 goodies, therefore, you should compile/synthesize accordingly
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.fft_types.all; 

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FiniteStateMachine is
    Port (
        clk                 : in  std_logic;
        rst                 : in  std_logic;
        DDATAINVALID        : IN  STD_LOGIC;
        DDATAIN             : IN  STD_LOGIC_VECTOR(11 DOWNTO 0); -- MIC
        XDATAINVALID        : IN  std_logic;
        XDATAIN             : IN  std_logic_vector(11 DOWNTO 0);  -- SPEAKER
        OUTDATA             : OUT STD_LOGIC_VECTOR(11 DOWNTO 0) := (others => '0'); -- e = d - y
        OUTDATAVALID        : OUT STD_LOGIC := '0';
        Frame_ReadyI        : IN  std_logic;
        System_ReadyO       : OUT STD_LOGIC := '0';
        STOP_WFFTUPDT       : IN STD_LOGIC;
        GLOBALRAMDUMP       : IN  STD_LOGIC 
        -- synthesis translate_off
        ;

        -- Debug Ports
        DPO_STRTRDWFFT      : OUT STD_LOGIC;
        DPO_DONE_xWFFT      : OUT STD_LOGIC;
        DPO_DONEW_WFFT      : OUT STD_LOGIC;
        DPO_STRTWRWFFT      : OUT STD_LOGIC;
        DPO_RMENB_WFFT      : OUT STD_LOGIC;

        DPO_STRTRDXFFT      : OUT STD_LOGIC;
        DPO_DONE_xXFFT      : OUT STD_LOGIC;
        DPO_DONEW_XFFT      : OUT STD_LOGIC;
        DPO_STRTWRXFFT      : OUT STD_LOGIC;
        DPO_RMENB_XFFT      : OUT STD_LOGIC;

        DPO_STRTRDXBUF      : OUT STD_LOGIC;
        DPO_DONE_xXBUF      : OUT STD_LOGIC;
        DPO_DONEW_XBUF      : OUT STD_LOGIC;
        DPO_STRTWRXBUF      : OUT STD_LOGIC;
        DPO_RMENB_XBUF      : OUT STD_LOGIC;

        DPO_STRTRDEFRM      : OUT STD_LOGIC;
        DPO_DONE_xEFRM      : OUT STD_LOGIC;
        DPO_DONEW_EFRM      : OUT STD_LOGIC;
        DPO_STRTWREFRM      : OUT STD_LOGIC;
        DPO_RMENB_EFRM      : OUT STD_LOGIC;

        DPO_STRTRDEFFT      : OUT STD_LOGIC;
        DPO_DONE_xEFFT      : OUT STD_LOGIC;
        DPO_DONEW_EFFT      : OUT STD_LOGIC;
        DPO_STRTWREFFT      : OUT STD_LOGIC;
        DPO_RMENB_EFFT      : OUT STD_LOGIC;

        DPO_STRTRDDDAT      : OUT STD_LOGIC;
        DPO_DONE_xDDAT      : OUT STD_LOGIC;
        DPO_DONEW_DDAT      : OUT STD_LOGIC;
        DPO_STRTWRDDAT      : OUT STD_LOGIC;
        DPO_RMENB_DDAT      : OUT STD_LOGIC;

        DPO_STRTRDGRDJ      : OUT STD_LOGIC;
        DPO_DONE_xGRDJ      : OUT STD_LOGIC;
        DPO_DONEW_GRDJ      : OUT STD_LOGIC;
        DPO_STRTWRGRDJ      : OUT STD_LOGIC;
        DPO_RMENB_GRDJ      : OUT STD_LOGIC;

        DPO_STRTRDGINV      : OUT STD_LOGIC;
        DPO_DONE_xGINV      : OUT STD_LOGIC;
        DPO_DONEW_GINV      : OUT STD_LOGIC;
        DPO_STRTWRGINV      : OUT STD_LOGIC;
        DPO_RMENB_GINV      : OUT STD_LOGIC;

        DPO_STRTRDGRJC      : OUT STD_LOGIC;
        DPO_DONE_xGRJC      : OUT STD_LOGIC;
        DPO_DONEW_GRJC      : OUT STD_LOGIC;
        DPO_STRTWRGRJC      : OUT STD_LOGIC;
        DPO_RMENB_GRJC      : OUT STD_LOGIC;

        DPO_STRTRDYCNV      : OUT STD_LOGIC;
        DPO_DONE_xYCNV      : OUT STD_LOGIC;
        DPO_DONEW_YCNV      : OUT STD_LOGIC;
        DPO_STRTWRYCNV      : OUT STD_LOGIC;
        DPO_RMENB_YCNV      : OUT STD_LOGIC;

        DPO_STRTRDYFFT      : OUT STD_LOGIC;
        DPO_DONE_xYFFT      : OUT STD_LOGIC;
        DPO_DONEW_YFFT      : OUT STD_LOGIC;
        DPO_STRTWRYFFT      : OUT STD_LOGIC;
        DPO_RMENB_YFFT      : OUT STD_LOGIC;

        DPO_STRTRDPOWR      : OUT STD_LOGIC;
        DPO_DONE_xPOWR      : OUT STD_LOGIC;
        DPO_DONEW_POWR      : OUT STD_LOGIC;
        DPO_STRTWRPOWR      : OUT STD_LOGIC;
        DPO_RMENB_POWR      : OUT STD_LOGIC;

        DPO_FFTPOUTRIG      : OUT STD_LOGIC;
        DPO_FFTPHSEOUT      : OUT INTEGER range 0 to 1023;
        DPO_VINFFTMODL      : OUT STD_LOGIC;
        DPO_VOTFFTMODL      : OUT STD_LOGIC;

        DPO_VOUTCMCMOD      : OUT STD_LOGIC;
        DPO_VIN_CMCMOD      : OUT STD_LOGIC;
        
        DPO_RMW_EN_xIN      : OUT STD_LOGIC;
        DPO_RMW_EN_OUT      : OUT STD_LOGIC;

        DPOSTATECOUNTR      : OUT INTEGER range 0 to 11;

        -- Pins to inspect the internals of a singular state
        DPOSTINTERNAL0      : OUT STD_LOGIC;
        DPOSTINTERNAL1      : OUT STD_LOGIC;
        DPOSTINTERNAL2      : OUT STD_LOGIC;
        DPOSTINTERNAL3      : OUT STD_LOGIC;
        DPOSTINTERNAL4      : OUT STD_LOGIC;
        DPOSTINTERNAL5      : OUT STD_LOGIC;
        DPOSTINTERNAL6      : OUT STD_LOGIC;
        DPOSTINTERNAL7      : OUT STD_LOGIC;
        DPOSTINTERNAL8      : OUT STD_LOGIC;
        DPOSTINTERNAL9      : OUT STD_LOGIC;
        DPOSTINTERNALA      : OUT STD_LOGIC;
        DPOSTINTERNALB      : OUT STD_LOGIC;
        DPOSTINTERNALC      : OUT STD_LOGIC;
        DPOSTINTERNALD      : OUT STD_LOGIC;
        DPOSTINTERNALE      : OUT STD_LOGIC;
        DPOSTINTERNALF      : OUT STD_LOGIC;

        DPOSTLVPROBE00      : OUT UNSIGNED(23 DOWNTO 0);
        DPOSTLVPROBE01      : OUT UNSIGNED(23 DOWNTO 0);
        DPOSTLVPROBE10      : OUT UNSIGNED(23 DOWNTO 0);
        DPOSTLVPROBE11      : OUT UNSIGNED(23 DOWNTO 0)
        -- synthesis translate_on        
        );

end FiniteStateMachine;

architecture Behavioral of FiniteStateMachine is

    -- State Counter / Its actually for debug but I will probably keep it permanently
    signal state_counter          : INTEGER range 0 to 11;

    -- Signal Declerations for RAM Readers
    -- Weights      | FullReader
    signal strtrd_WFFT            : std_logic := '0';
    signal done_x_WFFT            : std_logic := '0';
    signal rmrdar_WFFT            : std_logic_vector(9 downto 0);
    signal rmdtin_WFFT            : std_logic_vector(47 downto 0);
    signal rmen_x_WFFT            : std_logic := '0';
    signal rmdtot_WFFT            : std_logic_vector(47 downto 0);
    signal vout_x_WFFT            : std_logic := '0';    
    -- X_buffer     | OLSReader
    signal strtrd_XBuff           : std_logic := '0';
    signal done_x_XBuff           : std_logic := '0';
    signal ppsel_xXBuff           : std_logic := '0';
    signal rmrdar_XBuff           : std_logic_vector(9 downto 0);
    signal rmdtin_XBuff           : std_logic_vector(23 downto 0);
    signal rmen_x_XBuff           : std_logic := '0';
    signal rmdtot_XBuff           : std_logic_vector(23 downto 0);
    signal vout_x_XBuff           : std_logic := '0';    
    -- D_Data       | HalfReader
    signal strtrd_DDat            : std_logic := '0';
    signal done_x_DDat            : std_logic := '0';
    signal rmrdar_DDat            : std_logic_vector(8 downto 0);
    signal rmdtin_DDat            : std_logic_vector(23 downto 0);
    signal rmen_x_DDat            : std_logic := '0';
    signal rmdtot_DDat            : std_logic_vector(23 downto 0);
    signal vout_x_DDat            : std_logic := '0'; 
    -- X_fft        | FullReader
    signal strtrd_XFFT            : std_logic := '0';
    signal done_x_XFFT            : std_logic := '0';
    signal rmrdar_XFFT            : std_logic_vector(9 downto 0);
    signal rmdtin_XFFT            : std_logic_vector(47 downto 0);
    signal rmen_x_XFFT            : std_logic := '0';
    signal rmdtot_XFFT            : std_logic_vector(47 downto 0);
    signal vout_x_XFFT            : std_logic := '0'; 
    -- Y_fft        | FullReader
    signal strtrd_YFFT            : std_logic := '0';
    signal done_x_YFFT            : std_logic := '0';
    signal rmrdar_YFFT            : std_logic_vector(9 downto 0);
    signal rmdtin_YFFT            : std_logic_vector(47 downto 0);
    signal rmen_x_YFFT            : std_logic := '0';
    signal rmdtot_YFFT            : std_logic_vector(47 downto 0);
    signal vout_x_YFFT            : std_logic := '0'; 
    -- y_conv       | HalfReader
    signal strtrd_yconv           : std_logic := '0';
    signal done_x_yconv           : std_logic := '0';
    signal rmrdar_yconv           : std_logic_vector(8 downto 0);
    signal rmdtin_yconv           : std_logic_vector(23 downto 0);
    signal rmen_x_yconv           : std_logic := '0';
    signal rmdtot_yconv           : std_logic_vector(23 downto 0);
    signal vout_x_yconv           : std_logic := '0'; 
    -- e_frame      | HalfReader
    signal strtrd_eframe          : std_logic := '0';
    signal done_x_eframe          : std_logic := '0';
    signal rmrdar_eframe          : std_logic_vector(8 downto 0);
    signal rmdtin_eframe          : std_logic_vector(23 downto 0);
    signal rmen_x_eframe          : std_logic := '0';
    signal rmdtot_eframe          : std_logic_vector(23 downto 0);
    signal vout_x_eframe          : std_logic := '0'; 
    -- E_fft        | FullReader
    signal strtrd_EFFT            : std_logic := '0';
    signal done_x_EFFT            : std_logic := '0';
    signal rmrdar_EFFT            : std_logic_vector(9 downto 0);
    signal rmdtin_EFFT            : std_logic_vector(47 downto 0);
    signal rmen_x_EFFT            : std_logic := '0';
    signal rmdtot_EFFT            : std_logic_vector(47 downto 0);
    signal vout_x_EFFT            : std_logic := '0'; 
    -- Power        | FullReader
    signal strtrd_POWR           : std_logic := '0';
    signal done_x_POWR           : std_logic := '0';
    signal rmrdar_POWR           : std_logic_vector(9 downto 0);
    signal rmdtin_POWR           : std_logic_vector(23 downto 0);
    signal rmen_x_POWR           : std_logic := '0';
    signal rmdtot_POWR           : std_logic_vector(23 downto 0);
    signal vout_x_POWR           : std_logic := '0'; 
    -- StepSize     | FullReader
    --signal strtrd_mupb           : std_logic := '0';
    --signal done_x_mupb           : std_logic := '0';
    --signal rmrdar_mupb           : std_logic_vector(9 downto 0);
    --signal rmdtin_mupb           : std_logic_vector(15 downto 0);
    --signal rmen_x_mupb           : std_logic := '0';
    --signal rmdtot_mupb           : std_logic_vector(15 downto 0);
    --signal vout_x_mupb           : std_logic := '0'; 
    -- Grad_J       | FullReader
    signal strtrd_GRDJ            : std_logic := '0';
    signal done_x_GRDJ            : std_logic := '0';
    signal rmrdar_GRDJ            : std_logic_vector(9 downto 0);
    signal rmdtin_GRDJ            : std_logic_vector(47 downto 0);
    signal rmen_x_GRDJ            : std_logic := '0';
    signal rmdtot_GRDJ            : std_logic_vector(47 downto 0);
    signal vout_x_GRDJ            : std_logic := '0'; 
    -- Grad_Jinv    | HalfReader
    signal strtrd_GJInv           : std_logic := '0';
    signal done_x_GJInv           : std_logic := '0';
    signal rmrdar_GJInv           : std_logic_vector(8 downto 0);
    signal rmdtin_GJInv           : std_logic_vector(23 downto 0);
    signal rmen_x_GJInv           : std_logic := '0';
    signal rmdtot_GJInv           : std_logic_vector(23 downto 0);
    signal vout_x_GJInv           : std_logic := '0'; 
    -- Grad_Jconst  | FullReader
    signal strtrd_GRDJC           : std_logic := '0';
    signal done_x_GRDJC           : std_logic := '0';
    signal rmrdar_GRDJC           : std_logic_vector(9 downto 0);
    signal rmdtin_GRDJC           : std_logic_vector(47 downto 0);
    signal rmen_x_GRDJC           : std_logic := '0';
    signal rmdtot_GRDJC           : std_logic_vector(47 downto 0);
    signal vout_x_GRDJC           : std_logic := '0'; 

    -- Signal Declerations for RAM Writers | HalfWriter => ramwritetwottpnine
    -- Weights      | FullWriter
    signal strtwr_WFFT            : std_logic := '0';
    signal donew_xWFFT            : std_logic := '0';
    signal rmdtwi_WFFT            : std_logic_vector(47 downto 0);
    signal dtvin_xWFFT            : std_logic := '0';
    signal rmwren_WFFT            : std_logic := '0';
    signal rmwrar_WFFT            : std_logic_vector(9 downto 0);
    signal rmdtwr_WFFT            : std_logic_vector(47 downto 0);     
    -- X_buffer     | HalfWriter 
    signal strtwr_Xbuff           : std_logic := '0';
    --signal ppsel_xXbuff           : std_logic := '0';
    signal donew_xXbuff           : std_logic := '0';
    signal rmdtwi_Xbuff           : std_logic_vector(23 downto 0);
    signal dtvin_xXbuff           : std_logic := '0';
    signal rmwren_Xbuff           : std_logic := '0';
    signal rmadpplXBuff           : std_logic_vector(9 downto 0);
    signal rmwrar_Xbuff           : std_logic_vector(9 downto 0);
    signal rmdtwr_Xbuff           : std_logic_vector(23 downto 0);
    -- D_Data       | HalfWriter 
    signal strtwr_DDat            : std_logic := '0';
    --signal ppsel_xDDat            : std_logic := '0';
    signal donew_xDDat            : std_logic := '0';
    signal rmdtwi_DDat            : std_logic_vector(23 downto 0);
    signal dtvin_xDDat            : std_logic := '0';
    signal rmwren_DDat            : std_logic := '0';
    signal rmadpplDDat            : std_logic_vector(9 downto 0);
    signal rmwrar_DDat            : std_logic_vector(9 downto 0);
    signal rmdtwr_DDat            : std_logic_vector(23 downto 0);
    -- X_fft        | FullWriter    
    signal strtwr_XFFT            : std_logic := '0';
    signal donew_xXFFT            : std_logic := '0';
    signal rmdtwi_XFFT            : std_logic_vector(47 downto 0);
    signal dtvin_xXFFT            : std_logic := '0';
    signal rmwren_XFFT            : std_logic := '0';
    signal rmwrar_XFFT            : std_logic_vector(9 downto 0);
    signal rmdtwr_XFFT            : std_logic_vector(47 downto 0);
    -- Y_fft        | FullWriter 
    signal strtwr_YFFT            : std_logic := '0';
    signal donew_xYFFT            : std_logic := '0';
    signal rmdtwi_YFFT            : std_logic_vector(47 downto 0);
    signal dtvin_xYFFT            : std_logic := '0';
    signal rmwren_YFFT            : std_logic := '0';
    signal rmwrar_YFFT            : std_logic_vector(9 downto 0);
    signal rmdtwr_YFFT            : std_logic_vector(47 downto 0);
    -- y_conv       | HalfWriter 
    signal strtwr_yconv           : std_logic := '0';
    --signal ppsel_xyconv           : std_logic := '0';
    signal donew_xyconv           : std_logic := '0';
    signal rmdtwi_yconv           : std_logic_vector(23 downto 0);
    signal dtvin_xyconv           : std_logic := '0';
    signal rmwren_yconv           : std_logic := '0';
    signal rmwrar_yconv           : std_logic_vector(9 downto 0);
    signal rmdtwr_yconv           : std_logic_vector(23 downto 0);
    signal rmwdmd_yconv           : std_logic_vector(9 downto 0);
    
    -- e_frame      | HalfWriter 
    signal strtwr_eframe          : std_logic := '0';
    --signal ppsel_xeframe          : std_logic := '0';
    signal donew_xeframe          : std_logic := '0';
    signal rmdtwi_eframe          : std_logic_vector(23 downto 0);
    signal dtvin_xeframe          : std_logic := '0';
    signal rmwren_eframe          : std_logic := '0';
    signal rmwrar_eframe          : std_logic_vector(9 downto 0);
    signal rmdtwr_eframe          : std_logic_vector(23 downto 0);
    -- E_fft        | FullWriter 
    signal strtwr_EFFT            : std_logic := '0';
    signal donew_xEFFT            : std_logic := '0';
    signal rmdtwi_EFFT            : std_logic_vector(47 downto 0);
    signal dtvin_xEFFT            : std_logic := '0';
    signal rmwren_EFFT            : std_logic := '0';
    signal rmwrar_EFFT            : std_logic_vector(9 downto 0);
    signal rmdtwr_EFFT            : std_logic_vector(47 downto 0);
    -- Power        | FullWriter
    signal strtwr_POWR            : std_logic := '0';
    signal donew_xPOWR            : std_logic := '0';
    signal rmdtwi_POWR            : std_logic_vector(23 downto 0);
    signal dtvin_xPOWR            : std_logic := '0';
    signal rmwren_POWR            : std_logic := '0';
    signal rmwrar_POWR            : std_logic_vector(9 downto 0);
    signal rmdtwr_POWR            : std_logic_vector(23 downto 0);
    -- StpSiz       | FullWriter
    --signal strtwr_mupb            : std_logic := '0';
    --signal donew_xmupb            : std_logic := '0';
    --signal rmdtwi_mupb            : std_logic_vector(15 downto 0);
    --signal dtvin_xmupb            : std_logic := '0';
    --signal rmwren_mupb            : std_logic := '0';
    --signal rmwrar_mupb            : std_logic_vector(9 downto 0);
    --signal rmdtwr_mupb            : std_logic_vector(15 downto 0);
    -- Grad_J       | FullWriter 
    signal strtwr_GRDJ            : std_logic := '0';
    signal donew_xGRDJ            : std_logic := '0';
    signal rmdtwi_GRDJ            : std_logic_vector(47 downto 0);
    signal dtvin_xGRDJ            : std_logic := '0';
    signal rmwren_GRDJ            : std_logic := '0';
    signal rmwrar_GRDJ            : std_logic_vector(9 downto 0);
    signal rmdtwr_GRDJ            : std_logic_vector(47 downto 0);
    -- Grad_Jinv    | HalfWriter 
    signal strtwr_GJInv            : std_logic := '0';
    --signal ppsel_xGJInv            : std_logic := '0';
    signal donew_xGJInv           : std_logic := '0';
    signal rmdtwi_GJInv           : std_logic_vector(23 downto 0);
    signal dtvin_xGJInv           : std_logic := '0';
    signal rmwren_GJInv           : std_logic := '0';
    signal rmwrar_GJInv           : std_logic_vector(9 downto 0);
    signal rmdtwr_GJInv           : std_logic_vector(23 downto 0);
    -- Grad_Jconst  | FullWriter
    signal strtwr_GRDJC           : std_logic := '0';
    signal donew_xGRDJC           : std_logic := '0';
    signal rmdtwi_GRDJC           : std_logic_vector(47 downto 0);
    signal dtvin_xGRDJC           : std_logic := '0';
    signal rmwren_GRDJC           : std_logic := '0';
    signal rmwrar_GRDJC           : std_logic_vector(9 downto 0);
    signal rmdtwr_GRDJC           : std_logic_vector(47 downto 0);

    -- Signal Declerations for Integrated FFT Module | 1024-point, 3239 delay
    --Open source from: https://github.com/owocomm-0/fpga-fft
    signal isIFFT                 : std_logic := '0';
    signal valid_in               : std_logic := '0';
    signal data_inR               : std_logic_vector(23 downto 0);
    signal data_inI               : std_logic_vector(23 downto 0);
    signal valid_out              : std_logic := '0';
    signal fft_re_out             : std_logic_vector(23 downto 0);
    signal fft_im_out             : std_logic_vector(23 downto 0);
    signal phase_out_trigger      : std_logic := '0';
    signal phase_out_pipe         : std_logic_vector(15 downto 0) := (others => '0') ;
    signal halfpointdes           : std_logic := '0';
    signal hpdpipe                : std_logic_vector(7 downto 0) := (others => '0') ;
    --signal hpdduct_tape           : std_logic := '0';
    
    signal intfftzpvin            : std_logic := '0'; -- Integrated FFT zero pad valid in.
    -- One cyc delay is expected to be ok but just in case its longer, inspect at (1)
    signal validpipe              : std_logic_vector(9 downto 0) := (others => '0'); 
    signal phaseout               : unsigned(9 downto 0) := (others => '0');   
    

    -- Signal Declerations for Complex Multiplication Core | Stripped from the fft module and partly modified.
    signal vin_x_CMC              : std_logic := '0'; 
    signal vout_xCMC              : std_logic := '0';
    signal rdy_x_CMC              : std_logic := '0';
    signal in1_R_CMC              : std_logic_vector(23 downto 0);
    signal in1_I_CMC              : std_logic_vector(23 downto 0);
    signal in2_R_CMC              : std_logic_vector(23 downto 0);
    signal in2_I_CMC              : std_logic_vector(23 downto 0);
    signal AC_PW_CMC              : std_logic := '0';
    signal AC_GJ_CMC              : std_logic := '0';

    signal OUT_R_CMC              : std_logic_vector(23 downto 0);
    signal OUT_I_CMC              : std_logic_vector(23 downto 0);
    signal vpipe_CMC              : STD_LOGIC_VECTOR(9 downto 0);

    -- Read Modify Write Signals 
    signal RMW_EN_xIN             : std_logic := '0';
    signal RMW_EN_OUT             : STD_LOGIC_VECTOR(3 downto 0) := (others => '0') ;
    
    signal RMW_DT_xIN             : STD_LOGIC_VECTOR(47 downto 0) := (others => '0') ;
    signal RMW_DT_OUT             : STD_LOGIC_VECTOR(47 downto 0) := (others => '0') ;
    
    -- Signal Declerations for Algorithmic Parameters and Alignment Pipelines
    type   data_pipe_array is array (0 to 4) of std_logic_vector(47 downto 0);
    signal generic_data_pipe      : data_pipe_array := (others => (others => '0'));
    signal inputtognrcdtpipe      : std_logic_vector(47 downto 0);
    TYPE   GJALIGNPIPEARR0 IS array (0 TO 1) OF STD_LOGIC_VECTOR(47 DOWNTO 0);
    SIGNAL GJALIGNPIPEARR         : GJALIGNPIPEARR0 := (others => (others => '0'));
    SIGNAL GJALINPT               : STD_LOGIC_VECTOR(47 DOWNTO 0) := (others => '0'); 
    signal external_config_valid  : std_logic := '0';
    signal external_config_addr   : std_logic_vector(7 downto 0);
    signal external_config_data   : std_logic_vector(15 downto 0);
    signal wire_mu                : STD_LOGIC_VECTOR(15 downto 0);
    signal wire_lambda            : std_logic_vector(15 downto 0);
    signal wire_lambdarem         : std_logic_vector(15 downto 0);



    -- Signal&State Declerations for FSM 
    type hubstate is (ST_IDLE,
                      ST_DATA_INPUT,
                      ST_XFFT,
                      ST_FILTER,
                      ST_CALC_YCONV,
                      ST_CALC_OUT_EFRAME,
                      ST_EFFT,
                      ST_POWER,
                      ST_CALC_GRADJ,
                      ST_CALC_GRADJINV,
                      ST_CALC_GRADJCONST,
                      ST_CALC_UPDATE_WFFT );
    signal current_state          : hubstate := ST_IDLE;
    signal frame_ready            : std_logic:= '0';
    signal system_readyflag       : std_logic := '0';
    
    -- Signal Declerations for Leading One Detector (Priority Encoder)
    -- Data in will be the Power
    signal stpszbarrshf           : integer range 0 to 23; -- Max number of shifts are 23
    signal cmc_shift              : integer range 0 to 23; -- 12 in ST_FILTER, floor(log2 P) otherwise

    -- Generic Signals
    signal raw_grad_im            : signed(39 downto 0);
    signal raw_grad_re            : signed(39 downto 0);

    signal P_est                  : std_logic_vector(23 downto 0)   := (others => '0'); 
    signal P_old                  : std_logic_vector(23 downto 0)   := (others => '0'); 
    constant PWR_FRAC : integer := 15;
    constant EMU_FRAC : integer := 4;

    function rnd_sat24(v : signed; lsb_pos : natural) return std_logic_vector is
        variable t : signed(v'length downto 0);
    begin
        t := shift_right(resize(v, v'length + 1) + shift_left(to_signed(1, v'length + 1), lsb_pos - 1), lsb_pos);
        if t > 2**23 - 1 then
            return std_logic_vector(to_signed(2**23 - 1, 24));
        elsif t < -2**23 then
            return std_logic_vector(to_signed(-2**23, 24));
        end if;
        return std_logic_vector(resize(t, 24));
    end function;

    function sat_add24(a, b : std_logic_vector(23 downto 0)) return std_logic_vector is
        variable s : signed(24 downto 0);
    begin
        s := resize(signed(a), 25) + resize(signed(b), 25);
        if s > 2**23 - 1 then
            return std_logic_vector(to_signed(2**23 - 1, 24));
        elsif s < -2**23 then
            return std_logic_vector(to_signed(-2**23, 24));
        end if;
        return std_logic_vector(resize(s, 24));
    end function;

    function neg24(a : std_logic_vector(23 downto 0)) return std_logic_vector is
    begin
        if signed(a) = -2**23 then
            return std_logic_vector(to_signed(2**23 - 1, 24));
        end if;
        return std_logic_vector(-signed(a));
    end function;

    function sat12(a : std_logic_vector(23 downto 0)) return std_logic_vector is
    begin
        if signed(a) > 2**11 - 1 then
            return std_logic_vector(to_signed(2**11 - 1, 12));
        elsif signed(a) < -2**11 then
            return std_logic_vector(to_signed(-2**11, 12));
        end if;
        return std_logic_vector(resize(signed(a), 12));
    end function;
    -- Signal Declarations for testing only
    SIGNAL STOP_WFFTUPDTSIG       : STD_LOGIC := '0';
begin
    -- Debug Port Connections
    -- synthesis translate_off
    Debug_Port_Connections: block
        begin 
        -- Pretty Much permanent
        -- Weights (WFFT)
        DPO_STRTRDWFFT  <= strtrd_WFFT;
        DPO_DONE_xWFFT  <= done_x_WFFT;
        DPO_DONEW_WFFT  <= donew_xWFFT;
        DPO_STRTWRWFFT  <= strtwr_WFFT;
        DPO_RMENB_WFFT  <= rmen_x_WFFT;

        -- XFFT
        DPO_STRTRDXFFT  <= strtrd_XFFT;
        DPO_DONE_xXFFT  <= done_x_XFFT;
        DPO_DONEW_XFFT  <= donew_xXFFT;
        DPO_STRTWRXFFT  <= strtwr_XFFT;
        DPO_RMENB_XFFT  <= rmen_x_XFFT;

        -- X Buffer (XBuff)
        DPO_STRTRDXBUF  <= strtrd_XBuff;
        DPO_DONE_xXBUF  <= done_x_XBuff;
        DPO_DONEW_XBUF  <= donew_xXBuff;
        DPO_STRTWRXBUF  <= strtwr_Xbuff;
        DPO_RMENB_XBUF  <= rmen_x_XBuff;

        -- Error Frame (eframe)
        DPO_STRTRDEFRM  <= strtrd_eframe;
        DPO_DONE_xEFRM  <= done_x_eframe;
        DPO_DONEW_EFRM  <= donew_xeframe;
        DPO_STRTWREFRM  <= strtwr_eframe;
        DPO_RMENB_EFRM  <= rmen_x_eframe;

        -- Error FFT (EFFT)
        DPO_STRTRDEFFT  <= strtrd_EFFT;
        DPO_DONE_xEFFT  <= done_x_EFFT;
        DPO_DONEW_EFFT  <= donew_xEFFT;
        DPO_STRTWREFFT  <= strtwr_EFFT;
        DPO_RMENB_EFFT  <= rmen_x_EFFT;

        -- Desired Data (DDat)
        DPO_STRTRDDDAT  <= strtrd_DDat;
        DPO_DONE_xDDAT  <= done_x_DDat;
        DPO_DONEW_DDAT  <= donew_xDDat;
        DPO_STRTWRDDAT  <= strtwr_DDat;
        DPO_RMENB_DDAT  <= rmen_x_DDat;

        -- Gradient J (GRDJ)
        DPO_STRTRDGRDJ  <= strtrd_GRDJ;
        DPO_DONE_xGRDJ  <= done_x_GRDJ;
        DPO_DONEW_GRDJ  <= donew_xGRDJ;
        DPO_STRTWRGRDJ  <= strtwr_GRDJ;
        DPO_RMENB_GRDJ  <= rmen_x_GRDJ;

        -- Gradient J Inverse (GJInv)
        DPO_STRTRDGINV  <= strtrd_GJInv;
        DPO_DONE_xGINV  <= done_x_GJInv;
        DPO_DONEW_GINV  <= donew_xGJInv;
        DPO_STRTWRGINV  <= strtwr_GJInv;
        DPO_RMENB_GINV  <= rmen_x_GJInv;

        -- Gradient J Constant (GRDJC)
        DPO_STRTRDGRJC  <= strtrd_GRDJC;
        DPO_DONE_xGRJC  <= done_x_GRDJC;
        DPO_DONEW_GRJC  <= donew_xGRDJC;
        DPO_STRTWRGRJC  <= strtwr_GRDJC;
        DPO_RMENB_GRJC  <= rmen_x_GRDJC;

        -- Y Convolution (yconv)
        DPO_STRTRDYCNV  <= strtrd_yconv;
        DPO_DONE_xYCNV  <= done_x_yconv;
        DPO_DONEW_YCNV  <= donew_xyconv;
        DPO_STRTWRYCNV  <= strtwr_yconv;
        DPO_RMENB_YCNV  <= rmen_x_yconv;

        -- Y FFT (YFFT)
        DPO_STRTRDYFFT  <= strtrd_YFFT;
        DPO_DONE_xYFFT  <= done_x_YFFT;
        DPO_DONEW_YFFT  <= donew_xYFFT;
        DPO_STRTWRYFFT  <= strtwr_YFFT;
        DPO_RMENB_YFFT  <= rmen_x_YFFT;

        -- Power (POWR)
        DPO_STRTRDPOWR  <= strtrd_POWR;
        DPO_DONE_xPOWR  <= done_x_POWR;
        DPO_DONEW_POWR  <= donew_xPOWR;
        DPO_STRTWRPOWR  <= strtwr_POWR;
        DPO_RMENB_POWR  <= rmen_x_POWR;
        
        DPO_FFTPOUTRIG  <= phase_out_trigger;
        DPO_FFTPHSEOUT  <= TO_INTEGER(phaseout);
        DPO_VINFFTMODL  <= valid_in;
        DPO_VOTFFTMODL  <= valid_out;
        
        DPO_VIN_CMCMOD  <= vin_x_CMC;
        DPO_VOUTCMCMOD  <= vout_xCMC;

        DPO_RMW_EN_xIN  <= RMW_EN_xIN;
        DPO_RMW_EN_OUT  <= RMW_EN_OUT(3);
        DPOSTATECOUNTR  <= state_counter;

        DPOSTLVPROBE00  <= unsigned(rmdtwi_GRDJ(47 DOWNTO 24)) when (current_state = ST_CALC_GRADJ) else (others => '0');--unsigned(RMW_DT_xIN(23 DOWNTO 0));
        DPOSTLVPROBE01  <= unsigned(rmdtwi_GRDJ(23 DOWNTO 0)) when (current_state = ST_CALC_GRADJ) else (others => '0');--
        DPOSTLVPROBE10  <= unsigned(rmdtot_POWR) when (current_state = ST_CALC_GRADJ) else (others => '0');--RESIZE(unsigned(rmwrar_POWR),24);-- 
        DPOSTLVPROBE11  <= to_unsigned(stpszbarrshf, 24) when (current_state = ST_CALC_GRADJ) else (others => '0');

        DPOSTINTERNAL7  <= RMW_EN_xIN;
        DPOSTINTERNAL8  <= rmwren_GJInv;
        DPOSTINTERNAL9  <= dtvin_xGJInv;
        DPOSTINTERNALA  <= hpdpipe(0);
        DPOSTINTERNALB  <= AC_PW_CMC;
        DPOSTINTERNALC  <= AC_GJ_CMC;


        -- Test Pin Connections
            
    end block Debug_Port_Connections;
    -- synthesis translate_on
    STOP_WFFTUPDTSIG<= STOP_WFFTUPDT;
    -- RAMs
    Weights_RAM : entity work.Generic_SDP_RAM
        generic map (
            DATA_WIDTH => 48,
            ADDR_WIDTH => 10,
            DUMP_FILE_NAME => "DFContainer/WFFTDF"
        ) 
        port map (
            clk          => clk,
            we           => rmwren_WFFT,
            waddr        => rmwrar_WFFT,
            din          => rmdtwr_WFFT,
            raddr        => rmrdar_WFFT,
            dout         => rmdtin_WFFT,
            dump_trigger => GLOBALRAMDUMP
        );

    X_Buffer_RAM : entity work.Generic_SDP_RAM
        generic map (
            DATA_WIDTH => 24,
            ADDR_WIDTH => 10,
            DUMP_FILE_NAME => "DFContainer/XBUFDF"
        )
        port map (
            clk          => clk,
            we           => rmwren_XBuff,
            waddr        => rmadpplXBuff, -- make sure the ppsel is at correct phase
            din          => rmdtwr_XBuff,
            raddr        => rmrdar_XBuff,
            dout         => rmdtin_XBuff,
            dump_trigger => GLOBALRAMDUMP
        );

    D_data_RAM : entity work.Generic_SDP_RAM
        generic map (
            DATA_WIDTH => 24,
            ADDR_WIDTH => 9,
            DUMP_FILE_NAME => "DFContainer/DDATDF"
        )
        port map (
            clk          => clk,
            we           => rmwren_DDat,
            waddr        => rmadpplDDat(8 downto 0),
            din          => rmdtwr_DDat,
            raddr        => rmrdar_DDat,
            dout         => rmdtin_DDat,
            dump_trigger => GLOBALRAMDUMP
        );

    X_fft_RAM : entity work.Generic_SDP_RAM
        generic map (
            DATA_WIDTH => 48,
            ADDR_WIDTH => 10,
            DUMP_FILE_NAME => "DFContainer/XFFTDF"
        )
        port map (
            clk          => clk,
            we           => rmwren_XFFT,
            waddr        => rmwrar_XFFT,
            din          => rmdtwr_XFFT,
            raddr        => rmrdar_XFFT,
            dout         => rmdtin_XFFT,
            dump_trigger => GLOBALRAMDUMP
        );

    Y_fft_RAM : entity work.Generic_SDP_RAM
        generic map (
            DATA_WIDTH => 48,
            ADDR_WIDTH => 10,
            DUMP_FILE_NAME => "DFContainer/YFFTDF"
        )
        port map (
            clk          => clk,
            we           => rmwren_YFFT,
            waddr        => rmwrar_YFFT,
            din          => rmdtwr_YFFT,
            raddr        => rmrdar_YFFT,
            dout         => rmdtin_YFFT,
            dump_trigger => GLOBALRAMDUMP
        );

    y_conv_RAM : entity work.Generic_SDP_RAM
        generic map (
            DATA_WIDTH => 24,
            ADDR_WIDTH => 9,
            DUMP_FILE_NAME => "DFContainer/YCNVDF"
        )
        port map (
            clk          => clk,
            we           => rmwren_yconv,
            waddr        => rmwdmd_yconv(8 downto 0),
            din          => rmdtwr_yconv,
            raddr        => rmrdar_yconv,
            dout         => rmdtin_yconv,
            dump_trigger => GLOBALRAMDUMP
        );

    e_frame_RAM : entity work.Generic_SDP_RAM
        generic map (
            DATA_WIDTH => 24,
            ADDR_WIDTH => 9,
            DUMP_FILE_NAME => "DFContainer/EFRMDF"
        )
        port map (
            clk          => clk,
            we           => rmwren_eframe,
            waddr        => rmwrar_eframe(8 downto 0),
            din          => rmdtwr_eframe,
            raddr        => rmrdar_eframe,
            dout         => rmdtin_eframe,
            dump_trigger => GLOBALRAMDUMP
        );

    E_FFT_RAM : entity work.Generic_SDP_RAM
        generic map (
            DATA_WIDTH => 48,
            ADDR_WIDTH => 10,
            DUMP_FILE_NAME => "DFContainer/EFFTDF"
        )
        port map (
            clk          => clk,
            we           => rmwren_EFFT,
            waddr        => rmwrar_EFFT,
            din          => rmdtwr_EFFT,
            raddr        => rmrdar_EFFT,
            dout         => rmdtin_EFFT,
            dump_trigger => GLOBALRAMDUMP
        );

    Grad_J_RAM : entity work.Generic_SDP_RAM
        generic map (
            DATA_WIDTH => 48,
            ADDR_WIDTH => 10,
            DUMP_FILE_NAME => "DFContainer/GRDJDF"
        )
        port map (
            clk          => clk,
            we           => rmwren_GRDJ,
            waddr        => rmwrar_GRDJ,
            din          => rmdtwr_GRDJ,
            raddr        => rmrdar_GRDJ,
            dout         => rmdtin_GRDJ,
            dump_trigger => GLOBALRAMDUMP
        );

    Grad_Jinv_RAM : entity work.Generic_SDP_RAM
        generic map (
            DATA_WIDTH => 24,
            ADDR_WIDTH => 9,
            DUMP_FILE_NAME => "DFContainer/GINVDF"
        )
        port map (
            clk          => clk,
            we           => rmwren_GJInv,
            waddr        => NOT GJALIGNPIPEARR(0)(32 downto 24),
            din          => rmdtwr_GJInv,
            raddr        => rmrdar_GJInv,
            dout         => rmdtin_GJInv,
            dump_trigger => GLOBALRAMDUMP
        );

    Grad_Jconst_RAM : entity work.Generic_SDP_RAM
        generic map (
            DATA_WIDTH => 48,
            ADDR_WIDTH => 10,
            DUMP_FILE_NAME => "DFContainer/GRJCDF"
        )
        port map (
            clk          => clk,
            we           => rmwren_GRDJC,
            waddr        => rmwrar_GRDJC,
            din          => rmdtwr_GRDJC,
            raddr        => rmrdar_GRDJC,
            dout         => rmdtin_GRDJC,
            dump_trigger => GLOBALRAMDUMP
        );

    PowerSpectrm_RAM : entity work.Generic_SDP_RAM
        generic map (
            DATA_WIDTH => 24,
            ADDR_WIDTH => 10,
            DUMP_FILE_NAME => "DFContainer/POWRDF"
        )
        port map (
            clk          => clk,
            we           => rmwren_POWR,
            waddr        => rmwrar_POWR,
            din          => rmdtwr_POWR,
            raddr        => rmrdar_POWR,
            dout         => rmdtin_POWR,
            dump_trigger => GLOBALRAMDUMP
        );
    
    

    
    
        -- RAMReaders
    -- Weights      | FullReader    
    Weights_RamRead : entity work.Fullreadtttpt
        generic map (
            bitwidth => 48
        )
        
        port map(
            clk_cc           =>         clk,
            rst              =>         rst,
            start_read       =>         strtrd_WFFT,
            done             =>         done_x_WFFT,
            ram_addr         =>         rmrdar_WFFT,
            ram_data         =>         rmdtin_WFFT,
            ram_en           =>         rmen_x_WFFT,
            data_out         =>         rmdtot_WFFT,
            out_valid        =>         vout_x_WFFT
        );

    -- X_buffer     | OLSReader 
    XBuff_RamRead : entity work.OLSreadertttpt
        generic map (
            bitwidth => 24
        )
    
        port map(
            clk_cc           =>         clk,
            rst              =>         rst,
            start_read       =>         strtrd_XBuff,
            done             =>         done_x_XBuff,
            ping_pong_sel    =>         ppsel_xXBuff,
            ram_addr         =>         rmrdar_XBuff,
            ram_data         =>         rmdtin_XBuff,
            ram_en           =>         rmen_x_XBuff,
            data_out         =>         rmdtot_XBuff,
            out_valid        =>         vout_x_XBuff
        );
    -- D_Data       | HalfReader
    DDat_RamRead : entity work.Halfreadtttpn
        generic map (
            bitwidth => 24
        )

        port map(
            clk_cc           =>         clk,
            rst              =>         rst,
            start_read       =>         strtrd_DDat,
            done             =>         done_x_DDat,
            ram_addr         =>         rmrdar_DDat,
            ram_data         =>         rmdtin_DDat,
            ram_en           =>         rmen_x_DDat,
            data_out         =>         rmdtot_DDat,
            out_valid        =>         vout_x_DDat
        );

    -- X_fft        | FullReader 
    XFFT_RamRead : entity work.Fullreadtttpt
        generic map (
            bitwidth => 48
        )

        port map(
            clk_cc           =>         clk,
            rst              =>         rst,
            start_read       =>         strtrd_XFFT,
            done             =>         done_x_XFFT,
            ram_addr         =>         rmrdar_XFFT,
            ram_data         =>         rmdtin_XFFT,
            ram_en           =>         rmen_x_XFFT,
            data_out         =>         rmdtot_XFFT,
            out_valid        =>         vout_x_XFFT
        );

    -- Y_fft        | FullReader
    YFFT_RamRead : entity work.Fullreadtttpt
        generic map (
            bitwidth => 48
        )

        port map(
            clk_cc           =>         clk,
            rst              =>         rst,
            start_read       =>         strtrd_YFFT,
            done             =>         done_x_YFFT,
            ram_addr         =>         rmrdar_YFFT,
            ram_data         =>         rmdtin_YFFT,
            ram_en           =>         rmen_x_YFFT,
            data_out         =>         rmdtot_YFFT,
            out_valid        =>         vout_x_YFFT
        );

    -- y_conv       | HalfReader 
    yconv_RamRead : entity work.Halfreadtttpn
        generic map (
            bitwidth => 24
        )

        port map(
            clk_cc           =>         clk,
            rst              =>         rst,
            start_read       =>         strtrd_yconv,
            done             =>         done_x_yconv,
            ram_addr         =>         rmrdar_yconv,
            ram_data         =>         rmdtin_yconv,
            ram_en           =>         rmen_x_yconv,
            data_out         =>         rmdtot_yconv,
            out_valid        =>         vout_x_yconv
        );

    -- e_frame      | HalfReader
    eframe_RamRead : entity work.Halfreadtttpn
        generic map (
            bitwidth => 24
        )

        port map(
            clk_cc           =>         clk,
            rst              =>         rst,
            start_read       =>         strtrd_eframe,
            done             =>         done_x_eframe,
            ram_addr         =>         rmrdar_eframe,
            ram_data         =>         rmdtin_eframe,
            ram_en           =>         rmen_x_eframe,
            data_out         =>         rmdtot_eframe,
            out_valid        =>         vout_x_eframe
        );

    -- E_fft        | FullReader
    EFFT_RamRead : entity work.Fullreadtttpt
        generic map (
            bitwidth => 48
        )

        port map(
            clk_cc           =>         clk,
            rst              =>         rst,
            start_read       =>         strtrd_EFFT,
            done             =>         done_x_EFFT,
            ram_addr         =>         rmrdar_EFFT,
            ram_data         =>         rmdtin_EFFT,
            ram_en           =>         rmen_x_EFFT,
            data_out         =>         rmdtot_EFFT,
            out_valid        =>         vout_x_EFFT
        );
    -- Power        | FullReader
    PowerSpectrm_RamRead : entity work.Fullreadtttpt
        generic map (
            bitwidth => 24
        )

        port map(
            clk_cc           =>         clk,
            rst              =>         rst,
            start_read       =>         strtrd_POWR,
            done             =>         done_x_POWR,
            ram_addr         =>         rmrdar_POWR,
            ram_data         =>         rmdtin_POWR,
            ram_en           =>         rmen_x_POWR,
            data_out         =>         rmdtot_POWR,
            out_valid        =>         vout_x_POWR
        );
    -- StepSize     | FullReader
    --StepSizePerBin_RamRead : entity work.Fullreadtttpt
    --    generic map (
    --        bitwidth => 16
    --    )
    --
    --    port map(
    --        clk_cc           =>         clk,
    --        rst              =>         rst,
    --        start_read       =>         strtrd_mupb,
    --        done             =>         done_x_mupb,
    --        ram_addr         =>         rmrdar_mupb,
    --        ram_data         =>         rmdtin_mupb,
    --        ram_en           =>         rmen_x_mupb,
    --        data_out         =>         rmdtot_mupb,
    --        out_valid        =>         vout_x_mupb
    --    );
    -- Grad_J       | FullReader
    GRADJ_RamRead : entity work.Fullreadtttpt
        generic map (
            bitwidth => 48
        )        

        port map(
            clk_cc           =>         clk,
            rst              =>         rst,
            start_read       =>         strtrd_GRDJ,
            done             =>         done_x_GRDJ,
            ram_addr         =>         rmrdar_GRDJ,
            ram_data         =>         rmdtin_GRDJ,
            ram_en           =>         rmen_x_GRDJ,
            data_out         =>         rmdtot_GRDJ,
            out_valid        =>         vout_x_GRDJ
        );

    -- Grad_Jinv    | HalfReader
    GRADJInv_RamRead : entity work.Halfreadtttpn
        generic map (
            bitwidth => 24
        )

        port map(
            clk_cc           =>         clk,
            rst              =>         rst,
            start_read       =>         strtrd_GJInv,
            done             =>         done_x_GJInv,
            ram_addr         =>         rmrdar_GJInv,
            ram_data         =>         rmdtin_GJInv,
            ram_en           =>         rmen_x_GJInv,
            data_out         =>         rmdtot_GJInv,
            out_valid        =>         vout_x_GJInv
        );

    -- Grad_Jconst  | FullReader
    GRADJConst_RamRead : entity work.Fullreadtttpt
        generic map (
            bitwidth => 48
        )

        port map(
            clk_cc           =>         clk,
            rst              =>         rst,
            start_read       =>         strtrd_GRDJC,
            done             =>         done_x_GRDJC,
            ram_addr         =>         rmrdar_GRDJC,
            ram_data         =>         rmdtin_GRDJC,
            ram_en           =>         rmen_x_GRDJC,
            data_out         =>         rmdtot_GRDJC,
            out_valid        =>         vout_x_GRDJC
        );

    -- RAMWriters
    -- Weights      | FullWriter
    Weights_RamWrite : entity work.Fullwritertttpt
        generic map (
            bitwidth => 48
        )

        port map(
            clk_cc           =>         clk,
            rst              =>         rst,
            start_write      =>         strtwr_WFFT,
            done             =>         donew_xWFFT,
            data_in          =>         rmdtwi_WFFT,
            data_valid       =>         dtvin_xWFFT,
            ram_we           =>         rmwren_WFFT,
            ram_addr         =>         rmwrar_WFFT,
            ram_data         =>         rmdtwr_WFFT,
            wactivelabel     =>         Open
        );

    -- X_buffer     | HalfWriter
    XBUFF_RamWrite : entity work.ramwritetwottpnine
        generic map (
            bitwidth => 24
        )

        port map(
            clk_cc           =>         clk,
            rst              =>         rst,
            start_ac         =>         strtwr_Xbuff,
            ping_pong_sel    =>         ppsel_xXbuff,
            done             =>         donew_xXbuff,
            data_in          =>         rmdtwi_Xbuff,
            data_valid       =>         dtvin_xXbuff,
            ram_we           =>         rmwren_Xbuff,
            ram_addr         =>         rmwrar_Xbuff,--(8 downto 0),
            ram_data         =>         rmdtwr_Xbuff
        );
        --rmwrar_Xbuff(9)      <=         ppsel_xXBuff;
    -- D_Data       | HalfWriter 
    DDat_RamWrite : entity work.ramwritetwottpnine
        generic map (
            bitwidth => 24
        )

        port map(
            clk_cc           =>         clk,
            rst              =>         rst,
            start_ac         =>         strtwr_DDat,
            ping_pong_sel    =>         '0',
            done             =>         donew_xDDat,
            data_in          =>         rmdtwi_DDat,
            data_valid       =>         dtvin_xDDat,
            ram_we           =>         rmwren_DDat,
            ram_addr         =>         rmwrar_DDat,
            ram_data         =>         rmdtwr_DDat
        );

    -- X_fft        | FullWriter 
    XFFT_RamWrite : entity work.Fullwritertttpt
        generic map (
            bitwidth => 48
        )

        port map(
            clk_cc           =>         clk,
            rst              =>         rst,
            start_write      =>         strtwr_XFFT,
            done             =>         donew_xXFFT,
            data_in          =>         rmdtwi_XFFT,
            data_valid       =>         dtvin_xXFFT,
            ram_we           =>         rmwren_XFFT,
            ram_addr         =>         rmwrar_XFFT,
            ram_data         =>         rmdtwr_XFFT,
            wactivelabel     =>         open
        );

    -- Y_fft        | FullWriter
    YFFT_RamWrite : entity work.Fullwritertttpt
        generic map (
            bitwidth => 48
        )

        port map(
            clk_cc           =>         clk,
            rst              =>         rst,
            start_write      =>         strtwr_YFFT,
            done             =>         donew_xYFFT,
            data_in          =>         rmdtwi_YFFT,
            data_valid       =>         dtvin_xYFFT,
            ram_we           =>         rmwren_YFFT,
            ram_addr         =>         rmwrar_YFFT,
            ram_data         =>         rmdtwr_YFFT,
            wactivelabel     =>         open
        );

    -- y_conv       | HalfWriter 
    yconv_RamWrite : entity work.ramwritetwottpnine
        generic map (
            bitwidth => 24
        )

        port map(
            clk_cc           =>         clk,
            rst              =>         rst,
            start_ac         =>         strtwr_yconv,
            ping_pong_sel    =>         '0',
            done             =>         donew_xyconv,
            data_in          =>         rmdtwi_yconv,
            data_valid       =>         dtvin_xyconv,
            ram_we           =>         rmwren_yconv,
            ram_addr         =>         rmwrar_yconv,
            ram_data         =>         rmdtwr_yconv
        );

    -- e_frame      | HalfWriter
    eframe_RamWrite : entity work.ramwritetwottpnine
        generic map (
            bitwidth => 24
        )

        port map(
            clk_cc           =>         clk,
            rst              =>         rst,
            start_ac         =>         strtwr_eframe,
            ping_pong_sel    =>         '0',
            done             =>         donew_xeframe,
            data_in          =>         rmdtwi_eframe,
            data_valid       =>         dtvin_xeframe,
            ram_we           =>         rmwren_eframe,
            ram_addr         =>         rmwrar_eframe,
            ram_data         =>         rmdtwr_eframe
        );

    -- E_fft        | FullWriter
    EFFT_RamWrite : entity work.Fullwritertttpt
        generic map (
            bitwidth => 48
        )

        port map(
            clk_cc           =>         clk,
            rst              =>         rst,
            start_write      =>         strtwr_EFFT,
            done             =>         donew_xEFFT,
            data_in          =>         rmdtwi_EFFT,
            data_valid       =>         dtvin_xEFFT,
            ram_we           =>         rmwren_EFFT,
            ram_addr         =>         rmwrar_EFFT,
            ram_data         =>         rmdtwr_EFFT,
            wactivelabel     =>         open
        );
    -- Power        | FullWriter
    PowerSpectrm_RamWrite : entity work.Fullwritertttpt
        generic map (
            bitwidth => 24
        )

        port map(
            clk_cc           =>         clk,
            rst              =>         rst,
            start_write      =>         strtwr_POWR,
            done             =>         donew_xPOWR,
            data_in          =>         rmdtwi_POWR,
            data_valid       =>         dtvin_xPOWR,
            ram_we           =>         rmwren_POWR,
            ram_addr         =>         rmwrar_POWR,
            ram_data         =>         rmdtwr_POWR,
            wactivelabel     =>         open
        );
    -- Grad_J       | FullWriter
    GRADJ_RamWrite : entity work.Fullwritertttpt
        generic map (
            bitwidth => 48
        )

        port map(
            clk_cc           =>         clk,
            rst              =>         rst,
            start_write      =>         strtwr_GRDJ,
            done             =>         donew_xGRDJ,
            data_in          =>         rmdtwi_GRDJ,
            data_valid       =>         dtvin_xGRDJ,
            ram_we           =>         rmwren_GRDJ,
            ram_addr         =>         rmwrar_GRDJ,
            ram_data         =>         rmdtwr_GRDJ,
            wactivelabel     =>         open
        );

    -- Grad_Jinv    | HalfWriter
    GRADJInv_RamWrite : entity work.ramwritetwottpnine
        generic map (
            bitwidth => 24
        )

        port map(
            clk_cc           =>         clk,
            rst              =>         rst,
            start_ac         =>         strtwr_GJInv,
            ping_pong_sel    =>         '0',
            done             =>         donew_xGJInv,
            data_in          =>         rmdtwi_GJInv,
            data_valid       =>         dtvin_xGJInv,
            ram_we           =>         rmwren_GJInv,
            ram_addr         =>         rmwrar_GJInv,
            ram_data         =>         rmdtwr_GJInv
        );

    -- Grad_Jconst  | FullWriter
    GRDJC_RamWrite : entity work.Fullwritertttpt
        generic map (
            bitwidth => 48
        )

        port map(
            clk_cc           =>         clk,
            rst              =>         rst,
            start_write      =>         strtwr_GRDJC,
            done             =>         donew_xGRDJC,
            data_in          =>         rmdtwi_GRDJC,
            data_valid       =>         dtvin_xGRDJC,
            ram_we           =>         rmwren_GRDJC,
            ram_addr         =>         rmwrar_GRDJC,
            ram_data         =>         rmdtwr_GRDJC,
            wactivelabel     =>         open
        );


    -- Integrated FFT Module
    IntFFTMod : entity work.master_fft_wrapper 
        port map (
            clk                 => clk,
            rst                 => rst,
            isIFFT              => isIFFT,
            valid_in            => valid_in,
            data_inR            => data_inR,
            data_inI            => data_inI,
            valid_out           => valid_out,
            fft_re_out          => fft_re_out,
            fft_im_out          => fft_im_out,
            phase_out_trigger   => phase_out_trigger,
            halfpointdes        => halfpointdes,
            -- Debug Signals
            phase_out           => phaseout
            --valid_acc_debug => valid_acc_debug,
            --data_inRDebug   => data_inRDebug,
            --data_inIDebug   => data_inIDebug
            --data_in         => data_in
        );

    -- Complex Multiplier Core
    ComplexMultiplierCore_inst: entity work.ComplexMultiplierCore
        port map(
            clk                 => clk,
            rst                 => rst,
            valid_in            => vin_x_CMC,
            valid_out           => vout_xCMC,
            ready               => rdy_x_CMC,
            in1_R               => in1_R_CMC,
            in1_I               => in1_I_CMC,
            in2_R               => in2_R_CMC,
            in2_I               => in2_I_CMC,
            ACTV_PWR            => AC_PW_CMC,
            ACTV_GRDJ           => AC_GJ_CMC,
            GRDJ_SHFT           => cmc_shift,
            OUT_R               => OUT_R_CMC,
            OUT_I               => OUT_I_CMC
        );

    -- Y = X*W/2^14
    cmc_shift <= 12 when (current_state = ST_FILTER) else stpszbarrshf;

    -- Priority Encoder
    PriorityEncoder : entity work.LeadingOneDetector
        port map (
            data_in         => rmdtot_POWR,
            position        => stpszbarrshf
        );

    -- Read Modify Write 
    ReadModWrite    : entity work.RMWPipeline
        port map (
            clk             => clk,
            DATA_IN         => RMW_DT_xIN,
            DATA_OUT        => RMW_DT_OUT,
            EN_IN           => RMW_EN_xIN,
            EN_OUT_PIPE     => RMW_EN_OUT
        );

    -- Algorithmic Parameters | CSR Bank
    System_CSRs : entity work.CSR_Bank
        port map (
            clk             => clk,
            rst             => rst,
            
            config_valid    => external_config_valid,
            config_addr     => external_config_addr,
            config_data_in  => external_config_data,

            out_mu          => wire_mu,
            out_lambda      => wire_lambda,
            out_lambdarem   => wire_lambdarem
        );

    --  Finite State Machine
    --  ST_IDLE                 | The Hub
    --  ST_DATA_INPUT           | Load input data to ram. 
    --  ST_XFFT                 | Calculate the fft of the XBuff
    --  ST_FILTER               | Multiply XFFT and WFFT, write it to YFFT ram
    --  ST_CALC_YCONV           | Read YFFT, calculate its ifft, throw away half and write it to ram
    --  ST_CALC_OUT_EFRAME      | Calculate e_frame = DData - OutPut; and write it to ram
    --  ST_EFFT                 | Calculate the FFT of the zeropadded e_frame
    --  ST_POWER                | Calculate the Power Spectrum Of X_FFT 
    --  ST_CALC_GRADJ           | Multiply the conjugate of the XFFT with E_FFT
    --  ST_CALC_GRADJINV        | Calculate ifft of GRADJ
    --  ST_CALC_GRADJCONST      | Throw Half of the GRADJINV, zeropad, calculate fft
    --  ST_CALC_UPDATE_WFFT     | Calculate WFFT + GRADJCONST and write it to the same address

    -- Permanent I/O pins
        rmdtwi_DDat             <= std_logic_vector(RESIZE(signed(generic_data_pipe(0)(11 DOWNTO 0)), 24)) WHEN (current_state = ST_DATA_INPUT) else (others => '0');
        rmdtwi_Xbuff            <= std_logic_vector(RESIZE(signed(generic_data_pipe(0)(35 DOWNTO 24)), 24)) WHEN (current_state = ST_DATA_INPUT) else (others => '0');
        frame_ready             <= Frame_ReadyI;
        System_ReadyO           <= system_readyflag;
        dtvin_xDDat             <= DDATAINVALID;
        dtvin_xXbuff            <= XDATAINVALID;

    Output_Register: process (clk)
    begin
        if rising_edge(clk) then
            OUTDATAVALID <= '0';
            if (current_state = ST_EFFT) and (rmen_x_eframe = '1') then
                OUTDATA      <= sat12(rmdtot_eframe);
                OUTDATAVALID <= '1';
            end if;
        end if;
    end process;


    -- ADDRESS PIPELINING
    rmadpplDDat                 <= generic_data_pipe(0)(21 DOWNTO 12) WHEN (current_state = ST_DATA_INPUT) else (others => '0');
    rmadpplXBuff                <= generic_data_pipe(0)(45 DOWNTO 36) WHEN (current_state = ST_DATA_INPUT) else (others => '0');    

    -- Internal Valid&Data chain
    dtvin_xXFFT                 <= validpipe(1) when (current_state = ST_XFFT) else '0';
    dtvin_xYFFT                 <= vpipe_CMC(1) when (current_state = ST_FILTER) else '0';
    dtvin_xyconv                <= valid_out when (current_state = ST_CALC_YCONV) else '0';
    dtvin_xeframe               <= vout_x_DDat and vout_x_yconv when (current_state = ST_CALC_OUT_EFRAME) else '0';
    dtvin_xEFFT                 <= validpipe(2) when (current_state = ST_EFFT) else '0';
    dtvin_xPOWR                 <= RMW_EN_OUT(2) when (current_state = ST_POWER) else '0';
    dtvin_xGRDJ                 <= vpipe_CMC(1) when (current_state = ST_CALC_GRADJ) else '0';
    dtvin_xGJInv                <= valid_out when (current_state = ST_CALC_GRADJINV) else '0';
    dtvin_xGRDJC                <= valid_out when (current_state = ST_CALC_GRADJCONST) else '0';
    dtvin_xWFFT                 <= RMW_EN_OUT(3)   when (current_state = ST_CALC_UPDATE_WFFT) else '0';
    
    -- Data pipeline entrance:
    inputtognrcdtpipe           <=  STD_LOGIC_VECTOR(RESIZE(UNSIGNED(rmwrar_Xbuff), XDATAIN'length)) & XDATAIN 
                                    & STD_LOGIC_VECTOR(RESIZE(UNSIGNED(rmwrar_DDat), DDATAIN'length)) & DDATAIN  WHEN (current_state = ST_DATA_INPUT) ELSE 
                                    
                                    std_logic_vector(-signed(fft_im_out)) & fft_re_out when (current_state = ST_XFFT) else 
                                    std_logic_vector(RESIZE(signed(rmdtot_DDat) - signed(rmdtot_yconv), 48)) when (current_state = ST_CALC_OUT_EFRAME) else
                                    rnd_sat24(raw_grad_im, EMU_FRAC) & rnd_sat24(raw_grad_re, EMU_FRAC) when (current_state = ST_EFFT) else
                                    OUT_I_CMC & OUT_R_CMC when (current_state = ST_CALC_GRADJ) else 
                                    rmdtot_GRDJ when (current_state = ST_CALC_GRADJINV) else  
                                    std_logic_vector(RESIZE(signed(rmdtot_GJInv), 48)) when (current_state = ST_CALC_GRADJCONST) else     
                                    OUT_I_CMC & OUT_R_CMC when (current_state = ST_FILTER) else 
                                    fft_re_out & std_logic_vector(RESIZE(unsigned(rmwrar_yconv), 24)) when (current_state = ST_CALC_YCONV) else
                                    STD_LOGIC_VECTOR(RESIZE(UNSIGNED(rmdtot_POWR), 48)) WHEN (current_state = ST_POWER) ELSE    
                                    (others => '0');

    rmdtwi_XFFT                 <= generic_data_pipe(1) when (current_state = ST_XFFT) else (others => '0');
    rmdtwi_eframe               <= generic_data_pipe(0)(23 downto 0) when (current_state = ST_CALC_OUT_EFRAME) else (others => '0');
    rmdtwi_EFFT                 <= generic_data_pipe(1) when (current_state = ST_EFFT) else (others => '0');   
    rmdtwi_GRDJ                 <= generic_data_pipe(2) when (current_state = ST_CALC_GRADJ) else (others => '0'); 
    rmdtwi_GRDJC                <= STD_LOGIC_VECTOR(-SIGNED(fft_im_out)) & fft_re_out when (current_state = ST_CALC_GRADJCONST) else (others => '0'); 
    rmdtwi_YFFT                 <= generic_data_pipe(2) when (current_state = ST_FILTER) else (others => '0');
    rmdtwi_yconv                <= generic_data_pipe(0)(47 downto 24) when (current_state = ST_CALC_YCONV) else (others => '0'); 
    

    GJALINPT                    <= STD_LOGIC_VECTOR(RESIZE(UNSIGNED(rmwrar_GJInv) & UNSIGNED(fft_re_out), 48)) WHEN (current_state = ST_CALC_GRADJINV) ELSE (others => '0'); 
    rmdtwi_GJInv(23 downto 0)   <= GJALINPT(23 DOWNTO 0) when (current_state = ST_CALC_GRADJINV) else (others => '0');
    --rmdtwi_yconv
    --rmdtwi_EFFT
    --rmdtwi_GJInv
     
    rmwdmd_yconv                <= NOT generic_data_pipe(0)(9 downto 0) when (current_state = ST_CALC_YCONV) else b"00_0000_0000";

        -- Integrated FFT Module
    data_inR <= rmdtot_XBuff when (current_state = ST_XFFT) else
                --rmdtot_YFFT(23 downto 0) when (current_state = ST_CALC_YCONV) else
                rmdtot_eframe when (current_state = ST_EFFT) and (rmen_x_eframe = '1') else 
                generic_data_pipe(0)(23 downto 0) when (current_state = ST_CALC_GRADJINV) else
                generic_data_pipe(0)(23 downto 0) when (current_state = ST_CALC_GRADJCONST) and intfftzpvin = '0' else 
                RMW_DT_OUT(23 downto 0) when (current_state = ST_CALC_YCONV) else -- X*W/2^14 
                (others => '0'); -- Perhaps loookout for the imag of the Grad J
    data_inI <= --rmdtot_YFFT(47 downto 24)   when (current_state = ST_CALC_YCONV) else
                --rmdtwi_eframe when (current_state = ST_EFFT)
                generic_data_pipe(0)(47 downto 24) when (current_state = ST_CALC_GRADJINV) else
                RMW_DT_OUT(47 downto 24) when (current_state = ST_CALC_YCONV) 
                else (others => '0'); 
    valid_in <= vout_x_XBuff when (current_state = ST_XFFT) else
                RMW_EN_OUT(2) when (current_state = ST_CALC_YCONV) else
                vout_x_eframe or intfftzpvin when (current_state = ST_EFFT) else
                vout_x_GRDJ when (current_state = ST_CALC_GRADJINV) else
                vout_x_GJInv or intfftzpvin when (current_state = ST_CALC_GRADJCONST)
                else '0';
    -- Complex Multiplier Core
    in1_R_CMC       <= rmdtot_XFFT(23 downto 0) when (current_state = ST_FILTER) else
                       rmdtot_XFFT(23 downto 0) when (current_state = ST_CALC_GRADJ) else
                       rmdtot_XFFT(23 downto 0) when (current_state = ST_POWER)
                       else (others => '0'); 

    in1_I_CMC       <= rmdtot_XFFT(47 downto 24) when (current_state = ST_FILTER) else
                       std_logic_vector(-signed(rmdtot_XFFT(47 downto 24))) when (current_state = ST_CALC_GRADJ) else
                       rmdtot_XFFT(47 downto 24) when (current_state = ST_POWER) 
                       else (others => '0');      

    in2_R_CMC       <= rmdtot_WFFT(23 downto 0) when (current_state = ST_FILTER) ELSE
                       rmdtot_EFFT(23 downto 0) when (current_state = ST_CALC_GRADJ) else
                       rmdtot_XFFT(23 downto 0) when (current_state = ST_POWER) 
                       else (others => '0'); 

    in2_I_CMC       <= rmdtot_WFFT(47 downto 24) when (current_state = ST_FILTER) else
                       rmdtot_EFFT(47 downto 24) when (current_state = ST_CALC_GRADJ) ELSE
                       std_logic_vector(-signed(rmdtot_XFFT(47 downto 24))) when (current_state = ST_POWER)
                       else (others => '0'); 


    --rmdtwi_GRDJ(23 downto 0)  <= OUT_R_CMC when (current_state = ST_CALC_GRADJ) else (others => '0');
    --rmdtwi_GRDJ(47 downto 24) <= OUT_I_CMC when (current_state = ST_CALC_GRADJ) else (others => '0');

    P_est                     <= OUT_R_CMC when (current_state = ST_POWER) ELSE (others => '0'); -- major truncation error with CMC. Fixed
        
    
    vin_x_CMC                 <= vout_x_WFFT and vout_x_XFFT when (current_state = ST_FILTER) else
                                    vout_x_EFFT and vout_x_XFFT when (current_state = ST_CALC_GRADJ) else 
                                    vout_x_XFFT when (current_state = ST_POWER) 
                       
                       ELSE '0';
    --vout_xCMC       <= 

    -- RMW
    RMW_DT_xIN      <=  std_logic_vector(RESIZE((unsigned(P_old)*unsigned(wire_lambda) + unsigned(wire_lambdarem)*unsigned(P_est) + TO_UNSIGNED(2**(PWR_FRAC-1), 40)), 48)) when (current_state = ST_POWER) else
                        sat_add24(rmdtot_WFFT(47 downto 24), rmdtot_GRDJC(47 downto 24)) & sat_add24(rmdtot_WFFT(23 downto 0), rmdtot_GRDJC(23 downto 0)) when (current_state = ST_CALC_UPDATE_WFFT) and (STOP_WFFTUPDTSIG = '0') else
                        rmdtot_WFFT when (current_state = ST_CALC_UPDATE_WFFT) else
                        -- (-1)^k
                        rmdtot_YFFT when (current_state = ST_CALC_YCONV) and (rmrdar_YFFT(0) = '1') else
                        neg24(rmdtot_YFFT(47 downto 24)) & neg24(rmdtot_YFFT(23 downto 0)) when (current_state = ST_CALC_YCONV)
                        --STD_LOGIC_VECTOR(RESIZE(UNSIGNED(rmwrar_GJInv) & UNSIGNED(fft_re_out), 48)) when (current_state = ST_CALC_GRADJINV)
                        ELSE (others => '0');
    RMW_EN_xIN      <=  vout_xCMC when (current_state = ST_POWER) else
                        rmen_x_WFFT and rmen_x_GRDJC when (current_state = ST_CALC_UPDATE_WFFT) else
                        vout_x_YFFT when (current_state = ST_CALC_YCONV)
                        else '0';
                        
    rmdtwi_POWR     <= RMW_DT_OUT(PWR_FRAC+23 DOWNTO PWR_FRAC) when (current_state = ST_POWER) else (others => '0') ;
    
    rmdtwi_WFFT     <= RMW_DT_OUT when (current_state = ST_CALC_UPDATE_WFFT) else (others => '0') ;

    -- Generic
    -- eframe should be 12 bits
    raw_grad_im     <= RESIZE(-signed(fft_im_out)* signed(wire_mu), 40) when rising_edge(clk);
    raw_grad_re     <= RESIZE(signed(fft_re_out)* signed(wire_mu), 40) when rising_edge(clk);

    P_old           <= generic_data_pipe(4)(23 DOWNTO 0);     

    

    process (clk)

        -- Control Signals
        -- Writer strtwr, ppslwr, donew, rmdtwi, dtvin, rmwren, rmwrar, rmdtwr
        -- Reader strtrd, done, ppsel, rmrdar, rmdtin, rmen, rmdtot, vout

        -- Generic Vars for shared modules
        -- FFT Module
        variable ltchfallingvo      : std_logic := '0';
        variable ltchrisingvo       : std_logic := '0';
        variable ltchhlfpntd        : std_logic := '0';
        variable ltchphsstate       : std_logic := '0';
        
        -- CMC
        variable ltchvorcmc         : std_logic := '0';
        variable ltchvofcmc         : std_logic := '0';
        -- RMW
        variable ltchvorrmw         : std_logic := '0';
        variable ltchvofrmw         : std_logic := '0';
        variable trgrvorrmw         : std_logic := '0';
        
        -- Vars for ST_IDLE
        variable ltchfrmrdy         : std_logic := '0';
        variable ltchsystrdyflag    : std_logic := '0';
        
        
        
        -- Vars for ST_DATA_INPUT
        variable ltchdonew_DDAT     : std_logic := '0';
        variable ltchdonew_XBuff    : std_logic := '0';
        variable entrydataiptst     : std_logic := '0';
        variable exitdatainptst     : std_logic := '0'; -- might be unnecessary
        
        -- Vars for ST_XFFT
        variable entryxfftst        : std_logic := '0';
        variable exitxfftst         : std_logic := '0';
        --variable ltcholsppsl_xfft   : std_logic := '0';
        variable ltchdonexfftwr     : std_logic := '0';  
        
        -- Vars for ST_FILTER
        variable entryfilterst      : std_logic := '0';
        variable extfilterst        : std_logic := '0';
        variable ltchdoneyfftwr     : std_logic := '0';
        
        -- Vars for ST_CALC_YCONV
        variable entryyconvst       : std_logic := '0';
        variable ltchycnvx_wr       : std_logic := '0';
        variable exit_yconvst       : std_logic := '0';
        variable ltchdoneycnv       : std_logic := '0';
        
        -- Vars for ST_CALC_EFRAME
        variable entryeframest      : std_logic := '0';
        variable exit_eframest      : std_logic := '0';
        variable ltchdoneycv        : std_logic := '0';
        variable ltchdoneddt        : std_logic := '0';
        variable ltchdonewef        : std_logic := '0';

        -- Vars for ST_EFFT
        variable entryefftst        : std_logic := '0';
        variable exit_efftst        : std_logic := '0';
        variable ltchdoneefftwr     : std_logic := '0';

        -- Vars for ST_Pow
        variable entrypwrst        : std_logic := '0';
        variable exit_pwrst        : std_logic := '0';
        variable ltchdonepwrwr     : std_logic := '0';


        -- Vars for ST_CALC_GRADJ 
        variable entrygrdjst        : std_logic := '0';
        variable exit_grdjst        : std_logic := '0';
        variable ltchdonegrdjwr     : std_logic := '0';
        
        -- Vars for ST_CALC_GRADJINV 
        variable entrygrdjinvst     : std_logic := '0';
        variable exit_grdjinvst     : std_logic := '0';
        variable ltchdonegjinv      : std_logic := '0';
        
        -- Vars for ST_CALC_GRADJCONST 
        variable entrygrdjcnstst    : std_logic := '0';
        variable exit_grdjcnstst    : std_logic := '0';
        variable ltchgrdjvozerop    : std_logic := '0';
        variable ltchdonegjcstwr    : std_logic := '0';
        

        -- Vars for ST_CALC_UPDATE_WFFT 
        variable entryupdtewst      : std_logic := '0';
        variable exit_updtewst      : std_logic := '0';
        variable ltchdonewghtwr     : std_logic := '0';
        
        
        
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Reset Signals
                current_state       <= ST_IDLE;
                ppsel_xXBuff        <= '0';
            else
                strtwr_DDat         <= '0';
                strtwr_Xbuff        <= '0';
                strtwr_XFFT         <= '0';
                strtwr_EFFT         <= '0';
                strtwr_eframe       <= '0';
                strtwr_GJInv        <= '0';
                strtwr_GRDJ         <= '0';
                strtwr_GRDJC        <= '0';
                strtwr_POWR         <= '0';
                strtwr_WFFT         <= '0';
                strtwr_YFFT         <= '0';
                strtwr_yconv        <= '0';

                strtrd_DDat         <= '0';
                strtrd_Xbuff        <= '0';
                strtrd_XFFT         <= '0';
                strtrd_EFFT         <= '0';
                strtrd_eframe       <= '0';
                strtrd_GJInv        <= '0';
                strtrd_GRDJ         <= '0';
                strtrd_GRDJC        <= '0';
                strtrd_POWR         <= '0';
                strtrd_WFFT         <= '0';
                strtrd_YFFT         <= '0';
                strtrd_yconv        <= '0';
                AC_PW_CMC           <= '0';
                AC_GJ_CMC           <= '0';
                -- Temporary Debug Test Pin connections
                -- synthesis translate_off
                DPOSTINTERNAL0  <= ltchrisingvo;
                DPOSTINTERNAL1  <= ltchfallingvo;
                DPOSTINTERNAL2  <= dtvin_xEFFT;
                DPOSTINTERNAL3  <= dtvin_xXFFT;
                DPOSTINTERNAL4  <= phase_out_pipe(8);
                DPOSTINTERNAL5  <= intfftzpvin;
                DPOSTINTERNAL6  <= dtvin_xPOWR;

                -- synthesis translate_on

                phase_out_pipe              <= phase_out_pipe(14 downto 0) & phase_out_trigger;
                validpipe                   <= validpipe(8 downto 0) & valid_out;
                vpipe_CMC                   <= vpipe_CMC(8 downto 0) & vout_xCMC;
                hpdpipe                     <= hpdpipe(6 downto 0) & halfpointdes;
                generic_data_pipe(1 to 4)   <= generic_data_pipe(0 to 3);
                generic_data_pipe(0)        <= inputtognrcdtpipe;
                GJALIGNPIPEARR(1)           <= GJALIGNPIPEARR(0);
                GJALIGNPIPEARR(0)           <= GJALINPT;
                case current_state is
                    when ST_IDLE =>
                        -- Set State Counter
                        state_counter           <= 0;
                        -- Start of the Algorithmic Cycle
                        
                        if not ltchsystrdyflag and not ltchfrmrdy then
                            system_readyflag    <= '1';
                            ltchsystrdyflag     := '1';
                        end if;
                        -- Safety net for sysrdy = 0 and frame_rdy = 1
                        
                        -- Go to data input state
                        if frame_ready and system_readyflag then
                            current_state       <= ST_DATA_INPUT;
                            system_readyflag    <= '0';
                            ltchsystrdyflag     := '0';
                            ltchfrmrdy          := '1';
                            entrydataiptst      := '1';
                        end if;
                        -- End of data input state and point to next state
                        if exitdatainptst then 
                            entryxfftst         := '1';     
                            exitdatainptst      := '0';     -- This reset is the official end of ST_DATA_INPUTs
                        end if;

                        if entryxfftst then -- Pointing to next state with its own entry flag might be stupid
                            current_state       <= ST_XFFT;
                        end if;

                        if exit_updtewst then
                            ltchfrmrdy          := '0';

                            exit_updtewst       := '0';
                        end if;
                
                    when ST_DATA_INPUT =>
                        -- Set State Counter
                        state_counter           <= 1;

                        if entrydataiptst  = '1' then
                            strtwr_DDat         <= '1';
                            strtwr_Xbuff        <= '1';
                            ltchdonew_DDat      := '0';
                            ltchdonew_XBuff     := '0';
                            entrydataiptst      := '0';
                        end if;

                        if donew_xXbuff and not ltchdonew_XBuff then 
                            ltchdonew_XBuff := '1';
                        end if;

                        if donew_xDDat then 
                            ltchdonew_DDat  := '1';
                        end if;

                        if ltchdonew_DDat and ltchdonew_XBuff then
                            exitdatainptst := '1';
                        end if;

                        if exitdatainptst then
                            current_state       <= ST_IDLE;
                        end if;   
                        
                    
                    when ST_XFFT =>
                    -- Set State Counter
                        state_counter           <= 2;

                    -- Read Xbuffer (PingPong) | feed data into Integrated FFT module with correct parameters
                    -- Write the data to XFFT dedicated RAM | Watch out for trigger and enable style signals
                    -- Pay attention to Ram delay&Signal Assignment Delay Multiple signals need to match be clk perfectly

                        isIFFT   <= '0'; 
                        if phase_out_pipe(8) and entryxfftst then
                            strtrd_XBuff    <= '1';
                            entryxfftst     := '0';
                        end if;

                        if valid_out and not ltchrisingvo then
                            strtwr_XFFT         <= '1';
                            ltchrisingvo        := '1';
                        end if;

                        if not valid_out and not ltchfallingvo and ltchrisingvo then 
                            ltchfallingvo       := '1';
                        end if;

                        if donew_xXFFT then
                            ltchdonexfftwr      := '1';
                        end if;

                        if ltchdonexfftwr and ltchfallingvo then
                            exitxfftst          := '1';
                        end if;

                        if exitxfftst then 
                            current_state <= ST_FILTER;
                            ltchrisingvo        := '0';
                            ltchfallingvo       := '0';
                            ltchdonexfftwr      := '0';
                            entryfilterst       := '1';
                        end if;

                    when ST_FILTER =>
                    -- Set State Counter
                        state_counter           <= 3;
                        AC_GJ_CMC               <= '1'; -- Y = X*W/2^14

                    -- Read XFFT and WFFT simultaneously | Multiply using the CMC | Write the output to YFFT

                        if exitxfftst  then
                            ppsel_xXBuff        <= not ppsel_xXBuff; -- We update here since read/write needs to be in sync
                            exitxfftst          := '0';
                        end if;

                        if entryfilterst then
                            strtrd_XFFT     <= '1';
                            strtrd_WFFT     <= '1';
                            ltchdoneyfftwr  := '0';
                            extfilterst     := '0';
                            entryfilterst   := '0';
                        end if;

                        if vout_xCMC and not ltchvorcmc then
                            strtwr_YFFT     <= '1';

                            ltchvorcmc      := '1';
                        end if;

                        if not vout_xCMC and not ltchvofcmc and ltchvorcmc then
                            ltchvofcmc      := '1';
                        end if;

                        if donew_xYFFT then
                            ltchdoneyfftwr  := '1';
                        end if;

                        if ltchvofcmc and ltchdoneyfftwr then
                            extfilterst     := '1';
                        end if;

                        if extfilterst then
                            current_state   <= ST_CALC_YCONV;
                            ltchvofcmc      := '0';
                            ltchvorcmc      := '0';
                            AC_GJ_CMC       <= '0';
                            entryyconvst    := '1';

                        end if;

                    when ST_CALC_YCONV =>
                        -- Set State Counter
                        state_counter           <= 4;

                        isIFFT                  <= '1';
                        -- Read YFFT, calculate its IFFT and write half of it to yconv
                        if entryyconvst and phase_out_pipe(4) then
                            strtrd_YFFT     <= '1';
                            ltchdoneycnv    := '0';
                            exit_yconvst    := '0';
                            entryyconvst    := '0';
                        end if;

                        if valid_out and not ltchrisingvo then
                            ltchrisingvo    := '1';
                        end if;

                        --a boolean condition unlike the rest which are all stdls
                        if (ltchrisingvo = '1') and (phaseout = x"A7") and (ltchycnvx_wr = '0') then --hpdpipe(0) 
                            strtwr_yconv    <= '1';
                            ltchycnvx_wr    := '1';
                        end if;

                        if not valid_out and not ltchfallingvo and ltchrisingvo then 
                            ltchfallingvo   := '1';
                        end if;
                        
                        if donew_xyconv then
                            ltchdoneycnv    := '1'; 
                        end if;

                        if ltchdoneycnv and ltchfallingvo then
                            exit_yconvst    := '1';
                        end if;

                        if exit_yconvst then
                            current_state   <= ST_CALC_OUT_EFRAME;
                            entryeframest   := '1';
                            ltchrisingvo    := '0';
                            ltchfallingvo   := '0';
                            ltchycnvx_wr    := '0';
                            exit_yconvst    := '0';
                        end if;

                    when ST_CALC_OUT_EFRAME =>
                        -- Set State Counter
                        state_counter           <= 5;

                        if entryeframest then
                            strtrd_yconv        <= '1';
                            strtrd_DDat         <= '1';
                            strtwr_eframe       <= '1';
                            ltchdoneycv         := '0';                            
                            ltchdoneddt         := '0';
                            ltchdonewef         := '0';
                            entryeframest       := '0';
                        end if;
                        
                        if done_x_DDat then
                            ltchdoneddt         := '1';
                        end if;

                        if done_x_yconv then
                            ltchdoneycv         := '1';
                        end if;

                        if donew_xeframe then
                            ltchdonewef         := '1';
                        end if;

                        if ltchdonewef and ltchdoneddt and ltchdoneycv then
                            exit_eframest       := '1';
                        end if;

                        if exit_eframest then
                            current_state       <= ST_EFFT;
                            entryefftst         := '1';

                            exit_eframest       := '0';
                        end if;

                    when ST_EFFT =>
                    -- Set State Counter
                        state_counter           <= 6;

                        isIFFT   <= '0'; 

                        if entryefftst and phase_out_pipe(10) then
                            ltchdoneefftwr  := '0';
                            exit_efftst     := '0';
                            intfftzpvin     <= '1';
                            entryefftst     := '0';
                        end if;

                        if hpdpipe(3) and intfftzpvin then
                            strtrd_eframe   <= '1';                            
                        end if;

                        if rmen_x_eframe then 
                            intfftzpvin     <= '0';
                        end if;

                        if valid_out and not ltchrisingvo then
                            strtwr_EFFT     <= '1';
                            ltchrisingvo    := '1';
                        end if;

                        if ltchrisingvo then 
                            intfftzpvin     <= '0';
                        end if;

                        if not valid_out and not ltchfallingvo and ltchrisingvo then 
                            ltchfallingvo   := '1';
                        end if;

                        if donew_xEFFT then
                            ltchdoneefftwr  := '1';
                        end if;

                        if ltchdoneefftwr and ltchfallingvo then
                            exit_efftst      := '1';
                        end if;

                        if exit_efftst then 
                            current_state    <= ST_POWER;
                            ltchrisingvo    := '0';
                            ltchfallingvo   := '0';
                            entrypwrst      := '1';
                            exit_efftst     := '0';
                        end if;

                    when ST_POWER =>
                        -- Set State Counter
                        state_counter           <= 7;
                        AC_PW_CMC               <= '1';
                        if entrypwrst then
                            strtrd_XFFT           <= '1';
                            strtrd_POWR           <= '1';
                            ltchdonepwrwr         := '0';  
                            entrypwrst            := '0';
                        end if;

                        if not ltchvorcmc and vout_xCMC then
                            ltchvorcmc            := '1';
                            --strtrd_POWR           <= '1';
                        end if;

                        if not ltchvorrmw and RMW_EN_xIN then 
                            ltchvorrmw            := '1';
                            strtwr_POWR           <= '1';
                        end if;

                        if not RMW_EN_xIN and not ltchvofrmw and ltchvorrmw then
                            ltchvofrmw            := '1';
                        end if;
                        
                        if donew_xPOWR then
                            ltchdonepwrwr         := '1';
                        end if;

                        if ltchdonepwrwr and ltchvofrmw then
                            exit_pwrst            := '1';
                        end if;

                        if exit_pwrst then
                            current_state         <= ST_CALC_GRADJ;
                            ltchvorcmc            := '0';
                            ltchvofrmw            := '0';
                            ltchvorrmw            := '0';
                            AC_PW_CMC             <= '0';
                            entrygrdjst           := '1';
                            exit_pwrst            := '0';
                        end if; 

                    when ST_CALC_GRADJ =>
                        -- Set State Counter
                        state_counter           <= 8;
                        AC_GJ_CMC               <= '1';

                        if entrygrdjst then
                            strtrd_EFFT     <= '1';
                            strtrd_XFFT     <= '1';
                            strtrd_POWR     <= '1';
                            strtwr_GRDJ     <= '1'; -- Gets the Ram Ready
                            ltchdonegrdjwr  := '0';
                            exit_grdjst     := '0';
                            entrygrdjst     := '0';
                        end if;

                        if vout_xCMC and not ltchvorcmc then
                            ltchvorcmc      := '1';
                        end if;

                        if not vout_xCMC and not ltchvofcmc and ltchvorcmc then
                            ltchvofcmc      := '1';
                        end if;

                        if donew_xGRDJ then
                            ltchdonegrdjwr  := '1';
                        end if;

                        if ltchvofcmc and ltchdonegrdjwr then
                            exit_grdjst     := '1';
                        end if;

                        if exit_grdjst then
                            current_state   <= ST_CALC_GRADJINV;
                            ltchvofcmc      := '0';
                            ltchvorcmc      := '0';
                            AC_GJ_CMC       <= '0';
                            entrygrdjinvst  := '1';
                        end if;

                    when ST_CALC_GRADJINV =>
                        -- Set State Counter
                        state_counter           <= 9;

                        if entrygrdjinvst then
                            isIFFT            <= '1';
                            exit_grdjinvst    := '0';
                            entrygrdjinvst    := '0';
                            ltchhlfpntd       := '0';
                            strtwr_GJInv      <= '1';
                            ltchdonegjinv     := '0';
                            ltchphsstate      := '0';
                        end if;

                        if not ltchphsstate and phase_out_pipe(7) then
                            ltchphsstate        := '1';
                            strtrd_GRDJ         <= '1';
                        end if;

                        if valid_out and not ltchrisingvo then
                            ltchrisingvo        := '1';
                        end if;

                        if not ltchhlfpntd and hpdpipe(0) then
                            ltchhlfpntd        := '1';
                        end if;

                        if not valid_out and not ltchfallingvo and ltchrisingvo then 
                            ltchfallingvo       := '1';
                        end if;
                        
                        if donew_xGJInv then
                            ltchdonegjinv       := '1';
                        end if;

                        if ltchdonegjinv and ltchfallingvo then
                            exit_grdjinvst      := '1';
                        end if;

                        if exit_grdjinvst then
                            current_state       <= ST_CALC_GRADJCONST;
                            entrygrdjcnstst     := '1';
                            ltchrisingvo        := '0';
                            ltchfallingvo       := '0';

                            exit_grdjinvst      := '0';
                        end if;
                    when ST_CALC_GRADJCONST => -- TestBench Result: PASS
                        -- Set State Counter
                        state_counter           <= 10;
                        isIFFT                  <= '0';
                        if entrygrdjcnstst and phase_out_pipe(7) then
                            ltchdonegjcstwr := '0';
                            exit_grdjcnstst := '0';
                            strtrd_GJInv    <= '1';
                            strtwr_GRDJC    <= '1';
                            entrygrdjcnstst := '0';
                        end if;

                        if done_x_GJInv then -- Fix these 1cc signal delays later. Fixed
                            intfftzpvin     <= '1';
                        end if;

                        if valid_out and not ltchrisingvo then
                            ltchrisingvo    := '1';
                        end if;

                        if ltchrisingvo or phase_out_pipe(10) then 
                            intfftzpvin     <= '0';
                        end if;

                        if not valid_out and not ltchfallingvo and ltchrisingvo then 
                            ltchfallingvo   := '1';
                        end if;

                        if donew_xGRDJC then
                            ltchdonegjcstwr := '1';
                        end if;

                        if ltchdonegjcstwr and ltchfallingvo then
                            exit_grdjcnstst      := '1';
                        end if;

                        if exit_grdjcnstst then 
                            current_state    <= ST_CALC_UPDATE_WFFT;
                            ltchrisingvo     := '0';
                            ltchfallingvo    := '0';
                            entryupdtewst    := '1';
                            
                            exit_grdjcnstst  := '0';
                        end if;

                    when ST_CALC_UPDATE_WFFT =>
                        -- Set State Counter
                        state_counter           <= 11;

                        if entryupdtewst then
                            strtrd_WFFT           <= '1';
                            strtrd_GRDJC          <= '1';
                            ltchdonewghtwr        := '0';

                            entryupdtewst         := '0';
                        end if;

                        if not ltchvorrmw and RMW_EN_xIN then 
                            ltchvorrmw            := '1';
                            trgrvorrmw            := '1';
                        end if;

                        if trgrvorrmw then
                            strtwr_WFFT           <= '1';
                            trgrvorrmw            := '0';  
                        end if;                        

                        if not RMW_EN_xIN and not ltchvofrmw and ltchvorrmw then
                            ltchvofrmw            := '1';
                        end if;
                        
                        if donew_xWFFT then
                            ltchdonewghtwr         := '1';
                        end if;

                        if ltchdonewghtwr and ltchvofrmw then
                            exit_updtewst            := '1';
                        end if;

                        if exit_updtewst then
                            current_state         <= ST_IDLE;
                            ltchvorcmc            := '0';
                            ltchvofrmw            := '0';
                            ltchvorrmw            := '0';
                            ltchdonewghtwr        := '0';

                            --exit_updtewst            := '0';
                            -- reset exit at the idle so we can reload the algorithm
                        end if; 
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;
end Behavioral;
