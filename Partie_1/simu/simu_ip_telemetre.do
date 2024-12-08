puts "Simulation script for ModelSim "

vlib work
vcom -93 ../src/ip_telemetre.vhd
vcom -93 tb_ip_telemetre.vhd

vsim tb_ip_telemetre
view signals
add wave -r /*

run -a