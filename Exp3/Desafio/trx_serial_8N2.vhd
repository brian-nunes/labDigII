library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity trx_serial_8N2 is
  port(
    clock:         in  std_logic;
    reset:         in  std_logic;
    partida:       in  std_logic;
    recebe_dado:   in  std_logic;
    dados_ascii:   in  std_logic_vector (7 downto 0);
    dado_enviado_pronto:  out std_logic;
    dado_recebido_pronto: out std_logic;
    dado_recebido: out std_logic_vector(7 downto 0);
  );
end entity;

architecture trx_serial_8N2_arch of trx_serial_8N2 is

  component rx_serial_8N2 is
    port(
      clock:         in  std_logic;
      reset:         in  std_logic;
      dado_serial:   in  std_logic;
      recebe_dado:   in  std_logic;
      pronto_rx:     out std_logic;
      tem_dado:      out std_logic;
      dado_recebido: out std_logic_vector(7 downto 0);
      db_estado:     out std_logic_vector(6 downto 0)
    );
  end component;

  component tx_serial_8N2 is
    port (
        clock, reset, partida: in  std_logic;
        dados_ascii:           in  std_logic_vector (7 downto 0);
        saida_serial, pronto : out std_logic
    );
  end component;

  signal s_saida_serial: std_logic; -- saida serial entre transmissor e receptor

  begin

    transmissor: tx_serial_8N2 port map(clock, reset, partida, dados_ascii, s_saida_serial, dado_enviado_pronto);

    receptor: rx_serial_8N2 port map(clock, reset, s_saida_serial, recebe_dado, open, dado_recebido_pronto, dado_recebido, open);

end architecture;
