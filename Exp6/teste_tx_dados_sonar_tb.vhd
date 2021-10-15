library ieee;
use ieee.std_logic_1164.all;

entity teste_tx_dados_sonar_tb is
end teste_tx_dados_sonar_tb;

architecture tb of teste_tx_dados_sonar_tb is

    component teste_tx_dados_sonar
        port (clock           : in std_logic;
              reset           : in std_logic;
              transmitir      : in std_logic;
              saida_serial    : out std_logic;
              pronto          : out std_logic;
              db_transmitir   : out std_logic;
              db_saida_serial : out std_logic;
              db_estado       : out std_logic_vector (3 downto 0));
    end component;

    signal clock           : std_logic;
    signal reset           : std_logic;
    signal transmitir      : std_logic;
    signal saida_serial    : std_logic;
    signal pronto          : std_logic;
    signal db_transmitir   : std_logic;
    signal db_saida_serial : std_logic;
    signal db_estado       : std_logic_vector (3 downto 0);

    constant TbPeriod : time := 20 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : teste_tx_dados_sonar
    port map (clock           => clock,
              reset           => reset,
              transmitir      => transmitir,
              saida_serial    => saida_serial,
              pronto          => pronto,
              db_transmitir   => db_transmitir,
              db_saida_serial => db_saida_serial,
              db_estado       => db_estado);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clock is really your main clock signal
    clock <= TbClock;

    stimuli : process
    begin
        transmitir <= '0';

        -- Reset generation
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;

        transmitir <= '1';
        wait for 100 ns;
        transmitir <= '0';
        wait for 100 ns;

        wait for 530000 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;