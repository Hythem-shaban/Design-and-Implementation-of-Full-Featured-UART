module push_button#(
	parameter counter_final_value = 99
)(
  input wire i_clk,
	input wire i_rst_n,
	input wire i_in,
	output wire o_out
);

  wire edge_in;

  debouncer#(
    .counter_final_value(counter_final_value)
  ) debouncer_u(
    .i_clk(i_clk),
	  .i_rst_n(i_rst_n),
	  .i_in(i_in),
	  .o_out(edge_in)
  );

  edge_detector edge_detector_u(
    .i_clk(i_clk),
	  .i_rst_n(i_rst_n),
	  .i_in(edge_in),
	  .o_out(o_out)
  );

endmodule