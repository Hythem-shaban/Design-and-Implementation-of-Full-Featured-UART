module fifo#(
  parameter WIDTH = 8,
  parameter DEPTH = 8
)(
  input wire              i_clk,
  input wire              i_rst_n,
  input wire  [WIDTH-1:0] i_wr_data,
  input wire              i_wr,
  input wire              i_rd,
  output wire [WIDTH-1:0] o_rd_data,
  output wire             o_full,
  output wire             o_empty
);
  
  reg [WIDTH-1:0] mem [0:DEPTH-1];

  reg [$clog2(DEPTH):0] wr_ptr, rd_ptr;

  assign o_full  = (wr_ptr[$clog2(DEPTH)] != rd_ptr[$clog2(DEPTH)]) && (wr_ptr[$clog2(DEPTH)-1:0] == rd_ptr[$clog2(DEPTH)-1:0]);
  assign o_empty = (rd_ptr == wr_ptr);

  always @(posedge i_clk, negedge i_rst_n) begin
    if(!i_rst_n) begin
      wr_ptr <= 'b0;
    end
    else if(i_wr && !o_full) begin
      mem[wr_ptr[$clog2(DEPTH)-1:0]] <= i_wr_data;
      wr_ptr <= wr_ptr + 1;
    end
    else if(i_wr && i_rd) begin
      mem[wr_ptr[$clog2(DEPTH)-1:0]] <= i_wr_data;
      wr_ptr <= wr_ptr + 1;
    end
  end

  assign o_rd_data = mem[rd_ptr[$clog2(DEPTH)-1:0]];

  always @(posedge i_clk, negedge i_rst_n) begin
    if(!i_rst_n) begin
      rd_ptr <= 'b0;
    end
    else if(i_rd && !o_empty) begin
      rd_ptr <= rd_ptr + 1;
    end
    else if(i_wr && i_rd) begin
      rd_ptr <= rd_ptr + 1;
    end
  end

endmodule