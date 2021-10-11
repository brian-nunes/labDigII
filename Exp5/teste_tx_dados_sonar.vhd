library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity teste_tx_dados_sonar is
    port (
        clock: in std_logic;
        reset: in std_logic;
        transmitir: in std_logic;
        saida_serial: out std_logic;
        pronto: out std_logic;
        db_transmitir: out std_logic;
        db_saida_serial: out std_logic;
        db_estado: out std_logic_vector(3 downto 0)
    );
end entity;
   
architecture teste_tx_dados_sonar_arch of teste_tx_dados_sonar is

    component tx_dados_sonar
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
    end component;

    component edge_detector
        port (
            clk         : in   std_logic;
            signal_in   : in   std_logic;
            output      : out  std_logic
        );
    end component;

    signal transmitir_detected: std_logic;

begin

    dados_sonar: tx_dados_sonar port map (clock, reset, transmitir_detected, "0110111", "0110101", "0110001", "0110111", "0110001", "0110000", saida_serial, pronto, db_transmitir, db_saida_serial, db_estado);

    detector_borda: edge_detector port map (clock, transmitir, transmitir_detected);

end architecture;