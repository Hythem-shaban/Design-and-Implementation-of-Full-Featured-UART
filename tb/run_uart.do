quit -sim
if [file exists "work"] {vdel -all}
vlib work

vlog ../rtl/baud_rate_generator.v
vlog ../rtl/fifo.v
vlog ../rtl/rx.v
vlog ../rtl/tx.v
vlog ../rtl/uart.v
vlog uart_tb.v

vsim -voptargs=+acc work.uart_tb

add wave -position insertpoint sim:/uart_tb/*
add wave -position insertpoint sim:/uart_tb/dut/tx_fifo/*
add wave -position insertpoint sim:/uart_tb/dut/rx_fifo/*
add wave -position insertpoint sim:/uart_tb/dut/baud_rate_generator_u/*
add wave -position insertpoint sim:/uart_tb/dut/tx_u/*
add wave -position insertpoint sim:/uart_tb/dut/rx_u/*


run -all;