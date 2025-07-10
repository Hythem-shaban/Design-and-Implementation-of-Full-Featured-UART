module debouncer 
#(
	parameter counter_final_value = 99
)
(
	input wire i_clk,
	input wire i_rst_n,
	input wire i_in,
	output wire o_out
);

wire sync_in;
wire timer_en, timer_done;

d_sync sync_dut(
  .i_clk(i_clk),
  .i_rst_n(i_rst_n),
  .i_in(i_in),
  .o_out(sync_in)
);

d_fsm fsm_dut(
.rst_n(i_rst_n),
.clk(i_clk),
.noisy_sig(sync_in), 
.timer_done(timer_done),
.debounced_sig(o_out), 
.timer_en(timer_en));

d_timer #(.counter_final_value(counter_final_value)) timer_dut(
.clk(i_clk),
.rst_n(i_rst_n),
.enable(timer_en),
.done(timer_done));

endmodule