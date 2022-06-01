library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sim is
--  Port ( );
end sim;

architecture Behavioral of sim is

   component SP
       port ( RST : in std_logic;
                CLK : in std_logic;
              SP_LD : in std_logic;
            SP_INCR : in std_logic;
            SP_DECR : in std_logic;
              DATA_IN : in std_logic_vector (7 downto 0); 
              DATA_OUT : out std_logic_vector (7 downto 0)); 
    end component;
    
    component S_RAM
    Port ( DATA_IN : in STD_LOGIC_VECTOR (9 downto 0);
           SCR_ADDR : in STD_LOGIC_VECTOR (7 downto 0);
           SCR_WE : in STD_LOGIC;
           CLK : in STD_LOGIC;
           DATA_OUT : out STD_LOGIC_VECTOR (9 downto 0));
    end component;

    component FlagReg
        port ( D    : in  STD_LOGIC; --flag input
               LD   : in  STD_LOGIC; --load Q with the D value
               SET  : in  STD_LOGIC; --set the flag to '1'
               CLR  : in  STD_LOGIC; --clear the flag to '0'
               CLK  : in  STD_LOGIC; --system clock
               Q    : out  STD_LOGIC); --flag output
    end component;

   component prog_rom  
      port (     ADDRESS : in std_logic_vector(9 downto 0); 
             INSTRUCTION : out std_logic_vector(17 downto 0); 
                     CLK : in std_logic);  
   end component;

   component ALU
       Port ( A : in  STD_LOGIC_VECTOR (7 downto 0);
              B : in  STD_LOGIC_VECTOR (7 downto 0);
              Cin : in  STD_LOGIC;
              SEL : in  STD_LOGIC_VECTOR(3 downto 0);
              C : out  STD_LOGIC;
              Z : out  STD_LOGIC;
              RESULT : out  STD_LOGIC_VECTOR (7 downto 0));
   end component;

   component CONTROL_UNIT 
       Port ( CLK           : in   STD_LOGIC;
              C             : in   STD_LOGIC;
              Z             : in   STD_LOGIC;
              INT           : in   STD_LOGIC;
              RESET         : in   STD_LOGIC; 
              OPCODE_HI_5   : in   STD_LOGIC_VECTOR (4 downto 0);
              OPCODE_LO_2   : in   STD_LOGIC_VECTOR (1 downto 0);
              
              PC_LD         : out  STD_LOGIC;
              PC_INC        : out  STD_LOGIC;
              PC_MUX_SEL    : out  STD_LOGIC_VECTOR (1 downto 0);		  

              SP_LD         : out  STD_LOGIC;
              SP_INCR       : out  STD_LOGIC;
              SP_DECR       : out  STD_LOGIC;
 
              RF_WR         : out  STD_LOGIC;
              RF_WR_SEL     : out  STD_LOGIC_VECTOR (1 downto 0);

              ALU_OPY_SEL   : out  STD_LOGIC;
              ALU_SEL       : out  STD_LOGIC_VECTOR (3 downto 0);

              SCR_WR        : out  STD_LOGIC;
              SCR_ADDR_SEL  : out  STD_LOGIC_VECTOR (1 downto 0);
			  SCR_DATA_SEL  : out  STD_LOGIC; 

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
   end component;

   component RegisterFile 
       Port ( D_IN   : in     STD_LOGIC_VECTOR (7 downto 0);
              DX_OUT : out    STD_LOGIC_VECTOR (7 downto 0);
              DY_OUT : out    STD_LOGIC_VECTOR (7 downto 0);
              ADRX   : in     STD_LOGIC_VECTOR (4 downto 0);
              ADRY   : in     STD_LOGIC_VECTOR (4 downto 0);
              WR     : in     STD_LOGIC;
              CLK    : in     STD_LOGIC);
   end component;

   component PC 
      port ( RST,CLK,PC_LD,PC_INC : in std_logic; 
             FROM_IMMED : in std_logic_vector (9 downto 0); 
             FROM_STACK : in std_logic_vector (9 downto 0); 
--             FROM_INTRR : in std_logic_vector (9 downto 0); 
             PC_MUX_SEL : in std_logic_vector (1 downto 0); 
             PC_COUNT   : out std_logic_vector (9 downto 0));
   end component;          
             
   -- intermediate signals ----------------------------------
   signal s_pc_ld : std_logic := '0'; 
   signal s_pc_inc : std_logic := '0'; 
   signal s_rst : std_logic := '0'; 
   signal s_pc_mux_sel : std_logic_vector(1 downto 0) := "00"; 
   signal s_pc_count : std_logic_vector(9 downto 0) := (others => '0');   
   signal s_inst_reg : std_logic_vector(17 downto 0) := (others => '0'); 
   
   

   -- helpful aliases ------------------------------------------------------------------
   alias s_ir_immed_bits : std_logic_vector(9 downto 0) is s_inst_reg(12 downto 3); 
   alias s_ir_128 : std_logic_vector(4 downto 0) is s_inst_reg(12 downto 8); 
   alias s_ir_73 : std_logic_vector(4 downto 0) is s_inst_reg(7 downto 3); 
   alias s_ir_70 : std_logic_vector(7 downto 0) is s_inst_reg(7 downto 0);
   alias s_ir_1713 : std_logic_vector(4 downto 0) is s_inst_reg(17 downto 13);
   alias s_ir_10 : std_logic_vector(1 downto 0) is s_inst_reg(1 downto 0);
   
   
   signal reg_dx_out,reg_dy_out : std_logic_vector(7 downto 0) := (others => '0');
   
   signal alu_sel : std_logic_vector(3 downto 0) := (others => '0');
   signal rf_wr_sel,scr_addr_sel : std_logic_vector(1 downto 0) := (others => '0');
   signal sp_ld,sp_incr,sp_decr,rf_wr,alu_opy_sel,scr_wr,scr_data_sel,flg_c_ld,flg_c_set,flg_c_clr,flg_shad_ld,flg_ld_sel,flg_z_ld,i_flag_set,i_flag_clr,rst : std_logic := '0';

   signal c_flag,z_flag,cu_int : std_logic := '0';
   
   
   signal result : std_logic_vector(7 downto 0) := (others => '0');
   signal c,z,i_output : std_logic := '0';
   
   
   signal mux_alu,mux_reg : std_logic_vector(7 downto 0) := (others => '0');
   
   signal sp_data_out,s_ram_addr_mux : std_logic_vector(7 downto 0) := (others => '0');

   signal s_ram_data_mux, s_ram_data_out : std_logic_vector(9 downto 0) := (others => '0');
   
   alias s_ram_data_out8 : std_logic_vector(7 downto 0) is s_ram_data_out(7 downto 0);

   signal flg_mux_c_out,flg_mux_z_out,shad_c_out,shad_z_out : std_logic := '0';
   
   signal IN_PORT,OUT_PORT,PORT_ID : std_logic_vector(7 downto 0) := (others => '0');
   signal RESET,INT,IO_STRB,CLK : std_logic := '0';

begin

--s_ram addr mux
   process (scr_addr_sel,sp_data_out,s_ir_70,reg_dy_out) is
   begin
       if (scr_addr_sel ="00") then
           s_ram_addr_mux <= reg_dy_out;
       elsif (scr_addr_sel ="01") then
           s_ram_addr_mux <= s_ir_70;
       elsif (scr_addr_sel ="10") then
           s_ram_addr_mux <= sp_data_out;
       else
           s_ram_addr_mux <= sp_data_out - 1;
       end if;
   end process;
   
   
   --s_ram data_in mux
   process (scr_data_sel,reg_dy_out,s_pc_count) is
   begin
       if (scr_data_sel ='0') then
           s_ram_data_mux <= "00" & reg_dy_out;
       else
           s_ram_data_mux <= s_pc_count;
       end if;
   end process;
   
   
   --alu mux
   process (alu_opy_sel,s_ir_70,reg_dy_out) is
   begin
       if (alu_opy_sel ='0') then
           mux_alu <= reg_dy_out;
       else
           mux_alu <= s_ir_70;
       end if;
   end process;
   
   
   --reg_file mux
   process (rf_wr_sel,IN_PORT,result,s_ram_data_out8,sp_data_out) is
   begin
       if (rf_wr_sel = "00") then
           mux_reg <= result;
       elsif (rf_wr_sel = "01") then
           mux_reg <= s_ram_data_out8;
       elsif (rf_wr_sel = "10") then
           mux_reg <= sp_data_out;
       else
           mux_reg <= IN_PORT;
       end if;
   end process;
   
   
   
   --flags mux
   process (z,c,flg_ld_sel) is
   begin
       if (flg_ld_sel ='0') then
           flg_mux_c_out <= c;
           flg_mux_z_out <= z;
       else
           flg_mux_c_out <= shad_c_out;
           flg_mux_z_out <= shad_z_out;
       end if;
   end process;

cu_int <= INT and i_output;
OUT_PORT <= reg_dx_out;
PORT_ID <= s_ir_70;

   my_prog_rom: prog_rom  
   port map(     ADDRESS => s_pc_count, 
             INSTRUCTION => s_inst_reg, 
                     CLK => CLK); 

   my_alu: ALU
   port map ( A => reg_dx_out,       
              B => mux_alu,       
              Cin => c_flag,     
              SEL => alu_sel,     
              C => c,       
              Z => z,       
              RESULT => result); 


   my_cu: CONTROL_UNIT 
   port map ( CLK           => CLK, 
              C             => c_flag, 
              Z             => z_flag, 
              INT           => cu_int, 
              RESET         => RESET, 
              OPCODE_HI_5   => s_ir_1713, 
              OPCODE_LO_2   => s_ir_10, 
              
              PC_LD         => s_pc_ld, 
              PC_INC        => s_pc_inc,  
              PC_MUX_SEL    => s_pc_mux_sel, 

              SP_LD         => sp_ld, 
              SP_INCR       => sp_incr, 
              SP_DECR       => sp_decr, 

              RF_WR         => rf_wr, 
              RF_WR_SEL     => rf_wr_sel, 

              ALU_OPY_SEL   => alu_opy_sel, 
              ALU_SEL       => alu_sel,
			  
              SCR_WR        => scr_wr, 
              SCR_ADDR_SEL  => scr_addr_sel,              
			  SCR_DATA_SEL  => scr_data_sel,
			  
              FLG_C_LD      => flg_c_ld, 
              FLG_C_SET     => flg_c_set, 
              FLG_C_CLR     => flg_c_clr, 
              FLG_SHAD_LD   => flg_shad_ld, 
              FLG_LD_SEL    => flg_ld_sel, 
              FLG_Z_LD      => flg_z_ld, 
              I_FLAG_SET    => i_flag_set, 
              I_FLAG_CLR    => i_flag_clr,  

              RST           => rst,
              IO_STRB       => IO_STRB);
              

   my_regfile: RegisterFile 
   port map ( D_IN   => mux_reg,   
              DX_OUT => reg_dx_out,   
              DY_OUT => reg_dy_out,   
              ADRX   => s_ir_128,   
              ADRY   => s_ir_73,     
              WR     => rf_wr,   
              CLK    => CLK); 


   my_PC: PC 
   port map ( RST        => rst,
              CLK        => CLK,
              PC_LD      => s_pc_ld,
              PC_INC     => s_pc_inc,
              FROM_IMMED => s_ir_immed_bits,
              FROM_STACK => s_ram_data_out,
--              FROM_INTRR => x"3FF",--interrupt
              PC_MUX_SEL => s_pc_mux_sel,
              PC_COUNT   => s_pc_count); 
              

    C_Reg: FlagReg
    port map ( D    => flg_mux_c_out,
               LD   => flg_c_ld,
               SET  => flg_c_set,
               CLR  => flg_c_clr,
               CLK  => CLK,
               Q    => c_flag);
               
    Z_Reg: FlagReg
    port map ( D    => flg_mux_z_out,
               LD   => flg_z_ld,
               SET  => '0',
               CLR  => '0',
               CLK  => CLK,
               Q    => z_flag);
               
    Shad_C_Reg: FlagReg
    port map ( D    => c_flag,
               LD   => flg_shad_ld,
               SET  => '0',
               CLR  => '0',
               CLK  => CLK,
               Q    => shad_c_out);
              
    Shad_Z_Reg: FlagReg
    port map ( D    => z_flag,
               LD   => flg_shad_ld,
               SET  => '0',
               CLR  => '0',
               CLK  => CLK,
               Q    => shad_z_out);
               
    I_Reg: FlagReg
    port map ( D    => '0',
               LD   => '0',
               SET  => i_flag_set,
               CLR  => i_flag_clr,
               CLK  => CLK,
               Q    => i_output);
               
    StackPointer: SP
    port map ( RST    => rst,
               CLK   => CLK,
               SP_LD  => sp_ld,
               SP_INCR  => sp_incr,
               SP_DECR  => sp_decr,
               DATA_IN    => reg_dx_out,
               DATA_OUT => sp_data_out);
               
    SRAM: S_RAM
    port map ( DATA_IN    => s_ram_data_mux,
               SCR_ADDR   => s_ram_addr_mux,
               SCR_WE  => scr_wr,
               CLK  => CLK,
               DATA_OUT  => s_ram_data_out);
       
proc1: process
    begin
    clk <= not clk; --flip the bit
    wait for 10 ns;
end process;

proc2: process
begin

    wait for 300 ns; --80ns fail
    INT <= '1';
    wait for 40 ns;
    INT <= '0';
    wait for 99999 ns;
    
end process;


end Behavioral;
