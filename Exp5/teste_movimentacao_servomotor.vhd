library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity teste_movimentacao_servomotor is
    port (
        clock: in std_logic;
        reset: in std_logic;
        ligar: in std_logic;
        db_ligar: out std_logic;
        pwm: out std_logic;
        db_pwm: out std_logic;
        posicao: out std_logic_vector(2 downto 0)
    );
end entity;

architecture teste_movimentacao_servomotor_arch of teste_movimentacao_servomotor is
    component contadorg_m
        generic (
            constant M: integer := 50 -- modulo do contador
        );
       port (
            clock, zera_as, zera_s, conta: in std_logic;
            Q: out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
            fim, meio: out std_logic
       );
    end component;

    component contadorg_updown_m
        generic (
            constant M: integer := 50 -- modulo do contador
        );
        port (
            clock:   in  std_logic;
            zera_as: in  std_logic;
            zera_s:  in  std_logic;
            conta:   in  std_logic;
            Q:       out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
            inicio:  out std_logic;
            fim:     out std_logic;
            meio:    out std_logic
        );
    end component;

    component controle_servo_3
        port (
            clock    : in  std_logic;
            reset    : in  std_logic;
            posicao  : in  std_logic_vector(2 downto 0);
            pwm      : out std_logic ;
            db_reset: out std_logic;
            db_pwm: out std_logic;
            db_posicao: out std_logic_vector(2 downto 0)
         );
    end component;

    signal s_ligar, s_reset, s_fim_contador: std_logic;
    signal s_posicao: std_logic_vector(2 downto 0);
begin
    s_ligar <= ligar;
    s_reset <= reset;

    -- Dado clock de 50MHz
    contador: contadorg_m generic map (M => 50000000) port map (clock, s_reset, s_reset, s_ligar, open, s_fim_contador, open);

    updown: contadorg_updown_m generic map (M => 8) port map (clock, s_reset, s_reset, s_fim_contador, s_posicao, open, open, open);

    servo: controle_servo_3 port map(clock, s_reset, s_posicao, pwm, open, db_pwm, open);

    posicao <= s_posicao;
    db_ligar <= s_ligar;

end architecture;.
