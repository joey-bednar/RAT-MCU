library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;


entity clk_div2_buf is
    Port ( CLK : in STD_LOGIC;
           CLK_2 : out STD_LOGIC);
end clk_div2_buf;

architecture Behavioral of clk_div2_buf is
   signal s_clk : std_logic := '0';
begin
 
   --  divide by 2 process
   clk_divider: process (CLK)
   begin
      if (rising_edge(CLK)) then 
         s_clk <= not s_clk; 
      end if; 
   end process; 

  
   CLK_2 <= s_clk;   
   
--   -- buffer instantiation
--   BUFG_inst : BUFG
--   port map (
--      O => CLK_2, 
--      I => s_clk
--   );

end Behavioral;

					
