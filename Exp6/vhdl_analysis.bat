:: Entidades Independentes

ghdl -a .\contadorg_m.vhd
ghdl -a .\contadorg_updown_m.vhd
ghdl -a .\rom_8x24.vhd
ghdl -a .\edge_detector.vhd
ghdl -a .\mux_4x1_n.vhd
ghdl -a .\mux_8x1_n.vhd
ghdl -a .\registrador_n.vhd
ghdl -a .\contador_bcd_4digitos.vhd
ghdl -a .\gerador_pulso.vhd
ghdl -a .\controle_servo_3.vhd
ghdl -a .\contador_m.vhd
ghdl -a .\deslocador_n.vhd
ghdl -a .\registrador_deslocamento_n.vhd
ghdl -a .\hex7seg.vhd


:: Sistemas Complexos
ghdl -a .\interface_hcsr04_uc.vhd
ghdl -a .\interface_hcsr04_fd.vhd
ghdl -a .\interface_hcsr04.vhd

ghdl -a .\tx_serial_tick_uc.vhd
ghdl -a .\tx_serial_8N2_fd.vhd
ghdl -a .\tx_serial_8N2.vhd

ghdl -a .\rx_serial_tick_uc.vhd
ghdl -a .\rx_serial_8N2_fd.vhd
ghdl -a .\rx_serial_8N2.vhd

ghdl -a .\uart_8N2.vhd

ghdl -a .\tx_dados_sonar_uc.vhd
ghdl -a .\tx_dados_sonar_fd.vhd
ghdl -a .\tx_dados_sonar.vhd

ghdl -a .\sonar_uc.vhd
ghdl -a .\sonar_fd.vhd
ghdl -a .\sonar.vhd

ghdl -a .\sonar_tb.vhd
ghdl -e sonar_tb
ghdl -r sonar_tb --vcd=teste_sonar.vcd

gtkwave .\teste_sonar.vcd