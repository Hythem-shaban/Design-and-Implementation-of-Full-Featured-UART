module d_fsm 
(
	input wire clk,
	input wire rst_n,
	input wire noisy_sig, 
	input wire timer_done,
	output reg debounced_sig, 
	output reg timer_en
);
	
reg [1:0] current_state, next_state;


localparam [1:0] idle = 2'b1,		//low state
				 check_low = 2'b0,
				 low_state = 2'b10,
				 check_high = 2'b11;
				 

//current state transition
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		current_state <= idle;
	
	end else begin
		current_state <= next_state;
	end
end

//next state logic
always @ (*) begin
	case(current_state)
		idle: begin
				if(!noisy_sig)
					next_state <= check_low;
				else
					next_state <= idle;
		end
		
		check_low: begin
				if(!noisy_sig && timer_done)
					next_state <= low_state;
					
				else if (!noisy_sig && !timer_done)
					next_state <= check_low;
					
				else
					next_state <= idle;
		end
		
		low_state: begin
				if(!noisy_sig)
					next_state <= low_state;
				else
					next_state <= check_high;
		end
		
		check_high: begin
				if(noisy_sig && timer_done)
					next_state <= idle;
					
				else if (noisy_sig && !timer_done)
					next_state <= check_high;
					
				else
					next_state <= low_state;
		end
		
		default: next_state <= idle;
	endcase
end

//moore FSM outputs logic
always @ (*) begin
	case(current_state)
		idle: begin
				debounced_sig = 1;
				timer_en = 0;
		end
		
		check_low: begin
				debounced_sig = 1;
				timer_en = 1;
		end
		
		low_state: begin
				debounced_sig = 0;
				timer_en <= 0;
		end
		
		check_high: begin
				debounced_sig = 0;
				timer_en <= 1;
		end
		
		default: begin
				debounced_sig = 1;
				timer_en <= 0;
		end
	endcase
end
endmodule