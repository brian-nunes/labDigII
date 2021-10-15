library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_dados_sonar_fd is
    port(
        clock, reset, transmitir:     in  std_logic;
        angulo2:                      in std_logic_vector(3 downto 0); -- digitos BCD
        angulo1:                      in std_logic_vector(3 downto 0); -- de angulo
        angulo0:                      in std_logic_vector(3 downto 0);
        distancia2:                   in std_logic_vector(3 downto 0); -- e de distancia
        distancia1:                   in std_logic_vector(3 downto 0);
        distancia0:                   in std_logic_vector(3 downto 0);
        seletor_dado:                 in std_logic_vector(2 downto 0);
        fim_transmissao:              out  std_logic;
        saida_serial:                 out  std_logic
    );
end entity;

architecture tx_dados_sonar_fd_arch of tx_dados_sonar_fd is
     
    component uart_8N2
        port (
            clock : in std_logic;
            reset : in std_logic;
            transmite_dado : in std_logic;
            dados_ascii : in std_logic_vector(7 downto 0);
            dado_serial : in std_logic;
            recebe_dado : in std_logic;
            saida_serial : out std_logic;
            pronto_tx : out std_logic;
            dado_recebido_rx : out std_logic_vector(7 downto 0);
            tem_dado : out std_logic;
            pronto_rx : out std_logic;
            db_transmite_dado : out std_logic;
            db_saida_serial : out std_logic;
            db_estado_tx : out std_logic_vector(3 downto 0);
            db_recebe_dado : out std_logic;
            db_dado_serial : out std_logic;
            db_estado_rx : out std_logic_vector(3 downto 0)
        );
    end component;

    component mux_8x1_n
        generic (
            constant BITS: integer := 4
        );
        port ( 
            D0 :     in  std_logic_vector (BITS-1 downto 0);
            D1 :     in  std_logic_vector (BITS-1 downto 0);
            D2 :     in  std_logic_vector (BITS-1 downto 0);
            D3 :     in  std_logic_vector (BITS-1 downto 0);
            D4 :     in  std_logic_vector (BITS-1 downto 0);
            D5 :     in  std_logic_vector (BITS-1 downto 0);
            D6 :     in  std_logic_vector (BITS-1 downto 0);
            D7 :     in  std_logic_vector (BITS-1 downto 0);
            SEL:     in  std_logic_vector (2 downto 0);
            MUX_OUT: out std_logic_vector (BITS-1 downto 0)
        );
    end component;

    signal saida_mux, s_angulo2,  s_angulo1, s_angulo0, s_distancia2,  s_distancia1, s_distancia0, virgula, ponto: std_logic_vector(7 downto 0);
    signal const_001: std_logic_vector(3 downto 0);
    signal rx_serial_pino: std_logic;
begin
    const_001 <= "0011";

    s_angulo2 <= const_001 & angulo2;
    s_angulo1 <= const_001 & angulo1;
    s_angulo0 <= const_001 & angulo0;

    s_distancia2 <= const_001 & distancia2;
    s_distancia1 <= const_001 & distancia1;
    s_distancia0 <= const_001 & distancia0;

    virgula <= "00101100";
    ponto <="00101110";

    rx_serial_pino <= '0';

    mux: mux_8x1_n generic map (BITS => 8) port map (s_angulo0, s_angulo1, s_angulo2, virgula, s_distancia0, s_distancia1, s_distancia2, ponto, seletor_dado, saida_mux);

    transmissor: uart_8N2 port map (clock, reset, transmitir, saida_mux, rx_serial_pino, rx_serial_pino, saida_serial, fim_transmissao, open, open, open, open, open, open, open, open, open);
    
end architecture;

