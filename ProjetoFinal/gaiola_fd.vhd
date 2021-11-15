LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY gaiola_fd IS
    PORT (
        clock, reset : IN STD_LOGIC;
        echo, medir, transmitir : IN STD_LOGIC;
        posicao_servo : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        estado: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        trigger, saida_serial, fim_medir, fim_transmitir, pwm : OUT STD_LOGIC;
        distancia_bcd : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE arch_gaiola_fd OF gaiola_fd IS
    COMPONENT uart_dados_gaiola
        port (
            clock: in std_logic;
            reset: in std_logic;
            transmitir: in std_logic;
            estado: in std_logic_vector(3 downto 0); -- estado da gaiola
            distancia2: in std_logic_vector(3 downto 0); -- e de distancia
            distancia1: in std_logic_vector(3 downto 0);
            distancia0: in std_logic_vector(3 downto 0);
            saida_serial: out std_logic;
            pronto: out std_logic;
            db_estado: out std_logic_vector(3 downto 0)
        );
    end COMPONENT;

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

    signal s_medir_pulso: std_logic;
    signal s_distancia_bcd: std_logic_vector(11 downto 0);
BEGIN

edge_medir: edge_detector port map (clock, medir, s_medir_pulso);

servo: controle_servo_3 port map (clock, reset, posicao_servo, pwm, open, open, open);

hcsr04: interface_hcsr04 port map (clock, reset, s_medir_pulso, echo, trigger, s_distancia_bcd, fim_medir, open);

uart: uart_dados_gaiola port map (clock, reset, transmitir, estado, s_distancia_bcd(11 downto 8), s_distancia_bcd(7 downto 4), s_distancia_bcd(3 downto 0), saida_serial, fim_transmitir, open);

distancia_bcd <= s_distancia_bcd;

END ARCHITECTURE;