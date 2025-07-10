module rx_top#(
  parameter CLK_FREQ = 50_000_000,
  parameter BAUD_RATE = 1200, 
  parameter SAMPLING_RATE = 16,
  parameter DEPTH = 8,
  parameter DBITS = 8,
  parameter SBITS = 2
)(
  input  wire             i_clk,
  input  wire             i_rst_n,
  input  wire             i_rx,
  input  wire             i_rd,
  input  wire             i_d_num,        // 1'b0:  7 data bits -- 1'b1:  8 data bits
  input  wire             i_s_num,        // 1'b0:  1 stop bit  -- 1'b1:  2 stop bits
  input  wire [1:0]       i_par,          // 2'b00: No parity   -- 2'b01: even parity -- 2'b10: odd parity
  input  wire [1:0]       i_bd_rate,
  output wire [DBITS-1:0] o_rd_data,
  output wire [2:0]       o_err,          // {start, parity, stop}
  output wire             o_empty
);

  wire s_tick;
  wire [DBITS-1:0] data;
  wire rx_done;

  baud_rate_generator#(
    .CLK_FREQ(CLK_FREQ),
    .BAUD_RATE(BAUD_RATE), 
    .SAMPLING_RATE(SAMPLING_RATE)
  ) baud_rate_generator_u(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_bd_rate(i_bd_rate),
    .o_tick(s_tick)
  );

  fifo#(
    .WIDTH(DBITS),
    .DEPTH(DEPTH)
  ) fifo_u(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_wr_data(data),
    .i_wr(rx_done),
    .i_rd(i_rd),
    .o_rd_data(o_rd_data),
    .o_full(),
    .o_empty(o_empty)
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
    .i_d_num(i_d_num),
    .i_s_num(i_s_num),
    .i_par(i_par),
    .o_err(o_err),
    .o_rx_done(rx_done),
    .o_rx_data(data)
  );
endmodule