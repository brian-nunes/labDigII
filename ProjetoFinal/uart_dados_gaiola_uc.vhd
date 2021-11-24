library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_dados_gaiola_uc is
  port(
    clock, reset, transmitir, fim_transmissao: in  std_logic;
    pronto, transmite_dado:                   out std_logic;
    seletor_dado:                             out std_logic_vector(2 downto 0);
    db_estado:                                out std_logic_vector(3 downto 0)
  );
end entity;

architecture uart_dados_gaiola_uc_arch of uart_dados_gaiola_uc is

  type tipo_estado is (inicial, transmite_id1, transmite_id2, transmite_traco, transmiteestado, transmited1, transmited2, transmited3, transmite_ponto, final);
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

        when inicial =>           if transmitir = '1' then Eprox <= transmite_id1;
                                  else                     Eprox <= inicial;
                                  end if;

        when transmite_id1 =>     if fim_transmissao = '1' then Eprox <= transmite_id2;
                                  else                         Eprox <= transmite_id1;
                                  end if;

        when transmite_id2 =>     if fim_transmissao = '1' then Eprox <= transmite_traco;
                                  else                         Eprox <= transmite_id2;
                                  end if;

        when transmite_traco =>   if fim_transmissao = '1' then Eprox <= transmiteestado;
                                  else                         Eprox <= transmite_traco;
                                  end if;

        when transmiteestado =>   if fim_transmissao = '1' then Eprox <= transmited1;
                                  else                         Eprox <= transmiteestado;
                                  end if;

        when transmited1 =>       if fim_transmissao = '1' then Eprox <= transmited2;
                                  else                          Eprox <= transmited1;
                                  end if;

        when transmited2 =>       if fim_transmissao = '1' then Eprox <= transmited3;
                                  else                          Eprox <= transmited2;
                                  end if;

        when transmited3 =>       if fim_transmissao = '1' then Eprox <= transmite_ponto;
                                  else                          Eprox <= transmited3;
                                  end if;

        when transmite_ponto =>   if fim_transmissao = '1' then Eprox <= final;
                                  else                          Eprox <= transmite_ponto;
                                  end if;

        when others =>            Eprox <= inicial;

      end case;
    end process;

    with Eatual select
      transmite_dado <= '1' when transmiteestado, -- 1
                        '1' when transmited1,     -- 2
                        '1' when transmited2,     -- 3
                        '1' when transmited3,     -- 4
                        '1' when transmite_ponto,
                        '1' when transmite_id1,
                        '1' when transmite_id2,
                        '1' when transmite_traco,
                        '0' when others;

    -- logica de saida (Moore)
    with Eatual select
      pronto <= '1' when final, '0' when others;

    -- Debug Estado (pro Display)
    with Eatual select
      seletor_dado <= "000" when transmite_id1,
                      "001" when transmite_id2,
                      "010" when transmite_traco,
                      "011" when transmiteestado,
                      "100" when transmited1,
                      "101" when transmited2,
                      "110" when transmited3,
                      "111" when transmite_ponto,
                      "000" when others;

    -- Debug Estado (pro Display)
    with Eatual select
      db_estado <=  "0000" when inicial,          -- 0
                    "0001" when transmite_id1,    -- 1
                    "0010" when transmite_id2,    -- 2
                    "0011" when transmite_traco,  -- 3
                    "0100" when transmiteestado,  -- 4
                    "0101" when transmited1,      -- 5
                    "0110" when transmited2,      -- 6
                    "0111" when transmited3,      -- 7
                    "1000" when transmite_ponto,  -- 8
                    "1001" when final,            -- 9
                    "1111" when others;           -- F

end architecture;
