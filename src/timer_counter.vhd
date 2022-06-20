----------------------------------------------------------------------------------
-- Description: This file implements a timer counter module. The input is any 
--    clock signal. The output is a 2-clock cycle wide pulse (using the system 
--    clock. The timer has a pre-scaler divides the clock from 0 to 15 before 
--    being used a as a clock for teh 24 bit timer-counter register. This timer
--    is implemented as an upcounter. The 24-bit value starts at zero, counts
--    to value set in TCNT2 & TCNT1 TCNT0 and then generates pulse which can 
--    be used to trigger an interrupt.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity timer_counter is
    Port ( CLK : in  STD_LOGIC;
           TCCR  : in  STD_LOGIC_VECTOR (7 downto 0);
           TCNT0 : in  STD_LOGIC_VECTOR (7 downto 0);
           TCNT1 : in  STD_LOGIC_VECTOR (7 downto 0);
           TCNT2 : in  STD_LOGIC_VECTOR (7 downto 0);
           TC_INT : out  STD_LOGIC);
end timer_counter;

architecture Behavioral of timer_counter is

   type state_type is (ST_off_1, ST_on_1, ST_on_2, ST_off_2);
   signal PS,NS : state_type;

   signal r_ps_count : std_logic_vector(3 downto 0); 
	signal r_counter24b : std_logic_vector(23 downto 0); 
   
	signal s_tc_terminal_count : std_logic_vector(23 downto 0); 
    
	signal s_clk_div : std_logic; 
   signal s_int_0 : std_logic; 
   signal s_int_1 : std_logic; 
   signal s_clk_scaled : std_logic; 
   signal s_pulse : std_logic; 
   
   alias s_prescale_val : std_logic_vector(3 downto 0) is TCCR(3 downto 0); 
   alias s_tc_enable : std_logic is TCCR(7); 

   
begin
   
   -- stitch signals together
   s_tc_terminal_count <= TCNT2 & TCNT1 & TCNT0; 
   
	-- here is the prescaler clock divider ----------
	scale: process(CLK,s_prescale_val,r_ps_count)
   begin
	   if (rising_edge(CLK)) then 
		   if (r_ps_count = s_prescale_val) then 
            s_clk_div <= '1';
				r_ps_count <= (others => '0'); 
			else 
			   s_clk_div <= '0'; 
			   r_ps_count <= r_ps_count + 1; 
         end if; 
      end if; 
   end process; 

   -- select clock source ---------------------------
   clk_sel: process(s_prescale_val,clk,s_clk_div)
   begin
      if (s_prescale_val = "0000") then 
	      s_clk_scaled <= clk; 
      else
	      s_clk_scaled <= s_clk_div; 
      end if; 
   end process;

	-- here is the 24-bit counter driven from prescaled clock
	cnt24b: process(s_clk_scaled,s_tc_enable)
   begin
      -- clock is reset when TC is turned off
	   if (s_tc_enable = '0') then 
		   r_counter24b <= (others => '0'); 
		else
	      if (rising_edge(s_clk_scaled)) then 
            if (r_counter24b = s_tc_terminal_count) then  
               s_pulse <= '1'; 
               r_counter24b <= (others => '0');
            else
               r_counter24b <= r_counter24b + 1; 
               s_pulse <= '0'; 
            end if; 
         end if; 
      end if; 
   end process; 
   
	-- FSM To shape one-shot of two system-clock cycle wide	length
   sync_p: process (CLK, NS)
	begin
		if (rising_edge(CLK)) then 
	      PS <= NS;
		end if;
	end process sync_p;

   comb_p: process (s_pulse, PS)
   begin
      case PS is
         when ST_off_1 => 
            TC_INT <= '0'; 
            if (s_pulse = '1') then 
               NS <= ST_on_1; 
            else 
               NS <= ST_off_1; 
            end if; 
          
         when ST_on_1 => 
            NS <= ST_on_2; 
            TC_INT <= '1'; 
   
         when ST_on_2 => 
            NS <= ST_off_2; 
            TC_INT <= '1'; 
   
         when ST_off_2 => 
            TC_INT <= '0'; 
            if (s_pulse = '1') then 
               NS <= ST_off_2; 
            else    
               NS <= ST_off_1; 
            end if; 
            
         when others => 
            NS <= ST_off_1; TC_INT <= '0'; 
            
         end case; 
   end process;     
end; 
	 


--
--
--architecture Behavioral of timer_counter is
--
--   signal r_ps_count : std_logic_vector(3 downto 0); 
--	signal r_counter24b : std_logic_vector(23 downto 0); 
--	signal tc_terminal_count_s : std_logic_vector(23 downto 0); 
--    
--	signal s_clk_div : std_logic; 
--   signal s_int_0 : std_logic; 
--   signal s_int_1 : std_logic; 
--   signal s_clk_scaled : std_logic; 
--   
--   alias s_prescale_val : std_logic_vector(3 downto 0) is TCCR(3 downto 0); 
--   alias s_tc_enable : std_logic is TCCR(7); 
--
--   
--begin
--   
--   tc_terminal_count_s <= TCNT2 & TCNT1 & TCNT0; 
--   
--	-- here is the prescaler clock divider ----------
--	scale: process(CLK,s_prescale_val,r_ps_count)
--   begin
--	   if (rising_edge(CLK)) then 
--		   if (r_ps_count = s_prescale_val) then 
--            s_clk_div <= '1';
--				r_ps_count <= (others => '0'); 
--			else 
--			   s_clk_div <= '0'; 
--			   r_ps_count <= r_ps_count + 1; 
--         end if; 
--      end if; 
--   end process; 
--
--   -- select clock source ---------------------------
--   clk_sel: process(s_prescale_val,clk,s_clk_div)
--   begin
--      if (s_prescale_val = "0000") then 
--	      s_clk_scaled <= clk; 
--      else
--	      s_clk_scaled <= s_clk_div; 
--      end if; 
--   end process;
--
--	-- here is the 24-bit counter driven from prescaled clock
--	cnt24b: process(s_clk_scaled,s_tc_enable)
--   begin
--      -- clock is reset when TC is turned off
--	   if (s_tc_enable = '0') then 
--		   r_counter24b <= (others => '0'); 
--         s_int_0 <= '0'; 
--		else
--	      if (rising_edge(s_clk_scaled)) then 
--            if (r_counter24b = tc_terminal_count_s) then  
--               s_int_0 <= '1'; 
--               r_counter24b <= (others => '0');
--            else
--               r_counter24b <= r_counter24b + 1; 
--               s_int_1 <= s_int_0; 
--               s_int_0 <= '0'; 
--            end if; 
--         end if; 
--      end if; 
--   end process; 
--   
--   process 
--   -- synthesize a 2 period (scaled clock) pulse
--   TC_INT <= s_int_1 OR s_int_0; 
--   
--end; 
	 

