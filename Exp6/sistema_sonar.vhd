library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity sistema_sonar is
  port(
    clock, reset, ligar, echo: in std_logic;
    seletor_depurador: in std_logic_vector(1 downto 0);
    trigger, pwm, saida_serial, alerta_proximidade: out std_logic;
    hex0, hex1, hex2, hex3, hex4, hex5 : out std_logic_vector(6 downto 0)
  );
end entity;

architecture sistema_sonar_arch of sistema_sonar is

  component sonar is
    port(
      clock, reset, ligar, echo: in std_logic;
      seletor_depurador: in std_logic_vector(1 downto 0);
      trigger, pwm, saida_serial, alerta_proximidade: out std_logic;
      depurador: out std_logic_vector(23 downto 0)
    );
  end component;

  component hex7seg is
    port(
      hexa : in  std_logic_vector(3 downto 0);
      sseg : out std_logic_vector(6 downto 0)
    );
  end component;

  signal s_depurador : std_logic_vector(23 downto 0);

begin

  sonar_component : sonar port map(clock, reset, ligar, echo, seletor_depurador, trigger, pwm, saida_serial, alerta_proximidade, s_depurador);

  display_0 : hex7seg port map(s_depurador(3 downto 0), hex0);

  display_1 : hex7seg port map(s_depurador(7 downto 4), hex1);

  display_2 : hex7seg port map(s_depurador(11 downto 8), hex2);

  display_3 : hex7seg port map(s_depurador(15 downto 12), hex3);

  display_4 : hex7seg port map(s_depurador(19 downto 16), hex4);

  display_5 : hex7seg port map(s_depurador(23 downto 20), hex5);

end architecture;
