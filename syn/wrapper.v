module wrapper#(
  parameter DBITS = 8
)(
  input  wire             i_clk,
  input  wire             i_rst_n,

  input  wire             i_rd_uart,   // push button
  input  wire             i_rx,        // FTDI (TX)
  output wire             o_rx_empty,  // LED
  output wire             o_rx_full,   // LED
  
  output wire [6:0]       o_seg3,      // rd_D1
  output wire [6:0]       o_seg4,      // rd_D2

  input  wire             i_wr_uart,   // push button
  output wire             o_tx,        // FTDI (RX)
  output wire             o_tx_full,   // LED
  output wire [6:0]       o_seg1,      // wr_D1
  output wire [6:0]       o_seg2,      // wr_D2


  input  wire [DBITS-1:0] i_switches,  // 8 switches
  input  wire             i_config_wrdata_sel,
  output wire [2:0]       o_err       // 3 LEDs {start_err, parity_err, stop_err}

);

  wire rd_uart, wr_uart;
  wire [DBITS-1:0] rd_data;

  wire [DBITS-1:0] wr_data;
  
  wire [1:0] par;
  wire [1:0] bd_rate;
  wire d_num;
  wire s_num;

push_button push_button_read(
  .i_clk(i_clk),
  .i_rst_n(i_rst_n),
  .i_in(i_rd_uart),
  .o_out(rd_uart)
);

push_button push_button_write(
  .i_clk(i_clk),
  .i_rst_n(i_rst_n),
  .i_in(i_wr_uart),
  .o_out(wr_uart)
);

demux demux_u(
  .i_clk(i_clk),
  .i_rst_n(i_rst_n),
  .i_sel(i_config_wrdata_sel),
  .i_switches(i_switches),
  .o_config({par, d_num, s_num, bd_rate}),
  .o_wr_data(wr_data)
);

uart#(
  .DBITS(DBITS)
  ) uart_u(
  .i_clk(i_clk),
  .i_rst_n(i_rst_n),
  .i_wr_uart(wr_uart),
  .i_rd_uart(rd_uart),
  .i_wr_data(wr_data),
  .i_bd_rate(bd_rate),
  .i_d_num(d_num),
  .i_s_num(s_num),
  .i_par(par),
  .i_rx(i_rx),
  .o_tx(o_tx),
  .o_rx_empty(o_rx_empty),
  .o_tx_full(o_tx_full),
  .o_rx_full(o_rx_full),
  .o_err(o_err),
  .o_rd_data(rd_data)
);


seven_seg_decoder seg1(
  .en(1'b1),
  .bcd(wr_data[3:0]),
  .dec(o_seg1)
);

seven_seg_decoder seg2(
  .en(1'b1),
  .bcd(wr_data[7:4]),
  .dec(o_seg2)
);

seven_seg_decoder seg3(
  .en(~o_rx_empty),
  .bcd(rd_data[3:0]),
  .dec(o_seg3)
);

seven_seg_decoder seg4(
  .en(~o_rx_empty),
  .bcd(rd_data[7:4]),
  .dec(o_seg4)
);

seven_seg_decoder seg5(
  .en(1'b1),
  .bcd({d_num, s_num, bd_rate}),
  .dec(o_seg4)
);

seven_seg_decoder seg6(
  .en(1'b1),
  .bcd(par),
  .dec(o_seg4)
);

endmodule