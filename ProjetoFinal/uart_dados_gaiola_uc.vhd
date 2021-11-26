library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_dados_gaiola_uc is
  port(
    clock, reset, transmitir, fim_transmissao: in  std_logic;
    pronto, transmite_dado:                   out std_logic;
    seletor_dado:                             out std_logic_vector(3 downto 0);
    db_estado:                                out std_logic_vector(3 downto 0)
  );
end entity;

architecture uart_dados_gaiola_uc_arch of uart_dados_gaiola_uc is

  type tipo_estado is (inicial, transmite_id1, transmite_id2, transmite_traco1, transmite_traco2, transmite_traco3, transmiteestado, transmitedi1, transmitedi2, transmitedi3, transmitedp1, transmitedp2, transmitedp3, transmite_ponto, final);
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

        when transmite_id2 =>     if fim_transmissao = '1' then Eprox <= transmite_traco1;
                                  else                         Eprox <= transmite_id2;
                                  end if;

        when transmite_traco1 =>  if fim_transmissao = '1' then Eprox <= transmiteestado;
                                  else                         Eprox <= transmite_traco1;
                                  end if;

        when transmiteestado =>   if fim_transmissao = '1' then Eprox <= transmite_traco2;
                                  else                         Eprox <= transmiteestado;
                                  end if;

        when transmite_traco2 =>  if fim_transmissao = '1' then Eprox <= transmitedi1;
                                  else                         Eprox <= transmite_traco2;
                                  end if;

        when transmitedi1 =>      if fim_transmissao = '1' then Eprox <= transmitedi2;
                                  else                          Eprox <= transmitedi1;
                                  end if;

        when transmitedi2 =>      if fim_transmissao = '1' then Eprox <= transmitedi3;
                                  else                          Eprox <= transmitedi2;
                                  end if;

        when transmitedi3 =>      if fim_transmissao = '1' then Eprox <= transmite_traco3;
                                  else                          Eprox <= transmitedi3;
                                  end if;

        when transmite_traco3 =>  if fim_transmissao = '1' then Eprox <= transmitedp1;
                                  else                         Eprox <= transmite_traco3;
                                  end if;

        when transmitedp1 =>      if fim_transmissao = '1' then Eprox <= transmitedp2;
                                  else                          Eprox <= transmitedp1;
                                  end if;

        when transmitedp2 =>      if fim_transmissao = '1' then Eprox <= transmitedp3;
                                  else                          Eprox <= transmitedp2;
                                  end if;

        when transmitedp3 =>      if fim_transmissao = '1' then Eprox <= transmite_ponto;
                                  else                          Eprox <= transmitedp3;
                                  end if;

        when transmite_ponto =>   if fim_transmissao = '1' then Eprox <= final;
                                  else                          Eprox <= transmite_ponto;
                                  end if;

        when others =>            Eprox <= inicial;

      end case;
    end process;

    with Eatual select
      transmite_dado <= '1' when transmiteestado, -- 1
                        '1' when transmitedi1,     -- 2
                        '1' when transmitedi2,     -- 3
                        '1' when transmitedi3,     -- 4
                        '1' when transmitedp1,
                        '1' when transmitedp2,
                        '1' when transmitedp3,
                        '1' when transmite_ponto,
                        '1' when transmite_id1,
                        '1' when transmite_id2,
                        '1' when transmite_traco1,
                        '1' when transmite_traco2,
                        '1' when transmite_traco3,
                        '0' when others;

    -- logica de saida (Moore)
    with Eatual select
      pronto <= '1' when final, '0' when others;

    -- Debug Estado (pro Display)
    with Eatual select
      seletor_dado <= "0000" when transmite_id1,
                      "0001" when transmite_id2,

                      "0010" when transmite_traco1,
                      "0010" when transmite_traco2,
                      "0010" when transmite_traco3,

                      "0011" when transmiteestado,

                      "0100" when transmitedi1,
                      "0101" when transmitedi2,
                      "0110" when transmitedi3,

                      "0111" when transmitedp1,
                      "1000" when transmitedp2,
                      "1001" when transmitedp3,

                      "1010" when transmite_ponto,
                      "0000" when others;

    -- Debug Estado (pro Display)
    with Eatual select
      db_estado <=  "0000" when inicial,          -- 0
                    "0001" when transmite_id1,    -- 1
                    "0010" when transmite_id2,    -- 2
                    "0011" when transmite_traco1,  -- 3
                    "0100" when transmiteestado,  -- 4
                    "0101" when transmitedi1,      -- 5
                    "0110" when transmitedi2,      -- 6
                    "0111" when transmitedi3,      -- 7
                    "1000" when transmite_ponto,  -- 8
                    "1001" when final,            -- 9
                    "1111" when others;           -- F

end architecture;
