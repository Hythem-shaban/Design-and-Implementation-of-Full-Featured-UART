module tx#(
  parameter DBITS = 8,
  parameter SBITS = 1,
  parameter SAMPLING_RATE = 16
)(
  input  wire             i_clk,
  input  wire             i_rst_n,
  input  wire             i_tx_start,
  input  wire [DBITS-1:0] i_tx_data,
  input  wire             i_s_tick,
  output wire             o_tx_done,
  output wire             o_tx
);

  localparam SB_TICKS = SBITS * SAMPLING_RATE;

  localparam [1:0]  IDLE = 2'b00,
                    START = 2'b01,
                    DATA = 2'b10,
                    STOP = 2'b11;

  reg [1:0] state_reg, state_next;
  reg [$clog2(SAMPLING_RATE)-1:0] s_reg, s_next;
  reg [$clog2(DBITS)-1:0] n_reg, n_next;
  reg [DBITS-1:0] b_reg, b_next;
  reg tx_reg, tx_next;
  reg tx_done;

  always @(posedge i_clk, negedge i_rst_n) begin
    if(!i_rst_n) begin
      state_reg <= IDLE;
      s_reg <= 'b0;
      n_reg <= 'b0;
      b_reg <= 'b0;
      tx_reg <= 1'b1;
    end
    else begin
      state_reg <= state_next;
      s_reg <= s_next;
      n_reg <= n_next;
      b_reg <= b_next;
      tx_reg <= tx_next;
    end
  end

  always @(*) begin
    state_next = state_reg;
    s_next = s_reg;
    n_next = n_reg;
    b_next = b_reg;
    tx_done = 1'b0;
    case(state_reg)
      IDLE: begin
        tx_next = 1'b1;
        if(i_tx_start) begin
          state_next = START;
          s_next = 0;
          b_next = i_tx_data;
        end
      end 
      START: begin
        tx_next = 1'b0;
        if(i_s_tick) begin
          if(s_reg == (SAMPLING_RATE-1)) begin
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
        tx_next = b_reg[0];
        if(i_s_tick) begin
          if(s_reg == (SAMPLING_RATE-1)) begin
            s_next = 0;
            b_next = {1'b0, b_reg[DBITS-1:1]};
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
        tx_next = 1'b1;
        if(i_s_tick) begin
          if(s_reg == (SB_TICKS-1)) begin
            tx_done = 1'b1;
            state_next = IDLE;
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

  assign o_tx = tx_reg;
  assign o_tx_done = tx_done;

endmodule