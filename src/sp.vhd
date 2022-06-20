library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SP is
   port ( RST : in std_logic;
            CLK : in std_logic;
          SP_LD : in std_logic;
        SP_INCR : in std_logic;
        SP_DECR : in std_logic;
          DATA_IN : in std_logic_vector (7 downto 0); 
          DATA_OUT : out std_logic_vector (7 downto 0)); 
end SP; 

architecture my_stack of SP is 
   signal  t_cnt : std_logic_vector(7 downto 0); 
begin 
         
   process (CLK,RST,SP_LD,DATA_IN,SP_INCR,SP_DECR) 
   begin
      if(rising_edge(CLK)) then
        if(RST = '1') then
            t_cnt <= "00000000";
        elsif(SP_LD = '1') then
            t_cnt <= DATA_IN;
        elsif(SP_INCR = '1') then
            t_cnt <= t_cnt + 1;
        elsif(SP_DECR = '1') then
            t_cnt <= t_cnt - 1;
        end if;
     end if;
   end process;

   DATA_OUT <= t_cnt; 

end my_stack; 