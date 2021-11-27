library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_dados_gaiola_fd is
    port(
        clock, reset, transmitir:     in  std_logic;
        estado:                       in  std_logic_vector(3 downto 0); -- digitos BCD

        distancia_interna2:                   in std_logic_vector(3 downto 0); -- e de distancia
        distancia_interna1:                   in std_logic_vector(3 downto 0);
        distancia_interna0:                   in std_logic_vector(3 downto 0);

        distancia_porta2:                   in std_logic_vector(3 downto 0); -- e de distancia
        distancia_porta1:                   in std_logic_vector(3 downto 0);
        distancia_porta0:                   in std_logic_vector(3 downto 0);
        seletor_dado:                 in  std_logic_vector(3 downto 0);

        recepcao_serial:               in std_logic;
        dado_recebido_rx : out std_logic_vector(7 downto 0);
        pronto_rx : out std_logic;

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

    signal saida_mux, s_id1, s_id2, s_traco, s_estado, s_distancia_interna2, s_distancia_interna1, s_distancia_interna0, s_distancia_porta2, s_distancia_porta1, s_distancia_porta0, s_ponto: std_logic_vector(7 downto 0);
    signal caractere : std_logic_vector(7 downto 0);
    signal const_0011: std_logic_vector(3 downto 0) := "0011";
    signal s_recepcao_serial, s_receber : std_logic;
    -- signal rx_serial_pino: std_logic := '0';
begin

    s_id1 <= const_0011 & "0000";
    s_id2 <= const_0011 & "0001";

    s_traco <= "00101101";

    s_estado <= const_0011 & estado;

    s_distancia_interna2 <= const_0011 & distancia_interna2;
    s_distancia_interna1 <= const_0011 & distancia_interna1;
    s_distancia_interna0 <= const_0011 & distancia_interna0;

    s_distancia_porta2 <= const_0011 & distancia_porta2;
    s_distancia_porta1 <= const_0011 & distancia_porta1;
    s_distancia_porta0 <= const_0011 & distancia_porta0;

    s_ponto <= "00101110";

    with seletor_dado select
      caractere <= s_id1        when "0000",
                   s_id2        when "0001",

                   s_traco      when "0010",

                   s_estado     when "0011",

                   s_distancia_interna2 when "0100",
                   s_distancia_interna1 when "0101",
                   s_distancia_interna0 when "0110",

                   s_distancia_porta2 when "0111",
                   s_distancia_porta1 when "1000",
                   s_distancia_porta0 when "1001",

                   s_ponto      when "1010",
                   s_ponto      when others;

    s_recepcao_serial <= recepcao_serial;
    s_receber <= '1'; -- Sempre está recebendo dados

    comunicacao_serial: uart_8N2 port map (clock, reset, transmitir, caractere, s_recepcao_serial, s_receber, saida_serial, fim_transmissao, dado_recebido_rx, open, open, open, open, open, open, open, open);

end architecture;
