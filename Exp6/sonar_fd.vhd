library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity sonar_fd is
    port(
        clock, reset, echo, medir, move, transmitir:     in  std_logic;
        estado:     in  std_logic_vector(3 downto 0);
        depurador:     in  std_logic_vector(1 downto 0);
        pwm, saida_serial, trigger, fim_medir, fim_transmissao, fim_mover, alerta_proximidade:      out  std_logic;
        saida_db:      out  std_logic_vector(23 downto 0)
    );
end entity;

architecture sonar_fd_arch of sonar_fd is

    component contadorg_m
        generic (
            constant M: integer := 50 -- modulo do contador
        );
       port (
            clock, zera_as, zera_s, conta: in std_logic;
            Q: out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
            fim, meio: out std_logic
       );
    end component;

    component contadorg_updown_m
        generic (
            constant M: integer := 50 -- modulo do contador
        );
       port (
            clock:   in  std_logic;
            zera_as: in  std_logic;
            zera_s:  in  std_logic;
            conta:   in  std_logic;
            Q:       out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
            inicio:  out std_logic;
            fim:     out std_logic;
            meio:    out std_logic
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

    component controle_servo_3
        port (
              clock    : in  std_logic;
              reset    : in  std_logic;
              posicao  : in  std_logic_vector(2 downto 0);
              pwm      : out std_logic ;
              db_reset: out std_logic;
              db_pwm: out std_logic;
              db_posicao: out std_logic_vector(2 downto 0)
             );
    end component;

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
            db_estado: out std_logic_vector(3 downto 0);
            db_estado_tx:                 out std_logic_vector(3 downto 0);
            db_estado_rx:                 out std_logic_vector(3 downto 0);
            db_dado_tx:                 out std_logic_vector(7 downto 0);
            db_dado_rx:                 out std_logic_vector(7 downto 0)
        );
    end component;

    component rom_8x24
        port (
            endereco: in  std_logic_vector(2 downto 0);
            saida   : out std_logic_vector(23 downto 0)
        );
    end component;

    component edge_detector
        port ( clk         : in   std_logic;
               signal_in   : in   std_logic;
               output      : out  std_logic
        );
    end component;

    component mux_4x1_n
        generic (
            constant BITS: integer := 4
        );
        port (
            D0 :     in  std_logic_vector (BITS-1 downto 0);
            D1 :     in  std_logic_vector (BITS-1 downto 0);
            D2 :     in  std_logic_vector (BITS-1 downto 0);
            D3 :     in  std_logic_vector (BITS-1 downto 0);
            SEL:     in  std_logic_vector (1 downto 0);
            MUX_OUT: out std_logic_vector (BITS-1 downto 0)
        );
    end component;

    signal s_reset, s_db_pwm, s_db_transmitir, s_db_saida_serial, move_pulso: std_logic;
    signal s_posicao: std_logic_vector(2 downto 0);
    signal s_depurador: std_logic_vector(1 downto 0);
    signal s_medida: std_logic_vector(11 downto 0);
    signal s_angulo, depurador_servo_medidor, depurador_uart, depurador_tx_dados_sonar, depurador_sonar: std_logic_vector(23 downto 0);
    signal db_estado_medidor, db_estado_transmissor, s_db_estado_tx, s_db_estado_rx: std_logic_vector(3 downto 0);
    signal s_db_dado_tx, s_db_dado_rx: std_logic_vector(7 downto 0);
begin
    s_reset <= reset;

    detector_borda: edge_detector port map (clock, move, move_pulso);

    -- Reduzido para testes, lembrar de mudar para FPGA (10000 para testes e deve estar em 100000000 para FPGA)
    contador: contadorg_m generic map (M => 100000000) port map (clock, s_reset, s_reset, move, open, fim_mover, open);

    medidor_distancias: interface_hcsr04 port map (clock, s_reset, medir, echo, trigger, s_medida, fim_medir, db_estado_medidor);

    updown: contadorg_updown_m generic map (M => 8) port map (clock, s_reset, s_reset, move_pulso, s_posicao, open, open, open);

    servo: controle_servo_3 port map(clock, s_reset, s_posicao, pwm, open, s_db_pwm, open);

    memoria_angulos:  rom_8x24 port map (s_posicao, s_angulo);

    dados_sonar: tx_dados_sonar port map (clock, s_reset, transmitir, s_angulo(19  downto 16), s_angulo(11  downto 8), s_angulo(3  downto 0), s_medida(11 downto 8), s_medida(7 downto 4), s_medida(3 downto 0), saida_serial, fim_transmissao, s_db_transmitir, s_db_saida_serial, db_estado_transmissor, s_db_estado_tx, s_db_estado_rx, s_db_dado_tx, s_db_dado_rx);

    depurador_servo_medidor <= "0" & s_posicao & db_estado_medidor & "0000" & s_medida;
    depurador_uart <= s_db_estado_tx & s_db_dado_tx & s_db_estado_rx & s_db_dado_rx;
    depurador_tx_dados_sonar <= db_estado_transmissor & "00" & s_depurador & s_db_dado_tx & "00000000";
    depurador_sonar <= estado & "00000000" & s_angulo(19  downto 16) & s_angulo(11  downto 8) & s_angulo(3  downto 0);
    depurador_mux: mux_4x1_n generic map (BITS => 24) port map (depurador_servo_medidor, depurador_uart, depurador_tx_dados_sonar, depurador_sonar, depurador, saida_db);

    with s_medida(7 downto 4) select
        alerta_proximidade <= '1' when "0001",
                              '1' when "0000",
                              '0' when others;

end architecture;
