LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY gaiola IS
    PORT (
      clock, reset : IN STD_LOGIC;
      armar, desarmar : IN STD_LOGIC;
      echo1, echo2 : IN STD_LOGIC;
      recepcao_serial: IN STD_LOGIC;
      trigger1, trigger2 : OUT STD_LOGIC;
      pwm : OUT STD_LOGIC;
      saida_serial : OUT STD_LOGIC;

      db_estado : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      db_distancia1, db_distancia2: OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
      db_dado_recebido_rx : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      db_reg_id0, db_reg_id1, db_reg_traco, db_reg_cmd : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      db_enable : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE arch_gaiola OF gaiola IS
    COMPONENT gaiola_uc
        PORT (
            clock, reset, armar, desarmar, fim_medir, fim_transmitir, fim_espera, fim_receber, cmd_R, cmd_A, cmd_D, tem_dado : IN STD_LOGIC;
            distancia_bcd1, distancia_bcd2 : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
            medir, transmitir, reset_interface, conta_espera, salva_estado, limpa_regs : OUT STD_LOGIC;
            e_reg_id0, e_reg_id1, e_reg_traco, e_reg_cmd : OUT STD_LOGIC;
            posicao_servo : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            db_estado : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT gaiola_fd
        PORT (
            clock, reset : IN STD_LOGIC;
            echo1, echo2, medir, transmitir, reset_interface, conta_espera, salva_estado : IN STD_LOGIC;
            posicao_servo : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            estado : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            trigger1, trigger2, saida_serial, fim_medir, fim_transmitir, fim_espera, pwm : OUT STD_LOGIC;
            recepcao_serial:               IN STD_LOGIC;
            dado_recebido_rx : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            pronto_rx, tem_dado : OUT STD_LOGIC;
            distancia_bcd1, distancia_bcd2 : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT registrador_n
      GENERIC (
        CONSTANT N: INTEGER := 8
      );
      PORT (
        clock:  IN  STD_LOGIC;
        clear:  IN  STD_LOGIC;
        enable: IN  STD_LOGIC;
        D:      IN  STD_LOGIC_VECTOR (N-1 DOWNTO 0);
        Q:      OUT STD_LOGIC_VECTOR (N-1 DOWNTO 0)
      );
    END COMPONENT;

    SIGNAL s_fim_medir, s_fim_transmitir, s_medir, s_transmitir, s_fim_espera, s_reset_interface, s_conta_espera, s_salva_estado : STD_LOGIC;
    SIGNAL s_estado : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL s_posicao_servo : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL s_distancia_bcd1, s_distancia_bcd2 : STD_LOGIC_VECTOR(11 DOWNTO 0);

    SIGNAL s_dado_recebido_rx : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL cmd_R, cmd_A, cmd_D, s_pronto_rx, s_limpa_regs, s_clear_reg_rx, s_tem_dado : STD_LOGIC;

    SIGNAL sel_reg : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL enable_reg_id0, enable_reg_id1, enable_reg_traco, enable_reg_cmd : STD_LOGIC;

    SIGNAL const_R : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01010010";
    SIGNAL const_A : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01000001";
    SIGNAL const_D : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01000100";
    SIGNAL const_traco : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00101101";
    SIGNAL const0 : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00110000";
    SIGNAL const1 : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00110001";

    SIGNAL reg_id0_out, reg_id1_out, reg_traco_out, reg_cmd_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN

    UC : gaiola_uc PORT MAP(clock, reset, armar, desarmar, s_fim_medir, s_fim_transmitir, s_fim_espera, s_pronto_rx, cmd_R, cmd_A, cmd_D, s_tem_dado, s_distancia_bcd1, s_distancia_bcd2, s_medir, s_transmitir, s_reset_interface, s_conta_espera, s_salva_estado, s_limpa_regs, enable_reg_id0, enable_reg_id1, enable_reg_traco, enable_reg_cmd, s_posicao_servo, s_estado);

    FD : gaiola_fd PORT MAP(clock, reset, echo1, echo2, s_medir, s_transmitir, s_reset_interface, s_conta_espera, s_salva_estado, s_posicao_servo, s_estado, trigger1, trigger2, saida_serial, s_fim_medir, s_fim_transmitir, s_fim_espera, pwm, recepcao_serial, s_dado_recebido_rx, s_pronto_rx, s_tem_dado, s_distancia_bcd1, s_distancia_bcd2);

    reg_id0 : registrador_n GENERIC MAP(N => 8) PORT MAP(clock, s_clear_reg_rx, enable_reg_id0, s_dado_recebido_rx, reg_id0_out);

    reg_id1 : registrador_n GENERIC MAP(N => 8) PORT MAP(clock, s_clear_reg_rx, enable_reg_id1, s_dado_recebido_rx, reg_id1_out);

    reg_traco : registrador_n GENERIC MAP(N => 8) PORT MAP(clock, s_clear_reg_rx, enable_reg_traco, s_dado_recebido_rx, reg_traco_out);

    reg_cmd : registrador_n GENERIC MAP(N => 8) PORT MAP(clock, s_clear_reg_rx, enable_reg_cmd, s_dado_recebido_rx, reg_cmd_out);

    sel_reg <=  "000" WHEN (reg_id0_out = "00000000" AND reg_id1_out = "00000000" AND reg_traco_out = "00000000" AND reg_cmd_out = "00000000") ELSE
                "001" WHEN (reg_id1_out = "00000000" AND reg_traco_out = "00000000" AND reg_cmd_out = "00000000") ELSE
                "010" WHEN (reg_traco_out = "00000000" AND reg_cmd_out = "00000000") ELSE
                "011" WHEN (reg_cmd_out = "00000000") ELSE
                "111";

    -- enable_reg_id0 <= '1' WHEN (sel_reg = "000" AND s_pronto_rx = '1') ELSE
    --                   '0';
    --
    -- enable_reg_id1 <= '1' WHEN (sel_reg = "001" AND s_pronto_rx = '1') ELSE
    --                   '0';
    --
    -- enable_reg_traco <= '1' WHEN (sel_reg = "010" AND s_pronto_rx = '1') ELSE
    --                     '0';
    --
    -- enable_reg_cmd <= '1' WHEN (sel_reg = "011" AND s_pronto_rx = '1') ELSE
    --                   '0';

    s_clear_reg_rx <= '1' WHEN (s_limpa_regs = '1') OR (NOT (reg_cmd_out = "00000000" OR reg_cmd_out = const_R OR reg_cmd_out = const_A OR reg_cmd_out = const_D)) ELSE
                      '0';

    cmd_R <= '1' WHEN (s_pronto_rx = '1' AND reg_id0_out = const0 AND reg_id1_out = const1 AND reg_traco_out = const_traco AND reg_cmd_out = const_R) ELSE
              '0';

    cmd_A <= '1' WHEN (s_pronto_rx = '1' AND reg_id0_out = const0 AND reg_id1_out = const1 AND reg_traco_out = const_traco AND reg_cmd_out = const_A) ELSE
              '0';

    cmd_D <= '1' WHEN (s_pronto_rx = '1' AND reg_id0_out = const0 AND reg_id1_out = const1 AND reg_traco_out = const_traco AND reg_cmd_out = const_D) ELSE
              '0';

    db_estado <= s_estado;
    db_distancia1 <= s_distancia_bcd1;
    db_distancia2 <= s_distancia_bcd2;

    db_dado_recebido_rx <= s_dado_recebido_rx;

    db_reg_id0 <= reg_id0_out;
    db_reg_id1 <= reg_id1_out;
    db_reg_traco <= reg_traco_out;
    db_reg_cmd <= reg_cmd_out;

    db_enable <= enable_reg_id0;

END ARCHITECTURE;
