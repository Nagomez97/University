--------------------------------------------------------------------------------
-- Bloque de control para la ALU. Arq0 2017.
--
-- (INCLUIR AQUI LA INFORMACION SOBRE LOS AUTORES)
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity alu_control is
   port (
      -- Entradas:
      ALUOp  : in std_logic_vector (1 downto 0); -- Codigo control desde la unidad de control
      Funct  : in std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
      -- Salida de control para la ALU:
      ALUControl : out std_logic_vector (3 downto 0) -- Define operacion a ejecutar por ALU
   );
end alu_control;

architecture rtl of alu_control is
   
	-- Tipos para los codigos de control:
   subtype t_aluControl is std_logic_vector (3 downto 0);
	subtype t_aluOp is std_logic_vector (1 downto 0);
	subtype t_funct is std_logic_vector (5 downto 0);

   -- Codigos de control:
   constant ALU_OR   : t_aluControl := "0111";   
   constant ALU_NOT  : t_aluControl := "0101";
   constant ALU_XOR  : t_aluControl := "0110";
   constant ALU_AND  : t_aluControl := "0100";
   constant ALU_SUB  : t_aluControl := "0001";
   constant ALU_ADD  : t_aluControl := "0000";
   constant ALU_SLT  : t_aluControl := "1010";
   constant ALU_S16  : t_aluControl := "1101";
	
	-- Codigos de ALUOp
	constant LSW	: t_aluOp := "00";
	constant BEQ	: t_aluOp := "01";
	constant RT		: t_aluOp := "10";
	
	-- Codigos de Funct
	constant F_ADD	: t_funct := "100000";
	constant F_AND	: t_funct := "100100";
	constant F_OR	: t_funct := "100101";
	constant F_SUB	: t_funct := "100010";
	constant F_XOR	: t_funct := "100110";
	
	-- Seniales
	signal sigResult: std_logic_vector (3 downto 0); --senial de salida dirigida a la ALU

begin
	process(ALUOp, Funct)
	begin
		case ALUOp is
			when LSW => sigResult <= ALU_ADD;
			when BEQ => sigResult <= ALU_SUB;
			when RT =>
				case Funct is
					when F_ADD => sigResult <= ALU_ADD;
					when F_AND => sigResult <= ALU_AND;
					when F_OR => sigResult <= ALU_OR;
					when F_SUB => sigResult <= ALU_SUB;
					when F_XOR => sigResult <= ALU_XOR;
					when others => sigResult <= "0000";
				end case;
			when others => sigResult <= "0000";
			end case;
	end process;
		
end architecture;
