library ieee;
use ieee.std_logic_1164.all;

entity gerador_pulso_tb is
end gerador_pulso_tb;

architecture tb of gerador_pulso_tb is

    component gerador_pulso
        generic (
           largura: integer:= 25
        );
        port(
           clock:  in  std_logic;
           reset:  in  std_logic;
           gera:   in  std_logic;
           para:   in  std_logic;
           pulso:  out std_logic;
           pronto: out std_logic
        );
     end component;

    signal clock  : std_logic;
    signal reset  : std_logic;
    signal gera   : std_logic;
    signal para   : std_logic;
    signal pulso  : std_logic;
    signal pronto : std_logic;

    constant TbPeriod : time := 20 ns;
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : gerador_pulso 
          generic map ( largura =>  500)
          port map    (clock   => clock,
                       reset   => reset,
                       gera    => gera,
                       para    => para,
                       pulso   => pulso,
                       pronto  => pronto);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
    clock <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        gera <= '0';
        para <= '0';

        -- Reset generation
        reset <= '1';
        wait for 60 ns;
        reset <= '0';
        wait for 60 ns;

        -- EDIT Add stimuli here
        gera <= '1';
        wait until pronto = '1';
        gera <= '0';

        -- Reset generation
        reset <= '1';
        wait for 60 ns;
        reset <= '0';
        wait for 60 ns;

        gera <= '1';
        wait for 2 * TbPeriod;
        gera <= '0';
        wait for 100 * TbPeriod;
        para <= '1';
        wait for 2 * TbPeriod;
        para <= '0';
        wait for 20 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_gerador_pulso_tb of gerador_pulso_tb is
    for tb
    end for;
end cfg_gerador_pulso_tb;