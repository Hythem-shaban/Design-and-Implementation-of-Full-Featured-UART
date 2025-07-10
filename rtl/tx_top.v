module tx_top#(
  parameter CLK_FREQ = 50_000_000,
  parameter BAUD_RATE = 1200, 
  parameter SAMPLING_RATE = 16,
  parameter DEPTH = 8,
  parameter DBITS = 8,
  parameter SBITS = 2
)(
  input  wire             i_clk,
  input  wire             i_rst_n,
  input  wire [DEPTH-1:0] i_wr_data,
  input wire              i_wr,
  input  wire             i_d_num,        // 1'b0:  7 data bits -- 1'b1:  8 data bits
  input  wire             i_s_num,        // 1'b0:  1 stop bit  -- 1'b1:  2 stop bits
  input  wire [1:0]       i_par,          // 2'b00: No parity   -- 2'b01: even parity -- 2'b10: odd parity
  input  wire [1:0]       i_bd_rate,
  output wire             o_tx,
  output wire             o_full
);

  wire s_tick;
  wire [DBITS-1:0] data;
  wire tx_done;
  wire fifo_empty, tx_start;

  assign tx_start = ~fifo_empty;


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
    .i_wr_data(i_wr_data),
    .i_wr(i_wr),
    .i_rd(tx_done),
    .o_rd_data(data),
    .o_full(o_full),
    .o_empty(fifo_empty)
  );

   tx#(
    .DBITS(DBITS),
    .SBITS(SBITS),
    .SAMPLING_RATE(SAMPLING_RATE)
  ) tx_u(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_tx_start(tx_start),
    .i_tx_data(data),
    .i_s_tick(s_tick),
    .i_d_num(i_d_num),
    .i_s_num(i_s_num),
    .i_par(i_par),
    .o_tx_done(tx_done),
    .o_tx(o_tx)
  );
endmodule