--------------------------------------------------------------------------------
-- Unidad de control principal del micro. Arq0 2017
--
-- (INCLUIR AQUI LA INFORMACION SOBRE LOS AUTORES)
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity control_unit is
   port (
      -- Entrada = codigo de operacion en la instruccion:
      OpCode  : in  std_logic_vector (5 downto 0);
      -- Seniales para el PC
      Branch : out  std_logic; -- 1=Ejecutandose instruccion branch
      -- Seniales relativas a la memoria
      MemToReg : out  std_logic; -- 1=Escribir en registro la salida de la mem.
      MemWrite : out  std_logic; -- Escribir la memoria
      MemRead  : out  std_logic; -- Leer la memoria
      -- Seniales para la ALU
      ALUSrc : out  std_logic;                     -- 0=oper.B es registro, 1=es valor inm.
      ALUOp  : out  std_logic_vector (1 downto 0); -- Tipo operacion para control de la ALU
      -- Seniales para el GPR
      RegWrite : out  std_logic; -- 1=Escribir registro
      RegDst   : out  std_logic;  -- 0=Reg. destino es rt, 1=rd
		LUICtrl	: out std_logic;	-- 1=LUI, 0 resto
		Jump		: out std_logic;	-- 1=Jump, 0 resto
      bubble   : in std_logic    -- 1=Bubble, 0 no.   
   );
end control_unit;

architecture rtl of control_unit is

   -- Tipo para los codigos de operacion:
   subtype t_opCode is std_logic_vector (5 downto 0);
   subtype t_aluOp is std_logic_vector (1 downto 0);

   -- Codigos de operacion para las diferentes instrucciones:
   constant OP_RTYPE  : t_opCode := "000000";
   constant OP_ADDI   : t_opCode := "001000";
   constant OP_BEQ    : t_opCode := "000100";
   constant OP_SW     : t_opCode := "101011";
   constant OP_LW     : t_opCode := "100011";
   constant OP_LUI    : t_opCode := "001111";
   constant OP_SLTI   : t_opCode := "001010";
   constant OP_J      : t_opCode := "000010";

   -- Codigos de ALUOp
   constant LSW   : t_aluOp := "00";
   constant BEQ   : t_aluOp := "01";
   constant RT    : t_aluOp := "10";
	constant SLTI  : t_aluOp := "11";

begin

   process (OpCode, bubble)
   begin
      if(bubble = '1') then
         RegDst <= '0';
         Branch <= '0';
         MemRead <= '0';
         MemToReg <= '0';
         ALUOp <= LSW;
         MemWrite <= '0';
         ALUSrc <= '0';
         RegWrite <= '0';
         LUICtrl <= '0';
         Jump <= '0';
      else
         case OpCode is 
            when OP_RTYPE =>
               RegDst <= '1';
               Branch <= '0';
               MemRead <= '0';
               MemToReg <= '0';
               ALUOp <= RT;
               MemWrite <= '0';
               ALUSrc <= '0';
               RegWrite <= '1';
   				LUICtrl <= '0';
   				Jump <= '0';

            when OP_ADDI =>
               RegDst <= '0';
               Branch <= '0';
               MemRead <= '0';
               MemToReg <= '0';
               ALUOp <= RT;
               MemWrite <= '0';
               ALUSrc <= '1';
               RegWrite <= '1';
   				LUICtrl <= '0';
   				Jump <= '0';

            when OP_BEQ =>
               RegDst <= '0';
               Branch <= '1';
               MemRead <= '0';
               MemToReg <= '0';
               ALUOp <= BEQ;
               MemWrite <= '0';
               ALUSrc <= '0';
               RegWrite <= '0';
   				LUICtrl <= '0';
   				Jump <= '0';

            when OP_SW =>
               RegDst <= '0';
               Branch <= '0';
               MemRead <= '0';
               MemToReg <= '0';
               ALUOp <= LSW;
               MemWrite <= '1';
               ALUSrc <= '1';
               RegWrite <= '0';
   				LUICtrl <= '0';
   				Jump <= '0';

            when OP_LW =>
               RegDst <= '0';
               Branch <= '0';
               MemRead <= '1';
               MemToReg <= '1';
               ALUOp <= LSW;
               MemWrite <= '0';
               ALUSrc <= '1';
               RegWrite <= '1';
   				LUICtrl <= '0';
   				Jump <= '0';

            when OP_LUI => 
   				RegDst <= '0';
               Branch <= '0';
               MemRead <= '0';
               MemToReg <= '0';
               ALUOp <= LSW;
               MemWrite <= '0';
               ALUSrc <= '0';
               RegWrite <= '1';
   				LUICtrl <= '1';
   				Jump <= '0';


            when OP_SLTI =>
   				RegDst <= '0';
               Branch <= '0';
               MemRead <= '0';
               MemToReg <= '0';
               ALUOp <= SLTI;
               MemWrite <= '0';
               ALUSrc <= '1';
               RegWrite <= '0';
   				LUICtrl <= '0';
   				Jump <= '0';
               
            when OP_J =>
   				RegDst <= '0';
               Branch <= '0';
               MemRead <= '0';
               MemToReg <= '0';
               ALUOp <= LSW;
               MemWrite <= '0';
               ALUSrc <= '0';
               RegWrite <= '0';
   				LUICtrl <= '0';
   				Jump <= '1';
   			
   			when others =>
   				RegDst <= '0';
               Branch <= '0';
               MemRead <= '0';
               MemToReg <= '0';
               ALUOp <= LSW;
               MemWrite <= '0';
               ALUSrc <= '0';
               RegWrite <= '0';
   				LUICtrl <= '0';
   				Jump <= '0';
               
         end case;
      end if;
   end process;

end architecture;
