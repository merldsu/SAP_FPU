// Copyright 2023 MERL-DSU

// Licensed under the Apache License, Version 2.0 (the "License"); you may not use 
// this file except in compliance with the License. You may obtain a copy of the License at

//   http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed under the 
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 

module FMADD_Post_Normalization_Add_Sub(Post_Normalization_input_Mantissa,Post_Normalization_input_exponent,Post_Normalization_input_Carry,Post_Normalization_input_Eff_sub,Post_Normalization_input_Eff_add,Post_Normalization_input_Guard,Post_Normalization_input_Round,Post_Normalization_input_Sticky,Post_Normalization_output_Guard,Post_Normalization_output_Round,Post_Normalization_output_Sticky,Post_Normalization_output_Mantissa,Post_Normalization_output_exponent );

//defination of parameters
parameter std = 31;
parameter man = 22;
parameter exp = 7;
parameter lzd = 4;

//Declaration of input ports
input [man+man+3:0] Post_Normalization_input_Mantissa;
input [exp+1:0] Post_Normalization_input_exponent;
input Post_Normalization_input_Carry,Post_Normalization_input_Eff_sub,Post_Normalization_input_Eff_add,Post_Normalization_input_Guard,Post_Normalization_input_Round,Post_Normalization_input_Sticky;

//Declaration of output ports
output [man + 1 :0] Post_Normalization_output_Mantissa;
output [exp+1:0] Post_Normalization_output_exponent;
output Post_Normalization_output_Guard,Post_Normalization_output_Round,Post_Normalization_output_Sticky;

//Declaration of interim wires
wire [exp+1:0] Post_Normaliaation_Bit_Shamt_interim;
wire [exp+1:0] Post_Normaliaation_Bit_Shamt_1;
wire [man+1:0]   Post_Normaliaation_Bit_input_LZD;
wire [lzd:0]   Post_Normaliaation_Bit_output_LZD;
wire [man+1:0]   Post_Normaliaation_Bit_input_LZD_LSB;
wire [lzd:0]   Post_Normaliaation_Bit_output_LZD_LSB;
wire Post_Normaliaation_Bit_exp_LZD_Comp;
wire [exp+1:0] Post_Normaliaation_Bit_Shift_Amount,Post_Normaliaation_Bit_Shift_Amount_LSB;
wire [man+man+3:0] Post_Normalization_Shifter_Output_Sub_interim,Post_Normalization_Shifter_Output_Sub,Post_Normalization_Shifter_Output_add,Post_Normalization_Shifter_input_add;
wire [man+man+3:0] Post_Normalization_Mantissa_interim_48;
wire [exp+1:0]   Post_Normaliaation_EFF_Sub_interim_Exponent_interim,Post_Normaliaation_EFF_Sub_interim_Exponent;
wire [exp+1:0] Post_Normaliaation_EFF_add_interim_Exponent;

