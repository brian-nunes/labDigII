library ieee;
use ieee.std_logic_1164.all;

entity sonar_tb is
end sonar_tb;

architecture tb of sonar_tb is

    component sonar
        port (clock              : in std_logic;
              reset              : in std_logic;
              ligar              : in std_logic;
              echo               : in std_logic;
              trigger            : out std_logic;
              pwm                : out std_logic;
              saida_serial       : out std_logic;
              alerta_proximidade : out std_logic);
    end component;

    signal clock              : std_logic;
    signal reset              : std_logic;
    signal ligar              : std_logic;
    signal echo               : std_logic;
    signal trigger            : std_logic;
    signal pwm                : std_logic;
    signal saida_serial       : std_logic;
    signal alerta_proximidade : std_logic;

    constant TbPeriod : time := 20 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : sonar
    port map (clock              => clock,
              reset              => reset,
              ligar              => ligar,
              echo               => echo,
              trigger            => trigger,
              pwm                => pwm,
              saida_serial       => saida_serial,
              alerta_proximidade => alerta_proximidade);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clock is really your main clock signal
    clock <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        ligar <= '0';
        echo <= '0';

        -- Reset generation
        -- EDIT: Check that reset is really your reset signal
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;

        ligar <= '1';
        -- wait for 2000000 ns;
        echo <= '1';
        wait for 588000 ns;
        echo <= '0';


        -- EDIT Add stimuli here
        wait for 50000 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;
