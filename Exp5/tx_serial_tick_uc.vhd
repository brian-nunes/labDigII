library ieee;
use ieee.std_logic_1164.all;

entity tx_serial_tick_uc is 
    port ( 
        clock, reset, partida, tick, fim:      in  std_logic;
        zera, conta, carrega, desloca, pronto: out std_logic;
        db_estado:                             out std_logic_vector(3 downto 0)
    );
end entity;

architecture tx_serial_tick_uc_arch of tx_serial_tick_uc is

    type tipo_estado is (inicial, preparacao, espera, transmissao, final);
    signal Eatual: tipo_estado;  -- estado atual
    signal Eprox:  tipo_estado;  -- proximo estado

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
    process (partida, tick, fim, Eatual) 
    begin

      case Eatual is

        when inicial =>          if partida='1' then Eprox <= preparacao;
                                 else                Eprox <= inicial;
                                 end if;

        when preparacao =>       Eprox <= espera;

        when espera =>           if tick='1' then   Eprox <= transmissao;
                                 elsif fim='0' then Eprox <= espera;
                                 else               Eprox <= final;
                                 end if;

        when transmissao =>      if fim='0' then Eprox <= espera;
                                 else            Eprox <= final;
                                 end if;
 
        when final =>            Eprox <= inicial;

        when others =>           Eprox <= inicial;

      end case;

    end process;

    -- logica de saida (Moore)
    with Eatual select
        carrega <= '1' when preparacao, '0' when others;

    with Eatual select
        zera <= '1' when preparacao, '0' when others;

    with Eatual select
        desloca <= '1' when transmissao, '0' when others;

    with Eatual select
        conta <= '1' when transmissao, '0' when others;

    with Eatual select
        pronto <= '1' when final, '0' when others;

    with Eatual select
        db_estado <=  "0000" when inicial,         -- 0
                      "0001" when preparacao,      -- 1
                      "0010" when espera,          -- 2
                      "0011" when transmissao,     -- 3
                      "0100" when final,           -- 4
                      "1111" when others;          -- F

end tx_serial_tick_uc_arch;
