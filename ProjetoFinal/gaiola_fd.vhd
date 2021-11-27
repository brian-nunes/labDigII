LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use ieee.math_real.all;

ENTITY gaiola_fd IS
    PORT (
        clock, reset : IN STD_LOGIC;
        echo1, echo2, medir, transmitir, reset_interface, conta_espera, salva_estado : IN STD_LOGIC;
        posicao_servo : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        estado : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        trigger1, trigger2, saida_serial, fim_medir, fim_transmitir, fim_espera, pwm : OUT STD_LOGIC;
        recepcao_serial:               IN STD_LOGIC;
        dado_recebido_rx : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        pronto_rx : OUT STD_LOGIC;
        distancia_bcd1, distancia_bcd2 : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE arch_gaiola_fd OF gaiola_fd IS
    COMPONENT uart_dados_gaiola
        PORT (
            clock : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            transmitir : IN STD_LOGIC;
            estado : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- estado da gaiola

            distancia_interna2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- e de distancia
            distancia_interna1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            distancia_interna0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);

            distancia_porta2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            distancia_porta1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            distancia_porta0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);

            recepcao_serial:               in std_logic;
            dado_recebido_rx : out std_logic_vector(7 downto 0);
            pronto_rx : out std_logic;

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

    COMPONENT edge_detector
        PORT (
            clk : IN STD_LOGIC;
            signal_in : IN STD_LOGIC;
            output : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL s_medir_pulso, s_reset, s_reset_interface : STD_LOGIC;
    SIGNAL s_distancia_bcd1, s_distancia_bcd2 : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL fim_medir1, fim_medir2: STD_LOGIC;
    SIGNAL s_distancia_interna2, s_distancia_interna1, s_distancia_interna0, s_ultimo_estado, s_distancia_porta2, s_distancia_porta1, s_distancia_porta0 : STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN
    s_reset <= reset;
    s_reset_interface <= s_reset OR reset_interface;

    edge_medir : edge_detector PORT MAP(clock, medir, s_medir_pulso);

    servo : controle_servo_3 PORT MAP(clock, s_reset, posicao_servo, pwm, OPEN, OPEN, OPEN);

    hcsr04_interno : interface_hcsr04 PORT MAP(clock, s_reset_interface, s_medir_pulso, echo1, trigger1, s_distancia_bcd1, fim_medir1, OPEN);

    hcsr04_porta : interface_hcsr04 PORT MAP(clock, s_reset_interface, s_medir_pulso, echo2, trigger2, s_distancia_bcd2, fim_medir2, OPEN);

    uart : uart_dados_gaiola PORT MAP(clock, s_reset, transmitir, estado, s_distancia_interna2, s_distancia_interna1, s_distancia_interna0, s_distancia_porta2, s_distancia_porta1, s_distancia_porta0, recepcao_serial, dado_recebido_rx, pronto_rx, saida_serial, fim_transmitir, OPEN);


    fim_medir <= fim_medir1 AND fim_medir2;

    -- tempo de espera de 100ms
    espera : contadorg_m GENERIC MAP(M => 5000000) PORT MAP(clock, s_reset, s_reset, conta_espera, OPEN, fim_espera, OPEN);

    WITH estado SELECT
      s_distancia_interna2 <= s_distancia_bcd1(11 DOWNTO 8) WHEN "0001", -- só tem dados válidos de medição quando acabou de medir!
                              s_distancia_bcd1(11 DOWNTO 8) WHEN "0010",
                              "0000" WHEN OTHERS;

    WITH estado SELECT
      s_distancia_interna1 <= s_distancia_bcd1(7 DOWNTO 4) WHEN "0001", -- só tem dados válidos de medição quando acabou de medir!
                              s_distancia_bcd1(7 DOWNTO 4) WHEN "0010",
                              "0000"                       WHEN OTHERS;

    WITH estado SELECT
      s_distancia_interna0 <= s_distancia_bcd1(3 DOWNTO 0) WHEN "0001", -- só tem dados válidos de medição quando acabou de medir!
                              s_distancia_bcd1(3 DOWNTO 0) WHEN "0010",
                              "0000"                       WHEN OTHERS;

    WITH estado SELECT
      s_distancia_porta2 <= s_distancia_bcd2(11 DOWNTO 8) WHEN "0001", -- só tem dados válidos de medição quando acabou de medir!
                            s_distancia_bcd2(11 DOWNTO 8) WHEN "0010",
                            "0000" WHEN OTHERS;

    WITH estado SELECT
      s_distancia_porta1 <= s_distancia_bcd2(7 DOWNTO 4) WHEN "0001", -- só tem dados válidos de medição quando acabou de medir!
                            s_distancia_bcd2(7 DOWNTO 4) WHEN "0010",
                            "0000"                       WHEN OTHERS;

    WITH estado SELECT
      s_distancia_porta0 <= s_distancia_bcd2(3 DOWNTO 0) WHEN "0001", -- só tem dados válidos de medição quando acabou de medir!
                            s_distancia_bcd2(3 DOWNTO 0) WHEN "0010",
                            "0000"                       WHEN OTHERS;

    distancia_bcd1 <= s_distancia_bcd1;
    distancia_bcd2 <= s_distancia_bcd2;

END ARCHITECTURE;
