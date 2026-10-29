library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.fft_types.all;
use work.multiplyAdd;

-- Modified from fpga-fft complex_multiply2.vhd (owocomm-0, CC BY-NC-SA 2.0)

-- delay is 5 cycles
-- rounding is always enabled regardless of "round" parameter
entity complexMultiplyCMC is
	generic(in1Bits,in2Bits,outBits: integer := 24;
			rndngbitfrtp: integer := 22;
			rndngbitfrtp_pwr: INTEGER := 19;
			round: boolean := true);
	port(clk: in std_logic;
			in1,in2: in complex;
			actv_pwr: in std_logic;
			actv_grdj: in std_logic := '0';
			grdj_shift: in integer range 0 to 23 := 0;
			out1: out complex
			);
end entity;
architecture a of complexMultiplyCMC is
	constant internalBits: integer := in1Bits + in2Bits;
	signal halfLSB: signed(internalBits-1 downto 0) := (others => '0') ; 
	--signal halfLSB1: signed(internalBits-1 downto 0);
	signal a,b,a1,b1: signed(in1Bits-1 downto 0);
	signal c,d,c1,d1: signed(in2Bits-1 downto 0);
	
	signal ac,bd,ad,bc: signed(internalBits-1 downto 0);
	signal res_re, res_im: signed(outBits-1 downto 0);

	type shiftPipe_t is array (0 to 3) of integer range 0 to 23;
	signal grdj_shift_pipe: shiftPipe_t := (others => 0);
	constant keepHigh: integer := internalBits - rndngbitfrtp - 1;
	constant keepLow: integer := internalBits - outBits - rndngbitfrtp;
	constant pwrShift: integer := rndngbitfrtp - rndngbitfrtp_pwr;
begin
	a <= complex_re(in1, in1Bits);-- when rising_edge(clk);
	b <= complex_im(in1, in1Bits);-- when rising_edge(clk);
	c <= complex_re(in2, in2Bits);-- when rising_edge(clk);
	d <= complex_im(in2, in2Bits);-- when rising_edge(clk);
	a1 <= a when rising_edge(clk);
	b1 <= b when rising_edge(clk);
	c1 <= c when rising_edge(clk);
	d1 <= d when rising_edge(clk);
	
	
	--halfLSB <= (halfLSB'left downto 1=>'0') & "1";
	--halfLSB1 <= resize(halfLSB,internalBits);
	--halfLSB1 <= (others => '0');
	mAdd1: entity multiplyAdd
		generic map(in1Bits=>in1Bits, in2Bits=>in2Bits, outBits=>internalBits)
		port map(clk, a, c, halfLSB, ac);
	mAdd2: entity multiplyAdd
		generic map(in1Bits=>in1Bits, in2Bits=>in2Bits, outBits=>internalBits)
		port map(clk, a, d, halfLSB, ad);
	
	mAdd3: entity multiplyAdd
		generic map(in1Bits=>in1Bits, in2Bits=>in2Bits, outBits=>internalBits, subtract=>true)
		port map(clk, b1, d1, ac, bd);
	mAdd4: entity multiplyAdd
		generic map(in1Bits=>in1Bits, in2Bits=>in2Bits, outBits=>internalBits, subtract=>false)
		port map(clk, b1, c1, ad, bc);
	
	process (clk)
	begin
		if rising_edge(clk) then
			grdj_shift_pipe(0) <= grdj_shift;
			grdj_shift_pipe(1 to 3) <= grdj_shift_pipe(0 to 2);
		end if;
	end process;

	process (clk)
	variable v_shift         : integer range 0 to 23;
	variable v_is_max_pos_re : std_logic;
	variable v_is_max_pos_im : std_logic;
	variable v_round_bit_re  : std_logic;
	variable v_round_bit_im  : std_logic;
	variable v_bd, v_bc      : signed(internalBits-1 downto 0);
	variable v_lowmask       : signed(internalBits-1 downto 0);
	begin
		if rising_edge(clk) then
			if actv_grdj = '1' then
			    v_shift := grdj_shift_pipe(3);
			elsif actv_pwr = '1' then
			    v_shift := pwrShift;
			else
			    v_shift := 0;
			end if;
			v_lowmask := not shift_left(to_signed(-1, internalBits), v_shift);
			v_bd := shift_right(bd, v_shift);
			v_bc := shift_right(bc, v_shift);
			if (bd and v_lowmask) /= 0 then
			    v_bd(0) := '1';
			end if;
			if (bc and v_lowmask) /= 0 then
			    v_bc(0) := '1';
			end if;
			if (v_bd(keepHigh) = '0') and ((AND v_bd(keepHigh - 1 downto keepLow)) = '1') then
			    v_is_max_pos_re := '1';
			else
			    v_is_max_pos_re := '0';
			end if;

			case STD_LOGIC_VECTOR'(v_bd(keepLow - 1) & (OR v_bd(keepLow - 2 downto 0))) is
			    when "00" | "01" =>
			        v_round_bit_re := '0';
			    when "11" =>
			        v_round_bit_re := '1';
			    when "10" =>
			        v_round_bit_re := v_bd(keepLow);
			    when others =>
			        v_round_bit_re := '0';
			end case;

			if v_is_max_pos_re = '1' then
			    v_round_bit_re := '0';
			end if;

			if (actv_grdj = '1') and ((OR v_bd(internalBits-1 downto keepHigh)) = '1') and ((AND v_bd(internalBits-1 downto keepHigh)) = '0') then
			    if v_bd(internalBits-1) = '1' then
			        res_re <= (res_re'high => '1', others => '0');
			    else
			        res_re <= (res_re'high => '0', others => '1');
			    end if;
			elsif v_round_bit_re = '1' then
			    res_re <= v_bd(keepHigh downto keepLow) + 1;
			else
			    res_re <= v_bd(keepHigh downto keepLow);
			end if;

			if (v_bc(keepHigh) = '0') and ((AND v_bc(keepHigh - 1 downto keepLow)) = '1') then
			    v_is_max_pos_im := '1';
			else
			    v_is_max_pos_im := '0';
			end if;

			case STD_LOGIC_VECTOR'(v_bc(keepLow - 1) & (OR v_bc(keepLow - 2 downto 0))) is
			    when "00" | "01" =>
			        v_round_bit_im := '0';
			    when "11" =>
			        v_round_bit_im := '1';
			    when "10" =>
			        v_round_bit_im := v_bc(keepLow);
			    when others =>
			        v_round_bit_im := '0';
			end case;

			if v_is_max_pos_im = '1' then
			    v_round_bit_im := '0';
			end if;

			if (actv_grdj = '1') and ((OR v_bc(internalBits-1 downto keepHigh)) = '1') and ((AND v_bc(internalBits-1 downto keepHigh)) = '0') then
			    if v_bc(internalBits-1) = '1' then
			        res_im <= (res_im'high => '1', others => '0');
			    else
			        res_im <= (res_im'high => '0', others => '1');
			    end if;
			elsif v_round_bit_im = '1' then
			    res_im <= v_bc(keepHigh downto keepLow) + 1;
			else
			    res_im <= v_bc(keepHigh downto keepLow);
			end if;
		end if;
	end process;
	

	--res_re <= bd(outBits downto 1) when rising_edge(clk);--res_re <= bd(bd'left-2 downto bd'left-outBits-1) when rising_edge(clk);
	--res_im <= bc(outBits downto 1) when rising_edge(clk);--res_im <= bc(bc'left-2 downto bc'left-outBits-1) when rising_edge(clk);
	
	out1 <= to_complex(res_re, res_im); -- when rising_edge(clk);
end a;
