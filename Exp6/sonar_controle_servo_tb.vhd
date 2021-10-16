library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity sonar_controle_servo_tb is
end entity;

architecture tb_servo of sonar_controle_servo_tb is

  component sonar is
    port(
      clock, reset, ligar, echo: in std_logic;
      seletor_depurador: in std_logic_vector(1 downto 0);
      trigger, pwm, saida_serial, alerta_proximidade: out std_logic;
      depurador: out std_logic_vector(23 downto 0)
    );
  end component;

  signal clock_in, reset_in, ligar_in, echo_in : std_logic := '0';
  signal seletor_depurador_in : std_logic_vector(1 downto 0) := "00";
  signal trigger_out, pwm_out, saida_serial_out, alerta_proximidade_out : std_logic;
  signal depurador_out : std_logic_vector(23 downto 0);

  signal keep_simulating: std_logic := '0';
  constant clockPeriod: time := 20 ns;

  type caso_teste_type is record
      id     : natural;
      largura_de_pulso: time;
  end record;

  --OBS: Os tempos estão 10 us menores para certificar que o valor do pulso é '1' neste intante e se será
  -- '0' 11us depois! (checar loop no process)
  type casos_teste_array is array (natural range <>) of caso_teste_type;
  constant casos_teste : casos_teste_array :=
      (
        -- A primeira coisa que o sistema faz é se mover, então vai direto para a posição 2
        -- (1, 990 us),   -- pulso de 1ms
        (2, 1133 us),  -- pulso de 1,143ms
        (3, 1276 us),  -- pulso de 1,286ms
        (4, 1419 us),  -- pulso de 1,429ms
        (5, 1561 us),  -- pulso de 1,571ms
        (6, 1709 us),  -- pulso de 1,719ms
        (7, 1847 us),  -- pulso de 1,857ms
        (8, 1990 us),  -- pulso de 2ms
        --
        (9, 1847 us),   -- pulso de 1,857ms
        (10, 1709 us),  -- pulso de 1,719ms
        (11, 1561 us),  -- pulso de 1,571ms
        (12, 1419 us),  -- pulso de 1,429ms
        (13, 1276 us),  -- pulso de 1,286ms
        (14, 1133 us),  -- pulso de 1,143ms
        (15, 990 us),   -- pulso de 1ms
        --
        (16, 1133 us)   -- pulso de 1,143ms
      );

begin

  clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;

  dut: sonar port map(
    clock => clock_in,
    reset => reset_in,
    ligar => ligar_in,
    echo => echo_in,
    seletor_depurador => seletor_depurador_in,
    trigger => trigger_out,
    pwm => pwm_out,
    saida_serial => saida_serial_out,
    alerta_proximidade => alerta_proximidade_out,
    depurador => depurador_out
  );

  teste_pulso: process is
  begin

    assert false report "Inicio da simulacao" severity note;
    keep_simulating <= '1';

    reset_in <= '1';
    wait for 2*clockPeriod;
    reset_in <= '0';
    wait for 2*clockPeriod;

    ligar_in <= '1';

    for i in casos_teste'range loop
      -- imprime caso e largura do pulso em us
      assert false report "Caso de teste " & integer'image(casos_teste(i).id) severity note;

      wait until pwm_out'event and pwm_out = '1';
      wait for casos_teste(i).largura_de_pulso;
      assert pwm_out = '1' report "Falha na duracao. Teste: " & integer'image(casos_teste(i).id) severity error;
      wait for 14 us;
      assert pwm_out = '0' report "Falha no desativamento. Teste: " & integer'image(casos_teste(i).id) severity error;

      assert false report "Fim do teste " & integer'image(casos_teste(i).id) severity note;

      wait until trigger_out'event and trigger_out = '1';
      wait for 10 ms;

      echo_in <= '1';
      wait for 588 us;
      echo_in <= '0';

      wait for 30 ms; -- aguarda tempo de transmissão

    end loop;

    assert false report "Fim dos testes" severity note;
    keep_simulating <= '0';
    ligar_in <= '0';

    wait;
  end process;

end architecture;
