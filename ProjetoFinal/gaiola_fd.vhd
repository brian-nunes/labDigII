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
    -- precisa de uart para transmitir distância
    -- precisa de interface hcsr04 para medir distância
    -- precisa de controle_servo_3 para controlar servo
    -- precisa de edge_detector para levar pulso do sinal de transmite e mede para suas entidades
BEGIN
END ARCHITECTURE;