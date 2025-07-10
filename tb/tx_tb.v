module tx_tb;
  parameter CLK_PERIOD = 20;
  parameter CLK_FREQ = 50_000_000;
  parameter DBITS = 8;
  parameter SBITS = 2;
  parameter DEPTH = 8;

  reg             i_clk;
  reg             i_rst_n;
  reg [DBITS-1:0] i_wr_data;
  reg             i_wr;
  reg             i_d_num;        // 1'b0:  7 data bits -- 1'b1:  8 data bits
  reg             i_s_num;        // 1'b0:  1 stop bit  -- 1'b1:  2 stop bits
  reg [1:0]       i_par;          // 2'b00: No parity   -- 2'b01: even parity -- 2'b10: odd parity
  reg [1:0]       i_bd_rate;
  wire            o_tx;
  wire            o_full;

  initial begin
    initialize();
    reset();  
    repeat(max_ticks(1200)*16*2) begin
      #(CLK_PERIOD);
    end
    set_config(2'b00, 1'b1, 1'b0, 2'b00);
    fifo_write($random()); // no parity, 8 data bits, 1 stop bit, 1200 baud rate
    repeat(max_ticks(1200)*16*10) begin
      #(CLK_PERIOD);
    end
    
    set_config(2'b00, 1'b1, 1'b0, 2'b00);
    fifo_write($random()); // even parity, 8 data bits, 1 stop bit, 1200 baud rate
    fifo_write($random()); // even parity, 8 data bits, 1 stop bit, 1200 baud rate
    fifo_write($random()); // even parity, 8 data bits, 1 stop bit, 1200 baud rate
    fifo_write($random()); // even parity, 8 data bits, 1 stop bit, 1200 baud rate
    repeat(max_ticks(1200)*16*11) begin
      #(CLK_PERIOD);
    end

    set_config(2'b10, 1'b1, 1'b0, 2'b00);
    fifo_write($random()); // odd parity, 8 data bits, 1 stop bit, 1200 baud rate
    repeat(max_ticks(1200)*16*11) begin
      #(CLK_PERIOD);
    end

    set_config(2'b10, 1'b0, 1'b0, 2'b00);
    fifo_write($random()); // odd parity, 7 data bits, 1 stop bit, 1200 baud rate
    repeat(max_ticks(1200)*16*10) begin
      #(CLK_PERIOD);
    end

    set_config(2'b10, 1'b1, 1'b1, 2'b00);
    fifo_write($random()); // odd parity, 8 data bits, 2 stop bit, 1200 baud rate
    repeat(max_ticks(1200)*16*12) begin
      #(CLK_PERIOD);
    end

    set_config(2'b10, 1'b1, 1'b1, 2'b01);
    fifo_write($random()); // odd parity, 8 data bits, 2 stop bit, 2400 baud rate
    repeat(max_ticks(2400)*16*12) begin
      #(CLK_PERIOD);
    end
    
    $stop;
  end

  task initialize();
    begin
      i_clk = 0;
      i_rst_n = 0;
      i_wr = 0;
      i_d_num = 1;
      i_s_num = 0;
      i_par = 2'b00;
      i_bd_rate = 2'b00;
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
        i_wr = 1'b1;
        #(CLK_PERIOD);
        i_wr = 1'b0;
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
    input integer baud_rate;
    parameter CLK_FREQ = 50_000_000;
    parameter SAMPLING_RATE = 16;
    begin
      max_ticks = (CLK_FREQ + baud_rate*SAMPLING_RATE - 1) / (baud_rate*SAMPLING_RATE);
    end
  endfunction

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars;
  end

  always #(CLK_PERIOD/2.0) i_clk = ~i_clk;

  tx_top#(
    .CLK_FREQ(50_000_000),
    .DEPTH(DEPTH),
    .DBITS(DBITS),
    .SBITS(SBITS)
  ) dut(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_wr_data(i_wr_data),
    .i_wr(i_wr),
    .i_d_num(i_d_num),      
    .i_s_num(i_s_num),      
    .i_par(i_par),          
    .i_bd_rate(i_bd_rate),
    .o_tx(o_tx),
    .o_full(o_full)
  );

endmodule