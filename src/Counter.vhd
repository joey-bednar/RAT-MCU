library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Counter is
    Port ( D_in : in STD_LOGIC_VECTOR (9 downto 0);
           PC_LD : in STD_LOGIC;
           PC_INC : in STD_LOGIC;
           RST : in STD_LOGIC;
           PC_COUNT : out STD_LOGIC_VECTOR (9 downto 0);
           CLK : in STD_LOGIC);
end Counter;

architecture Behavioral of Counter is

   signal  t_cnt : std_logic_vector(9 downto 0); 


begin

   process (CLK, RST, PC_LD, PC_INC, t_cnt) 
   begin
      if (RST = '1') then    
         t_cnt <= (others => '0'); -- async clear
      elsif (rising_edge(CLK)) then
         if (PC_LD = '1') then     t_cnt <= D_in;  -- load
         else 
            if (PC_INC = '1') then  t_cnt <= t_cnt + 1; -- incr
            else                --t_cnt <= t_cnt - 1; -- decr
            end if;
         end if;
      end if;
   end process;

   PC_COUNT <= t_cnt; 

end Behavioral;
