----------------------------------------------------------------------------------
-- Company:   CPE 233 Productions
-- Engineer:  Various Engineers
-- 
-- Create Date:    20:59:29 02/04/2013 
-- Design Name: 
-- Module Name:    RAT Control Unit
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:  Control unit (FSM) for RAT CPU
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Revision 4.02 - added SCR_DATA_SEL (11-04-2016)
-- Revision 4.03 - removed NS from comb_proc (11-15-2016)
-- Revision 4.04 - made reset synchronous (10-12-2017)
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


Entity CONTROL_UNIT is
    Port ( CLK           : in   STD_LOGIC;
           C             : in   STD_LOGIC;
           Z             : in   STD_LOGIC;
           INT           : in   STD_LOGIC;
           RESET         : in   STD_LOGIC;
           OPCODE_HI_5   : in   STD_LOGIC_VECTOR (4 downto 0);
           OPCODE_LO_2   : in   STD_LOGIC_VECTOR (1 downto 0);
              
           PC_LD         : out  STD_LOGIC;
           PC_INC        : out  STD_LOGIC;
           PC_MUX_SEL    : out  STD_LOGIC_VECTOR(1 downto 0); 		  

           SP_LD         : out  STD_LOGIC;
           SP_INCR       : out  STD_LOGIC;
           SP_DECR       : out  STD_LOGIC;
 
           RF_WR         : out  STD_LOGIC;
           RF_WR_SEL     : out  STD_LOGIC_VECTOR (1 downto 0);

           ALU_OPY_SEL   : out  STD_LOGIC;
           ALU_SEL       : out  STD_LOGIC_VECTOR (3 downto 0);

           SCR_WR        : out  STD_LOGIC;
           SCR_DATA_SEL  : out  STD_LOGIC; 
           SCR_ADDR_SEL  : out  STD_LOGIC_VECTOR (1 downto 0);

           FLG_C_LD      : out  STD_LOGIC;
           FLG_C_SET     : out  STD_LOGIC;
           FLG_C_CLR     : out  STD_LOGIC;
           FLG_SHAD_LD   : out  STD_LOGIC;
           FLG_LD_SEL    : out  STD_LOGIC;
           FLG_Z_LD      : out  STD_LOGIC;
              
           I_FLAG_SET    : out  STD_LOGIC;
           I_FLAG_CLR    : out  STD_LOGIC;

           RST           : out  STD_LOGIC;
           IO_STRB       : out  STD_LOGIC);
end;

architecture Behavioral of CONTROL_UNIT is

   type state_type is (ST_init, ST_fet, ST_exec, ST_int);
   signal PS,NS : state_type;
   
   signal sig_OPCODE_7: std_logic_vector (6 downto 0);

begin
   

   sig_OPCODE_7 <= OPCODE_HI_5 & OPCODE_LO_2;

   sync_p: process (CLK, NS, RESET)
   begin
      if (rising_edge(CLK)) then 
         if (RESET = '1') then
            PS <= ST_init;
         else
            PS <= NS;
         end if;
      end if; 
   end process sync_p;


   comb_p: process (sig_OPCODE_7, PS, C, Z)
   begin
   

      PC_LD      <= '0';   
      PC_MUX_SEL <= "00";   	    
      PC_INC     <= '0';		  			      				

      SP_LD   <= '0';   
      SP_INCR <= '0'; 
      SP_DECR <= '0'; 
 
      RF_WR     <= '0';   
      RF_WR_SEL <= "00";   
  
      ALU_OPY_SEL <= '0';  
      ALU_SEL     <= "0000";       			

      SCR_WR       <= '0';       
      SCR_DATA_SEL <= '0';       
      SCR_ADDR_SEL <= "00";  
      
      FLG_C_SET   <= '0';   
	  FLG_C_CLR   <= '0'; 
      FLG_C_LD    <= '0';   
      FLG_Z_LD    <= '0'; 
      FLG_LD_SEL  <= '0';   
      FLG_SHAD_LD <= '0';    

      I_FLAG_SET   <= '0';        
      I_FLAG_CLR   <= '0';    

      RST     <= '0';
      IO_STRB <= '0';       
            
   case PS is
      
    -- STATE: the init cycle ------------------------------------
	when ST_init => 
         RST <= '1'; 
	     NS <= ST_fet;
						 	
				
      -- STATE: the fetch cycle -----------------------------------
      when ST_fet => 
         NS <= ST_exec;
         PC_INC <= '1';
         
     -- STATE: the interrupt cycle ---------------------------------
      when ST_int => 
         NS <= ST_fet;
         
         PC_LD <= '1';
         PC_MUX_SEL <= "10";

         FLG_SHAD_LD <= '1';
       
         SP_DECR <= '1';
         SCR_ADDR_SEL <= "11";
         SCR_DATA_SEL <= '1';
         SCR_WR <= '1';
         
         I_FLAG_CLR <= '1';
            
            
      -- STATE: the execute cycle ---------------------------------
      when ST_exec =>
         if(INT = '1') then
            NS <= ST_int;
         else
            NS <= ST_fet;
         end if;
         
         PC_INC <= '0'; 
         
         		
	     case sig_OPCODE_7 is		
                
