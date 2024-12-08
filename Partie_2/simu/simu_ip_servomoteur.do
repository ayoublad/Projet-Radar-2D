puts "Simulation script for ModelSim "

vlib work
vcom -93 ../src/ip_servomoteur.vhd
vcom -93 tb_ip_servomoteur.vhd

vsim tb_ip_servomoteur
view signals
add wave -r /*

run -a