module baud_rate_generator#(
  parameter CLK_FREQ = 50_000_000,
  parameter BAUD_RATE = 1200, 
  parameter SAMPLING_RATE = 16,
  parameter MAX_TICKS = (CLK_FREQ + BAUD_RATE*SAMPLING_RATE - 1) / (BAUD_RATE*SAMPLING_RATE),
  parameter COUNT_WIDTH = $clog2(MAX_TICKS)
)(
  input  wire       i_clk,
  input  wire       i_rst_n,
  input  wire [1:0] i_bd_rate,
  output wire       o_tick
);

  reg [13:0] baud_rate;

  wire [17:0] denomenator;

  wire [COUNT_WIDTH-1:0] max_ticks;

  reg [COUNT_WIDTH-1:0] counter;

  always @(*) begin
    case (i_bd_rate)
      2'b00:   baud_rate = 1200;
      2'b01:   baud_rate = 2400;
      2'b10:   baud_rate = 4800;
      2'b11:   baud_rate = 9600;
      default: baud_rate = 9600;
    endcase
  end

  assign denomenator = baud_rate*SAMPLING_RATE;
  assign max_ticks = (CLK_FREQ + denomenator - 1) / (denomenator);

  always @(posedge i_clk, negedge i_rst_n) begin
    if(!i_rst_n)
      counter <= 0;
    else if(counter == max_ticks)
      counter <= 0;
    else
      counter <= counter + 1;
  end

  assign o_tick = (counter == max_ticks);
endmodule