//Calculation of number of Zero concatinations in LZD's output
localparam  [2:0]  Post_Normalization_wire_Concatination_Amount = (man == 32'd22) ? 3'd4 : (exp == 32'd4) ? 3'd2 : (man == 32'd6 ) ? 3'd5 : 3'd0 ;

//instantition of LZD 
FPU_LZD_64 Lzd_PN_AD_MSB ( 
                   .LZD_64_input_int ( Post_Normaliaation_Bit_input_LZD ), 
                   .LZD_64_output_pos   ( Post_Normaliaation_Bit_output_LZD) 
                   ) ;
defparam Lzd_PN_AD_MSB.man = man;                  
defparam Lzd_PN_AD_MSB.lzd = lzd;

 //Calculation of number of Zero concatinations in LZD's output
localparam  [2:0]  Post_Normalization_wire_Concatination_Amount_LSB = (man == 32'd22) ? 3'd4 : (exp == 32'd4) ? 3'd2 : (man == 32'd6 ) ? 3'd5 : 3'd0 ;

//instantition of LZD 
FPU_LZD_64 Lzd_PN_AD_LSB ( 
                   .LZD_64_input_int ( Post_Normaliaation_Bit_input_LZD_LSB ), 
                   .LZD_64_output_pos   ( Post_Normaliaation_Bit_output_LZD_LSB) 
                   ) ;
defparam Lzd_PN_AD_LSB.man = man;                  
defparam Lzd_PN_AD_LSB.lzd = lzd;

//main functionality 

//subtraction lane 
assign Post_Normaliaation_Bit_Shamt_interim = Post_Normalization_input_exponent - 1'b1; 
assign Post_Normaliaation_Bit_Shamt_1 = (Post_Normalization_input_Eff_sub) ?  Post_Normaliaation_Bit_Shamt_interim : {exp+2{1'b0}};
assign Post_Normaliaation_Bit_input_LZD = (Post_Normalization_input_Eff_sub) ?  Post_Normalization_input_Mantissa[man+man+3:man+2] : {man+2{1'b0}};
assign Post_Normaliaation_Bit_exp_LZD_Comp = Post_Normalization_input_exponent > Post_Normaliaation_Bit_output_LZD;

assign Post_Normaliaation_Bit_input_LZD_LSB = (Post_Normalization_input_Eff_sub) ? Post_Normalization_input_Mantissa[man+1:0] : {man+2{1'b0}};

assign Post_Normaliaation_Bit_Shift_Amount = (Post_Normaliaation_Bit_exp_LZD_Comp) ?  {{Post_Normalization_wire_Concatination_Amount{1'b0}},Post_Normaliaation_Bit_output_LZD} : Post_Normaliaation_Bit_Shamt_1 ;
assign Post_Normalization_Shifter_Output_Sub_interim  = Post_Normalization_input_Mantissa << Post_Normaliaation_Bit_Shift_Amount;
assign Post_Normaliaation_EFF_Sub_interim_Exponent_interim = Post_Normalization_input_exponent - Post_Normaliaation_Bit_Shift_Amount ; 


assign Post_Normaliaation_Bit_Shift_Amount_LSB = (~Post_Normalization_Shifter_Output_Sub_interim[man+man+3]) ? ( ( Post_Normaliaation_EFF_Sub_interim_Exponent_interim > Post_Normaliaation_Bit_output_LZD_LSB ) ?  {{Post_Normalization_wire_Concatination_Amount_LSB{1'b0}},Post_Normaliaation_Bit_output_LZD_LSB} : (Post_Normaliaation_EFF_Sub_interim_Exponent_interim - 1'b1) ) : {exp+2{1'b0}} ;
assign Post_Normalization_Shifter_Output_Sub = Post_Normalization_Shifter_Output_Sub_interim << Post_Normaliaation_Bit_Shift_Amount_LSB;
assign Post_Normaliaation_EFF_Sub_interim_Exponent = Post_Normaliaation_EFF_Sub_interim_Exponent_interim - Post_Normaliaation_Bit_Shift_Amount_LSB;

//addition lane
assign Post_Normaliaation_EFF_add_interim_Exponent = Post_Normalization_input_exponent + Post_Normalization_input_Carry ; 
assign Post_Normalization_Shifter_input_add = (Post_Normalization_input_Eff_add) ? Post_Normalization_input_Mantissa : 48'h000000000000;
assign Post_Normalization_Shifter_Output_add = (Post_Normalization_input_Carry) ? { Post_Normalization_input_Carry,Post_Normalization_Shifter_input_add[man+man+3:1] } : Post_Normalization_Shifter_input_add[man+man+3:0]  ;

//Output Selestion and Round bits extarcion
assign Post_Normalization_Mantissa_interim_48 = (Post_Normalization_input_Eff_sub) ? Post_Normalization_Shifter_Output_Sub : Post_Normalization_Shifter_Output_add ; 

assign Post_Normalization_output_Mantissa = Post_Normalization_Mantissa_interim_48[man+man+3:man+2];
assign Post_Normalization_output_Round = Post_Normalization_Mantissa_interim_48[man] ;
assign Post_Normalization_output_Guard = Post_Normalization_Mantissa_interim_48[man+1];
assign Post_Normalization_output_Sticky = ( (|Post_Normalization_Mantissa_interim_48[man-1:0]) | Post_Normalization_input_Guard | Post_Normalization_input_Round | Post_Normalization_input_Sticky);
assign Post_Normalization_output_exponent = (Post_Normalization_input_Eff_sub) ? Post_Normaliaation_EFF_Sub_interim_Exponent : Post_Normaliaation_EFF_add_interim_Exponent;


endmodule

