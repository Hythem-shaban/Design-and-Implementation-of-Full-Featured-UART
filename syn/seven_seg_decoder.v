module seven_seg_decoder(
  input wire       en,
  input wire [3:0] bcd,
  output reg [6:0] dec
);

  always@(bcd)
    begin 
      if(en)
        case(bcd)
          0:  dec = 7'b1000000;
          1:  dec = 7'b1111001;            
          2:  dec = 7'b0100100;             
          3:  dec = 7'b0110000;              
          4:  dec = 7'b0011001;             
          5:  dec = 7'b0010010;             
          6:  dec = 7'b0000010;             
          7:  dec = 7'b1111000;             
          8:  dec = 7'b0000000;             
          9:  dec = 7'b0010000;             
          10: dec = 7'b0001000;             
          11: dec = 7'b0000011;             
          12: dec = 7'b1000110;             
          13: dec = 7'b0100001;             
          14: dec = 7'b0000110;             
          15: dec = 7'b0001110;     
          default: dec = 7'b1000000; 
        endcase 
      else
        dec = 7'b1111111;
    end
    
endmodule