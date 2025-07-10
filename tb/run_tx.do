quit -sim
if [file exists "work"] {vdel -all}
vlib work

vlog ../rtl/baud_rate_generator.v
vlog ../rtl/fifo.v
vlog ../rtl/tx.v
vlog ../rtl/tx_top.v
vlog tx_tb.v

vsim -voptargs=+acc work.tx_tb

add wave -position insertpoint sim:/tx_tb/*
#add wave -position insertpoint sim:/tx_tb/dut/fifo_u/o_empty
add wave -position insertpoint sim:/tx_tb/dut/fifo_u/*

#add wave -position insertpoint sim:/tx_tb/dut/tx_u/i_tx_start
add wave -position insertpoint sim:/tx_tb/dut/tx_u/*
#add wave -position insertpoint sim:/tx_tb/dut/tx_u/o_tx_done
#add wave -position insertpoint sim:/tx_tb/dut/baud_rate_generator_u/max_ticks
add wave -position insertpoint sim:/tx_tb/dut/baud_rate_generator_u/*




run -all;