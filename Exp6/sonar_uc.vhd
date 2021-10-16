library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sonar_uc is
  port(
    clock, reset, ligar, fim_movimentacao, fim_medir, fim_transmissao:        in  std_logic;
    move, mede, transmite:            out std_logic;
    db_estado:                  out std_logic_vector(3 downto 0)
  );
end entity;

architecture sonar_uc_arch of sonar_uc is

  type tipo_estado is (inicial, move_servo, mede_distancia, transmite_dado);
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
    process (ligar, fim_movimentacao, fim_medir, fim_transmissao, Eatual)
    begin

      case Eatual is

        when inicial =>           if ligar = '1'            then Eprox <= move_servo;
                                  else                           Eprox <= inicial;
                                  end if;

        when move_servo =>        if fim_movimentacao = '1' then Eprox <= mede_distancia;
                                  else                           Eprox <= move_servo;
                                  end if;

        when mede_distancia =>    if fim_medir = '1'        then Eprox <= transmite_dado;
                                  else                           Eprox <= mede_distancia;
                                  end if;

        when transmite_dado =>    if fim_transmissao = '1'  then Eprox <= inicial;
                                  else                           Eprox <= transmite_dado;
                                  end if;

        when others =>            Eprox <= inicial;

      end case;
    end process;

    -- logica de saida (Moore)
    with Eatual select
     move <= '1' when move_servo, '0' when others;

    with Eatual select
     mede <= '1' when mede_distancia, '0' when others;

    with Eatual select
     transmite <= '1' when transmite_dado, '0' when others;

    -- Debug Estado (pro Display)
    with Eatual select
      db_estado <=  "0000" when inicial,          -- 0
                    "0001" when move_servo,       -- 1
                    "0010" when mede_distancia,   -- 2
                    "0011" when transmite_dado,   -- 3
                    "1111" when others;           -- F

end architecture;
