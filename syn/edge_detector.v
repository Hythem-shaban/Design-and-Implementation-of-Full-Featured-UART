module edge_detector (
  input  wire i_clk,
  input  wire i_rst_n,
  input  wire i_in,
  output wire o_out
);

reg q;

always @(posedge i_clk, negedge i_rst_n) begin
  if (!i_rst_n)
    q <= 1'b0;
  else
    q <= i_in;
end

assign o_out = !i_in & q;
endmodule