--REG-REG COMMANDS

		  -- AND reg-reg  --------
              when "0000000" =>
                RF_WR_SEL <= "00";
                RF_WR <= '1';
                ALU_OPY_SEL <= '0';
                ALU_SEL <= "0101";
                FLG_C_CLR <= '1';
                FLG_Z_LD <= '1';
                
		  -- OR reg-reg  --------
              when "0000001" =>
                RF_WR_SEL <= "00";
                RF_WR <= '1';
                ALU_OPY_SEL <= '0';
                ALU_SEL <= "0110";
                FLG_C_CLR <= '1';
                FLG_Z_LD <= '1';
                
		  -- EXOR reg-reg  --------
              when "0000010" =>
                RF_WR_SEL <= "00";
                RF_WR <= '1';
                ALU_OPY_SEL <= '0';
                ALU_SEL <= "0111";
                FLG_C_CLR <= '1';
                FLG_Z_LD <= '1';
                
		  -- TEST reg-reg  --------
              when "0000011" =>
                RF_WR_SEL <= "00";
                RF_WR <= '0';
                ALU_OPY_SEL <= '0';
                ALU_SEL <= "1000";
                FLG_C_CLR <= '1';
                FLG_Z_LD <= '1';                          
                
		  -- ADD reg-reg  --------
              when "0000100" =>
                RF_WR_SEL <= "00";
                RF_WR <= '1';
                ALU_OPY_SEL <= '0';
                ALU_SEL <= "0000";
                FLG_C_LD <= '1';
                FLG_Z_LD <= '1';
                                
		  -- ADDC reg-reg  --------
              when "0000101" =>
                RF_WR_SEL <= "00";
                RF_WR <= '1';
                ALU_OPY_SEL <= '0';
                ALU_SEL <= "0001";
                FLG_C_LD <= '1';
                FLG_Z_LD <= '1';
                            
		  -- SUB reg-reg  --------
              when "0000110" =>
                RF_WR_SEL <= "00";
                RF_WR <= '1';
                ALU_OPY_SEL <= '0';
                ALU_SEL <= "0010";
                FLG_C_LD <= '1';
                FLG_Z_LD <= '1';
                
		  -- SUBC reg-reg  --------
              when "0000111" =>
                RF_WR_SEL <= "00";
                RF_WR <= '1';
                ALU_OPY_SEL <= '0';
                ALU_SEL <= "0011";
                FLG_C_LD <= '1';
                FLG_Z_LD <= '1';
                
		  -- CMP reg-reg  --------
              when "0001000" =>
                RF_WR_SEL <= "00";
                RF_WR <= '0';
                ALU_OPY_SEL <= '0';
                ALU_SEL <= "0100";
                FLG_C_LD <= '1';
                FLG_Z_LD <= '1';
                
		  -- MOV reg-reg  --------
              when "0001001" =>
                RF_WR_SEL <= "00";
                RF_WR <= '1';
                ALU_OPY_SEL <= '0';
                ALU_SEL <= "1110";
                
		  -- LD reg-reg  --------
              when "0001010" =>
                RF_WR_SEL <= "01";
                RF_WR <= '1';
                SCR_ADDR_SEL <= "00";
          
		  -- ST reg-reg  --------
              when "0001011" =>
                SCR_DATA_SEL <= '0';
                SCR_ADDR_SEL <= "00";
                SCR_WR <= '1';
             
