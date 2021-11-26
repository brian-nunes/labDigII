library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interface_hcsr04_uc is
  port(
    clock, reset, medir, echo:                in  std_logic;
    gera, pronto, contaEcho, registra, limpa: out std_logic;
    db_estado:                                out std_logic_vector(3 downto 0)
  );
end entity;

architecture interface_hcsr04_uc_arch of interface_hcsr04_uc is

  type tipo_estado is (inicial, LimpaFD, enviaPulso, aguardaEcho, calculaDistancia, registraDistancia, mostraDistancia);
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
    process (medir, Eatual, echo)
    begin
      case Eatual is
        when inicial           => if medir = '1'    then    Eprox <= LimpaFD;
                                  else                      Eprox <= inicial;
                                  end if;

        when LimpaFD        => Eprox <= enviaPulso;

        when enviaPulso        => Eprox <= aguardaEcho;

        when aguardaEcho       => if echo = '1'     then    Eprox <= calculaDistancia;
                                  else                      Eprox <= aguardaEcho;
                                  end if;

        when calculaDistancia  => if echo = '0'     then    Eprox <= registraDistancia;
                                  else                      Eprox <= calculaDistancia;
                                  end if;

        when registraDistancia => Eprox <= mostraDistancia;

        when mostraDistancia => Eprox <= mostraDistancia;

        when others =>            Eprox <= inicial;

      end case;
    end process;

    -- logica de saida (Moore)
    with Eatual select
      gera <= '1' when enviaPulso, '0' when others;

    with Eatual select
      limpa <= '1' when LimpaFD, '0' when others;

    with Eatual select
      contaEcho <= '1' when calculaDistancia, '0' when others;

    with Eatual select
      registra <= '1' when registraDistancia, '0' when others;

    with Eatual select
      pronto <= '1' when mostraDistancia, '0' when others;

    -- Debug Estado (pro Display)
    with Eatual select
      db_estado <=  "0000" when inicial,            -- 0
                    "0001" when enviaPulso,         -- 1
                    "0010" when aguardaEcho,        -- 2
                    "0011" when calculaDistancia,   -- 3
                    "0100" when registraDistancia,  -- 4
                    "0101" when mostraDistancia,    -- 5
                    "1111" when others;             -- F


end architecture;
