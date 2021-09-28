library ieee;
use ieee.std_logic_1164.all;

entity interface_hcsr04 is
  port (
    clock, reset: in  std_logic;
    medir:        in  std_logic;
    echo:         in  std_logic;
    trigger:      out std_logic;
    medida:       out std_logic_vector(11 downto 0);
    pronto:       out std_logic;
    db_estado:    out std_logic_vector(3 downto 0)
  );
end entity;

architecture arch_interface_hcsr04 of interface_hcsr04 is
  component interface_hcsr04_uc
    port(
      clock, reset, medir, echo:        in  std_logic;
      gera, pronto, contaEcho, registra, limpa:    out std_logic;
      db_estado:                                  out std_logic_vector(3 downto 0)
    );
  end component;

  component interface_hcsr04_fd is
    port(
      clock, reset, conta, registra, gera: in  std_logic;
      medida:                              out std_logic_vector(11 downto 0);
      trigger:                             out std_logic
    );
  end component;

 signal s_medir, s_echo, s_gera, s_conta_echo, s_registra, s_trigger, s_pronto, s_limpa: std_logic;
 signal s_db_estado: std_logic_vector(3 downto 0);
 signal s_medida: std_logic_vector(11 downto 0);
begin
  s_medir <= medir;
  s_echo <= echo;

  UC: interface_hcsr04_uc port map (clock, reset, s_medir, s_echo, s_gera, s_pronto, s_conta_echo, s_registra, s_limpa, s_db_estado);

  FD: interface_hcsr04_fd port map (clock, s_limpa, s_conta_echo, s_registra, s_gera, s_medida, s_trigger);

  trigger <= s_trigger;
  pronto <= s_pronto;
  db_estado <= s_db_estado;
  medida <= s_medida;
end architecture;
