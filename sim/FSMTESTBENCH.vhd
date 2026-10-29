----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/16/2026 12:56:08 AM
-- Design Name: 
-- Module Name: FSMTESTBENCH - Behavioral
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
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity tb_FiniteStateMachine is
    generic (
        MAX_FRAMES     : integer := 0;
        DUMP_LAST      : integer := 3;
        DPO_LOG_FRAMES : integer := 3
    );
end tb_FiniteStateMachine;

architecture Behavioral of tb_FiniteStateMachine is

    -- System
    signal clk            : std_logic := '0';
    signal rst            : std_logic := '0';
    
    -- I/O
    signal DDATAINVALID   : STD_LOGIC := '0';
    signal DDATAIN        : std_logic_vector(11 downto 0) := (others => '0');
    signal XDATAINVALID   : std_logic := '0';
    signal XDATAIN        : std_logic_vector(11 downto 0) := (others => '0');
    signal OUTDATA        : std_logic_vector(11 downto 0);
    signal OUTDATAVALID   : std_logic;
    signal Frame_ReadyI   : std_logic := '0';
    signal System_ReadyO  : std_logic;

    -- State
    signal DPOSTATECOUNTR : integer range 0 to 11;

    -- Debug Port Out signal decs
    signal GLOBALRAMDUMP : STD_LOGIC := '0';
    
    signal DPO_STRTRDWFFT, DPO_DONE_xWFFT, DPO_DONEW_WFFT, DPO_STRTWRWFFT, DPO_RMENB_WFFT : std_logic;
    signal DPO_STRTRDXFFT, DPO_DONE_xXFFT, DPO_DONEW_XFFT, DPO_STRTWRXFFT, DPO_RMENB_XFFT : std_logic;
    signal DPO_STRTRDXBUF, DPO_DONE_xXBUF, DPO_DONEW_XBUF, DPO_STRTWRXBUF, DPO_RMENB_XBUF : std_logic;
    signal DPO_STRTRDEFRM, DPO_DONE_xEFRM, DPO_DONEW_EFRM, DPO_STRTWREFRM, DPO_RMENB_EFRM : std_logic;
    signal DPO_STRTRDEFFT, DPO_DONE_xEFFT, DPO_DONEW_EFFT, DPO_STRTWREFFT, DPO_RMENB_EFFT : std_logic;
    signal DPO_STRTRDDDAT, DPO_DONE_xDDAT, DPO_DONEW_DDAT, DPO_STRTWRDDAT, DPO_RMENB_DDAT : std_logic;
    signal DPO_STRTRDGRDJ, DPO_DONE_xGRDJ, DPO_DONEW_GRDJ, DPO_STRTWRGRDJ, DPO_RMENB_GRDJ : std_logic;
    signal DPO_STRTRDGINV, DPO_DONE_xGINV, DPO_DONEW_GINV, DPO_STRTWRGINV, DPO_RMENB_GINV : std_logic;
    signal DPO_STRTRDGRJC, DPO_DONE_xGRJC, DPO_DONEW_GRJC, DPO_STRTWRGRJC, DPO_RMENB_GRJC : std_logic;
    signal DPO_STRTRDYCNV, DPO_DONE_xYCNV, DPO_DONEW_YCNV, DPO_STRTWRYCNV, DPO_RMENB_YCNV : std_logic;
    signal DPO_STRTRDYFFT, DPO_DONE_xYFFT, DPO_DONEW_YFFT, DPO_STRTWRYFFT, DPO_RMENB_YFFT : std_logic;
    signal DPO_STRTRDPOWR, DPO_DONE_xPOWR, DPO_DONEW_POWR, DPO_STRTWRPOWR, DPO_RMENB_POWR : std_logic;
    
    signal DPOSTINTERNAL0, DPOSTINTERNAL1, DPOSTINTERNAL2, DPOSTINTERNAL3 : STD_LOGIC;
    signal DPOSTINTERNAL4, DPOSTINTERNAL5, DPOSTINTERNAL6, DPOSTINTERNAL7 : STD_LOGIC;
    signal DPOSTINTERNAL8, DPOSTINTERNAL9, DPOSTINTERNALA, DPOSTINTERNALB : STD_LOGIC;
    signal DPOSTINTERNALC, DPOSTINTERNALD, DPOSTINTERNALE, DPOSTINTERNALF : STD_LOGIC;
    signal DPOSTLVPROBE00, DPOSTLVPROBE01, DPOSTLVPROBE10, DPOSTLVPROBE11 : UNSIGNED(23 DOWNTO 0);  

    signal DPO_FFTPOUTRIG, DPO_VINFFTMODL, DPO_VOTFFTMODL : std_logic;
    signal DPO_FFTPHSEOUT                                 : INTEGER range 0 to 1023;
    
    signal DPO_VOUTCMCMOD, DPO_VIN_CMCMOD                 : std_logic;
    signal DPO_RMW_EN_xIN, DPO_RMW_EN_OUT                 : std_logic;
    SIGNAL STOP_WFFTUPDT                                  : STD_LOGIC := '0';

    signal frame_nr       : integer := 0;
    signal n_frames_tb    : integer := 0;
    signal first_dump_tb  : integer := 0;
    signal out_count      : integer := 0;

    -- Clock period constant
    constant clk_period : time := 20 ns; 

    -- File for dumping DPOs
    file log_file : text open write_mode is "dpo_dump.txt";

