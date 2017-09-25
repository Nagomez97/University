--------------------------------------------------------------------------------
-- Procesador MIPS con pipeline curso Arquitectura 2017-18
--
-- (INCLUIR AQUI LA INFORMACION SOBRE LOS AUTORES)
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity processor is
   port(
      Clk         : in  std_logic; -- Reloj activo flanco subida
      Reset       : in  std_logic; -- Reset asincrono activo nivel alto
      -- Instruction memory
      IAddr      : out std_logic_vector(31 downto 0); -- Direccion de instruccion
      IDataIn    : in  std_logic_vector(31 downto 0); -- Dato leido
      -- Data memory
      DAddr      : out std_logic_vector(31 downto 0); -- Direccion de dato
      DRdEn      : out std_logic;                     -- Habilitacion lectura
      DWrEn      : out std_logic;                     -- Habilitacion escritura
      DDataOut   : out std_logic_vector(31 downto 0); -- Dato escrito
      DDataIn    : in  std_logic_vector(31 downto 0)  -- Dato leido
   );
end processor;

architecture rtl of processor is 
	
	component reg_bank
		port(
			Clk   : in std_logic; -- Reloj activo en flanco de subida
			Reset : in std_logic; -- Reset asíncrono a nivel alto
			A1    : in std_logic_vector(4 downto 0);   -- Dirección para el puerto Rd1
			Rd1   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd1
			A2    : in std_logic_vector(4 downto 0);   -- Dirección para el puerto Rd2
			Rd2   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd2
			A3    : in std_logic_vector(4 downto 0);   -- Dirección para el puerto Wd3
			Wd3   : in std_logic_vector(31 downto 0);  -- Dato de entrada Wd3
			We3   : in std_logic -- Habilitación de la escritura de Wd3
		);
	end component;
	
	component alu
		port(
			OpA     : in  std_logic_vector (31 downto 0); -- Operando A
			OpB     : in  std_logic_vector (31 downto 0); -- Operando B
			Control : in  std_logic_vector ( 3 downto 0); -- Codigo de control=op. a ejecutar
			Result  : out std_logic_vector (31 downto 0); -- Resultado
			ZFlag   : out std_logic                       -- Flag Z
		);
	end component;
	
	component control_unit
		port(
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
			RegDst   : out  std_logic  -- 0=Reg. destino es rt, 1=rd
		);
	end component;
	
	component alu_control
		port(
				 -- Entradas:
			ALUOp  : in std_logic_vector (1 downto 0); -- Codigo control desde la unidad de control
			Funct  : in std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
			-- Salida de control para la ALU:
			ALUControl : out std_logic_vector (3 downto 0) -- Define operacion a ejecutar por ALU
		);
	end component;
	
	-- Seniales del procesador
	signal pc_exit : std_logic_vector(31 downto 0);
	signal pc_in	: std_logic_vector(31 downto 0);
	signal PC4		: std_logic_vector(31 downto 0);
	
	-- Seniales de interconexion
	-- alu
	signal OpA     : std_logic_vector (31 downto 0); -- Operando A
	signal OpB     : std_logic_vector (31 downto 0); -- Operando B
	signal Control : std_logic_vector ( 3 downto 0); -- Codigo de control=op. a ejecutar
	signal Result  : std_logic_vector (31 downto 0); -- Resultado
	signal ZFlag   : std_logic;
	
	-- control_unit
	signal Branch	: std_logic;
	signal MemToReg: std_logic;
	signal MemWrite: std_logic;
	signal MemRead : std_logic;
	signal ALUSrc  : std_logic;
	signal ALUOp   : std_logic_vector (1 downto 0);
	signal RegWrite: std_logic;
	signal RegDst  : std_logic;
	
	-- registros
	signal Rd2 : std_logic_vector(31 downto 0);
	signal A3  : std_logic_vector(4 downto 0);   -- Dirección para el puerto Wd3
	signal Wd3 : std_logic_vector(31 downto 0);  -- Dato de entrada Wd3
	
	
begin  
	
	-- instanciacion de alu
	
	i_alu : alu
		port map (
			OpA => OpA,
			OpB => OpB,
			Control => Control,
			Result => Result,
			ZFlag => ZFlag
		);
		
	-- instanciacion de alu_control
	i_alu_control: alu_control
		port map(
			ALUOp => ALUOp,
			Funct => IDataIn (5 downto 0),
			ALUControl => Control
		);
		
	-- instanciacion de control_unit
	
	i_control_unit : control_unit
		port map (
			OpCode => IDataIn(31 downto 26),
			Branch => Branch,
			MemToReg => MemToReg,
			MemWrite => MemWrite,
			MemRead => MemRead,
			ALUSrc => ALUSrc,
			ALUOp => ALUOp,
			RegWrite => RegWrite,
			RegDst => RegDst
		);
		
	-- instanciacion de reg_bank
		
	i_reg_bank : reg_bank
		port map (
			Clk => Clk,
			Reset => Reset,
			A1 => IDataIn(25 downto 21),
			Rd1 => OpA,
			A2 => IDataIn (20 downto 16),
			Rd2 => Rd2,
			A3 => A3,
			Wd3 => Wd3,
			We3 => RegWrite
		);

	------------------------------------------------------
   -- Program Counter
   ------------------------------------------------------
	
	PC4 <= pc_exit + 4;
	
	process(Clk, pc_in)
	begin
		if rising_edge(Clk) then
			pc_exit <= pc_in;
		end if;
	end process;
	
	------------------------------------------------------
   -- MUX Write Register
   ------------------------------------------------------
	
	process(IDataIn, RegDst)
	begin
		if RegDst = 1 then
			A3 <= IDataIn(15 downto 11);
		else if RegDst = 0 then
			A3 <= IDataIn (20 downto 16);
		end if;
	end process;
	
end architecture;
