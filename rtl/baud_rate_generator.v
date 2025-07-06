module baud_rate_generator#(
  parameter CLK_FREQ = 50_000_000,
  parameter BAUD_RATE = 19200, 
  parameter SAMPLING_RATE = 16,
  parameter MAX_TICKS = (CLK_FREQ + BAUD_RATE*SAMPLING_RATE - 1) / (BAUD_RATE*SAMPLING_RATE),
  parameter COUNT_WIDTH = $clog2(MAX_TICKS)
)(
  input  wire i_clk,
  input  wire i_rst_n,
  output wire o_tick
);

  reg [COUNT_WIDTH-1:0] counter;

  always @(posedge i_clk, negedge i_rst_n) begin
    if(!i_rst_n)
      counter <= 0;
    else if(counter == MAX_TICKS)
      counter <= 0;
    else
      counter <= counter + 1;
  end

  assign o_tick = (counter == MAX_TICKS);
endmodule