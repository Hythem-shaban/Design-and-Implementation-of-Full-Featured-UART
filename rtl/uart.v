module uart#(
  parameter CLK_FREQ = 50_000_000,
  parameter BAUD_RATE = 19200,
  parameter SAMPLING_RATE = 16,
  parameter DBITS = 8,
  parameter SBITS = 1,
  parameter FIFO_DEPTH = 8
)(
  input  wire             i_clk,
  input  wire             i_rst_n,
  input  wire             i_wr_uart,
  input  wire             i_rd_uart,
  input  wire [DBITS-1:0] i_wr_data,
  input  wire             i_rx,
  output wire             o_tx,
  output wire             o_rx_empty,
  output wire             o_tx_full,
  output wire             o_rx_full,
  output wire [DBITS-1:0] o_rd_data
);

  wire s_tick;
  wire [DBITS-1:0] tx_fifo_rd_data;
  wire [DBITS-1:0] rx_fifo_wr_data;
  wire tx_fifo_empty, tx_fifo_not_empty;
  wire tx_fifo_rd;
  wire rx_fifo_wr;

  assign tx_fifo_not_empty = ~tx_fifo_empty;

  baud_rate_generator#(
    .CLK_FREQ(CLK_FREQ),
    .BAUD_RATE(BAUD_RATE),
    .SAMPLING_RATE(SAMPLING_RATE)
  ) baud_rate_generator_u(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .o_tick(s_tick)
  );

  fifo#(
    .WIDTH(DBITS),
    .DEPTH(FIFO_DEPTH)
  ) tx_fifo(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_wr_data(i_wr_data),
    .i_wr(i_wr_uart),
    .i_rd(tx_fifo_rd),
    .o_rd_data(tx_fifo_rd_data),
    .o_full(o_tx_full),
    .o_empty(tx_fifo_empty)
  );

  tx#(
    .DBITS(DBITS),
    .SBITS(SBITS),
    .SAMPLING_RATE(SAMPLING_RATE)
  ) tx_u(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_tx_start(tx_fifo_not_empty),
    .i_tx_data(tx_fifo_rd_data),
    .i_s_tick(s_tick),
    .o_tx_done(tx_fifo_rd),
    .o_tx(o_tx)
  );

  fifo#(
    .WIDTH(DBITS),
    .DEPTH(FIFO_DEPTH)
  ) rx_fifo(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_wr_data(rx_fifo_wr_data),
    .i_wr(rx_fifo_wr),
    .i_rd(i_rd_uart),
    .o_rd_data(o_rd_data),
    .o_full(o_rx_full),
    .o_empty(o_rx_empty)
  );

  rx#(
    .DBITS(DBITS),
    .SBITS(SBITS),
    .SAMPLING_RATE(SAMPLING_RATE)
  ) rx_u(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_rx(i_rx),
    .i_s_tick(s_tick),
    .o_rx_done(rx_fifo_wr),
    .o_rx_data(rx_fifo_wr_data)
  );

endmodule