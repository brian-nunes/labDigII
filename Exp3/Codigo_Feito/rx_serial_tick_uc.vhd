library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_serial_tick_uc is
  port(
    clock, dado_serial, reset, tick, fim, recebe_dado: in  std_logic;
    carrega, desloca, limpa, registra, zera, conta:    out std_logic;
    db_estado:                                         out std_logic_vector(3 downto 0)
  );
end entity;

architecture rx_serial_tick_uc_arch of rx_serial_tick_uc is

  type tipo_estado is (inicial, preparacao, espera, recepcao, armazena, final, dado_presente);
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
    process (dado_serial, tick, fim, recebe_dado, Eatual)
    begin

      case Eatual is

        when inicial =>           if dado_serial = '0' then Eprox <= preparacao;
                                  else                      Eprox <= inicial;
                                  end if;

        when preparacao =>        Eprox <= espera;

        when espera =>            if tick='1' then          Eprox <= recepcao;
                                  elsif fim='0' then        Eprox <= espera;
                                  else                      Eprox <= armazena;
                                  end if;

        when recepcao =>          Eprox <= espera;

        when armazena =>          Eprox <= final;

        when final =>             Eprox <= dado_presente;

        when dado_presente =>     if recebe_dado = '1' then Eprox <= inicial;
                                  else                      Eprox <= dado_presente
                                  end if;

        when others =>            Eprox <= inicial;

      end case;
    end process;

    -- logica de saida (Moore)
    with Eatual select
        carrega <= '1' when preparacao, '0' when others;

    with Eatual select
        desloca <= '1' when recepcao, '0' when others;

    with Eatual select
        limpa <= '1' when preparacao, '0' when others;

    with Eatual select
        registra <= '1' when armazena, '0' when others;

    with Eatual select
        zera <= '1' when preparacao, '0' when others;

    with Eatual select
        conta <= '1' when recepcao, '0' when others;

    with Eatual select
        pronto <= '1' when final, '0' when others;

    with Eatual select
        tem_dado <= '1' when dado_presente, '0' when others;

    -- Debug Estado (pro Display)
    with Eatual select
      db_estado <=  "0000" when inicial,         -- 0
                    "0001" when preparacao,      -- 1
                    "0010" when espera,          -- 2
                    "0011" when recepcao,        -- 3
                    "0100" when armazena,        -- 4
                    "0101" when final,           -- 5
                    "0110" when dado_presente,   -- 6
                    "1111" when others;          -- F

end architecture;
