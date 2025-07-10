module rx_tb;
  parameter CLK_PERIOD = 20;
  parameter CLK_FREQ = 50_000_000;
  parameter DBITS = 8;
  parameter SBITS = 2;
  parameter DEPTH = 8;

  reg              i_clk;
  reg              i_rst_n;
  reg              i_rx;
  reg              i_rd;
  reg              i_d_num;        // 1'b0:  7 data bits -- 1'b1:  8 data bits
  reg              i_s_num;        // 1'b0:  1 stop bit  -- 1'b1:  2 stop bits
  reg  [1:0]       i_par;          // 2'b00: No parity   -- 2'b01: even parity -- 2'b10: odd parity
  reg  [1:0]       i_bd_rate;
  wire [DBITS-1:0] o_rd_data;
  wire [2:0]       o_err;          // {start, parity, stop}
  wire             o_empty;

  initial begin
    initialize();
    reset();  
    //      (data     , no parity  , d_num=8, s_num=1, bd_rate=1200)
    //drive_rx($random(), 2'b00      , 1'b1   , 1'b0   , 2'b00       );
    //      (data     , no parity  , d_num=7, s_num=1, bd_rate=1200)
    drive_rx($random(), 2'b00      , 1'b0   , 1'b0   , 2'b00       );
    //      (data     , no parity  , d_num=8, s_num=2, bd_rate=1200)
    drive_rx($random(), 2'b00      , 1'b1   , 1'b1   , 2'b00       );
    //      (data     , even parity, d_num=8, s_num=1, bd_rate=1200)
    drive_rx($random(), 2'b01      , 1'b1   , 1'b0   , 2'b00       );
    //      (data     , odd parity , d_num=8, s_num=1, bd_rate=1200)
    drive_rx($random(), 2'b10      , 1'b1   , 1'b0   , 2'b00       );
    //      (data     , even parity, d_num=8, s_num=1, bd_rate=9600)
    drive_rx($random(), 2'b01      , 1'b1   , 1'b0   , 2'b11       );
    
    $stop;
  end

  task initialize();
    begin
      i_clk = 0;
      i_rst_n = 0;
      i_rd = 0;
      i_rx = 1;
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

  task drive_rx;
    input [DBITS-1:0] IN_Data;
    input [1:0] par;
    input d_num;
    input s_num;
    input [1:0] bd_rate;
    reg parity_bit;
    integer i,j;
    integer dbits;
    integer sbits;
    integer baud_rate;
    begin
      set_config(par, d_num, s_num, bd_rate);
      dbits = d_num? 8 : 7;
      sbits = s_num? 2 : 1;
      case (bd_rate)
        2'b00:   baud_rate = 1200;
        2'b01:   baud_rate = 2400; 
        2'b10:   baud_rate = 4800; 
        2'b11:   baud_rate = 9600; 
        default: baud_rate = 9600; 
      endcase

      i_rx = 0;
      repeat(max_ticks(baud_rate)*16) begin
        #(CLK_PERIOD);
      end

      for(i=0; i<dbits; i=i+1) begin
        i_rx = IN_Data[i];
        repeat(max_ticks(baud_rate)*16) begin
          #(CLK_PERIOD);
        end
      end

      if(^par) begin
        parity_bit = par[0]? (^IN_Data) : (~^IN_Data);
        i_rx = parity_bit;
        repeat(max_ticks(baud_rate)*16) begin
          #(CLK_PERIOD);
        end
      end

      for(i=0; i<sbits; i=i+1) begin
        i_rx = 1'b1;
        repeat(max_ticks(baud_rate)*16) begin
          #(CLK_PERIOD);
        end
      end
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

  rx_top#(
    .CLK_FREQ(50_000_000),
    .DEPTH(DEPTH),
    .DBITS(DBITS),
    .SBITS(SBITS)
  ) dut(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_rx(i_rx),
    .i_rd(i_rd),
    .i_d_num(i_d_num),      
    .i_s_num(i_s_num),      
    .i_par(i_par),          
    .i_bd_rate(i_bd_rate),
    .o_rd_data(o_rd_data),
    .o_err(o_err),
    .o_empty(o_empty)
  );

endmodule