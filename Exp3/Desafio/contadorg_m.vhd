library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity contadorg_m is
    generic (
        constant M: integer := 50 -- modulo do contador
    );
   port (
        clock, zera_as, zera_s, conta: in std_logic;
        Q: out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
        fim, meio: out std_logic
   );
end entity contadorg_m;

architecture comportamental of contadorg_m is
    signal IQ: integer range 0 to M-1;
begin

    process (clock,zera_as,zera_s,conta,IQ)
    begin
        if zera_as='1' then IQ <= 0;
        elsif rising_edge(clock) then
            if zera_s='1' then IQ <= 0;
            elsif conta='1' then
                if IQ=M-1 then IQ <= 0;
                else IQ <= IQ + 1;
                end if;
            else IQ <= IQ;
            end if;
        end if;

        -- fim de contagem
        if IQ=M-1 then fim <= '1';
        else fim <= '0';
        end if;

        -- meio da contagem
        if IQ=M/2-1 then meio <= '1';
        else meio <= '0';
        end if;

        Q <= std_logic_vector(to_unsigned(IQ, Q'length));

    end process;

end comportamental;
