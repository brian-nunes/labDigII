-- Circuito Receptor Serial Assíncrono - 8N2

--TODO: mudar nome de "fim" e "recebe_dado" (nomes meio merda)
--      revisar código e fazer melhorias + ajustar estilo

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity rx_serial_8N2 is
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
end entity;

architecture rx_serial_8N2_arch of rx_serial_8N2 is

  component rx_serial_tick_uc
    port(
      clock, dado_serial, reset, tick, fim, recebe_dado: in  std_logic;
      carrega, desloca, limpa, registra, zera, conta, pronto, tem_dado:    out std_logic;
      db_estado:                                         out std_logic_vector(3 downto 0)
    );
  end component;

  component rx_serial_8N2_fd
    port(
      clock, reset, carrega, desloca, limpa, registra, zera, conta: in  std_logic;
      dado_serial:                                                  in  std_logic;
      dado_recebido:                                                out std_logic_vector(7 downto 0);
      fim:                                                          out std_logic
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

  component hex7seg
    port(
      hexa : in  std_logic_vector(3 downto 0);
      sseg : out std_logic_vector(6 downto 0)
    );
  end component;

  signal s_reset, s_recebe_dado: std_logic;                                     -- sinais recebidos pelo Circuito Principal
  signal s_tick, s_fim: std_logic;                                              -- sinais recebidos pela UC
  signal s_carrega, s_desloca, s_limpa, s_registra, s_zera, s_conta: std_logic; -- sinais recebidos pelo FD
  signal s_estado: std_logic_vector(3 downto 0);                                -- sinais recebidos pelo Display

  begin

    s_reset <= reset;
    s_recebe_dado <= recebe_dado;

    Unidade_Controle: rx_serial_tick_uc port map(clock, dado_serial, s_reset, s_tick, s_fim, s_recebe_dado, s_carrega,
                                                  s_desloca, s_limpa, s_registra, s_zera, s_conta, pronto_rx, tem_dado, s_estado);

    Fluxo_Dados: rx_serial_8N2_fd port map(clock, s_reset, s_carrega, s_desloca, s_limpa, s_registra, s_zera, s_conta,
                                            dado_serial, dado_recebido, s_fim);

    Contador_Ticks: contadorg_m generic map(M => 5208) port map(clock, s_reset, s_zera, '1', open, open, s_tick);

    Display_Hexa: hex7seg port map(s_estado, db_estado);
end architecture;
