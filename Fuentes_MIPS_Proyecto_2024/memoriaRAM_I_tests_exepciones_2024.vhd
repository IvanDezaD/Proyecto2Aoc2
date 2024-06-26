----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:38:16 04/08/2014 
-- Design Name: 
-- Module Name:    memoriaRAM_I - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity memoriaRAM_I is port (
		  	CLK : in std_logic;
		  	ADDR : in std_logic_vector (31 downto 0); --Dir 
        	Din : in std_logic_vector (31 downto 0);--entrada de datos para el puerto de escritura
        	WE : in std_logic;		-- write enable	
		  	RE : in std_logic;		-- read enable		  
		  	Dout : out std_logic_vector (31 downto 0));
end memoriaRAM_I;

--************************************************************************************************************
-- Fichero con la memoria de instrucciones cargada con diversos test
--************************************************************************************************************

architecture Behavioral of memoriaRAM_I is
type RamType is array(0 to 127) of std_logic_vector(31 downto 0);
--------------------------------------------------------------------------------------------------------------------------------
-- Instruction Memory Map
-- From Word 0 to 3: Exception Vector Table: (@ of the exception routines)
-- 		@0: reset
-- 		@4: IRQ
-- 		@8: Data Abort
-- 		@C: UNDEF
-- From Word 4  (@010): .CODE (code of the application to execute)
-- From Word 64 (@100): RTI (code for the IRQ)
-- From Word 96 (@180): Data abort (code for the Data Abort exception)
-- From Word 112(@1C0): UNDEF (code for the UNDEF exception)
--------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------------
-- BANCO DE PRUEBAS INICIAL 2024
-- Código descrito en Codigo_test_2024 
--------------------------------------------------------------------------------------------------------------------------------
signal RAM : RamType := (  	X"10210003", X"1021003E", X"1021005D", X"1021006C", X"081F0000", X"08010008", X"0CC17004", X"04211000", --word 0,1,...
				X"08030010", X"04422000", X"04832800", X"0C050018", X"1005000F", X"04000000", X"08200000", X"00000000", --word 8,9,...
				X"08C00004", X"1003000B", X"0CC37004", X"08C10000", X"0CC17004", X"08C10003", X"08C15DC0", X"14010006",--word 16,...
				X"14010006", X"FFFFFFFF", X"0CC37004", X"1000FFFF", X"1000FFFF", X"1000FFFF", X"18200000", X"04260800",--word 24,...
				X"18200000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 32,...
				X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 40,...
				X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 48,...
				X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 56,...
				X"0FE10000", X"0FE20004", X"08C10008", X"07E1F800", X"08C2000C", X"08C10004", X"04221000", X"0CC27004", --word 64,...
				X"0CC2000C", X"0CC17008", X"08C10008", X"07E1F801", X"0BE10000", X"0BE20004", X"20000000", X"08C17FFF",--word 72,...
				X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 80,...
				X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 88,...
				X"08C10014", X"0CC67004", X"0CC17004", X"20000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 96,...
				X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 104,...
				X"08C1001C", X"0CC17004", X"1000FFFF", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 112,...
				X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000");--word 120,...
									
								



--------------------------------------------------------------------------------------------------------------------------------
-- BANCO DE PRUEBAS PARA EL PROCESADOR BASE: 
-- Incluye nops para eliminar los riesgos de datos y control 
-- El código se describe en Codigo_retardado
-- Está pensado para simular con las IRQ desactivadas
--------------------------------------------------------------------------------------------------------------------------------
-- signal RAM : RamType := (  		X"10210003", X"00000000", X"00000000", X"00000000", X"081F0000", X"08010000", X"08020004", X"00000000", --word 0,1,...
-- 									X"00000000", X"04221800", X"00000000", X"00000000", X"0C030008", X"1000FFFF", X"00000000", X"00000000", --word 8,9,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 16,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 24,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 32,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 40,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 48,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 56,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 64,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",--word 72,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 80,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 88,...
-- 									X"1000FFFF", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 96,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 104,...
-- 									X"1000FFFF", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 112,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000");--word 120,...										
														
--------------------------------------------------------------------------------------------------------------------------------
-- BANCO DE PRUEBAS PARA LAS INT
-- Código descrito en Codigo_test_IRQ
--------------------------------------------------------------------------------------------------------------------------------
-- signal RAM : RamType := (  		X"10210003", X"1021003E", X"1021005D", X"1021006C", X"081F0000", X"08010004", X"0CC17004", X"04210800", --word 0,1,...
-- 									X"0CC17004", X"1021FFFD", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 8,9,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 16,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 24,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 32,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 40,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 48,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 56,...
-- 									X"0FE10000", X"0FE20004", X"08C10008", X"07E1F800", X"08C2000C", X"08C10004", X"04221000", X"0CC27004", --word 64,...
-- 									X"0CC2000C", X"0CC17008", X"08C10008", X"07E1F801", X"0BE10000", X"0BE20004", X"20000000", X"08C17FFF",--word 72,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 80,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 88,...
-- 									X"08C10014", X"0CC67004", X"0CC17004", X"20000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 96,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 104,...
-- 									X"08C1001C", X"0CC17004", X"1000FFFF", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 112,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000");--word 120,...
-- 									
									
--------------------------------------------------------------------------------------------------------------------------------
-- BANCO DE PRUEBAS PARA EL DATA ABORT: 
-- Acceso a memoria no alineado: 08010003 = LW R1, 3(R0)
-- Produce un abort y saltamos a la palabra 96 que saca por la salida el código 0x00000AB0 y entra en un bucle infinito: 1000FFFF = BEQ r0,r0,-1
-- Hay un RTE después del bucle que no debe ejecutarse
--------------------------------------------------------------------------------------------------------------------------------
-- signal RAM : RamType := (  			X"10210003", X"1021003E", X"1021005D", X"1021006C", X"08010003", X"00000000", X"00000000", X"00000000", --word 0,1,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 8,9,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 16,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 24,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 32,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 40,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 48,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 56,...
-- 									X"0FE10000", X"0FE20004", X"08C10008", X"07E1F800", X"08C2000C", X"08C10004", X"04221000", X"0CC27004", --word 64,...
-- 									X"0CC2000C", X"0CC17008", X"08C10008", X"07E1F801", X"0BE10000", X"0BE20004", X"20000000", X"08C17FFF",--word 72,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 80,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 88,...
-- 									X"08C10014", X"0CC17004", X"1000FFFF", X"20000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 96,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 104,...
-- 									X"08C1001C", X"0CC17004", X"1000FFFF", X"20000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 112,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000");--word 120,...
-- 									
--------------------------------------------------------------------------------------------------------------------------------
-- BANCO DE PRUEBAS PARA EL DATA ABORT: 
-- Acceso a dirección fuera de rango: 08017ffC = LW R1, 32767(R0)
-- Produce un abort y saltamos a la palabra 96 que saca por la salida el código 0x00000AB0 y entra en un bucle infinito: 1000FFFF = BEQ r0,r0,-1
-- Hay un RTE después del bucle que no debe ejecutarse
--------------------------------------------------------------------------------------------------------------------------------
-- signal RAM : RamType := (  		X"10210003", X"1021003E", X"1021005D", X"1021006C", X"08017ffC", X"00000000", X"00000000", X"00000000", --word 0,1,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 8,9,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 16,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 24,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 32,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 40,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 48,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 56,...
-- 									X"0FE10000", X"0FE20004", X"08C10008", X"07E1F800", X"08C2000C", X"08C10004", X"04221000", X"0CC27004", --word 64,...
-- 									X"0CC2000C", X"0CC17008", X"08C10008", X"07E1F801", X"0BE10000", X"0BE20004", X"20000000", X"08C17FFF",--word 72,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 80,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 88,...
-- 									X"08C10014", X"0CC17004", X"1000FFFF", X"20000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 96,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 104,...
-- 									X"08C1001C", X"0CC17004", X"1000FFFF", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 112,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000");--word 120,...
-- 									
--------------------------------------------------------------------------------------------------------------------------------
-- BANCO DE PRUEBAS PARA EL UNDEF: 
-- Instrucción con código erróneo: FFFFFFFF = ¿?
-- Produce un UNDEF y saltamos a la palabra 112 que saca por la salida el código 0x0BAD0C0D y entra en un bucle infinito: 1000FFFF = BEQ r0,r0,-1
-- Hay un RTE después del bucle que no debe ejecutarse
--------------------------------------------------------------------------------------------------------------------------------
-- signal RAM : RamType := (  		X"10210003", X"1021003E", X"1021005D", X"1021006C", X"FFFFFFFF", X"00000000", X"00000000", X"00000000", --word 0,1,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 8,9,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 16,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 24,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 32,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 40,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 48,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 56,...
-- 									X"0FE10000", X"0FE20004", X"08C10008", X"07E1F800", X"08C2000C", X"08C10004", X"04221000", X"0CC27004", --word 64,...
-- 									X"0CC2000C", X"0CC17008", X"08C10008", X"07E1F801", X"0BE10000", X"0BE20004", X"20000000", X"08C17FFF",--word 72,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 80,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 88,...
-- 									X"08C10014", X"0CC17004", X"1000FFFF", X"20000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 96,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 104,...
-- 									X"08C1001C", X"0CC17004", X"1000FFFF", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", --word 112,...
-- 									X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000");--word 120,...

-----------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------
-- BANCO DE PRUEBAS PROPIO 1: 
-- Comprobamos el JAL y el RET y un poco de risgo de datos. 
-- signal RAM : RamType :=          ( X"14010005", X"04840800", X"0c410004", X"08020030", X"10210006", X"00000000", X"00000000", X"08020030", 
--                                    X"08030034", X"04432000", X"18200000", X"00000000", X"1021ffff", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000");

 -----------------------------------------------------------------------------------------------------------------------------
-- BANCO DE PRUEBAS PROPIO 2:
-- Comprobamos la anticipación de operandos.
-- signal RAM : RamType :=          ( X"08010050", X"08040054", X"04840800", X"0c010028", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000");

-----------------------------------------------------------------------------------------------------------------------------	
-- BANCO DE PRUEBAS PROPIO 3:
-- En este comprobamos el riesgo de datos.
-- signal RAM : RamType :=          ( X"08010050", X"08020054", X"04221800", X"08640000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000");
								   
-----------------------------------------------------------------------------------------------------------------------------	
-- BANCO DE PRUEBAS PROPIO 4:
-- En este comprobamos que funcionan los riesgos de control 
-- mediante el uso de las instrucciones BEQ, RTE, JAL y RET.
-- signal RAM : RamType :=          ( X"10210001", X"10420006", X"08010000", X"08020004", X"08030000", X"04220800", X"04421001", X"1021fffd", 
--                                    X"14040002", X"10220001", X"10420004", X"04411000", X"04621801", X"18800000", X"20000000", X"1042ffff", 
-- 								   X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", 
--                                    X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000");

-----------------------------------------------------------------------------------------------------------------------------	                                
 																																		
signal dir_7:  std_logic_vector(6 downto 0); 
begin
 
 dir_7 <= ADDR(8 downto 2); -- como la memoria es de 128 plalabras no usamos la dirección completa sino sólo 7 bits. Como se direccionan los bytes, pero damos palabras no usamos los 2 bits menos significativos
 process (CLK)
    begin
        if (CLK'event and CLK = '1') then
            if (WE = '1') then -- sólo se escribe si WE vale 1
                RAM(conv_integer(dir_7)) <= Din;
            end if;
        end if;
    end process;

    Dout <= RAM(conv_integer(dir_7)) when (RE='1') else "00000000000000000000000000000000"; --sólo se lee si RE vale 1

end Behavioral;


