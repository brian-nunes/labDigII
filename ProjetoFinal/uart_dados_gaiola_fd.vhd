library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_dados_gaiola_fd is
    port(
        clock, reset, transmitir:     in  std_logic;
        estado:                       in  std_logic_vector(3 downto 0); -- digitos BCD
        distancia2:                   in  std_logic_vector(3 downto 0); -- e de distancia
        distancia1:                   in  std_logic_vector(3 downto 0);
        distancia0:                   in  std_logic_vector(3 downto 0);
        seletor_dado:                 in  std_logic_vector(1 downto 0);
        fim_transmissao:              out std_logic;
        saida_serial:                 out std_logic
    );
end entity;

architecture uart_dados_gaiola_fd_arch of uart_dados_gaiola_fd is
     
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

    component mux_4x1_n
        generic (
            constant BITS: integer := 4
        );
        port ( 
            D0 :     in  std_logic_vector (BITS-1 downto 0);
            D1 :     in  std_logic_vector (BITS-1 downto 0);
            D2 :     in  std_logic_vector (BITS-1 downto 0);
            D3 :     in  std_logic_vector (BITS-1 downto 0);
            SEL:     in  std_logic_vector (1 downto 0);
            MUX_OUT: out std_logic_vector (BITS-1 downto 0)
        );
    end component;

    signal saida_mux, s_estado, s_distancia2,  s_distancia1, s_distancia0: std_logic_vector(7 downto 0);
    signal const_001: std_logic_vector(3 downto 0) := "0011";
    signal rx_serial_pino: std_logic := '0';
begin

    s_estado <= const_001 & estado;

    s_distancia2 <= const_001 & distancia2;
    s_distancia1 <= const_001 & distancia1;
    s_distancia0 <= const_001 & distancia0;

    mux: mux_4x1_n generic map (BITS => 8) port map (s_estado, s_distancia2, s_distancia1, s_distancia0, seletor_dado, saida_mux);

    transmissor: uart_8N2 port map (clock, reset, transmitir, saida_mux, rx_serial_pino, rx_serial_pino, saida_serial, fim_transmissao, open, open, open, open, open, open, open, open, open);
    
end architecture;

