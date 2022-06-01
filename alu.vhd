----------------------------------------------------------------------------------
-- Chris Lim, Joey Bednar
-- ALU unit
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU is
    Port ( A : in STD_LOGIC_VECTOR (7 downto 0);
           B : in STD_LOGIC_VECTOR (7 downto 0);
           SEL : in STD_LOGIC_VECTOR (3 downto 0);
           Cin : in STD_LOGIC;
           RESULT : out STD_LOGIC_VECTOR (7 downto 0);
           C : out STD_LOGIC;
           Z : out STD_LOGIC);
end ALU;

architecture Behavioral of ALU is

signal c1 : std_logic := '0';  --sets initial cflag to 0
signal z1 : std_logic := '1';  --sets initial zflag to 0

begin

proc1: process(A, B, SEL, Cin)

variable rslt : std_logic_vector(8 downto 0) := "000000000"; -- creates rslt variable and initializes to 0

begin
    case SEL is
        when "0000" => --ADD: adds two values
            rslt := ('0' & A) + ('0' & B);
            
        when "0001" => --ADDC: adds two values and Cin
            rslt := ('0' & A) + ('0' & B) + ("00000000" & Cin);
            
        when "0010" => --SUB: subtracts B from A
            rslt := ('0' & A) - ('0' & B);
            
        when "0011" => --SUBC: subtracts B and Cin from A
            rslt := ('0' & A) - ('0' & B) - ("00000000" & Cin);
            
        when "0100" => --CMP: subtracts B from A (we only want flags)
            rslt := ('0' & A) - ('0' & B);
            
        when "0101" => --AND: performs and operand on A and B
            rslt := ('0' & A) and ('0' & B);
            
        when "0110" => --OR: performs or operand on A and B
            rslt := ('0' & A) or ('0' & B);
            
        when "0111" => --EXOR: performs exor operand on A and B
            rslt := ('0' & A) xor ('0' & B);
            
        when "1000" => --TEST: perform and on A and B, only check flags
            rslt := ('0' & A) and ('0' & B);
            
        when "1001" => --LSL: shifts data left, shifting Cin in lsb and msb goes to C 
            rslt := A & Cin;
        
        when "1010" => --LSR: shifts data right, shifts Cin to msb and lsb to C
            rslt := A(0) & Cin & A(7 downto 1);
        
        when "1011" => --ROL: left shifts, moving msb to both lsb and C
            rslt := A(7 downto 0) & A(7);
        
        when "1100" => --ROR: right shifts, moving lsb to both msb and C
            rslt := A(0) & A(0) & A(7 downto 1);
        
        when "1101" => --ASR: right shift that keeps original msb, moves lsb to c
            rslt := A(0) & A(7) & A(7 downto 1);
        
        when "1110" => --MOV: moves data in b to a (not sure if a is a location in this case)
            rslt := '0' & B;
            
        when others =>
            rslt := "011111111";


    end case;
    
    if (rslt(7 downto 0) = "00000000") then
        Z <= '1';
    else
        Z <= '0';
    end if;
    
    C <= rslt(8);
    
    RESULT <= rslt(7 downto 0);    
    
end process;

end Behavioral;
