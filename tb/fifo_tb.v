module fifo_tb;
  parameter CLK_PERIOD = 10;
  parameter WIDTH = 8;
  parameter DEPTH = 8;

  reg              i_clk;
  reg              i_rst_n;
  reg  [WIDTH-1:0] i_wr_data;
  reg              i_wr;
  reg              i_rd;
  wire [WIDTH-1:0] o_rd_data;
  wire             o_full;
  wire             o_empty;

  always #(CLK_PERIOD/2.0) i_clk = ~i_clk;

  integer i;
  initial begin
    initialize();
    reset();
    
    // Test Write and Full
    for (i=0; i<20; i=i+1) begin
      i_wr_data = 10+i;
      i_wr = 1;
      #(CLK_PERIOD);
      i_wr = 0;
      #(CLK_PERIOD);
    end
    

    // Test Read and Empty
    for (i=0; i<20; i=i+1) begin
      i_rd = 1;
      #(CLK_PERIOD);
      i_rd = 0;
      #(CLK_PERIOD);
    end

    // Test Read and Write When Empty 
    for (i=0; i<20; i=i+1) begin
      i_wr_data = 10+i;
      i_wr = 1;
      i_rd = 1;
      #(CLK_PERIOD);
      i_wr = 0;
      i_rd = 0;
      #(CLK_PERIOD);
    end

    // Test Read and Write When Full 
    for (i=0; i<20; i=i+1) begin
      i_wr_data = 10+i;
      i_wr = 1;
      #(CLK_PERIOD);
      i_wr = 0;
      #(CLK_PERIOD);
    end
    for (i=0; i<20; i=i+1) begin
      i_wr_data = 10+i;
      i_wr = 1;
      i_rd = 1;
      #(CLK_PERIOD);
      i_wr = 0;
      i_rd = 0;
      #(CLK_PERIOD);
    end

    $stop;

  end

  task initialize();
    begin
      i_clk = 0;
      i_rst_n = 0;
      i_wr = 0;
      i_rd = 0;
    end
  endtask

  task reset();
    begin
      i_rst_n = 0;
      #(CLK_PERIOD);
      i_rst_n = 1;
    end
  endtask

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars;
  end

  fifo#(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH)
  ) dut(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_wr_data(i_wr_data),
    .i_wr(i_wr),
    .i_rd(i_rd),
    .o_rd_data(o_rd_data),
    .o_full(o_full),
    .o_empty(o_empty)
  );
endmodule