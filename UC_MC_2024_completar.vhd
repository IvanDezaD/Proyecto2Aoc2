---------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:38:18 05/15/2014 
-- Design Name: 
-- Module Name:    UC_slave - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: la UC incluye un contador de 2 bits para llevar la cuenta de las transferencias de bloque y una m�quina de estados
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UC_MC is
    Port ( 	clk : in  STD_LOGIC;
			reset : in  STD_LOGIC;
			-- �rdenes del MIPS
			RE : in  STD_LOGIC; 
			WE : in  STD_LOGIC;
			-- Respuesta al MIPS
			ready : out  STD_LOGIC; -- indica si podemos procesar la orden actual del MIPS en este ciclo. En caso contrario habr� que detener el MIPs
			-- Se�ales de la MC
			hit0 : in  STD_LOGIC; --se activa si hay acierto en la via 0
			hit1 : in  STD_LOGIC; --se activa si hay acierto en la via 1
			via_2_rpl :  in  STD_LOGIC; --indica que via se va a reemplazar
			addr_non_cacheable: in STD_LOGIC; --indica que la direcci�n no debe almacenarse en MC. En este caso porque pertenece a la scratch
			internal_addr: in STD_LOGIC; -- indica que la direcci�n solicitada es de un registro de MC
			MC_WE0 : out  STD_LOGIC;
            MC_WE1 : out  STD_LOGIC;
            MC_bus_Rd_Wr : out  STD_LOGIC; --1 para escritura en Memoria y 0 para lectura
			MC_tags_WE : out  STD_LOGIC; -- para escribir la etiqueta en la memoria de etiquetas
            palabra : out  STD_LOGIC_VECTOR (1 downto 0);--indica la palabra actual dentro de una transferencia de bloque (1�, 2�...)
            mux_origen: out STD_LOGIC; -- Se utiliza para elegir si el origen de la direcci�n de la palabra y el dato es el Mips (cuando vale 0) o la UC y el bus (cuando vale 1)
			block_addr : out  STD_LOGIC; -- indica si la direcci�n a enviar es la de bloque (rm) o la de palabra (w)
			mux_output: out  std_logic_vector(1 downto 0); -- para elegir si le mandamos al procesador la salida de MC (valor 0),los datos que hay en el bus (valor 1), o un registro interno( valor 2)
			-- se�ales para los contadores de rendimiento de la MC
			inc_m : out STD_LOGIC; -- indica que ha habido un fallo en MC
			inc_w : out STD_LOGIC; -- indica que ha habido una escritura en MC
			inc_r : out STD_LOGIC; -- indica que ha habido una escritura en MC
			inc_cb :out STD_LOGIC; -- indica que ha habido un reemplazo sucio en MC
			-- Gesti�n de errores
			unaligned: in STD_LOGIC; --indica que la direcci�n solicitada por el MIPS no est� alineada
			Mem_ERROR: out std_logic; -- Se activa si en la ultima transferencia el esclavo no respondi� a su direcci�n
			load_addr_error: out std_logic; --para controlar el registro que guarda la direcci�n que caus� error
			-- Gesti�n de los bloques sucios
			send_dirty: out std_logic;-- Indica que hay que enviar la @ del bloque sucio
			Update_dirty	: out  STD_LOGIC; --indica que hay que actualizar los bits dirty tanto por que se ha realizado una escritura, como porque se ha enviado el bloque sucio a memoria
			dirty_bit : in  STD_LOGIC; --indica si el bloque a reemplazar es sucio
			Block_copied_back	: out  STD_LOGIC; -- indica que se ha enviado a memoria un bloque que estaba sucio. Se usa para elegir la m�scara que quita el bit de sucio
			-- Para gestionar las transferencias a trav�s del bus
			bus_TRDY : in  STD_LOGIC; --indica que la memoria puede realizar la operaci�n solicitada en este ciclo
			Bus_DevSel: in  STD_LOGIC; --indica que la memoria ha reconocido que la direcci�n est� dentro de su rango
			Bus_grant :  in  STD_LOGIC; --indica la concesi�n del uso del bus
			MC_send_addr_ctrl : out  STD_LOGIC; --ordena que se env�en la direcci�n y las se�ales de control al bus
            MC_send_data : out  STD_LOGIC; --ordena que se env�en los datos
            Frame : out  STD_LOGIC; --indica que la operaci�n no ha terminado
            last_word : out  STD_LOGIC; --indica que es el �ltimo dato de la transferencia
            Bus_req :  out  STD_LOGIC --indica la petici�n al �rbitro del uso del bus
			);
