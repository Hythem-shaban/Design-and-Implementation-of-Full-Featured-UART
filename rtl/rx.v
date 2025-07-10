module rx#(
  parameter DBITS = 8,
  parameter SBITS = 2,
  parameter SAMPLING_RATE = 16
)(
  input  wire             i_clk,
  input  wire             i_rst_n,
  input  wire             i_rx,
  input  wire             i_s_tick,
  input  wire             i_d_num,
  input  wire             i_s_num, 
  input  wire [1:0]       i_par,
  output wire [2:0]       o_err,        // o_err = {start_err, parity_err, stop_err}
  output wire             o_rx_done,
  output wire [DBITS-1:0] o_rx_data
);

  localparam SB_TICKS = SBITS * SAMPLING_RATE;

  localparam [2:0]  IDLE  = 3'b000,
                    START = 3'b001,
                    DATA  = 3'b010,
                    PRTY  = 3'b011,
                    STOP  = 3'b100;

  wire [$clog2(SAMPLING_RATE*2):0] sb_ticks;

  wire [DBITS-1:0] dbits;

  reg stop_err, start_err, parity_err;

  reg stop_check, start_check, parity_check;

  reg [2:0] state_reg, state_next;
  reg [$clog2(SAMPLING_RATE*2)-1:0] s_reg, s_next;
  reg [$clog2(DBITS)-1:0] n_reg, n_next;
  reg [DBITS-1:0] b_reg, b_next;
  reg rx_done;

  assign sb_ticks = SAMPLING_RATE << i_s_num;

  assign dbits = i_d_num? 8'd8 : 8'd7;

  assign o_err = {stop_err, parity_err, start_err};

  always @(posedge i_clk, negedge i_rst_n) begin
    if(!i_rst_n)
      start_err <= 1'b0;
    else if(start_check)
      start_err <= (i_rx == 1'b0)? 1'b0 : 1'b1;
  end

  always @(posedge i_clk, negedge i_rst_n) begin
    if(!i_rst_n)
      stop_err <= 1'b0;
    else if(stop_check)
      stop_err <= (i_rx == 1'b1)? 1'b0 : 1'b1;
  end

  always @(posedge i_clk, negedge i_rst_n) begin
    if(!i_rst_n)
      parity_err <= 1'b0;
    else if(parity_check)
      case({i_par, i_d_num})
        2'b00:   parity_err <= ~^({o_rx_data[DBITS-2:0], i_rx});    // odd,  7 data bits
        2'b01:   parity_err <= ~^({o_rx_data, i_rx});               // odd,  8 data bits
        2'b10:   parity_err <= ^({o_rx_data[DBITS-2:0], i_rx});     // even, 7 data bits
        2'b11:   parity_err <= ^({o_rx_data, i_rx});                // even, 8 data bits
        default: parity_err <= 1'b0;
      endcase
  end

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
    start_check = 1'b0;
    parity_check = 1'b0;
    stop_check = 1'b0;
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
            start_check = 1'b1;
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
            if(n_reg == (dbits - 1)) begin
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
        if(i_s_tick) begin
          if(s_reg == (SAMPLING_RATE-1)) begin
            s_next = 0;
            parity_check = 1'b1;
            state_next = STOP;
          end
          else begin
            s_next = s_reg + 1;
          end
        end
      end
      STOP: begin
        if(i_s_tick) begin
          if(s_reg == (sb_ticks-1)) begin
            state_next = IDLE;
            stop_check = 1'b1;
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

  assign o_rx_data = i_d_num? b_reg : {b_reg >> 1};
  assign o_rx_done = rx_done;
  
endmodule