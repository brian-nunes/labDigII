--------------------------------------------------------------------
-- Arquivo   : gerador_pulso.vhd
-- Projeto   : Experiencia 4 - Interface com sensor de distancia
--------------------------------------------------------------------
-- Descricao : gera pulso de saida com largura pulsos de clock 
--
--             1) descricao na forma de uma maquina de estados
-- 
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     19/09/2021  1.0     Edson Midorikawa  versao inicial
--------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exp4_sensor is
   port (
      clock: in std_logic;
      reset: in std_logic;
      medir: in std_logic;
      echo: in std_logic;
      trigger: out std_logic;
      hex0: out std_logic_vector(6 downto 0);
      hex1: out std_logic_vector(6 downto 0);
      hex2: out std_logic_vector(6 downto 0);
      pronto: out std_logic;
      db_trigger: out std_logic;
      db_echo: out std_logic;
      db_estado: out std_logic_vector(6 downto 0)
   );
  end entity exp4_sensor;

architecture exp4_sensor_arch of exp4_sensor is

   component hex7seg
      port (
          hexa : in  std_logic_vector(3 downto 0);
          sseg : out std_logic_vector(6 downto 0)
      );
   end component;

   component edge_detector
      port ( 
         clk         : in   std_logic;
         signal_in   : in   std_logic;
         output      : out  std_logic
      );
   end component;
  
   component interface_hcsr04
      port (
        clock, reset: in  std_logic;
        medir:        in  std_logic;
        echo:         in  std_logic;
        trigger:      out std_logic;
        medida:       out std_logic_vector(11 downto 0);
        pronto:       out std_logic;
        db_estado:    out std_logic_vector(3 downto 0)
      );
   end component;

   signal s_medir, s_echo, s_trigger, s_pronto: std_logic;
   signal s_db_estado_4: std_logic_vector(3 downto 0);
   signal s_db_estado_7, s_unidade_7, s_dezena_7, s_centena_7: std_logic_vector(6 downto 0);
   signal s_medida: std_logic_vector(11 downto 0);

begin
   s_echo <= echo;

   detector_borda: edge_detector port map (clock, medir, s_medir);

   interface_sensor: interface_hcsr04 port map (clock, reset, s_medir, s_echo, s_trigger, s_medida, s_pronto, s_db_estado_4);

   display_unidade: hex7seg port map (s_medida(3 downto 0), s_unidade_7);

   display_dezena: hex7seg port map (s_medida(7 downto 4), s_dezena_7);

   display_centena: hex7seg port map (s_medida(11 downto 8), s_centena_7);

   hex0 <= s_unidade_7;
   hex1 <= s_dezena_7;
   hex2 <= s_centena_7;
   db_estado <= s_db_estado_7;
   pronto <= s_pronto;
   trigger <= s_trigger;
   db_trigger <= s_trigger;
   db_echo <= s_echo;

end exp4_sensor_arch;

