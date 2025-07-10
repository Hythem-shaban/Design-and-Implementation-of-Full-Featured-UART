quit -sim
if [file exists "work"] {vdel -all}
vlib work

vlog ../rtl/baud_rate_generator.v
vlog ../rtl/fifo.v
vlog ../rtl/rx.v
vlog ../rtl/rx_top.v
vlog rx_tb.v

vsim -voptargs=+acc work.rx_tb

add wave -position insertpoint sim:/rx_tb/*
add wave -position insertpoint sim:/rx_tb/drive_rx/IN_Data
add wave -position insertpoint sim:/rx_tb/dut/fifo_u/*

add wave -position insertpoint sim:/rx_tb/dut/rx_u/*
add wave -position insertpoint sim:/rx_tb/dut/baud_rate_generator_u/*




run -all;