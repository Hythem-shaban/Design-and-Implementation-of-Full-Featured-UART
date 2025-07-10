module tx#(
  parameter DBITS = 8,
  parameter SBITS = 2,
  parameter SAMPLING_RATE = 16
)(
  input  wire             i_clk,
  input  wire             i_rst_n,
  input  wire             i_tx_start,
  input  wire [DBITS-1:0] i_tx_data,
  input  wire             i_s_tick,
  input  wire             i_d_num,        // 1'b0:  7 data bits -- 1'b1:  8 data bits
  input  wire             i_s_num,        // 1'b0:  1 stop bit  -- 1'b1:  2 stop bits
  input  wire [1:0]       i_par,          // 2'b00: No parity   -- 2'b01: even parity -- 2'b10: odd parity
  output wire             o_tx_done,
  output wire             o_tx
);

  localparam SB_TICKS = SBITS * SAMPLING_RATE;

  localparam [2:0]  IDLE  = 3'b000,
                    START = 3'b001,
                    DATA  = 3'b010,
                    PRTY  = 3'b011,
                    STOP  = 3'b100;

  wire [$clog2(SAMPLING_RATE*2):0] sb_ticks;

  wire [DBITS-1:0] dbits;

  reg pbit;

  reg [2:0] state_reg, state_next;
  reg [$clog2(SAMPLING_RATE*2)-1:0] s_reg, s_next;
  reg [$clog2(DBITS)-1:0] n_reg, n_next;
  reg [DBITS-1:0] b_reg, b_next;
  reg tx_reg, tx_next;
  reg tx_done;

  assign sb_ticks = SAMPLING_RATE << i_s_num;

  assign dbits = i_d_num? 8'd8 : 8'd7;

  always @(*) begin
    case({i_par[0], i_d_num})
      2'b00:   pbit = ~^(i_tx_data[DBITS-2:0]);    // odd,  7 data bits
      2'b01:   pbit = ~^(i_tx_data);               // odd,  8 data bits
      2'b10:   pbit = ^(i_tx_data[DBITS-2:0]);     // even, 7 data bits
      2'b11:   pbit = ^(i_tx_data);                // even, 8 data bits
      default: pbit = ^(i_tx_data);
    endcase
  end

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
            if(n_reg == (dbits-1)) begin
              state_next = ^(i_par)? PRTY : STOP;
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
      PRTY: begin
        tx_next = pbit;
        if(i_s_tick) begin
          if(s_reg == (SAMPLING_RATE-1)) begin
            s_next = 0;
            state_next = STOP;
          end
          else begin
            s_next = s_reg + 1;
          end
        end
      end
      STOP: begin
        tx_next = 1'b1;
        if(i_s_tick) begin
          if(s_reg == (sb_ticks-1)) begin
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