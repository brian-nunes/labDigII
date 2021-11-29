LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY gaiola_uc IS
    PORT (
        clock, reset, armar, desarmar, fim_medir, fim_transmitir, fim_espera, fim_receber, cmd_R, cmd_A, cmd_D, tem_dado : IN STD_LOGIC;
        distancia_bcd1, distancia_bcd2 : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        medir, transmitir, reset_interface, conta_espera, salva_estado, limpa_regs: OUT STD_LOGIC;
        e_reg_id0, e_reg_id1, e_reg_traco, e_reg_cmd : OUT STD_LOGIC;
        posicao_servo : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        db_estado : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE gaiola_uc_arch OF gaiola_uc IS

    TYPE tipo_estado IS (transmite_inativo, inativo, mede, transmite_medicao, compara, espera, transmite_fechado, fechado, recebe_id0, recebe_id1, recebe_traco, recebe_cmd);
    SIGNAL Eatual, Eprox : tipo_estado;

BEGIN

    -- memoria de estado
    PROCESS (Eatual, reset, clock)
    BEGIN
        IF reset = '1' THEN
            Eatual <= transmite_inativo;
        ELSIF clock'event AND clock = '1' THEN
            Eatual <= Eprox;
        END IF;
    END PROCESS;

    -- logica de proximo estado
    PROCESS (Eatual, reset, armar, desarmar, fim_medir, fim_transmitir, fim_espera, distancia_bcd1, distancia_bcd2)
    BEGIN
        CASE Eatual IS

            WHEN transmite_inativo => IF fim_transmitir = '1' THEN
                Eprox <= inativo;
            ELSE
                Eprox <= transmite_inativo;
            END IF;

            WHEN inativo => IF fim_receber = '1' AND cmd_D = '1' THEN
                -- Eprox <= mede;
                Eprox <= transmite_fechado;
            ELSIF (armar = '1' AND desarmar = '0') OR (fim_receber = '1' AND cmd_A = '1') THEN
                -- Eprox <= inativo;
                Eprox <= mede;
            ElSIF tem_dado = '1' THEN
                Eprox <= recebe_id0;
            ELSE
                Eprox <= inativo;
            END IF;

            WHEN mede => IF fim_medir = '1' THEN
                Eprox <= transmite_medicao;
            ELSIF desarmar = '1' THEN
                Eprox <= transmite_inativo;
            ELSE
                Eprox <= mede;
            END IF;

            WHEN transmite_medicao => IF fim_transmitir = '1' THEN
                Eprox <= compara;
            ELSIF desarmar = '1' THEN
                Eprox <= transmite_inativo;
            ELSE
                Eprox <= transmite_medicao;
            END IF;

            WHEN compara => IF (distancia_bcd1(11 DOWNTO 8) = "0010" OR distancia_bcd1(11 DOWNTO 8) = "0001" OR distancia_bcd1(11 DOWNTO 8) = "0000") AND NOT((distancia_bcd2(11 DOWNTO 8) = "0001" AND distancia_bcd2(7 DOWNTO 6) = "00") OR distancia_bcd2(11 DOWNTO 8) = "0000") THEN
                Eprox <= transmite_fechado;
            ELSIF desarmar = '1'THEN
                Eprox <= transmite_inativo;
            ELSE
                Eprox <= espera;
            END IF;

            WHEN espera => IF fim_espera = '1' THEN
                Eprox <= mede;
            ELSIF (desarmar = '1') OR (fim_receber = '1' AND cmd_D = '1') THEN
                Eprox <= transmite_inativo;
            ELSIF (fim_receber = '1' AND cmd_D = '1') THEN
                Eprox <= transmite_fechado;
            ElSIF tem_dado = '1' THEN
                Eprox <= recebe_id0;
            ELSE
                Eprox <= espera;
            END IF;

            WHEN transmite_fechado => IF fim_transmitir = '1' THEN
                Eprox <= fechado;
            ELSIF desarmar = '1' THEN
                Eprox <= transmite_inativo;
            ELSE
                Eprox <= transmite_fechado;
            END IF;

            WHEN fechado => IF (desarmar = '1') OR (fim_receber = '1' AND cmd_D = '1') THEN
                Eprox <= transmite_inativo;
            ELSIF (fim_receber = '1' AND cmd_A = '1') THEN
                Eprox <= mede;
            ElSIF tem_dado = '1' THEN
                Eprox <= recebe_id0;
            ELSE
                Eprox <= fechado;
            END IF;

            WHEN recebe_id0 => IF (fim_receber = '1') THEN
                Eprox <= recebe_id1;
            ELSE
                Eprox <= recebe_id0;
            END IF;

            WHEN recebe_id1 => IF (fim_receber = '1') THEN
                Eprox <= recebe_traco;
            ELSE
                Eprox <= recebe_id1;
            END IF;

            WHEN recebe_traco => IF (fim_receber = '1') THEN
                Eprox <= recebe_cmd;
            ELSE
                Eprox <= recebe_traco;
            END IF;

            WHEN recebe_cmd => IF (fim_receber = '1') THEN
                IF cmd_A = '1' THEN
                  Eprox <= mede;
                ElSIF cmd_D = '1' THEN
                  Eprox <= transmite_fechado;
                ELSIF cmd_R <= '1' THEN
                  Eprox <= transmite_inativo;
                ELSE
                  Eprox <= recebe_id0;
                END IF;
            ELSE
                Eprox <= recebe_cmd;
            END IF;

            WHEN OTHERS => Eprox <= inativo;

        END CASE;
    END PROCESS;

    -- logica de saida (Moore)
    WITH Eatual SELECT
        medir <= '1' WHEN mede,
                 '0' WHEN OTHERS;

    WITH Eatual SELECT
        transmitir <= '1' WHEN transmite_medicao,
                      '1' WHEN transmite_inativo,
                      '1' WHEN transmite_fechado,
                      '0' WHEN OTHERS;

    WITH Eatual SELECT
        posicao_servo <= "111" WHEN mede,
                         "111" WHEN transmite_medicao,
                         "111" WHEN compara,
                         "111" WHEN espera,
                         "000" WHEN OTHERS;

    WITH Eatual SELECT
        reset_interface <= '1' WHEN transmite_medicao,
                           '1' WHEN transmite_inativo,
                           '1' WHEN transmite_fechado,
                           '0' WHEN OTHERS;

    WITH Eatual SELECT
        conta_espera <= '1' WHEN espera,
                        '0' WHEN OTHERS;

    WITH Eatual SELECT
        salva_estado <= '1' WHEN inativo,
                        '1' WHEN mede,
                        '1' WHEN fechado,
                        '0' WHEN OTHERS;

    WITH Eatual SELECT
        limpa_regs <=   '1' WHEN transmite_inativo,
                        '1' WHEN transmite_medicao,
                        '1' WHEN transmite_fechado,
                        '0' WHEN OTHERS;

    WITH Eatual SELECT
        e_reg_id0 <=    '1' WHEN recebe_id0,
                        '0' WHEN OTHERS;

    WITH Eatual SELECT
        e_reg_id1 <=    '1' WHEN recebe_id1,
                        '0' WHEN OTHERS;

    WITH Eatual SELECT
        e_reg_traco <=    '1' WHEN recebe_traco,
                          '0' WHEN OTHERS;

    WITH Eatual SELECT
        e_reg_cmd <=    '1' WHEN recebe_cmd,
                        '0' WHEN OTHERS;

    -- Debug Estado (pro Display)
    WITH Eatual SELECT
        db_estado <= "0000" WHEN transmite_inativo, -- 0
                     "0001" WHEN mede, -- 1
                     "0010" WHEN transmite_medicao, -- 2
                     "0011" WHEN compara, -- 3
                     "0100" WHEN espera, -- 4
                     "0101" WHEN transmite_fechado, -- 5
                     "1010" WHEN inativo,
                     "1011" WHEN fechado,
                     "1111" WHEN OTHERS; -- F
END ARCHITECTURE;
