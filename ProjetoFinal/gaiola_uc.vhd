LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY gaiola_uc IS
    PORT (
        clock, reset, armar, desarmar, fim_medir, fim_transmitir, fim_espera : IN STD_LOGIC;
        distancia_bcd : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        ultimo_estado : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        medir, transmitir, reset_interface, conta_espera, salva_estado: OUT STD_LOGIC;
        posicao_servo : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        db_estado : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE gaiola_uc_arch OF gaiola_uc IS

    TYPE tipo_estado IS (inativo, mede, transmite, compara, espera, fechado);
    SIGNAL Eatual, Eprox : tipo_estado;

BEGIN

    -- memoria de estado
    PROCESS (Eatual, reset, clock)
    BEGIN
        IF reset = '1' THEN
            Eatual <= inativo;
        ELSIF clock'event AND clock = '1' THEN
            Eatual <= Eprox;
        END IF;
    END PROCESS;

    -- logica de proximo estado
    PROCESS (Eatual, reset, armar, desarmar, fim_medir, fim_transmitir, fim_espera, distancia_bcd, ultimo_estado)
    BEGIN
        CASE Eatual IS

            WHEN inativo => IF armar = '1' THEN
                Eprox <= mede;
            ELSE
                -- Eprox <= inativo;
                Eprox <= transmite;
            END IF;

            WHEN mede => IF fim_medir = '1' THEN
                Eprox <= transmite;
            ELSIF desarmar = '1' THEN
                Eprox <= inativo;
            ELSE
                Eprox <= mede;
            END IF;

            WHEN transmite => IF fim_transmitir = '1' THEN
                -- Eprox <= compara;
                IF ultimo_estado = "0000" THEN
                  Eprox <= inativo;
                ELSIF ultimo_estado = "0101" THEN
                  Eprox <= fechado;
                ELSIF ultimo_estado = "0001" THEN
                  Eprox <= compara;
                END IF;
            ELSIF desarmar = '1' THEN
                Eprox <= inativo;
            ELSE
                Eprox <= transmite;
            END IF;

            WHEN compara => IF (distancia_bcd(11 DOWNTO 8) = "0010" OR distancia_bcd(11 DOWNTO 8) = "0001" OR distancia_bcd(11 DOWNTO 8) = "0000") THEN
                Eprox <= fechado;
            ELSIF desarmar = '1' THEN
                Eprox <= inativo;
            ELSE
                Eprox <= espera;
            END IF;

            WHEN espera => IF fim_espera = '1' THEN
                Eprox <= mede;
            ELSIF desarmar = '1' THEN
                Eprox <= inativo;
            ELSE
                Eprox <= espera;
            END IF;

            WHEN fechado => IF desarmar = '1' THEN
                Eprox <= inativo;
            ELSE
                -- Eprox <= fechado;
                Eprox <= transmite;
            END IF;

            WHEN OTHERS => Eprox <= inativo;

        END CASE;
    END PROCESS;

    -- logica de saida (Moore)
    WITH Eatual SELECT
        medir <= '1' WHEN mede,
                 '0' WHEN OTHERS;

    WITH Eatual SELECT
        transmitir <= '1' WHEN transmite,
                      '0' WHEN OTHERS;

    WITH Eatual SELECT
        posicao_servo <= "111" WHEN mede,
                         "111" WHEN transmite,
                         "111" WHEN compara,
                         "111" WHEN espera,
                         "000" WHEN OTHERS;

    WITH Eatual SELECT
        reset_interface <= '1' WHEN transmite,
                           '0' WHEN OTHERS;

    WITH Eatual SELECT
        conta_espera <= '1' WHEN espera,
                        '0' WHEN OTHERS;

    WITH Eatual SELECT
        salva_estado <= '1' WHEN inativo,
                        '1' WHEN mede,
                        '1' WHEN fechado,
                        '0' WHEN OTHERS;

    -- Debug Estado (pro Display)
    WITH Eatual SELECT
        db_estado <= "0000" WHEN inativo, -- 0
                     "0001" WHEN mede, -- 1
                     "0010" WHEN transmite, -- 2
                     "0011" WHEN compara, -- 3
                     "0100" WHEN espera, -- 4
                     "0101" WHEN fechado, -- 5
                     "1111" WHEN OTHERS; -- F
END ARCHITECTURE;
