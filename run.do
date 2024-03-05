vlib work
vdel -all
vlib work
vlog -lint top.sv +acc -sv
vlog -lint 8088.svp +acc -sv
vsim work.top
add wave -r /*
run -all