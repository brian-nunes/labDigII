library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity uart_8N2 is
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
end entity;

architecture uart_8N2_arch of uart_8N2 is

    component tx_serial_8N2
        port (
            clock, reset, partida: in  std_logic;
            dados_ascii:           in  std_logic_vector (7 downto 0);
            saida_serial, pronto_tx : out std_logic;
            db_estado:     out std_logic_vector(3 downto 0)
        );
    end component;

    component rx_serial_8N2
        port(
          clock:         in  std_logic;
          reset:         in  std_logic;
          dado_serial:   in  std_logic;
          recebe_dado:   in  std_logic;
          pronto_rx:     out std_logic;
          tem_dado:      out std_logic;
          dado_recebido: out std_logic_vector(7 downto 0);
          db_estado:     out std_logic_vector(3 downto 0)
        );
      end component;

      signal s_transmite_dado, s_saida_serial, s_recebe_dado, s_dado_serial, s_pronto_rx, s_tem_dado: std_logic;
      signal s_dado: std_logic_vector(7 downto 0);

begin

    s_transmite_dado <= transmite_dado;
    s_recebe_dado <= recebe_dado;
    s_dado_serial <= dado_serial;

    receptor: rx_serial_8N2 port map (clock, reset, s_dado_serial, s_recebe_dado, s_pronto_rx, s_tem_dado, s_dado, db_estado_rx);

    transmissor: tx_serial_8N2 port map (clock, reset, s_tem_dado, s_dado, s_saida_serial, pronto_tx, db_estado_tx);

    saida_serial <= s_saida_serial;
    pronto_rx <= s_pronto_rx;
    db_transmite_dado <= s_transmite_dado;
    db_saida_serial <= s_saida_serial;
    db_recebe_dado <= s_recebe_dado;
    db_dado_serial <= s_dado_serial;

end architecture;