library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity tx_dados_sonar is
    port (
        clock: in std_logic;
        reset: in std_logic;
        transmitir: in std_logic;
        angulo2: in std_logic_vector(3 downto 0); -- digitos BCD
        angulo1: in std_logic_vector(3 downto 0); -- de angulo
        angulo0: in std_logic_vector(3 downto 0);
        distancia2: in std_logic_vector(3 downto 0); -- e de distancia
        distancia1: in std_logic_vector(3 downto 0);
        distancia0: in std_logic_vector(3 downto 0);
        saida_serial: out std_logic;
        pronto: out std_logic;
        db_transmitir: out std_logic;
        db_saida_serial: out std_logic;
        db_estado: out std_logic_vector(3 downto 0)
    );
end entity;
   
architecture tx_dados_sonar_arch of tx_dados_sonar is
    component tx_dados_sonar_uc
        port(
          clock, reset, trasmitir, fim_transmissao: in  std_logic;
          pronto:                                   out std_logic;
          seletor_dado:                             out std_logic_vector(2 downto 0);
          db_estado:                                out std_logic_vector(3 downto 0)
        );
    end component;

    component tx_dados_sonar_fd
        port(
          clock, reset, trasmitir:      in  std_logic;
          angulo2:                      in std_logic_vector(3 downto 0); -- digitos BCD
          angulo1:                      in std_logic_vector(3 downto 0); -- de angulo
          angulo0:                      in std_logic_vector(3 downto 0);
          distancia2:                   in std_logic_vector(3 downto 0); -- e de distancia
          distancia1:                   in std_logic_vector(3 downto 0);
          distancia0:                   in std_logic_vector(3 downto 0);
          seletor_dado:                 in std_logic_vector(2 downto 0);
          fim_transmissao:              out  std_logic;
          saida_serial:                 out  std_logic
        );
    end component;

    signal s_transmitir, s_fim_transmissao, s_saida_serial: std_logic;
    signal s_seletor_dado: std_logic_vector(2 downto 0);
begin
    s_transmitir <= transmitir;

    UC: tx_dados_sonar_uc port map (clock, reset, s_transmitir, s_fim_transmissao, pronto, s_seletor_dado, db_estado)

    FD: tx_dados_sonar_fd port map (clock, reset, s_transmitir, angulo2, angulo1, angulo0, distancia2, distancia1, distancia0, s_seletor_dado, s_fim_transmissao, s_saida_serial)

    saida_serial <= s_saida_serial;
    db_saida_serial <= saida_serial;
    db_transmitir <= s_transmitir;
end architecture;