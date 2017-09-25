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
      IAddr      : out std_logic_vector(31 downto 0); -- Direccion
      IDataIn    : in  std_logic_vector(31 downto 0); -- Dato leido
      -- Data memory
      DAddr      : out std_logic_vector(31 downto 0); -- Direccion
      DRdEn      : out std_logic;                     -- Habilitacion lectura
      DWrEn      : out std_logic;                     -- Habilitacion escritura
      DDataOut   : out std_logic_vector(31 downto 0); -- Dato escrito
      DDataIn    : in  std_logic_vector(31 downto 0)  -- Dato leido
   );
end processor;

architecture rtl of processor is 
	
	component alu
		port(
			OpA     : in  std_logic_vector (31 downto 0); -- Operando A
			OpB     : in  std_logic_vector (31 downto 0); -- Operando B
			Control : in  std_logic_vector ( 3 downto 0); -- Codigo de control=op. a ejecutar
			Result  : out std_logic_vector (31 downto 0); -- Resultado
			ZFlag   : out std_logic                       -- Flag Z
   );
	end component;
	
	-- Seniales del procesador
	signal pc_exit : std_logic_vector(31 downto 0);
	signal pc_in	: std_logic_vector(31 downto 0);
	
	-- Seniales de interconexion
	-- alu
	signal OpA      : in  std_logic_vector (31 downto 0); -- Operando A
	signal OpB     : in  std_logic_vector (31 downto 0); -- Operando B
	signal Control : in  std_logic_vector ( 3 downto 0); -- Codigo de control=op. a ejecutar
	signal Result  : out std_logic_vector (31 downto 0); -- Resultado
	signal ZFlag   : out std_logic 
	
begin  
	
	-- instanciacion de la alu
	
	i_alu : alu
		port map (
			OpA => OpA,
			OpB => OpB,
			Control => Control,
			Result => Result,
			ZFlag => ZFlag
		);

	------------------------------------------------------
   -- Program Counter
   ------------------------------------------------------
	
	process(Clk, pc_in)
	begin
		if rising_edge(Clk) then
			pc_exit <= pc_in;
		end if;
	end process;
	
	
	
end architecture;