end UC_MC;

architecture Behavioral of UC_MC is
 
component counter is 
	generic (
	   size : integer := 10
	);
	Port ( clk : in  STD_LOGIC;
	       reset : in  STD_LOGIC;
	       count_enable : in  STD_LOGIC;
	       count : out  STD_LOGIC_VECTOR (size-1 downto 0)
					  );
end component;		           
-- Ejemplos de nombres de estado. No hay que usar estos. Nombrad a vuestros estados con nombres descriptivos. As� se facilita la depuraci�n
type state_type is (Inicio, single_word_transfer_addr, read_block, write_dirty_block, single_word_transfer_data, block_transfer_addr, block_transfer_data, Send_Addr, Send_ADDR_CB, fallo, CopyBack, bajar_Frame, no_cacheable, Dirty_miss, Clean_miss, Dirty_miss_send_data, Trans, Bus_Request); 
type error_type is (memory_error, No_error); 
signal state, next_state : state_type; 
signal error_state, next_error_state : error_type; 
signal last_word_block: STD_LOGIC; --se activa cuando se est� pidiendo la �ltima palabra de un bloque
signal one_word: STD_LOGIC; --se activa cuando s�lo se quiere transferir una palabra
signal count_enable: STD_LOGIC; -- se activa si se ha recibido una palabra de un bloque para que se incremente el contador de palabras
signal hit: std_logic;
signal palabra_UC : STD_LOGIC_VECTOR (1 downto 0);
begin

hit <= hit0 or hit1;	
 
--el contador nos dice cuantas palabras hemos recibido. Se usa para saber cuando se termina la transferencia del bloque y para direccionar la palabra en la que se escribe el dato leido del bus en la MC
word_counter: counter 	generic map (size => 2)
						port map (clk, reset, count_enable, palabra_UC); --indica la palabra actual dentro de una transferencia de bloque (1�, 2�...)

last_word_block <= '1' when palabra_UC="11" else '0';--se activa cuando estamos pidiendo la �ltima palabra

