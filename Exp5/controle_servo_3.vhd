-- controle_servo.vhd - descrição rtl
--
-- gera saída com modulacao pwm
--
-- parametros: CONTAGEM_MAXIMA e posicao_pwm
--             (clock a 50MHz ou 20ms)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo_3 is
port (
      clock    : in  std_logic;
      reset    : in  std_logic;
      posicao  : in  std_logic_vector(2 downto 0);
      pwm      : out std_logic ;
      db_reset: out std_logic;
      db_pwm: out std_logic;
      db_posicao: out std_logic_vector(2 downto 0)
     );
end controle_servo_3;

architecture rtl of controle_servo_3 is

  constant CONTAGEM_MAXIMA : integer := 1000000;  -- valor para frequencia da saida de 50Hz 
                                                  -- ou periodo de 20ms
  signal contagem     : integer range 0 to CONTAGEM_MAXIMA-1;
  signal posicao_pwm  : integer range 0 to CONTAGEM_MAXIMA-1;
  signal s_posicao    : integer range 0 to CONTAGEM_MAXIMA-1;
  signal s_reset, s_pwm: std_logic;
  signal s_db_posicao: std_logic_vector(2 downto 0);
  
begin
  s_reset <= reset;
  s_db_posicao <= posicao; 

  pwm <= s_pwm;
  db_pwm <= s_pwm;
  db_posicao <= s_db_posicao;
  db_reset <= reset;
  
  process(clock,s_reset,s_db_posicao)
  begin
    -- inicia contagem e posicao
    if(s_reset='1') then
      contagem    <= 0;
      s_pwm         <= '0';
      posicao_pwm <= s_posicao;
    elsif(rising_edge(clock)) then
        -- saida
        if(contagem < posicao_pwm) then
          s_pwm  <= '1';
        else
          s_pwm  <= '0';
        end if;
        -- atualiza contagem e posicao
        if(contagem=CONTAGEM_MAXIMA-1) then
          contagem   <= 0;
          posicao_pwm <= s_posicao;
        else
          contagem   <= contagem + 1;
        end if;
    end if;
  end process;

  process(s_db_posicao)
  begin
    case s_db_posicao is
      when "000" =>    s_posicao <=   50000;  -- pulso de 1,000ms
      when "001" =>    s_posicao <=   57143;  -- pulso de 1,143ms
      when "010" =>    s_posicao <=   64286;  -- pulso de 1,286ms
      when "011" =>    s_posicao <=   71429;  -- pulso de 1,429ms
      when "100" =>    s_posicao <=   78572;  -- pulso de 1.571ms
      when "101" =>    s_posicao <=   85715;  -- pulso de 1,719ms
      when "110" =>    s_posicao <=   92858;  -- pulso de 1,857ms
      when "111" =>    s_posicao <=  100000;  -- pulso de 2,000ms
      when others =>   s_posicao <=       0;  -- nulo     saida 0
    end case;
  end process;
  
end rtl;