--REG-IMM COMMANDS

          -- AND reg-imm  --------
              when "1000000" | "1000001" | "1000010" | "1000011" =>
                RF_WR_SEL <= "00";
                RF_WR <= '1';
                ALU_OPY_SEL <= '1';
                ALU_SEL <= "0101";
                FLG_C_CLR <= '1';
                FLG_Z_LD <= '1';
                
          -- OR reg-imm  --------
              when "1000100" | "1000101" | "1000110" | "1000111" =>
                RF_WR_SEL <= "00";
                RF_WR <= '1';
                ALU_OPY_SEL <= '1';
                ALU_SEL <= "0110";
                FLG_C_CLR <= '1';
                FLG_Z_LD <= '1';
                
          -- EXOR reg-imm  --------
              when "1001000" | "1001001" | "1001010" | "1001011" =>
                RF_WR_SEL <= "00";
                RF_WR <= '1';
                ALU_OPY_SEL <= '1';
                ALU_SEL <= "0111";
                FLG_C_CLR <= '1';
                FLG_Z_LD <= '1';
                
          -- TEST reg-imm  --------
              when "1001100" | "1001101" | "1001110" | "1001111" =>
                RF_WR_SEL <= "00";
                RF_WR <= '0';
                ALU_OPY_SEL <= '1';
                ALU_SEL <= "1000";
                FLG_C_CLR <= '1';
                FLG_Z_LD <= '1';                          
                
          -- ADD reg-imm  --------
              when "1010000" | "1010001" | "1010010" | "1010011" =>
                RF_WR_SEL <= "00";
                RF_WR <= '1';
                ALU_OPY_SEL <= '1';
                ALU_SEL <= "0000";
                FLG_C_LD <= '1';
                FLG_Z_LD <= '1';
                                
          -- ADDC reg-imm  --------
              when "1010100" | "1010101" | "1010110" | "1010111" =>
                RF_WR_SEL <= "00";
                RF_WR <= '1';
                ALU_OPY_SEL <= '1';
                ALU_SEL <= "0001";
                FLG_C_LD <= '1';
                FLG_Z_LD <= '1';
                            
          -- SUB reg-imm  --------
              when "1011000" | "1011001" | "1011010" | "1011011" =>
                RF_WR_SEL <= "00";
                RF_WR <= '1';
                ALU_OPY_SEL <= '1';
                ALU_SEL <= "0010";
                FLG_C_LD <= '1';
                FLG_Z_LD <= '1';
                
          -- SUBC reg-imm  --------
              when "1011100" | "1011101" | "1011110" | "1011111" =>
                RF_WR_SEL <= "00";
                RF_WR <= '1';
                ALU_OPY_SEL <= '1';
                ALU_SEL <= "0011";
                FLG_C_LD <= '1';
                FLG_Z_LD <= '1';
                
          -- CMP reg-immed  --------
              when "1100000" | "1100001" | "1100010" | "1100011" =>
                RF_WR_SEL <= "00";
                RF_WR <= '0';
                ALU_OPY_SEL <= '1';
                ALU_SEL <= "0100";
                FLG_C_LD <= '1';
                FLG_Z_LD <= '1';
                
		  -- IN reg-immed  ------
              when "1100100" | "1100101" | "1100110" | "1100111" =>
                RF_WR_SEL <= "11";
                RF_WR <= '1';
      
          -- OUT reg-immed  ------
              when "1101000" | "1101001" | "1101010" | "1101011" =>
                IO_STRB <= '1';
                
		  -- MOV reg-immed  ------
              when "1101100" | "1101101" | "1101110" | "1101111" =>
                RF_WR_SEL <= "00";
                RF_WR <= '1';
                ALU_OPY_SEL <= '1';
                ALU_SEL <= "1110";
                
          -- LD reg-imm  --------
              when "1110000" | "1110001" | "1110010" | "1110011" =>
                RF_WR_SEL <= "01";
                RF_WR <= '1';
                SCR_ADDR_SEL <= "01";
          
          -- ST reg-imm  --------
              when "1110100" | "1110101" | "1110110" | "1110111" =>
                SCR_DATA_SEL <= '0';
                SCR_ADDR_SEL <= "01";
                SCR_WR <= '1'; 
                
--IMMEDIATE COMMANDS--

		  -- BRN -------------------
              when "0010000" =>
                PC_MUX_SEL <= "00";
                PC_LD <= '1';
           
          -- CALL ------------------
            when "0010001" =>
                 PC_MUX_SEL <= "00";
                 SCR_WR <= '1';
                 SCR_DATA_SEL <= '1';
                 SCR_ADDR_SEL <= "11";
                 SP_DECR <= '1';
                 PC_LD <= '1';
                 
		  -- BREQ -------------------
            when "0010010" =>
                 PC_MUX_SEL <= "00";
                 PC_LD <= Z;
                 
          -- BRNE -------------------
            when "0010011" =>
