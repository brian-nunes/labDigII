LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY gaiola_com_display IS
  PORT(
    clock, reset : IN STD_LOGIC;
    armar, desarmar : IN STD_LOGIC;
    echo : IN STD_LOGIC;
    trigger : OUT STD_LOGIC;
    pwm : OUT STD_LOGIC;
    saida_serial : OUT STD_LOGIC;
    display_estado : OUT STD_LOGIC_VECTOR(6 downto 0);
    display_distancia2 : OUT STD_LOGIC_VECTOR(6 downto 0);
    display_distancia1 : OUT STD_LOGIC_VECTOR(6 downto 0);
    display_distancia0 : OUT STD_LOGIC_VECTOR(6 downto 0)
  );
END ENTITY;

ARCHITECTURE gaiola_com_display_arch OF gaiola_com_display IS

  COMPONENT gaiola IS
  PORT(
    clock, reset : IN STD_LOGIC;
    armar, desarmar : IN STD_LOGIC;
    echo : IN STD_LOGIC;
    trigger : OUT STD_LOGIC;
    pwm : OUT STD_LOGIC;
    saida_serial : OUT STD_LOGIC;
    db_estado : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    db_distancia: OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
  );
  END COMPONENT;

  COMPONENT hex7seg IS
  PORT(
    hexa : IN  STD_LOGIC_VECTOR(3 downto 0);
    sseg : OUT STD_LOGIC_VECTOR(6 downto 0)
  );
  END COMPONENT;

  SIGNAL s_db_estado : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL s_db_distancia : STD_LOGIC_VECTOR(11 DOWNTO 0);

BEGIN

  comp_gaiola : gaiola PORT MAP(clock, reset, armar, desarmar, echo, trigger, pwm, saida_serial, s_db_estado, s_db_distancia);

  hex_estado : hex7seg PORT MAP(s_db_estado, display_estado);

  hex_distancia2 : hex7seg PORT MAP(s_db_distancia(11 DOWNTO 8), display_distancia2);

  hex_distancia1 : hex7seg PORT MAP(s_db_distancia(7 DOWNTO 4), display_distancia1);

  hex_distancia0 : hex7seg PORT MAP(s_db_distancia(3 DOWNTO 0), display_distancia0);

END ARCHITECTURE;
