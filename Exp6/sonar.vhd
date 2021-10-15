library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity sonar is
    port(
        clock, reset, ligar, echo: in std_logic;
        trigger, pwm, saida_serial, alerta_proximidade: out std_logic
    );
end entity;

architecture sonar_arch of sonar is
    component sonar_uc
        port(
          clock, reset, ligar, fim_movimentacao, fim_medir, fim_transmissao:        in  std_logic;
          move, mede, transmite:            out std_logic;
          db_estado:                  out std_logic_vector(3 downto 0)
        );
    end component;

    component sonar_fd
        port(
            clock, reset, echo, medir, move, transmitir:     in  std_logic;
            depurador:     in  std_logic_vector(1 downto 0);
            pwm, saida_serial, trigger, fim_medir, fim_transmissao, fim_mover, alerta_proximidade:      out  std_logic
        );
    end component;

    signal s_fim_movimentacao, s_fim_medir, s_fim_transmissao, s_move, s_mede, s_transmite: std_logic;
begin

    UC: sonar_uc port map(clock, reset, ligar, s_fim_movimentacao, s_fim_medir, s_fim_transmissao, s_move, s_mede, s_transmite, open);

    FD: sonar_fd port map(clock, reset, echo, s_mede, s_move, s_transmite, open, pwm, saida_serial, trigger, s_fim_medir, s_fim_transmissao, s_fim_movimentacao, alerta_proximidade);

end architecture;