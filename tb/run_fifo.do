quit -sim
if [file exists "work"] {vdel -all}
vlib work

vlog ../rtl/fifo.v
vlog fifo_tb.v

vsim -voptargs=+acc work.fifo_tb

add wave -position insertpoint sim:/fifo_tb/*
add wave -position insertpoint sim:/fifo_tb/dut/mem
add wave -position insertpoint sim:/fifo_tb/dut/wr_ptr
add wave -position insertpoint sim:/fifo_tb/dut/rd_ptr

run -all;