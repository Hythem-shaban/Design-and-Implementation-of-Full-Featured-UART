module demux(
  input  wire [7:0] i_switches,
  input  wire       i_sel,
  input  wire       i_clk,
  input  wire       i_rst_n,
  output reg  [7:0] o_wr_data,
  output wire [5:0] o_config
);

  reg [5:0] configs_reg, configs_next;

  always @(posedge i_clk, negedge i_rst_n) begin
    if(!i_rst_n)
      configs_reg <= 'b0;
    else
      configs_reg <= configs_next;
  end

  always @(*) begin
    configs_next = configs_reg;
    o_wr_data = 'b0;
    case (i_sel)
      1'b0: configs_next = i_switches[5:0];
      1'b1: o_wr_data = i_switches;
    endcase
  end

  assign o_config = configs_reg;

endmodule