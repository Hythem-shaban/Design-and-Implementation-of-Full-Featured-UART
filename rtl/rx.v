module rx#(
  parameter DBITS = 8,
  parameter SBITS = 1,
  parameter SAMPLING_RATE = 16
)(
  input  wire             i_clk,
  input  wire             i_rst_n,
  input  wire             i_rx,
  input  wire             i_s_tick,
  output wire             o_rx_done,
  output wire [DBITS-1:0] o_rx_data
);

  localparam SB_TICKS = SBITS * SAMPLING_RATE;

  localparam [2:0]  IDLE  = 3'b000,
                    START = 3'b001,
                    DATA  = 3'b010,
                    PRTY  = 3'b011,
                    STOP  = 3'b100;

  reg [1:0] state_reg, state_next;
  reg [$clog2(SAMPLING_RATE)-1:0] s_reg, s_next;
  reg [$clog2(DBITS)-1:0] n_reg, n_next;
  reg [DBITS-1:0] b_reg, b_next;
  reg rx_done;

  always @(posedge i_clk, negedge i_rst_n) begin
    if(!i_rst_n) begin
      state_reg <= IDLE;
      s_reg <= 'b0;
      n_reg <= 'b0;
      b_reg <= 'b0;
    end
    else begin
      state_reg <= state_next;
      s_reg <= s_next;
      n_reg <= n_next;
      b_reg <= b_next;
    end
  end

  always @(*) begin
    state_next = state_reg;
    s_next = s_reg;
    n_next = n_reg;
    b_next = b_reg;
    rx_done = 1'b0;
    case (state_reg)
      IDLE: begin
        if(!i_rx) begin
          state_next = START;
          s_next = 'b0;
        end
      end
      START: begin
        if(i_s_tick) begin
          if(s_reg == (SAMPLING_RATE/2-1)) begin
            state_next = DATA;
            s_next = 0;
            n_next = 0;
          end
          else begin
            s_next = s_reg + 1;
          end
        end
      end
      DATA: begin
        if(i_s_tick) begin
          if(s_reg == (SAMPLING_RATE-1)) begin
            s_next = 0;
            b_next = {i_rx, b_reg[DBITS-1:1]};
            if(n_reg == (DBITS-1)) begin
              state_next = STOP;
            end
            else begin
              n_next = n_reg + 1;
            end
          end
          else begin
            s_next = s_reg + 1;
          end
        end
      end
      STOP: begin
        if(i_s_tick) begin
          if(s_reg == (SB_TICKS-1)) begin
            state_next = IDLE;
            rx_done = 1'b1;
          end
          else begin
            s_next = s_reg + 1;
          end
        end
      end
      default: begin
        state_next = IDLE;
      end
    endcase
  end

  assign o_rx_data = b_reg;
  assign o_rx_done = rx_done;

  
endmodule