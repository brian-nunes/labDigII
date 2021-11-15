library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_dados_gaiola_uc is
  port(
    clock, reset, transmitir, fim_transmissao: in  std_logic;
    pronto, transmite_dado:                   out std_logic;
    seletor_dado:                             out std_logic_vector(1 downto 0);
    db_estado:                                out std_logic_vector(3 downto 0)
  );
end entity;

architecture uart_dados_gaiola_uc_arch of uart_dados_gaiola_uc is

  type tipo_estado is (inicial, transmiteestado, transmited1, transmited2, transmited3, final);
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

        when inicial =>           if transmitir = '1' then Eprox <= transmiteestado;
                                  else                     Eprox <= inicial;
                                  end if;

        when transmiteestado =>  if fim_transmissao = '1' then Eprox <= transmited1;
                                  else                         Eprox <= transmiteestado;
                                  end if;

        when transmited1 =>       if fim_transmissao = '1' then Eprox <= transmited2;
                                  else                          Eprox <= transmited1;
                                  end if;

        when transmited2 =>       if fim_transmissao = '1' then Eprox <= transmited3;
                                  else                          Eprox <= transmited2;
                                  end if;

        when transmited3 =>       if fim_transmissao = '1' then Eprox <= final;
                                  else                          Eprox <= transmited3;
                                  end if; 

        when others =>            Eprox <= inicial;

      end case;
    end process;

    with Eatual select
      transmite_dado <= '1' when transmiteestado, -- 1
                        '1' when transmited1,     -- 2
                        '1' when transmited2,     -- 3
                        '1' when transmited3,     -- 4
                        '0' when others;

    -- logica de saida (Moore)
    with Eatual select
      pronto <= '1' when final, '0' when others;

    -- Debug Estado (pro Display)
    with Eatual select
      seletor_dado <= "00" when transmiteestado, -- 1
                      "01" when transmited1,     -- 2
                      "10" when transmited2,     -- 3
                      "11" when transmited3,     -- 4
                      "00" when others;

    -- Debug Estado (pro Display)
    with Eatual select
      db_estado <=  "0000" when inicial,          -- 0
                    "0001" when transmiteestado,  -- 1
                    "0010" when transmited1,      -- 5
                    "0011" when transmited2,      -- 6
                    "0100" when transmited3,      -- 7
                    "0101" when final,            -- 9
                    "1111" when others;           -- F

end architecture;
