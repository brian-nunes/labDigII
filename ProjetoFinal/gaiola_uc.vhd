LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY gaiola_uc IS
    PORT (
        clock, reset, armar, fim_medir, fim_transmitir : IN STD_LOGIC;
        distancia_bcd : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        medir, transmitir : OUT STD_LOGIC;
        posicao_servo : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        db_estado : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE gaiola_uc_arch OF gaiola_uc IS

    TYPE tipo_estado IS (inativo, mede, transmite, compara, fechado);
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
    PROCESS (Eatual, reset, armar, fim_medir, fim_transmitir, distancia_bcd)
    BEGIN
        CASE Eatual IS
            WHEN inativo => IF armar = '1' THEN
                Eprox <= mede;
            ELSE
                Eprox <= inativo;
        END IF;

        WHEN mede => IF fim_medir = '1' THEN
        Eprox <= transmite;
    ELSE
        Eprox <= mede;
    END IF;

    WHEN transmite => IF fim_transmitir = '1' THEN
    Eprox <= compara;
ELSE
    Eprox <= transmite;
END IF;

WHEN compara => IF (distancia_bcd(11 DOWNTO 8) = "0010" OR distancia_bcd(11 DOWNTO 8) = "0001" OR distancia_bcd(11 DOWNTO 8) = "0000") THEN
Eprox <= fechado;
ELSE
Eprox <= compara;
END IF;

WHEN fechado => Eprox <= fechado;

WHEN OTHERS => Eprox <= inativo;

END CASE;
END PROCESS;

-- logica de saida (Moore)
WITH Eatual SELECT
    medir <= '1' WHEN mede, '0' WHEN OTHERS;

WITH Eatual SELECT
    transmitir <= '1' WHEN transmite, '0' WHEN OTHERS;

WITH Eatual SELECT
    posicao_servo <= "111" WHEN mede,
    "111" WHEN transmite,
    "111" WHEN compara,
    "000" WHEN OTHERS;

-- inativo, mede, transmite, compara, fechado
-- Debug Estado (pro Display)
WITH Eatual SELECT
    db_estado <= "0000" WHEN inativo, -- 0
    "0001" WHEN mede, -- 1
    "0010" WHEN transmite, -- 2
    "0011" WHEN compara, -- 3
    "0100" WHEN fechado, -- 4
    "1111" WHEN OTHERS; -- F
END ARCHITECTURE;