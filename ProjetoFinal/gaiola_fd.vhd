LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use ieee.math_real.all;

ENTITY gaiola_fd IS
    PORT (
        clock, reset : IN STD_LOGIC;
        echo, medir, transmitir, reset_interface, conta_espera, salva_estado : IN STD_LOGIC;
        posicao_servo : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        estado : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        trigger, saida_serial, fim_medir, fim_transmitir, fim_espera, pwm : OUT STD_LOGIC;
        ultimo_estado : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        distancia_bcd : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE arch_gaiola_fd OF gaiola_fd IS
    COMPONENT uart_dados_gaiola
        PORT (
            clock : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            transmitir : IN STD_LOGIC;
            estado : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- estado da gaiola
            distancia2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- e de distancia
            distancia1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            distancia0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            saida_serial : OUT STD_LOGIC;
            pronto : OUT STD_LOGIC;
            db_estado : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT interface_hcsr04
        PORT (
            clock, reset : IN STD_LOGIC;
            medir : IN STD_LOGIC;
            echo : IN STD_LOGIC;
            trigger : OUT STD_LOGIC;
            medida : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
            pronto : OUT STD_LOGIC;
            db_estado : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT controle_servo_3
        PORT (
            clock : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            posicao : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            pwm : OUT STD_LOGIC;
            db_reset : OUT STD_LOGIC;
            db_pwm : OUT STD_LOGIC;
            db_posicao : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT contadorg_m
        GENERIC (
            CONSTANT M : INTEGER := 50 -- modulo do contador
        );
        PORT (
            clock, zera_as, zera_s, conta : IN STD_LOGIC;
            Q : OUT STD_LOGIC_VECTOR (NATURAL(ceil(log2(real(M)))) - 1 DOWNTO 0);
            fim, meio : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT registrador_n
      GENERIC (
        CONSTANT N : INTEGER := 8
      );
      PORT (
        clock:  IN  STD_LOGIC;
        clear:  IN  STD_LOGIC;
        enable: IN  STD_LOGIC;
        D:      IN  STD_LOGIC_VECTOR (N-1 downto 0);
        Q:      OUT STD_LOGIC_VECTOR (N-1 downto 0)
      );
    END COMPONENT;

    COMPONENT edge_detector
        PORT (
            clk : IN STD_LOGIC;
            signal_in : IN STD_LOGIC;
            output : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL s_medir_pulso, s_reset, s_reset_interface : STD_LOGIC;
    SIGNAL s_distancia_bcd : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL s_distancia_2, s_distancia_1, s_distancia_0, s_ultimo_estado : STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN
    s_reset <= reset;
    s_reset_interface <= s_reset OR reset_interface;

    edge_medir : edge_detector PORT MAP(clock, medir, s_medir_pulso);

    servo : controle_servo_3 PORT MAP(clock, s_reset, posicao_servo, pwm, OPEN, OPEN, OPEN);

    hcsr04 : interface_hcsr04 PORT MAP(clock, s_reset_interface, s_medir_pulso, echo, trigger, s_distancia_bcd, fim_medir, OPEN);

    uart : uart_dados_gaiola PORT MAP(clock, s_reset, transmitir, s_ultimo_estado, s_distancia_2, s_distancia_1, s_distancia_0, saida_serial, fim_transmitir, OPEN);

    -- tempo de espera de 100ms
    espera : contadorg_m GENERIC MAP(M => 5000000) PORT MAP(clock, s_reset, s_reset, conta_espera, OPEN, fim_espera, OPEN);

    registrador_de_estado : registrador_n GENERIC MAP(N => 4) PORT MAP(clock, '0', salva_estado, estado, s_ultimo_estado);

    WITH s_ultimo_estado SELECT
      s_distancia_2 <= s_distancia_bcd(11 DOWNTO 8) WHEN "0001", -- só tem dados válidos de medição quando acabou de medir!
                      "0000" WHEN OTHERS;

    WITH s_ultimo_estado SELECT
      s_distancia_1 <= s_distancia_bcd(7 DOWNTO 4) WHEN "0001", -- só tem dados válidos de medição quando acabou de medir!
                      "0000"                       WHEN OTHERS;

    WITH s_ultimo_estado SELECT
      s_distancia_0 <= s_distancia_bcd(3 DOWNTO 0) WHEN "0001", -- só tem dados válidos de medição quando acabou de medir!
                      "0000"                       WHEN OTHERS;

    ultimo_estado <= s_ultimo_estado;

    distancia_bcd <= s_distancia_bcd;

END ARCHITECTURE;
