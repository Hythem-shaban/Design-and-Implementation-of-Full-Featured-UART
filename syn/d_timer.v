module d_timer 
#(
    parameter counter_final_value = 99
)
(
    input wire clk,
    input wire rst_n,
    input wire enable,
    output reg done
);

localparam counter_bits = $clog2(counter_final_value);

reg [counter_bits-1:0]	counter;

always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		done <= 0;
		
	end else begin
		if(enable) begin
			if(counter == counter_final_value) begin
				done <= 1'b1;
				counter <= 'b0;
			
			end else begin
				done <= 1'b0;
				counter <= counter + 1'b1;
			end
		end else begin
				done <= 1'b0;
				counter <= 'b0;
		end
	end
end
endmodule