begin

    uut: entity work.FiniteStateMachine
        port map (
            clk             => clk,
            rst             => rst,
            DDATAINVALID    => DDATAINVALID,
            DDATAIN         => DDATAIN,
            XDATAINVALID    => XDATAINVALID,
            XDATAIN         => XDATAIN,
            OUTDATA         => OUTDATA,
            OUTDATAVALID    => OUTDATAVALID,
            Frame_ReadyI    => Frame_ReadyI,
            System_ReadyO   => System_ReadyO,
            GLOBALRAMDUMP   => GLOBALRAMDUMP,

            DPO_STRTRDWFFT  => DPO_STRTRDWFFT, DPO_DONE_xWFFT => DPO_DONE_xWFFT, DPO_DONEW_WFFT => DPO_DONEW_WFFT, DPO_STRTWRWFFT => DPO_STRTWRWFFT, DPO_RMENB_WFFT => DPO_RMENB_WFFT,
            DPO_STRTRDXFFT  => DPO_STRTRDXFFT, DPO_DONE_xXFFT => DPO_DONE_xXFFT, DPO_DONEW_XFFT => DPO_DONEW_XFFT, DPO_STRTWRXFFT => DPO_STRTWRXFFT, DPO_RMENB_XFFT => DPO_RMENB_XFFT,
            DPO_STRTRDXBUF  => DPO_STRTRDXBUF, DPO_DONE_xXBUF => DPO_DONE_xXBUF, DPO_DONEW_XBUF => DPO_DONEW_XBUF, DPO_STRTWRXBUF => DPO_STRTWRXBUF, DPO_RMENB_XBUF => DPO_RMENB_XBUF,
            DPO_STRTRDEFRM  => DPO_STRTRDEFRM, DPO_DONE_xEFRM => DPO_DONE_xEFRM, DPO_DONEW_EFRM => DPO_DONEW_EFRM, DPO_STRTWREFRM => DPO_STRTWREFRM, DPO_RMENB_EFRM => DPO_RMENB_EFRM,
            DPO_STRTRDEFFT  => DPO_STRTRDEFFT, DPO_DONE_xEFFT => DPO_DONE_xEFFT, DPO_DONEW_EFFT => DPO_DONEW_EFFT, DPO_STRTWREFFT => DPO_STRTWREFFT, DPO_RMENB_EFFT => DPO_RMENB_EFFT,
            DPO_STRTRDDDAT  => DPO_STRTRDDDAT, DPO_DONE_xDDAT => DPO_DONE_xDDAT, DPO_DONEW_DDAT => DPO_DONEW_DDAT, DPO_STRTWRDDAT => DPO_STRTWRDDAT, DPO_RMENB_DDAT => DPO_RMENB_DDAT,
            DPO_STRTRDGRDJ  => DPO_STRTRDGRDJ, DPO_DONE_xGRDJ => DPO_DONE_xGRDJ, DPO_DONEW_GRDJ => DPO_DONEW_GRDJ, DPO_STRTWRGRDJ => DPO_STRTWRGRDJ, DPO_RMENB_GRDJ => DPO_RMENB_GRDJ,
            DPO_STRTRDGINV  => DPO_STRTRDGINV, DPO_DONE_xGINV => DPO_DONE_xGINV, DPO_DONEW_GINV => DPO_DONEW_GINV, DPO_STRTWRGINV => DPO_STRTWRGINV, DPO_RMENB_GINV => DPO_RMENB_GINV,
            DPO_STRTRDGRJC  => DPO_STRTRDGRJC, DPO_DONE_xGRJC => DPO_DONE_xGRJC, DPO_DONEW_GRJC => DPO_DONEW_GRJC, DPO_STRTWRGRJC => DPO_STRTWRGRJC, DPO_RMENB_GRJC => DPO_RMENB_GRJC,
            DPO_STRTRDYCNV  => DPO_STRTRDYCNV, DPO_DONE_xYCNV => DPO_DONE_xYCNV, DPO_DONEW_YCNV => DPO_DONEW_YCNV, DPO_STRTWRYCNV => DPO_STRTWRYCNV, DPO_RMENB_YCNV => DPO_RMENB_YCNV,
            DPO_STRTRDYFFT  => DPO_STRTRDYFFT, DPO_DONE_xYFFT => DPO_DONE_xYFFT, DPO_DONEW_YFFT => DPO_DONEW_YFFT, DPO_STRTWRYFFT => DPO_STRTWRYFFT, DPO_RMENB_YFFT => DPO_RMENB_YFFT,
            DPO_STRTRDPOWR  => DPO_STRTRDPOWR, DPO_DONE_xPOWR => DPO_DONE_xPOWR, DPO_DONEW_POWR => DPO_DONEW_POWR, DPO_STRTWRPOWR => DPO_STRTWRPOWR, DPO_RMENB_POWR => DPO_RMENB_POWR,

            -- Module Triggers
            DPO_FFTPOUTRIG  => DPO_FFTPOUTRIG,
            DPO_FFTPHSEOUT  => DPO_FFTPHSEOUT,
            DPO_VINFFTMODL  => DPO_VINFFTMODL,
            DPO_VOTFFTMODL  => DPO_VOTFFTMODL,
            DPO_VOUTCMCMOD  => DPO_VOUTCMCMOD,
            DPO_VIN_CMCMOD  => DPO_VIN_CMCMOD,

            -- Internal States / Misc
            DPOSTINTERNAL0  => DPOSTINTERNAL0, DPOSTINTERNAL1  => DPOSTINTERNAL1, DPOSTINTERNAL2  => DPOSTINTERNAL2, DPOSTINTERNAL3  => DPOSTINTERNAL3,
            DPOSTINTERNAL4  => DPOSTINTERNAL4, DPOSTINTERNAL5  => DPOSTINTERNAL5, DPOSTINTERNAL6  => DPOSTINTERNAL6, DPOSTINTERNAL7  => DPOSTINTERNAL7,
            DPOSTINTERNAL8  => DPOSTINTERNAL8, DPOSTINTERNAL9  => DPOSTINTERNAL9, DPOSTINTERNALA  => DPOSTINTERNALA, DPOSTINTERNALB  => DPOSTINTERNALB,
            DPOSTINTERNALC  => DPOSTINTERNALC, DPOSTINTERNALD  => DPOSTINTERNALD, DPOSTINTERNALE  => DPOSTINTERNALE, DPOSTINTERNALF  => DPOSTINTERNALF,
            DPOSTLVPROBE00  => DPOSTLVPROBE00, DPOSTLVPROBE01  => DPOSTLVPROBE01, DPOSTLVPROBE10  => DPOSTLVPROBE10, DPOSTLVPROBE11  => DPOSTLVPROBE11, 
            
            DPO_RMW_EN_xIN  => DPO_RMW_EN_xIN,
            DPO_RMW_EN_OUT  => DPO_RMW_EN_OUT,

            -- State Counter
            DPOSTATECOUNTR  => DPOSTATECOUNTR,

            STOP_WFFTUPDT   => STOP_WFFTUPDT
        );

    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
        file input_file : text open read_mode is "vhdl_stimulus.txt";
        file count_file : text;
        variable in_line    : line;
        variable dummy_data : std_logic_vector(11 downto 0);
        variable x_data_var : std_logic_vector(11 downto 0);
        variable d_data_var : std_logic_vector(11 downto 0);
        variable n_lines    : integer := 0;
        variable n_frames   : integer;
        variable first_dump : integer;
    begin
        file_open(count_file, "vhdl_stimulus.txt", read_mode);
        while not endfile(count_file) loop
            readline(count_file, in_line);
            n_lines := n_lines + 1;
        end loop;
        file_close(count_file);
        n_frames := n_lines / 512;
        if (MAX_FRAMES > 0) and (MAX_FRAMES < n_frames) then
            n_frames := MAX_FRAMES;
        end if;
        first_dump := n_frames - DUMP_LAST + 1;
        if first_dump < 1 then
            first_dump := 1;
        end if;
        n_frames_tb   <= n_frames;
        first_dump_tb <= first_dump;
        report "STIMULUS: " & integer'image(n_lines) & " samples, running " & integer'image(n_frames)
             & " frames. RAM dumps _F1.._F" & integer'image(n_frames - first_dump + 1)
             & " = frames " & integer'image(first_dump) & ".." & integer'image(n_frames);

        -- Hold Reset
        rst <= '1';
        Frame_ReadyI <= '0';
        wait for clk_period * 5;
        rst <= '0';

        for cycle in 1 to n_frames loop
            frame_nr <= cycle;

            wait until rising_edge(clk) and System_ReadyO = '1';
            wait for clk_period * 2; 

            -- Specifically to test the Filter state
            --if cycle = 3 then
            --    STOP_WFFTUPDT <= '1';
            --end if;

            Frame_ReadyI <= '1';
            wait for clk_period;
            Frame_ReadyI <= '0';
            wait for clk_period;

            for i in 0 to 511 loop
                if not endfile(input_file) then
                    readline(input_file, in_line);

                    read(in_line, dummy_data); -- Column 1 (Discarded)
                    read(in_line, dummy_data); -- Column 2 (Discarded)
                    read(in_line, d_data_var); -- Column 3 (DDATA - Mic)
                    read(in_line, x_data_var); -- Column 4 (XDATA - Speaker)

                    XDATAINVALID <= '1';
                    DDATAINVALID <= '1';
                    XDATAIN <= x_data_var;
                    DDATAIN <= d_data_var;
                else
                    XDATAINVALID <= '0';
                    DDATAINVALID <= '0';
                    XDATAIN <= (others => '0');
                    DDATAIN <= (others => '0');
                end if;
                
                wait for clk_period;
            end loop;

            XDATAINVALID <= '0';
            DDATAINVALID <= '0';
            XDATAIN      <= (others => '0');
            DDATAIN      <= (others => '0');
            

            -- Specifically to test the Filter state
            --WAIT UNTIL RISING_EDGE(CLK) AND DPOSTATECOUNTR = 11;
            -- -- TAKE THE SNAPSHOT!
            --GLOBALRAMDUMP <= '1';
            --wait for clk_period;
            --GLOBALRAMDUMP <= '0';

            wait until rising_edge(clk) and System_ReadyO = '1';
            
            wait for clk_period * 5; 

            if cycle >= first_dump then
                GLOBALRAMDUMP <= '1';
                wait for clk_period;
                GLOBALRAMDUMP <= '0';
            end if;

        end loop;

        wait for clk_period * 10;
        assert out_count = 512 * n_frames
            report "OUTDUMP: expected " & integer'image(512 * n_frames) & " samples, got " & integer'image(out_count) severity error;
        report "TESTBENCH COMPLETE: " & integer'image(n_frames) & " Frames Processed, "
             & integer'image(out_count) & " output samples in DFContainer/OUTDUMP.txt" severity failure;
        wait;
    end process;

    logger_proc: process(clk)
        variable row_line : line;
        variable header_printed : boolean := false;

        variable x_int, d_int, out_int : integer;
        variable p00_int, p01_int, p10_int, p11_int : integer;
    begin
        if rising_edge(clk) then
            if not header_printed then
                write(row_line, string'("TIME(ns), STATE, SYSRDY, FRMRDY, [DATA: X, D, OUT], [WFFT: Rd,Dn,Dnw,Wr], [PROBES: 00, 01, 10, 11], ..."));
                writeline(log_file, row_line);
                header_printed := true;
            end if;

            if (rst = '0') and (frame_nr <= DPO_LOG_FRAMES) then
                write(row_line, now); write(row_line, string'(", "));
                write(row_line, DPOSTATECOUNTR); write(row_line, string'(", "));
                write(row_line, System_ReadyO); write(row_line, Frame_ReadyI); write(row_line, string'(", "));

                x_int   := to_integer(signed(XDATAIN));
                d_int   := to_integer(signed(DDATAIN));

                p00_int := to_integer(signed(std_logic_vector(DPOSTLVPROBE00)));
                p01_int := to_integer(signed(std_logic_vector(DPOSTLVPROBE01)));
                p10_int := to_integer(signed(std_logic_vector(DPOSTLVPROBE10)));
                p11_int := to_integer(signed(std_logic_vector(DPOSTLVPROBE11)));

                if OUTDATA(0) = 'U' then
                    out_int := 0;
                else
                    out_int := to_integer(signed(OUTDATA));
                end if;

                write(row_line, x_int); write(row_line, string'(", "));
                write(row_line, d_int); write(row_line, string'(", "));
                write(row_line, out_int); write(row_line, string'(", "));

                -- Log WFFT
                write(row_line, DPO_STRTRDWFFT); write(row_line, DPO_DONE_xWFFT); 
                write(row_line, DPO_DONEW_WFFT); write(row_line, DPO_STRTWRWFFT); write(row_line, string'(", "));
                
                -- Log Probes
                write(row_line, p00_int); write(row_line, string'(", "));
                write(row_line, p01_int); write(row_line, string'(", "));
                write(row_line, p10_int); write(row_line, string'(", "));
                write(row_line, p11_int); write(row_line, string'(", "));

                -- Log XFFT
                write(row_line, DPO_STRTRDXFFT); write(row_line, DPO_DONE_xXFFT); 
                write(row_line, DPO_DONEW_XFFT); write(row_line, DPO_STRTWRXFFT); write(row_line, string'(", "));

                -- Log YFFT
                write(row_line, DPO_STRTRDYFFT); write(row_line, DPO_DONE_xYFFT); 
                write(row_line, DPO_DONEW_YFFT); write(row_line, DPO_STRTWRYFFT); write(row_line, string'(", "));
                
                -- Log XBUF
                write(row_line, DPO_STRTRDXBUF); write(row_line, DPO_DONE_xXBUF); 
                write(row_line, DPO_DONEW_XBUF); write(row_line, DPO_STRTWRXBUF); write(row_line, string'(", "));

                -- Log EFFT
                write(row_line, DPO_STRTRDEFFT); write(row_line, DPO_DONE_xEFFT); 
                write(row_line, DPO_DONEW_EFFT); write(row_line, DPO_STRTWREFFT); write(row_line, string'(", "));

                -- Log first 8 Test connections
                write(row_line, DPOSTINTERNAL0); write(row_line, DPOSTINTERNAL1); write(row_line, DPOSTINTERNAL2); 
                write(row_line, DPOSTINTERNAL3); write(row_line, DPOSTINTERNAL4); write(row_line, DPOSTINTERNAL5); 
                write(row_line, DPOSTINTERNAL6); write(row_line, DPOSTINTERNAL7); write(row_line, string'(", "));
                
                -- Log CMC & FFT Module Triggers
                write(row_line, DPO_FFTPOUTRIG); write(row_line, DPO_FFTPHSEOUT); write(row_line, DPO_VINFFTMODL); 
                write(row_line, DPO_VOTFFTMODL); write(row_line, DPO_VOUTCMCMOD); write(row_line, DPO_VIN_CMCMOD);
                write(row_line, DPO_RMW_EN_xIN); write(row_line, DPO_RMW_EN_OUT); 

                writeline(log_file, row_line);
            end if;
        end if;
    end process;

    out_dump_proc: process(clk)
        file out_file : text open write_mode is "DFContainer/OUTDUMP.txt";
        variable out_line    : line;
        variable header_done : boolean := false;
    begin
        if rising_edge(clk) then
            if OUTDATAVALID = '1' then
                if not header_done then
                    write(out_line, string'("# FDAF output e = d - y (OUTDATA, 12-bit signed), one sample per line, same row order as vhdl_stimulus.txt"));
                    writeline(out_file, out_line);
                    write(out_line, string'("# frames ") & integer'image(n_frames_tb) & string'(", RAM dumps _F1.._F")
                                  & integer'image(n_frames_tb - first_dump_tb + 1) & string'(" = frames ")
                                  & integer'image(first_dump_tb) & string'("..") & integer'image(n_frames_tb));
                    writeline(out_file, out_line);
                    header_done := true;
                end if;
                write(out_line, to_integer(signed(OUTDATA)));
                writeline(out_file, out_line);
                out_count <= out_count + 1;
            end if;
        end if;
    end process;

end Behavioral;