library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity interface_hcsr04_fd is
  port(
    clock, reset, conta, registra, gera: in  std_logic;
    medida:                              out std_logic_vector(11 downto 0);
    trigger:               out std_logic
  );
end entity;

architecture interface_hcsr04_fd_arch of interface_hcsr04_fd is

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

  component contador_bcd_4digitos
    port (
      clock, zera, conta:     in  std_logic;
      dig3, dig2, dig1, dig0: out std_logic_vector(3 downto 0);
      fim:                    out std_logic
    );
  end component;

  component gerador_pulso
    generic (
       largura: integer:= 25
    );
    port(
       clock:  in  std_logic;
       reset:  in  std_logic;
       gera:   in  std_logic;
       para:   in  std_logic;
       pulso:  out std_logic;
       pronto: out std_logic
    );
  end component;

  -- Sinais
  signal s_gera, s_conta, s_trigger, s_registra, s_conta_centimetro: std_logic;
  signal s_medida, s_medida_interno: std_logic_vector(11 downto 0);

  begin
    s_gera <= gera;
    s_registra <= registra;
    s_conta <= conta;

    gerador_pulso_20us: gerador_pulso generic map (largura => 500) port map (clock, reset, s_gera, '0', s_trigger, open);

    registrador: registrador_n generic map(N => 12) port map(clock, reset, s_registra, s_medida_interno, s_medida);

    contagem_centimetros: contador_bcd_4digitos port map (clock, reset, s_conta_centimetro, open, s_medida_interno(11 downto 8), s_medida_interno(7 downto 4), s_medida_interno(3 downto 0), open);

    contador: contadorg_m generic map(M => 2940) port map(clock, reset, reset, s_conta, open, s_conta_centimetro, open);

    trigger <= s_trigger;
    medida <= s_medida;
end architecture;
