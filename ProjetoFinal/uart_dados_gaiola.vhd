library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity uart_dados_gaiola is
    port (
      clock : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      transmitir : IN STD_LOGIC;
      estado : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- estado da gaiola

      distancia_interna2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- e de distancia
      distancia_interna1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      distancia_interna0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);

      distancia_porta2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      distancia_porta1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      distancia_porta0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);

      saida_serial : OUT STD_LOGIC;
      pronto : OUT STD_LOGIC;
      db_estado : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
end entity;

architecture uart_dados_gaiola_arch of uart_dados_gaiola is
    component uart_dados_gaiola_uc
        port(
            clock, reset, transmitir, fim_transmissao: in  std_logic;
            pronto, transmite_dado:                   out std_logic;
            seletor_dado:                             out std_logic_vector(3 downto 0);
            db_estado:                                out std_logic_vector(3 downto 0)
        );
    end component;

    component uart_dados_gaiola_fd
        port(
          clock, reset, transmitir:      in  std_logic;
          estado:                      in std_logic_vector(3 downto 0); -- estado da gaiola
          distancia_interna2:                   in std_logic_vector(3 downto 0); -- e de distancia
          distancia_interna1:                   in std_logic_vector(3 downto 0);
          distancia_interna0:                   in std_logic_vector(3 downto 0);
          distancia_porta2:                   in std_logic_vector(3 downto 0); -- e de distancia
          distancia_porta1:                   in std_logic_vector(3 downto 0);
          distancia_porta0:                   in std_logic_vector(3 downto 0);
          seletor_dado:                 in std_logic_vector(3 downto 0);
          fim_transmissao:              out  std_logic;
          saida_serial:                 out  std_logic
        );
    end component;

    signal s_transmitir_dado, s_fim_transmissao: std_logic;
    signal s_seletor_dado: std_logic_vector(3 downto 0);
begin

    UC: uart_dados_gaiola_uc port map (clock, reset, transmitir, s_fim_transmissao, pronto, s_transmitir_dado, s_seletor_dado, db_estado);

    FD: uart_dados_gaiola_fd port map (clock, reset, s_transmitir_dado, estado, distancia_interna2, distancia_interna1, distancia_interna0, distancia_porta2, distancia_porta1, distancia_porta0, s_seletor_dado, s_fim_transmissao, saida_serial);

end architecture;
