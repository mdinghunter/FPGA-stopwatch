`timescale 1ns / 1ps

module sw_disp(
  input logic        clk,
  input logic        rst,
  input logic        en,
  input logic [3:0]  w,
  output logic [7:0] an,
  output logic [7:0] seg_out
);
  // declaration
  logic [3:0] d5, d4, d3, d2, d1, d0;
  logic [22:0] counter_reg, counter_next;
  logic [3:0] dec_in;
  logic [7:0] seg;

  // instantiation
  stopwatch time_logic (
    .clk,
    .rst,
    .en,
    .d5, .d4, .d3, .d2, .d1, .d0
  );

  PWM_dimmer dimmer (
    .clk,
    .w,
    .seg,
    .seg_out
  );

  // register
  always_ff @(posedge clk, posedge rst) begin
    if (rst) counter_reg <= 0;
    else if (counter_reg < 6 * 10 ** 5) counter_reg <= counter_next;
    else counter_reg <= 0;
  end
  
  // next state logic
  assign counter_next = counter_reg + 1;

  // display logic
  always_comb begin
    

    // time MUX
    if (counter_reg < 10 ** 5) begin
        an = 8'b11111011;
        dec_in = d0;
    end else if (counter_reg < 2 * 10 ** 5) begin
        an = 8'b11110111;
        dec_in = d1;
    end else if (counter_reg < 3 * 10 ** 5) begin
        an = 8'b11101111;
        dec_in = d2;
    end else if (counter_reg < 4 * 10 ** 5) begin
        an = 8'b11011111;
        dec_in = d3;
    end else if (counter_reg < 5 * 10 ** 5) begin
        an = 8'b10111111;
        dec_in = d4;        
    end else begin
        an = 8'b01111111;
        dec_in = d5;
    end
    
    // BCD decoder
    case (dec_in)
      4'h0: seg[6:0] = 7'b1000000;
      4'h1: seg[6:0] = 7'b1111001;
      4'h2: seg[6:0] = 7'b0100100;
      4'h3: seg[6:0] = 7'b0110000;
      4'h4: seg[6:0] = 7'b0011001;
      4'h5: seg[6:0] = 7'b0010010;
      4'h6: seg[6:0] = 7'b0000010;
      4'h7: seg[6:0] = 7'b1111000;
      4'h8: seg[6:0] = 7'b0000000;
      4'h9: seg[6:0] = 7'b0010000;
      default: seg[6:0] = 7'b1000000;
    endcase

    // decimal points
    case (an)
      8'b10111111 : seg[7] = 0;
      8'b11101111 : seg[7] = 0;
      default : seg[7] = 1;
    endcase
  end
endmodule