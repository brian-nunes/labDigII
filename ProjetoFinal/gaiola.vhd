LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY gaiola IS
    PORT (
        clock, reset : IN STD_LOGIC;
        armar, desarmar : IN STD_LOGIC;
        echo : IN STD_LOGIC;
        trigger : OUT STD_LOGIC;
        pwm : OUT STD_LOGIC;
        saida_serial : OUT STD_LOGIC;
        db_estado : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE arch_gaiola OF gaiola IS
    COMPONENT gaiola_uc
        PORT (
            clock, reset, armar, desarmar, fim_medir, fim_transmitir : IN STD_LOGIC;
            distancia_bcd : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
            medir, transmitir : OUT STD_LOGIC;
            posicao_servo : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            db_estado : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT gaiola_fd
        PORT (
            clock, reset : IN STD_LOGIC;
            echo, medir, transmitir : IN STD_LOGIC;
            posicao_servo : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            estado: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            trigger, saida_serial, fim_medir, fim_transmitir, pwm : OUT STD_LOGIC;
            distancia_bcd : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
        );
    END COMPONENT;

    signal s_fim_medir, s_fim_transmitir, s_medir, s_transmitir: std_logic;
    signal s_estado: std_logic_vector(3 downto 0);
    signal s_posicao_servo: std_logic_vector(2 downto 0);
    signal s_distancia_bcd: std_logic_vector(11 downto 0);
BEGIN

    UC: gaiola_uc port map (clock, reset, armar, desarmar, s_fim_medir, s_fim_transmitir, s_distancia_bcd, s_medir, s_transmitir, s_posicao_servo, s_estado);

    FD: gaiola_fd port map (clock, reset, echo, s_medir, s_transmitir, s_posicao_servo, s_estado, trigger, saida_serial, s_fim_medir, s_fim_transmitir, pwm, s_distancia_bcd);
        
    db_estado <= s_estado;

END ARCHITECTURE;