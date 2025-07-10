module uart_tb;
  parameter CLK_PERIOD = 20;
  parameter CLK_FREQ = 50_000_000;
  parameter BAUD_RATE = 1200;
  parameter SAMPLING_RATE = 16;
  parameter DBITS = 8;
  parameter SBITS = 2;
  parameter FIFO_DEPTH = 8;

  reg              i_clk;
  reg              i_rst_n;
  reg              i_wr_uart;
  reg              i_rd_uart;
  reg  [DBITS-1:0] i_wr_data;
  reg  [1:0]       i_bd_rate;
  reg              i_d_num;
  reg              i_s_num;
  reg  [1:0]       i_par;
  wire              i_rx;
  wire             o_tx;
  wire             o_rx_empty;
  wire             o_tx_full;
  wire             o_rx_full;
  wire [2:0]       o_err;
  wire [DBITS-1:0] o_rd_data;

  assign i_rx = o_tx;

  initial begin
    initialize();
    reset();

    set_config(2'b00, 1'b1, 1'b0, 2'b00); // no parity, 8 data bits, 1 stop bit, 1200 baud rate
    fifo_write($random());
    @(posedge dut.tx_u.o_tx_done);
    fifo_read();

    set_config(2'b01, 1'b1, 1'b1, 2'b01); // even parity, 8 data bits, 2 stop bit, 2400 baud rate
    fifo_write($random());
    @(posedge dut.tx_u.o_tx_done);
    fifo_read();

    set_config(2'b10, 1'b1, 1'b1, 2'b10); // odd parity, 8 data bits, 2 stop bit, 4800 baud rate
    fifo_write($random());
    @(posedge dut.tx_u.o_tx_done);
    fifo_read();

    set_config(2'b00, 1'b0, 1'b1, 2'b11); // no parity, 7 data bits, 2 stop bit, 9600 baud rate
    fifo_write($random());
    @(posedge dut.tx_u.o_tx_done);
    fifo_read();
    $stop;

  end

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars;
  end

  task initialize();
    begin
      i_clk = 0;
      i_rst_n = 0;
      i_wr_uart = 0;
      i_rd_uart = 0;
      i_bd_rate = 2'b00;
      i_d_num = 1;
      i_s_num = 0;
      i_par = 2'b00;
    end
  endtask

  task reset();
    begin
      i_rst_n = 0;
      #(CLK_PERIOD);
      i_rst_n = 1;
    end
  endtask

  task fifo_write;
    input [DBITS-1:0] wr_data;
    begin      
        i_wr_data = wr_data;
        i_wr_uart = 1'b1;
        #(CLK_PERIOD);
        i_wr_uart = 1'b0;
        #(CLK_PERIOD);
    end
  endtask

  task fifo_read;
    begin
        #(CLK_PERIOD);
        i_rd_uart = 1'b1;
        #(CLK_PERIOD);
        i_rd_uart = 1'b0;
        #(CLK_PERIOD);
    end
  endtask

  task set_config;
    input [1:0] par;
    input d_num;
    input s_num;
    input [1:0] bd_rate;
    begin      
      i_par = par;
      i_d_num = d_num;
      i_s_num = s_num;
      i_bd_rate = bd_rate;
    end
  endtask

  function integer max_ticks;
    input [1:0] bd_rate;
    integer baud_rate;
    begin
      case (bd_rate)
        2'b00:   baud_rate = 1200;
        2'b01:   baud_rate = 2400; 
        2'b10:   baud_rate = 4800; 
        2'b11:   baud_rate = 9600; 
        default: baud_rate = 9600; 
      endcase
      max_ticks = (CLK_FREQ + baud_rate*SAMPLING_RATE - 1) / (baud_rate*SAMPLING_RATE);
    end
  endfunction


  always #(CLK_PERIOD/2.0) i_clk = ~i_clk;

  uart#(
  .CLK_FREQ(CLK_FREQ),
  .BAUD_RATE(BAUD_RATE),
  .SAMPLING_RATE(SAMPLING_RATE),
  .DBITS(DBITS),
  .SBITS(SBITS),
  .FIFO_DEPTH(FIFO_DEPTH)
  ) dut(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_wr_uart(i_wr_uart),
    .i_rd_uart(i_rd_uart),
    .i_wr_data(i_wr_data),
    .i_bd_rate(i_bd_rate),
    .i_d_num(i_d_num),
    .i_s_num(i_s_num),
    .i_par(i_par),
    .i_rx(i_rx),
    .o_tx(o_tx),
    .o_rx_empty(o_rx_empty),
    .o_tx_full(o_tx_full),
    .o_rx_full(o_rx_full),
    .o_err(o_err),
    .o_rd_data(o_rd_data)
  );
endmodule