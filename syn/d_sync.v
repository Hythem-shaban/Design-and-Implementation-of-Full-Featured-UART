module d_sync (
  input wire i_clk,
  input wire i_rst_n,
  input wire i_in,
  output wire o_out
);

reg q1, q2;

always @(posedge i_clk, negedge i_rst_n) begin
  if (!i_rst_n)
    q1 <= 0;
  else
    q1 <= i_in;
end

always @(posedge i_clk, negedge i_rst_n) begin
  if (!i_rst_n)
    q2 <= 0;
  else
    q2 <= q1;
end

assign o_out = q2;
endmodule