--                 if( Z = '0') then
--                    PC_LD <= '1';
--                 end if;
                 PC_MUX_SEL <= "00";
                 PC_LD <= NOT Z;
                 
          -- BRCS -------------------
            when "0010100" =>
                 PC_MUX_SEL <= "00";
                 PC_LD <= C;
                 
          -- BRCC -------------------
            when "0010101" =>
                 PC_MUX_SEL <= "00";
                 PC_LD <= NOT C;
                 
          --LSL ---------------------
            when "0100000" =>
                 RF_WR_SEL <= "00";
                 RF_WR <= '1';
                 ALU_SEL <= "1001";
                 FLG_C_LD <= '1';
                 FLG_Z_LD <= '1';
                 
          --LSR ---------------------
            when "0100001" =>
                 RF_WR_SEL <= "00";
                 RF_WR <= '1';
                 ALU_SEL <= "1010";
                 FLG_C_LD <= '1';
                 FLG_Z_LD <= '1';
                 
          --ROL ---------------------
            when "0100010" =>
                 RF_WR_SEL <= "00";
                 RF_WR <= '1';
                 ALU_SEL <= "1011";
                 FLG_C_LD <= '1';
                 FLG_Z_LD <= '1';
                        
          --ROR ---------------------
            when "0100011" =>
                 RF_WR_SEL <= "00";
                 RF_WR <= '1';
                 ALU_SEL <= "1100";
                 FLG_C_LD <= '1';
                 FLG_Z_LD <= '1';
                 
          --ASR ---------------------
            when "0100100" =>
                 RF_WR_SEL <= "00";
                 RF_WR <= '1';
                 ALU_SEL <= "1101";
                 FLG_C_LD <= '1';
                 FLG_Z_LD <= '1';
                 
          --PUSH -------------------
            when "0100101" =>
                 SCR_WR <= '1';
                 SCR_DATA_SEL <= '0';
                 SCR_ADDR_SEL <= "11";
                 SP_DECR <= '1';
                 
          --POP -------------------
            when "0100110" =>
                 RF_WR_SEL <= "01";
                 SCR_ADDR_SEL <= "10";
                 SP_INCR <= '1';
                 RF_WR <= '1';
                 
          --WSP -------------------
            when "0101000" =>
                 SP_LD <= '1';
          
          --RSP -------------------
            when "0101001" =>
                 RST <= '1';
                 
--NONE INSTRUCTIONS

          --CLC -------------------
            when "0110000" =>
                 FLG_C_CLR <= '1';
          
          --SEC -------------------
            when "0110001" =>
                 FLG_C_SET <= '1';
                 
          --RET -------------------
            when "0110010" =>
                 PC_LD <= '1';
                 PC_MUX_SEL <= "01";
                 SCR_ADDR_SEL <= "10";
                 SP_INCR <= '1';
                 
          --SEI -------------------
            when "0110100" =>
                 I_FLAG_SET   <= '1';        
                 
          --CLI -------------------
            when "0110101" =>
                 I_FLAG_CLR <= '1';
                 
          --RETID -------------------
            when "0110110" =>
                 PC_LD      <= '1';   
                 PC_MUX_SEL <= "01";
                    
                 SP_INCR <= '1';
                  
      
                 SCR_ADDR_SEL <= "10";  
                   
                 FLG_C_LD    <= '1';   
                 FLG_Z_LD    <= '1'; 
                 FLG_LD_SEL  <= '1';   
                   
                 I_FLAG_CLR   <= '1';
                  
          --RETIE -------------------
            when "0110111" =>
                 PC_LD      <= '1';   
                 PC_MUX_SEL <= "01";
                    
                 SP_INCR <= '1';
                  
      
                 SCR_ADDR_SEL <= "10";  
                   
                 FLG_C_LD    <= '1';   
                 FLG_Z_LD    <= '1'; 
                 FLG_LD_SEL  <= '1';   
                   
                 I_FLAG_SET   <= '1';    
            

              when others =>  
                  NS <= ST_fet;       

            end case; 


          when others =>   
               NS <= ST_fet;		    
			 
				 
	    end case;  
       
   end process comb_p;
   
   
end Behavioral;
