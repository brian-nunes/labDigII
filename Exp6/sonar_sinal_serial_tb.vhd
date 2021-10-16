library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity sonar_sinal_serial_tb is
end entity;

architecture tb_serial of sonar_sinal_serial_tb is

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

  constant tempo_transmissao_bit : time := 104 us;
  constant virgula : std_logic_vector(7 downto 0) := "00101100";
  constant ponto : std_logic_vector(7 downto 0) := "00101110";

  type caso_teste_type is record
      id     : natural;
      duracao_echo : time;
      distancia_2 : std_logic_vector(7 downto 0);
      distancia_1 : std_logic_vector(7 downto 0);
      distancia_0 : std_logic_vector(7 downto 0);
      angulo_2 : std_logic_vector(7 downto 0);
      angulo_1 : std_logic_vector(7 downto 0);
      angulo_0 : std_logic_vector(7 downto 0);
  end record;

  type casos_teste_array is array (natural range <>) of caso_teste_type;
  constant casos_teste : casos_teste_array :=
      (
        -- A primeira coisa que o sistema faz é se mover, então vai direto para a posição 2!
        (1, 588 us, "00110000", "00110001", "00110000", "00110000", "00110010", "00110000"),   -- distancia de 10cm, ângulo de 020
        (2, 882 us, "00110000", "00110001", "00110101", "00110000", "00110100", "00110000"),   -- distancia de 15cm, ângulo de 040
        (3, 1353 us, "00110000", "00110010", "00110011", "00110000", "00110010", "00110011"),  -- distancia de 23cm, ângulo de 060
        (4, 236 us, "00110000", "00110000", "00110100", "00110000", "00110000", "00110010"),   -- distancia de 4cm, ângulo de 080
        (5, 17640 us, "00110011", "00110000", "00110000", "00110011", "00110000", "00110000"), -- distancia de 300cm, ângulo de 100
        (6, 22403 us, "00110011", "00111000", "00110001", "00110011", "00111000", "00110001"), -- distancia de 381cm, ângulo de 120
        (6, 1764 us, "00110000", "00110011", "00110000", "00110000", "00110011", "00110000")   -- distancia de 30cm, ângulo de 140
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

  teste_serial: process is
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

        wait until trigger_out'event and trigger_out = '1';
        wait for 10 ms;

        echo_in <= '1';
        wait for casos_teste(i).duracao_echo;
        echo_in <= '0';

        -- Angulo 0
        wait until saida_serial_out'event and saida_serial_out = '0'; -- Start bit
        wait for 0.5 * tempo_transmissao_bit; -- Pegar metade do sinal
        for b in 0 to 7 loop
          wait tempo_transmissao_bit;
          assert saida_serial_out = casos_teste(i).angulo_0(b)
          report "Falha no bit " & integer'image(b) & "da angulo 0, no teste " & integer'image(i)
          severity error;
        end loop;

        -- Angulo 1
        wait until saida_serial_out'event and saida_serial_out = '0'; -- Start bit
        wait for 0.5 * tempo_transmissao_bit; -- Pegar metade do sinal
        for b in 0 to 7 loop
          wait tempo_transmissao_bit;
          assert saida_serial_out = casos_teste(i).angulo_1(b)
          report "Falha no bit " & integer'image(b) & "da angulo 1, no teste " & integer'image(i)
          severity error;
        end loop;

        -- Angulo 2
        wait until saida_serial_out'event and saida_serial_out = '0'; -- Start bit
        wait for 0.5 * tempo_transmissao_bit; -- Pegar metade do sinal
        for b in 0 to 7 loop
          wait tempo_transmissao_bit;
          assert saida_serial_out = casos_teste(i).angulo_2(b)
          report "Falha no bit " & integer'image(b) & "da angulo 2, no teste " & integer'image(i)
          severity error;
        end loop;

        -- Virgula
        wait until saida_serial_out'event and saida_serial_out = '0'; -- Start bit
        wait for 0.5 * tempo_transmissao_bit; -- Pegar metade do sinal
        for b in 0 to 7 loop
          wait tempo_transmissao_bit;
          assert saida_serial_out = virgula(b)
          report "Falha no bit " & integer'image(b) & "da virgula, no teste " & integer'image(i)
          severity error;
        end loop;

        -- Distancia 0
        wait until saida_serial_out'event and saida_serial_out = '0'; -- Start bit
        wait for 0.5 * tempo_transmissao_bit; -- Pegar metade do sinal
        for b in 0 to 7 loop
          wait tempo_transmissao_bit;
          assert saida_serial_out = casos_teste(i).distancia_0(b)
          report "Falha no bit " & integer'image(b) & "da distancia 0, no teste " & integer'image(i)
          severity error;
        end loop;

        -- Distancia 1
        wait until saida_serial_out'event and saida_serial_out = '0'; -- Start bit
        wait for 0.5 * tempo_transmissao_bit; -- Pegar metade do sinal
        for b in 0 to 7 loop
          wait tempo_transmissao_bit;
          assert saida_serial_out = casos_teste(i).distancia_1(b)
          report "Falha no bit " & integer'image(b) & "da distancia 1, no teste " & integer'image(i)
          severity error;
        end loop;

        -- Distancia 2
        wait until saida_serial_out'event and saida_serial_out = '0'; -- Start bit
        wait for 0.5 * tempo_transmissao_bit; -- Pegar metade do sinal
        for b in 0 to 7 loop
          wait tempo_transmissao_bit;
          assert saida_serial_out = casos_teste(i).distancia_2(b)
          report "Falha no bit " & integer'image(b) & "da distancia 2, no teste " & integer'image(i)
          severity error;
        end loop;

        -- Ponto
        wait until saida_serial_out'event and saida_serial_out = '0'; -- Start bit
        wait for 0.5 * tempo_transmissao_bit; -- Pegar metade do sinal
        for b in 0 to 7 loop
          wait tempo_transmissao_bit;
          assert saida_serial_out = ponto(b)
          report "Falha no bit " & integer'image(b) & "do ponto, no teste " & integer'image(i)
          severity error;
        end loop;

    end loop;

    assert false report "Fim dos testes" severity note;
    keep_simulating <= '0';
    ligar_in <= '0';

    wait;
  end process;
end architecture;
