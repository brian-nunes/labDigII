library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity rx_serial_8N2_fd is
  port(
    clock, reset, carrega, desloca, limpa, registra, zera, conta: in  std_logic;
    dado_serial:                                                  in  std_logic;
    dado_recebido:                                                out std_logic_vector(7 downto 0);
    fim:                                                          out std_logic
  );
end entity;

architecture rx_serial_8N2_fd_arch of rx_serial_8N2_fd is

  component registrador_deslocamento_n
    generic(
      constant N: integer := 11 -- Número de bits a serem registrados
    );
    port(
      clock, reset:                     in  std_logic;
      carrega, desloca, entrada_serial: in  std_logic;
      dados:                            in  std_logic_vector (N-1 downto 0);
      saida:                            out std_logic_vector (N-1 downto 0)
    );
  end component;

  component registrador_n
    generic (
       constant N: integer := 8 -- Número de bits a serem registrados
    );
    port (
       clock:  in  std_logic;
       clear:  in  std_logic;
       enable: in  std_logic;
       D:      in  std_logic_vector (N-1 downto 0);
       Q:      out std_logic_vector (N-1 downto 0)
    );
  end component;

  component contadorg_m
    generic (
        constant M: integer := 50 -- modulo do contador
    );

    port(
      clock, zera_as, zera_s, conta: in std_logic;
      Q: out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
      fim, meio: out std_logic
    );
  end component;

  -- Sinais
  signal s_dados, s_saida: std_logic_vector(10 downto 0);

  begin

    s_dados <= (others => '1');

    Registrador_Deslocamento: registrador_deslocamento_n generic map(N => 11) port map(clock, reset, carrega, desloca, dado_serial, s_dados,
                                                                                       s_saida);

    Registrador: registrador_n generic map(N => 8) port map(clock, limpa, registra, s_saida(9 downto 2),
                                                            dado_recebido);

    Contador_Bits: contadorg_m generic map(M => 11) port map(clock, reset, zera, conta,
                                                             open, fim, open);

end architecture;
