------------------------------------------------------------------
-- Arquivo   : tx_serial_tb.vhd
-- Projeto   : Experiencia 2 - Transmissao Serial Assincrona
------------------------------------------------------------------
-- Descricao : circuito da experiencia 2 
--             > modelo de testbench para simulacao do circuito
--             > de transmissao serial assincrona
--             > 
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial
------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_serial_tb is
end entity;

architecture tb of tx_serial_tb is
  
  -- Componente a ser testado (Device Under Test -- DUT)
  component tx_serial_7E2
    port (
        clock, reset, partida: in  std_logic;
        dados_ascii:           in  std_logic_vector (6 downto 0);
        saida_serial, pronto : out std_logic
    );
  end component;
  
  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (ModelSim)
  signal clock_in: std_logic := '0';
  signal reset_in: std_logic := '0';
  signal partida_in: std_logic := '0';
  signal dados_ascii_7_in: std_logic_vector (6 downto 0) := "0000000";
  -- signal dados_ascii_8_in: std_logic_vector (7 downto 0) := "00000000";
  signal saida_serial_out: std_logic := '1';
  signal pronto_out: std_logic := '0';

  -- Configurações do clock
  signal keep_simulating: std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod : time := 20 ns;     -- clock de 50MHz
  
begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;
  
  -- Conecta DUT (Device Under Test)
  dut: tx_serial_7E2
       port map
       ( 
           clock=>          clock_in,
           reset=>          reset_in,
           partida=>        partida_in,
           dados_ascii=>    dados_ascii_7_in,
           saida_serial=>   saida_serial_out,
           pronto=>         pronto_out
      );

  -- geracao dos sinais de entrada (estimulos)
  stimulus: process is
  begin
  
    assert false report "Inicio da simulacao" severity note;
    keep_simulating <= '1';
    
    ---- inicio da simulacao: reset ----------------
    partida_in <= '0';
    reset_in <= '1'; 
    wait for 20*clockPeriod;  -- pulso com 20 periodos de clock
    reset_in <= '0';
    wait until falling_edge(clock_in);
    wait for 50*clockPeriod;

    ---- dado de entrada da simulacao (caso de teste #1)
    dados_ascii_7_in <= "0110101"; -- x35 = '5'	
    wait for 20*clockPeriod;

    ---- acionamento da partida (inicio da transmissao)
    partida_in <= '1';
    wait until rising_edge(clock_in);
    wait for 5*clockPeriod; -- pulso partida com 5 periodos de clock
    partida_in <= '0';

    ---- espera final da transmissao (pulso pronto em 1)
	wait until pronto_out='1';
	
	---- final do caso de teste 1

    -- intervalo entre casos de teste
    wait for 5000*clockPeriod;

    ---- dado de entrada da simulacao (caso de teste #2)
    dados_ascii_7_in <= "1110101"; -- x75 = 'u'	
    wait for 20*clockPeriod;

    ---- acionamento da partida (inicio da transmissao)
    partida_in <= '1';
    wait until rising_edge(clock_in);
    wait for 5*clockPeriod; -- pulso partida com 5 periodos de clock
    partida_in <= '0';

    ---- espera final da transmissao (pulso pronto em 1)
    wait until pronto_out='1';
    
    ---- final do caso de teste 2

    -- intervalo entre casos de teste
    wait for 5000*clockPeriod;
	
    ---- dado de entrada da simulacao (caso de teste #3)
    dados_ascii_7_in <= "1010100"; -- x54 = 'T'	
    wait for 20*clockPeriod;

    ---- acionamento da partida (inicio da transmissao)
    partida_in <= '1';
    wait until rising_edge(clock_in);
    wait for 5*clockPeriod; -- pulso partida com 5 periodos de clock
    partida_in <= '0';

    ---- espera final da transmissao (pulso pronto em 1)
    wait until pronto_out='1';
    
    ---- final do caso de teste 3

    -- intervalo entre casos de teste
    wait for 5000*clockPeriod;

    ---- dado de entrada da simulacao (caso de teste #4)
    dados_ascii_7_in <= "1001011"; -- x4B = 'k'	
    wait for 20*clockPeriod;

    ---- acionamento da partida (inicio da transmissao)
    partida_in <= '1';
    wait until rising_edge(clock_in);
    wait for 5*clockPeriod; -- pulso partida com 5 periodos de clock
    partida_in <= '0';

    ---- espera final da transmissao (pulso pronto em 1)
    wait until pronto_out='1';
    
    ---- final do caso de teste 4

    ---- final dos casos de teste da simulacao
    assert false report "Fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: aguarda indefinidamente
  end process;


end architecture;
