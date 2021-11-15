LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY gaiola_fd IS
    PORT (
        clock, reset : IN STD_LOGIC;
        echo, medir, transmitir : IN STD_LOGIC;
        posicao_servo : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        trigger, distancia : OUT STD_LOGIC;
        pwm, distancia_bcd : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE arch_gaiola_fd OF gaiola_fd IS
    COMPONENT uart_8N2
        PORT (
            clock : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            transmite_dado : IN STD_LOGIC;
            dados_ascii : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            dado_serial : IN STD_LOGIC;
            recebe_dado : IN STD_LOGIC;
            saida_serial : OUT STD_LOGIC;
            pronto_tx : OUT STD_LOGIC;
            dado_recebido_rx : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            tem_dado : OUT STD_LOGIC;
            pronto_rx : OUT STD_LOGIC;
            db_transmite_dado : OUT STD_LOGIC;
            db_saida_serial : OUT STD_LOGIC;
            db_estado_tx : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            db_recebe_dado : OUT STD_LOGIC;
            db_dado_serial : OUT STD_LOGIC;
            db_estado_rx : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
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

    COMPONENT edge_detector
        PORT (
            clk : IN STD_LOGIC;
            signal_in : IN STD_LOGIC;
            output : OUT STD_LOGIC
        );
    END COMPONENT;

BEGIN

END ARCHITECTURE;