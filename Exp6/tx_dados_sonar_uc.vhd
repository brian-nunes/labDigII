library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_dados_sonar_uc is
  port(
    clock, reset, transmitir, fim_transmissao: in  std_logic;
    pronto, transmite_dado:                   out std_logic;
    seletor_dado:                             out std_logic_vector(2 downto 0);
    db_estado:                                out std_logic_vector(3 downto 0)
  );
end entity;

architecture tx_dados_sonar_uc_arch of tx_dados_sonar_uc is

  type tipo_estado is (inicial, transmitea1, transmitea2, transmitea3, transmitevirgula, transmited1, transmited2, transmited3, transmiteponto, final);
  signal Eatual, Eprox: tipo_estado;

  begin

    -- memoria de estado
    process (reset, clock)
    begin
        if reset = '1' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox;
        end if;
    end process;

    -- logica de proximo estado
    process (transmitir, fim_transmissao, Eatual)
    begin

      case Eatual is

        when inicial =>           if transmitir = '1' then Eprox <= transmitea1;
                                  else                      Eprox <= inicial;
                                  end if;

        when transmitea1 =>       if fim_transmissao = '1' then Eprox <= transmitea2;
                                  else                          Eprox <= transmitea1;
                                  end if;

        when transmitea2 =>       if fim_transmissao = '1' then Eprox <= transmitea3;
                                  else                          Eprox <= transmitea2;
                                  end if;

        when transmitea3 =>       if fim_transmissao = '1' then Eprox <= transmitevirgula;
                                  else                          Eprox <= transmitea3;
                                  end if;

        when transmitevirgula =>  if fim_transmissao = '1' then Eprox <= transmited1;
                                  else                          Eprox <= transmitevirgula;
                                  end if;

        when transmited1 =>       if fim_transmissao = '1' then Eprox <= transmited2;
                                  else                          Eprox <= transmited1;
                                  end if;

        when transmited2 =>       if fim_transmissao = '1' then Eprox <= transmited3;
                                  else                          Eprox <= transmited2;
                                  end if;

        when transmited3 =>       if fim_transmissao = '1' then Eprox <= transmiteponto;
                                  else                          Eprox <= transmited3;
                                  end if;

        when transmiteponto =>    if fim_transmissao = '1' then Eprox <= final;
                                  else                          Eprox <= transmiteponto;
                                  end if;   

        when others =>            Eprox <= inicial;

      end case;
    end process;

    with Eatual select
      transmite_dado <= '1' when transmitea1,     -- 1
                        '1' when transmitea2,     -- 2
                        '1' when transmitea3,     -- 3
                        '1' when transmitevirgula,-- 4
                        '1' when transmited1,     -- 5
                        '1' when transmited2,     -- 6
                        '1' when transmited3,     -- 7
                        '1' when transmiteponto,  -- 8
                        '0' when others;

    -- logica de saida (Moore)
    with Eatual select
      pronto <= '1' when final, '0' when others;

    -- Debug Estado (pro Display)
    with Eatual select
      seletor_dado <= "000" when transmitea1,     -- 1
                      "001" when transmitea2,     -- 2
                      "010" when transmitea3,     -- 3
                      "011" when transmitevirgula,-- 4
                      "100" when transmited1,     -- 5
                      "101" when transmited2,     -- 6
                      "110" when transmited3,     -- 7
                      "111" when transmiteponto,  -- 8
                      "000" when others;

    -- Debug Estado (pro Display)
    with Eatual select
      db_estado <=  "0000" when inicial,          -- 0
                    "0001" when transmitea1,      -- 1
                    "0010" when transmitea2,      -- 2
                    "0011" when transmitea3,      -- 3
                    "0100" when transmitevirgula, -- 4
                    "0101" when transmited1,      -- 5
                    "0110" when transmited2,      -- 6
                    "0111" when transmited3,      -- 7
                    "1000" when transmiteponto,   -- 8
                    "1001" when final,            -- 9
                    "1111" when others;           -- F

end architecture;