palabra <= palabra_UC;

   State_reg: process (clk)
   begin
      if (clk'event and clk = '1') then
         if (reset = '1') then
            state <= Inicio;
         else
            state <= next_state;
         end if;        
      end if;
   end process;
 
   ---------------------------------------------------------------------------
-- 2023
-- M�quina de estados para el bit de error
---------------------------------------------------------------------------

error_reg: process (clk)
   begin
      if (clk'event and clk = '1') then
         if (reset = '1') then           
            error_state <= No_error;
        else
            error_state <= next_error_state;
         end if;   
      end if;
   end process;
   
--Salida Mem Error
Mem_ERROR <= '1' when (error_state = memory_error) else '0';

--Mealy State-Machine - Outputs based on state and inputs
   
   --MEALY State-Machine - Outputs based on state and inputs
   OUTPUT_DECODE: process (state, hit, last_word_block, bus_TRDY, RE, WE, Bus_DevSel, Bus_grant, via_2_rpl, hit0, hit1, addr_non_cacheable, internal_addr, unaligned)
   begin
			  -- valores por defecto, si no se asigna otro valor en un estado valdr�n lo que se asigna aqu�
	MC_WE0 <= '0';
	MC_WE1 <= '0';
	MC_bus_Rd_Wr <= '0';
	MC_tags_WE <= '0';
    ready <= '0';
    mux_origen <= '0';
    MC_send_addr_ctrl <= '0';
    MC_send_data <= '0';
    next_state <= state;  
	count_enable <= '0';
	Frame <= '0';
	block_addr <= '0';
	inc_m <= '0';
	inc_w <= '0';
	inc_r <= '0';
	inc_cb <= '0';
	Bus_req <= '0';
	one_word <= '0';
	mux_output <= "00";
	last_word <= '0';
	next_error_state <= error_state; 
	load_addr_error <= '0';
	send_dirty <= '0';
	Update_dirty <= '0';
	Block_copied_back <= '0';
		-- ! Importante, la conexion del bus es entre MC, Arbitro, IO Master, Md, Md Scratch asi que la logica de este es cuando exista comunicacion entre estos componentes, entre MIPS y MC no se usa el bus, va directo
		-- ! Además hay una MC especial de Datos que es la MD_Scratch asi que los datos no tienen que ir a MC
		-- ! El bus es Multiplexado, lo que quiere decir que addr y data se envia en la misma linea de manera secuencial 		
		-- ! Las 3 fases de la transferencia son:
		-- ! 	Arbitraje: solicitar bus a traves de BUS_req, y si lo tenemos disponible, el arbitro responde con BUS_grant, si no toca esperar ( volvemos a este estado de la UC)
		-- ! 	Dirección: despues de que bus_grant este activo, comienza la transferencia de datos. Se activa Bus_Frame y se envía la dirección (Bus_addr_data) y ademas el tipo de operación (Bus_Rd_Wr = 0 para lecturas y '1' para escrituras). Si un esclavo identifica esa dirección como suya responde con Bus_DevSel
		-- !    		   Si en el ciclo en el que se envía la dirección, nadie activa devsel, esa dirección se almacena en (ADDR_Error_Reg)  y se activa el MEM_Error, tambien hay errores de tipo acceso no alineado y intento de escritura en ADDR_REG_ERROR
		-- ! 	Datos: 	   Al siguiente ciclo de que se active devsel. Bus_Frame debe seguir a 1 y el servidor avisa si esta listo para la transferencia enviando BUS_TRDY y recibira o enviará un dato por ciclo a través de BUS_Data_Addr hasta que el maestro desactive la señal Bus_Frame. Si en un ciclo no se puede atender, se desactiva bus_trdy y esto indica al maestro que debe esperar.
		-- ! 			   Si el maestro pide la palabra 4, el servidor manda, la 4, la 8, la 12 etc (4 palabras). Cuando se envíe la última palabra, se activará la señal last_word.  Si solo queremos 1 last word se activara ya que es la primera y ultima palabra en transferir
		-- ? He quitado el estado de no cacheable ya que mealy podemos hacerlo en la transicion a inicio.
		-- Estado Inicio          
    if (state = Inicio and RE= '0' and WE= '0') then -- si no piden nada no hacemos nada
		next_state <= Inicio;  -- Por lo tanto el siguiente estado sería el mismo 
		ready <= '1';     -- Y estamos preparados para recibir las operaciones
	elsif (state = Inicio) and ((RE= '1') or (WE= '1')) and  (unaligned ='1') then -- si el procesador quiere leer una direcci�n no alineada
		-- Se procesa el error y se ignora la solicitud
		next_state <= Inicio;  -- Permaneciendo en el mismo estado
		ready <= '1';  -- Admitimos que nos lleguen operaciones
		next_error_state <= memory_error; --�ltima direcci�n incorrecta (no alineada)
		load_addr_error <= '1';
    elsif (state = Inicio and RE= '1' and  internal_addr ='1') then -- si quieren leer un registro de la MC se lo mandamos
    	next_state <= Inicio;
		ready <= '1';
		mux_output <= "00"; -- Completar. "00" es el valor por defecto. �Qu� valor hay que poner?
		next_error_state <= No_error; --Cuando se lee el registro interno el controlador quita la se�al de error
	elsif (state = Inicio and WE= '1' and  internal_addr ='1') then -- si quieren escribir en el registro interno de la MC se genera un error porque es s�lo de lectura
    	next_state <= Inicio;
		ready <= '1';
		next_error_state <= memory_error; --�ltima direcci�n incorrecta (intento de escritura en registro de lectura)
		load_addr_error <= '1';
	elsif (state = Inicio and RE= '1' and  hit='1') then -- si piden leer y es acierto mandamos el dato
        next_state <= Inicio;
		ready <= '1';
		inc_r <= '1'; -- se lee la MC
		mux_output <= "00"; -- ! Como es un acierto en Cache, deberemos dejar 00 ya que es la salida de la cache Completar. "00" es el valor por defecto. �Qu� valor hay que poner?
	elsif (state = Inicio and WE= '1' and  hit='1') then -- si piden escribir y es acierto, actualizamos MC y marcamos el bloque como sucio
        --Completar. Todas las señales están a '0' por defecto. Pensad cuales son los valores correctos
		next_state <= Inicio; -- ? No se si deberá ser inicio puesto que en el siguiente ciclo querremos escribir en MC (asumo que se puede)
		ready <= '1'; --Dado que hemos intentado hacer una escritura y ha sido un hit, en el siguiente ciclo, puede escribir 
		MC_WE0 <= hit0; --activamos la escritura en el banco en el que se ha acertado. 
		MC_WE1 <= hit1; -- ! Como juntamos las 2 señales en 1 pero cada una sigue teniendo su valor, vale con asignar MC_WEX a su correspondiente hit, si ha sido hit0, MC_WE0 valdrá 1 y MC_WE1 valdra 0	
		mux_origen <= '0';-- ! Como la direccion de palabra viene del MIPS se elige 1 
		Update_dirty <= '1' when dirty_bit = '0' else '0'; -- ! Dado que hemos hecho una escritura exitosa, ponemos el bit dirty en 1, en caso de que estuviera a 0
		inc_w <=  '1'; -- como la operaci�n era de escritura incrementamos el contador
	elsif(state = Inicio and hit= '0') then -- ! Tenemos que gestionar un miss o una direccion no cacheable
		next_state <= Bus_Request;  -- Estado al que iremos para gestionar/pedir el bus.
		inc_m  <= '1';  -- Indicamos que ha habido un fallo en la cache al no haber hit (hit = '0')
		Bus_req <= '1';  -- Indicamos al arbitro que queremos el bus. 
	elsif(state = Bus_Request and Bus_grant = '0') then -- En caso de que no nos llegue el bus: 
		next_state <= Bus_Request;  -- Seguimos pidiendo el bus 
		Bus_req <= '1';    -- Y se lo indicamos al árbitro. 
	elsif(state = Bus_Request and Bus_grant = '1') then  -- En caso de que nos den el árbitro:
		next_state <= Trans;  -- comenzamos la trasferencia de datos a la cache llevandolo al estado Trans
		MC_send_addr_ctrl <= '1';  -- Mandamos las direcciones y las señales de control al bus 
		Frame <= '1'; -- Ponemos el Frame a uno mientras todavia tengamos datos que enviar.
	elsif(state = Trans and Bus_DevSel = '0') then 
		next_state <= Inicio;
		Mem_ERROR <= '1';
	elsif(state = Trans and Bus_DevSel = '1' and addr_non_cacheable = '1' and bus_TRDY = '1') then -- ! Asumimos que se puede hacer todo en la transicion de la vuelta a inicio
		next_state  <= Inicio;
		last_word <= '1';
		MC_send_data  <= '1'; 
		Frame <= '1';
		MC_send_data  <=  '1' when WE = '1' else '0';
		mux_output <= "01" when (RE = '1') else "00";
	elsif(state = Trans and Bus_DevSel = '1' and Dirty_bit = '1' and hit = '0') then -- ! Caso de dirty miss
		next_state <= Dirty_miss;
		Frame <= '1';
	elsif(state = Trans and Bus_DevSel = '1' and Dirty_bit = '0' and hit = '0') then -- ! Fallo limpio
		next_state <= Clean_miss;
		Frame   <= '1';
	elsif(state = Clean_miss and bus_TRDY = '0') then
		next_state  <= Clean_miss;
		Frame  <= '1';
	elsif(state = Clean_miss and bus_TRDY = '1') then
		next_state  <=  Clean_miss;
		MC_bus_Rd_Wr  <= '1'; -- ! lo ponemos explicito para tenerlo mas claro (operacion de lectura de la memoria principal)
		MC_tags_WE  <= '1';
		MC_send_data  <= '1';
		Frame  <= '1';
		mux_origen <= '1';
		MC_WE0  <= '1' when (via_2_rpl  = '0') else '0';
		MC_WE1  <= '1' when (via_2_rpl = '1') else '0';
		count_enable  <= '1';
	elsif(state = Clean_miss and bus_TRDY = '1' and last_word_block = '1') then
		next_state  <= Inicio;
		MC_bus_Rd_Wr  <=  '1';
		MC_tags_WE  <= '1';
		MC_send_data <= '1';
		Frame  <= '1'; 
		ready  <= '1';
		MC_WE0  <= '1' when (via_2_rpl  = '0') else '0';
		MC_WE1  <= '1' when (via_2_rpl = '1') else '0';
		count_enable  <= '1';
		mux_origen  <= '1';
		last_word  <= '1'; -- ! Como es la ultima palabra avisamos 
	elsif(state = Dirty_miss and bus_TRDY = '1') then
		next_state  <= Dirty_miss_send_data;
		send_dirty  <= '1'; -- ! Mandamos a MP la dirección del bloque sucio
		Frame  <= '1'; -- ! Seguimos usando el bus
	elsif(state  = Dirty_miss_send_data and bus_TRDY = '1') then
		next_state  <= Bus_Request;
		MC_send_data  <= '1';
		Frame  <= '1';
		Update_dirty  <= '1';  
	elsif(state = Dirty_miss_send_data and bus_TRDY = '1' and last_word_block = '1') then
		next_state  <= Clean_miss;
		MC_send_data  <= '1';
		Frame  <= '1';
		Block_copied_back  <= '1';
		Update_dirty  <= '1';
		last_word <= '1';
		inc_cb <= '1';
	-- ! Casos de espera (cuando TRGT_ready sea 0)
	elsif(state = Dirty_miss and bus_TRDY = '0') then
		next_state  <= Dirty_miss;
		Frame  <= '1';
	elsif(state = Dirty_miss_send_data and bus_TRDY = '0') then
		next_state  <=  Dirty_miss_send_data;
		Frame  <= '1';
	elsif(state = Clean_miss and bus_TRDY = '1') then
		next_state <= Clean_miss;
		Frame  <= '1';
	elsif(state = Trans and Bus_DevSel = '1' and addr_non_cacheable = '1' and bus_TRDY = '0') then
		next_state <= Trans;
		Frame <= '1';

	--Completar. �Qu� m�s hay que hacer en INICIO?. 
	--Completar. �Qu� m�s estados ten�is?. 
------------------------------------------------------------------------------------------------------------------------
--�C�mo desarrollar esta UC?
-- Id paso a paso. Incluid primero la gesti�n de los aciertos y fallos de lectura. El primero est� ya casi hecho. El segundo implica pedir el bus, cuando os lo den, enviar la direcci�n del bloque,
-- comprobar que el server responde a la direcci�n, recibir las cuatro palabras a trav�s del bus y escribirlas en MC. 
-- Cuando funcionen las lecturas vamos a�adiendo funcionalidades, prob�ndolas: fallo y acierto de esritura, reemplazo sucio, acceso a MDS en lectura y escritura, gesti�n del abort y acceso al registro interno de la MC
-- Os damos un banco de pruebas inicial para los fallos y aciertos de lectura. Dise�ad los vuestros para el resto de casos. 	
							
	end if;
		
   end process;
 
   
end Behavioral;

