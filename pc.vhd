----------------------------------------------------------------------------------
--Chris L, Joey B

--Program Counter
-- Our Program counter, controls all of the instruction processes.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PC is
    Port ( FROM_IMMED : in STD_LOGIC_VECTOR (9 downto 0);
           FROM_STACK : in STD_LOGIC_VECTOR (9 downto 0);
           PC_MUX_SEL : in STD_LOGIC_VECTOR (1 downto 0);
           PC_COUNT : out STD_LOGIC_VECTOR (9 downto 0);
           PC_LD : in STD_LOGIC;
           PC_INC : in STD_LOGIC;
           RST : in STD_LOGIC;
           CLK : in STD_LOGIC);
end PC;

architecture my_PC of PC is

component Counter is
    Port ( D_in : in STD_LOGIC_VECTOR (9 downto 0);
           PC_LD : in STD_LOGIC;
           PC_INC : in STD_LOGIC;
           RST : in STD_LOGIC;
           PC_COUNT : out STD_LOGIC_VECTOR (9 downto 0);
           CLK : in STD_LOGIC);
end component;

signal s_load_data : std_logic_vector(9 downto 0);

begin

C1: Counter
port map ( D_in => s_load_data,
           PC_LD => PC_LD,
           PC_INC => PC_INC,
           RST => RST,
           PC_COUNT => PC_COUNT,
           CLK => CLK);

        mux:process(FROM_IMMED, FROM_STACK, PC_MUX_SEL)
        begin
    
            if (PC_MUX_SEL = "00") then
                s_load_data <= FROM_IMMED;
            elsif (PC_MUX_SEL = "01") then
                s_load_data <= FROM_STACK;
            elsif (PC_MUX_SEL = "10") then
                s_load_data <= "1111111111";
            else
                s_load_data <= "0000000000";
            end if;
            
        end process;


end my_PC;
