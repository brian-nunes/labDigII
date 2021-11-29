LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY gaiola IS
    PORT (
      clock, reset : IN STD_LOGIC;
      armar, desarmar : IN STD_LOGIC;
      echo1, echo2 : IN STD_LOGIC;
      trigger1, trigger2 : OUT STD_LOGIC;
      pwm : OUT STD_LOGIC;
      saida_serial : OUT STD_LOGIC;
      entrada_serial : IN STD_LOGIC;
      db_estado : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      db_distancia1, db_distancia2: OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE arch_gaiola OF gaiola IS
    COMPONENT gaiola_uc
        PORT (
            clock, reset, armar, desarmar, fim_medir, fim_transmitir, fim_recepcao, fim_espera, fim_timeout : IN STD_LOGIC;
            distancia_bcd1, distancia_bcd2 : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
            medir, transmitir, reset_interface, conta_espera, salva_estado, conta_timeout : OUT STD_LOGIC;
            posicao_servo : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            db_estado : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            dado_recebido_rx : IN STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT gaiola_fd
        PORT (
            clock, reset : IN STD_LOGIC;
            echo1, echo2, medir, transmitir, reset_interface, conta_espera, salva_estado, conta_timeout : IN STD_LOGIC;
            posicao_servo : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            estado : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            trigger1, trigger2, saida_serial, fim_medir, fim_transmitir, fim_recepcao, fim_espera, pwm, fim_timeout : OUT STD_LOGIC;
            distancia_bcd1, distancia_bcd2 : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
            entrada_serial : IN STD_LOGIC;
            dado_recebido_rx : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL s_fim_medir, s_fim_transmitir, s_medir, s_transmitir, s_fim_espera, s_fim_recepcao, s_reset_interface, s_conta_espera, s_salva_estado, s_fim_timeout, s_conta_timeout : STD_LOGIC;
    SIGNAL s_estado : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL s_posicao_servo : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL s_dado_recebido_rx : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL s_distancia_bcd1, s_distancia_bcd2 : STD_LOGIC_VECTOR(11 DOWNTO 0);
BEGIN

    UC : gaiola_uc PORT MAP(clock, reset, armar, desarmar, s_fim_medir, s_fim_transmitir, s_fim_recepcao, s_fim_espera, s_fim_timeout, s_distancia_bcd1, s_distancia_bcd2, s_medir, s_transmitir, s_reset_interface, s_conta_espera, s_salva_estado, s_conta_timeout, s_posicao_servo, s_estado);

    FD : gaiola_fd PORT MAP(clock, reset, echo1, echo2, s_medir, s_transmitir, s_reset_interface, s_conta_espera, s_salva_estado, s_conta_timeout, s_posicao_servo, s_estado, trigger1, trigger2, saida_serial, s_fim_medir, s_fim_transmitir, s_fim_recepcao, s_fim_espera, pwm, s_fim_timeout, s_distancia_bcd1, s_distancia_bcd2, entrada_serial, s_dado_recebido_rx);

    db_estado <= s_estado;
    db_distancia1 <= s_distancia_bcd1;
    db_distancia2 <= s_distancia_bcd2;

END ARCHITECTURE;
