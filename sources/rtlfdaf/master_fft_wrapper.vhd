library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.fft_types.all; 

entity master_fft_wrapper is
    port (
        clk                 : in  std_logic;
        rst                 : in  std_logic;
        
        -- Inputs
        isIFFT              : in  std_logic;            -- Should Remain High/Low throughout the I/Process/O of FFT
        valid_in            : in  std_logic;
        data_inR            : in  std_logic_vector(23 downto 0);
        data_inI            : in  std_logic_vector(23 downto 0);
        -- Outputs
        valid_out           : out std_logic;
        fft_im_out          : out std_logic_vector(23 downto 0);
        fft_re_out          : out std_logic_vector(23 downto 0);
        phase_out_trigger   : out std_logic;             -- Will trigger when the phase is at a certain value
        halfpointdes        : out std_logic;
        hpdduct_tape        : out std_logic;

        -- Signal Declerations for Simulation and Debug:
        phase_out           : out unsigned(9 downto 0)
        --valid_acc_debug     : out UNSIGNED(10 downto 0);
        --data_inRDebug       : out STD_LOGIC_VECTOR(23 downto 0);
        --data_inIDebug       : out std_logic_vector(23 downto 0)
     );
end master_fft_wrapper;

architecture Behavioral of master_fft_wrapper is

    component fft1024_wrapper1 is
        generic(
            dataBits : integer := 24; 
            twBits   : integer := 12
        );
        port(
            clk   : in std_logic;
            din   : in complex;
            phase : in unsigned(9 downto 0);
            dout  : out complex
        );
    end component;

    signal core_din         : complex;
    signal core_dout        : complex;
    signal phase_cnt        : unsigned(9 downto 0) := (others => '0');
    --signal current_phase    : unsigned(9 downto 0);
    signal valid_delay_cnt  : unsigned(12-1 downto 0) := (others => '0');
    signal valid_acc        : unsigned(10 downto 0) := "00000000001"; -- Normally 9 downto 0
    signal process_on       : std_logic := '0';
    signal strtprocsw       : std_logic  := '0';
    
begin

    process(all)
    begin
        if isIFFT = '0' then
            core_din.re <= resize(signed(data_inR), 48);
            core_din.im <= RESIZE(signed(data_inI), 48);
            fft_re_out <= std_logic_vector(core_dout.re(23 downto 0));
            fft_im_out <= std_logic_vector(core_dout.im(23 downto 0));
        else
            core_din.re <= resize(signed(data_inI), 48);
            core_din.im <= RESIZE(signed(data_inR), 48);
            fft_re_out <= std_logic_vector(core_dout.im(23 downto 0));--shift_right(signed(core_dout.im(23 downto 0)), 10)); -- Div by N
            fft_im_out <= std_logic_vector(core_dout.re(23 downto 0));--shift_right(signed(core_dout.re(23 downto 0)), 10));                        
        end if;        
    end process;

    fft_inst : fft1024_wrapper1
        generic map (
            dataBits => 24, 
            twBits   => 12
        )
        port map (
            clk   => clk,
            din   => core_din,
            phase => phase_cnt,
            dout  => core_dout
        );

    -- Standart Outputs
    halfpointdes    <= '1' when (valid_acc = x"1F9") else '0'; -- Half Point Designator | If 1, half point of output not crossed
    hpdduct_tape    <= '1' when (valid_acc = x"1FF") else '0';
    phase_out_trigger <= '1' when (phase_cnt = 1012) else '0';
    -- Debug Outputs
    phase_out <= phase_cnt;
    --valid_acc_debug <= valid_acc;
    --data_inRDebug <= std_logic_vector(core_din.re(23 downto 0));
    --data_inIDebug <= std_logic_vector(core_din.im(23 downto 0));
    -- Debug Outputs End
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                phase_cnt       <= (others => '0');
                valid_delay_cnt <= (others => '0');
                valid_acc       <= (others => '0') ;
                valid_out       <= '0';
                process_on      <= '0';
                strtprocsw      <= '0';
            else
                phase_cnt <= phase_cnt + 1;
                if strtprocsw = '0' then
                    if phase_cnt = 990 then
                        strtprocsw <= '1';
                    end if;
                else    
                    if valid_in = '1' and process_on = '0' then
                        process_on <= '1';
                    end if;
                    
                    if valid_in = '1' then
                        if valid_acc /= "10000000000"then
                            if valid_delay_cnt /= 3237 then -- Regular value for this and line Tag A is 3238
                                --but to account for the delay effects of the process blocks these have been tuned
                                valid_acc <= valid_acc +1;
                            end if;
                        end if;
                    end if; 

                    if process_on = '1' then
                        if valid_delay_cnt /= 3237 then -- Tag A
                        valid_delay_cnt <= valid_delay_cnt +1;
                        else
                            if valid_acc /= "00000000000" then
                                valid_out <= '1';
                                valid_acc <= valid_acc -1;
                            else
                                valid_delay_cnt <= (others => '0');
                                valid_acc <= "00000000000";
                                valid_out <='0';
                                process_on <= '0';
                            end if;
                        end if; 
                    end if;
                end if;
            end if;
        end if;
    end process;
end Behavioral;