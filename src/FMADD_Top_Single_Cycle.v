// Copyright 2023 MERL-DSU

// Licensed under the Apache License, Version 2.0 (the "License"); you may not use 
// this file except in compliance with the License. You may obtain a copy of the License at

//   http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed under the 
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 

module FPU_FMADD_SUBB_Top (FMADD_SUBB_input_IEEE_A, FMADD_SUBB_input_IEEE_B, FMADD_SUBB_input_IEEE_C, FMADD_SUBB_input_opcode,rst_l,FMADD_SUBB_input_Frm,FMADD_SUBB_output_IEEE_FMADD, FMADD_SUBB_output_S_Flags_FMADD, FMADD_SUBB_output_IEEE_FMUL, FMADD_SUBB_output_S_Flags_FMUL );

parameter std =31;
parameter man =22;
parameter exp =7;
parameter bias = 127;
parameter lzd = 4;

//Opcodes description
/*
Opcodes[0] = Fadd
Opcodes[1] = Fsubb
Opcodes[2] = Fmul
Opcodes[3] = Fmadd
Opcodes[4] = Fmsubb
Opcodes[5] = Fnmadd
Opcodes[6] = Fnmsubb
*/

//declaration of inputs
input  [std:0] FMADD_SUBB_input_IEEE_A, FMADD_SUBB_input_IEEE_B,FMADD_SUBB_input_IEEE_C;
input [6:0] FMADD_SUBB_input_opcode;
input [2:0] FMADD_SUBB_input_Frm;
input rst_l;

//declaration of putputs
output  [std:0] FMADD_SUBB_output_IEEE_FMADD, FMADD_SUBB_output_IEEE_FMUL;
output  [2:0] FMADD_SUBB_output_S_Flags_FMADD , FMADD_SUBB_output_S_Flags_FMUL;
//output FMADD_SUBB_output_FMADD_Ready_Flag;

//Wires
wire Activation_signal_MUL,Activation_signal;
wire [std:0] input_interim_Mantissa_gnerator_A,input_interim_Mantissa_gnerator_B,input_interim_Mantissa_gnerator_C;
wire [std+1:0] output_interim_M_G_A,output_interim_M_G_B,output_interim_M_G_C;
wire output_interim_A_sub_norm,output_interim_B_sub_norm,output_interim_A_pos_exp,output_interim_B_pos_exp,output_interim_A_neg_exp,output_interim_B_neg_exp;

//Extender wires
wire [std+1 : 0] input_Extender_B;
wire [2+exp+2*(man+2):0] output_interim_Extender_A,output_interim_Extender_B;

//Exponent addition multiplication wires
wire [4:0] input_interim_exponent_addition_opcodes;
wire input_Exponent_Addition_input_Sign_A;
wire [exp+1 : 0] output_interim_exponent_addition;
wire output_interim_exponent_addition_sign;


//Mantissa Multiplication wires
wire [man+man+3 :0] output_interim_mantissa_multiplication;

//LZD wires
wire [man+1:0] input_LZD;
wire [lzd : 0] output_LZD;
wire [man+1 : 0] input_interim_A_LZD,  input_interim_B_LZD ;

//Post normalization multiplication wires
wire [2+exp+2*(man+2):0] output_interim_post_normalization_IEEE_A;
wire  output_interim_post_normalization_mul_sticky;
wire underflow_FMUL;

//Rounding block multiplication wires
wire [std:0] output_rounding_Block;
wire [2:0] output_interim_rounding_Block_S_Flag;

//Addition lane wires
wire [2+exp+2*(man+2):0] input_interim_ADD_LANE_A;
wire [2+exp+2*(man+2):0] input_interim_ADD_LANE_B;
wire [2+exp+2*(man+2):0] output_interim_post_normalization_IEEE;

//Exponent matching wires
wire output_interim_Exponent_Mathcing_Sign;
wire [man+man+3:0] output_interim_Exponent_Mathcing_Mantissa_A;
wire [man+man+3:0] output_interim_Exponent_Mathcing_Mantissa_B;
wire [exp+1:0] output_interim_Exponent_Mathcing_Exponent;
wire output_interim_Exponent_Mathcing_Eff_add;
wire output_interim_Exponent_Mathcing_Eff_sub;
wire output_interim_Exponent_Mathcing_Guard;
wire output_interim_Exponent_Mathcing_Round;
wire output_interim_Exponent_Mathcing_Sticky;
wire output_interim_Exponent_Mathcing_Exp_Diff_Check;
wire output_interim_Exponent_Mathcing_A_gt_B;
wire output_interim_Exponent_Mathcing_A_eq_B;
wire output_interim_Exponent_Mathcing_Subnorm_Number;

//Mantissa addition wires
wire [man+man+3:0] output_interim_Mantissa_Addition_Mantissa;
wire output_interim_Mantissa_Addition_Carry;

//Addition post normalization wires
wire output_interim_Post_Norm_Add_Guard;
wire output_interim_Post_Norm_Add_Round;
wire output_interim_Post_Norm_Add_Sticky;
wire [exp+1:0] output_interim_Post_Norm_Add_Exponent;
wire [man+1:0] output_interim_Post_Norm_Add_Mantissa;

//Addition rounding module wires
wire [exp:0] output_interim_Rounding_Block_Exp;
wire [man:0] output_interim_Rounding_Block_Mantissa;
wire  output_interim_Rounding_Block_Sign;
wire [2:0] output_interim_Rounding_Block_S_flags;
wire [2:0] input_rounding_block_Add_frm;

//Reset condition
assign input_interim_Mantissa_gnerator_A = (rst_l)  ? FMADD_SUBB_input_IEEE_A : { std+1 {1'b0} };
assign input_interim_Mantissa_gnerator_B = (rst_l)  ? FMADD_SUBB_input_IEEE_B : { std+1 {1'b0} };
assign input_interim_Mantissa_gnerator_C = (rst_l)  ? FMADD_SUBB_input_IEEE_C : { std+1 {1'b0} };
assign Activation_signal_MUL = (rst_l) ? ( |(FMADD_SUBB_input_opcode[6:2]) ) : 1'b0;
assign Activation_signal = (rst_l) ? ( | (FMADD_SUBB_input_opcode[6:0])) : 1'b0;

//instantiation of sub modules
//mantissa generation modules: This module concatenates the hidden bit, and sets the exponent in accordance with the type of number (Normal Sub_Normal)v
FMADD_Mantissa_Generator Mantissa_Generator ( 
                        .Mantissa_Generator_input_IEEE_A (input_interim_Mantissa_gnerator_A),
                        .Mantissa_Generator_input_IEEE_B (input_interim_Mantissa_gnerator_B),
                        .Mantissa_Generator_input_IEEE_C (input_interim_Mantissa_gnerator_C),
                        .Mantissa_Generator_input_Activation_signal (Activation_signal),
                        .Mantissa_Generator_output_A_Sub_norm(output_interim_A_sub_norm),
                        .Mantissa_Generator_output_B_Sub_norm(output_interim_B_sub_norm),
                        .Mantissa_Generator_output_A_pos_exp(output_interim_A_pos_exp),
                        .Mantissa_Generator_output_B_pos_exp(output_interim_B_pos_exp),
                        .Mantissa_Generator_output_A_neg_exp(output_interim_A_neg_exp),
                        .Mantissa_Generator_output_B_neg_exp(output_interim_B_neg_exp),
                        .Mantissa_Generator_output_IEEE_A (output_interim_M_G_A),
                        .Mantissa_Generator_output_IEEE_B (output_interim_M_G_B),
                        .Mantissa_Generator_output_IEEE_C (output_interim_M_G_C)
 );
defparam Mantissa_Generator.std = std;
defparam Mantissa_Generator.man = man;
defparam Mantissa_Generator.exp = exp;

//extend  module : This module is responsible for making the input representable in IEEE exteded format
//selection of the second operand of the extender : If addition is the inputted instruction B goes to extender otherwise C goes to the Extender
assign input_Extender_B = (| FMADD_SUBB_input_opcode[1:0]) ? output_interim_M_G_B : output_interim_M_G_C;
FMADD_Extender Extender (
              .Extender_input_A(output_interim_M_G_A),
              .Extender_input_B(input_Extender_B),
              .Extender_output_A(output_interim_Extender_A),
              .Extender_output_B(output_interim_Extender_B)
);
defparam Extender.std = std;
defparam Extender.man = man;
defparam Extender.exp = exp;

//exponent addition module: This module is repsonsible for carrying out tje first operation of Multiplication i.e.e exponent addition
assign input_Exponent_Addition_input_Sign_A = ( |FMADD_SUBB_input_opcode[6:5] ) ? (~output_interim_M_G_A[std+1]) : (output_interim_M_G_A[std+1]) ;

FMADD_Exponent_addition Exponent_Addition (
                       .Exponent_addition_input_A({ input_Exponent_Addition_input_Sign_A, output_interim_M_G_A[std:man+2] } ),
                       .Exponent_addition_input_B(output_interim_M_G_B[std+1:man+2]),
                       .Exponent_addition_input_Activation_Signal (Activation_signal_MUL),
                       .Exponent_addition_output_exp(output_interim_exponent_addition),
                       .Exponent_addition_output_sign(output_interim_exponent_addition_sign)
);
defparam Exponent_Addition.std = std;
defparam Exponent_Addition.man = man;
defparam Exponent_Addition.exp = exp;


//mantissa multiplication Module
FMADD_Mantissa_Multiplication Mantissa_Multiplication ( 
                             .Mantissa_Multiplication_input_A(output_interim_M_G_A[man+1:0]),
                             .Mantissa_Multiplication_input_B(output_interim_M_G_B[man+1:0]),
                             .Mantissa_Multiplication_input_Activation_Signal (Activation_signal_MUL),
                             .Mantissa_Multiplication_output_Mantissa( output_interim_mantissa_multiplication) 
);
defparam Mantissa_Multiplication.man = man;
defparam Mantissa_Multiplication.exp = exp;

assign input_LZD = (output_interim_A_sub_norm) ? (output_interim_M_G_A[man+1:0]) : (output_interim_M_G_B[man+1:0]) ;



FPU_LZD_64 LZD_FMADD_Multiplication_Lane (
                  .LZD_64_input_int(input_LZD), 
                  .LZD_64_output_pos(output_LZD)
                  );
defparam LZD_FMADD_Multiplication_Lane.man = man;
defparam LZD_FMADD_Multiplication_Lane.lzd = lzd;

//post normalaization Module
FMADD_PN_MUL Post_Normalization_Mul ( 
                  . FMADD_PN_MUL_input_sign (output_interim_exponent_addition_sign),  
                  . FMADD_PN_MUL_input_multiplied_man (output_interim_mantissa_multiplication),
                  . FMADD_PN_MUL_input_exp_DB (output_interim_exponent_addition),
                  . FMADD_PN_MUL_input_lzd (output_LZD),
                  . FMADD_PN_MUL_input_A_sub  (output_interim_A_sub_norm),
                  . FMADD_PN_MUL_input_B_sub  (output_interim_B_sub_norm),
                  . FMADD_PN_MUL_input_A_pos  (output_interim_A_pos_exp),
                  . FMADD_PN_MUL_input_B_pos  (output_interim_B_pos_exp),
                  . FMADD_PN_MUL_input_A_neg  (output_interim_A_neg_exp),
                  . FMADD_PN_MUL_input_B_neg  (output_interim_B_neg_exp),
                  . FMADD_PN_MUL_output_zero_unrounded (underflow_FMUL),
                  . FMADD_PN_MUL_output_no (output_interim_post_normalization_IEEE_A), 
                  . FMADD_PN_MUL_output_sticky_PN(output_interim_post_normalization_mul_sticky),
                  . FMADD_PN_MUL_input_rm(FMADD_SUBB_input_Frm)
);

defparam Post_Normalization_Mul.std = std;
defparam Post_Normalization_Mul.exp = exp;
defparam Post_Normalization_Mul.man = man;
defparam Post_Normalization_Mul.bias = bias;
defparam Post_Normalization_Mul.lzd = lzd;

assign output_interim_post_normalization_IEEE = ( (&(~output_interim_post_normalization_IEEE_A[1+exp+2*(man+2):man+man+4]) & (~underflow_FMUL)) ) ? {output_interim_post_normalization_IEEE_A[2+exp+2*(man+2)],{exp+1{1'b0}},1'b1,output_interim_post_normalization_IEEE_A[man+man+3:0]  } : output_interim_post_normalization_IEEE_A ;

//module instantiatyion of Rounding Block of Multipliction Lane
FMADD_ROUND_MUL Rounding_Block_Mul (
                     .FMADD_ROUND_MUL_input_sticky_PN(output_interim_post_normalization_mul_sticky),
                     .FMADD_ROUND_MUL_input_no(output_interim_post_normalization_IEEE_A),
                     .FMADD_ROUND_MUL_input_rm(FMADD_SUBB_input_Frm),
                     .FMADD_ROUND_MUL_output_no(output_rounding_Block),
                     .FMADD_ROUND_MUL_output_S_Flags(output_interim_rounding_Block_S_Flag)
);
defparam Rounding_Block_Mul.std = std;
defparam Rounding_Block_Mul.exp = exp;
defparam Rounding_Block_Mul.man = man;

//module instantiation of FMADD Lane
///=interim wires and register for FMADD Lane

//inputs to the FMADD LANE
assign input_interim_ADD_LANE_A = (rst_l) ? (( |(FMADD_SUBB_input_opcode[1:0] ) ) ? output_interim_Extender_A : (| FMADD_SUBB_input_opcode[6:3]) ? output_interim_post_normalization_IEEE : {3+exp+2*(man+2){1'b0}} ) : {3+exp+2*(man+2){1'b0}} ;
assign input_interim_ADD_LANE_B = (rst_l) ? ((|(FMADD_SUBB_input_opcode[1:0] ) ) ? output_interim_Extender_B : (| FMADD_SUBB_input_opcode[6:3]) ? output_interim_Extender_B : {3+exp+2*(man+2){1'b0}} ) : {3+exp+2*(man+2){1'b0}};


//exponent_Matching


FMADD_Exponent_Matching Exponent_Matching ( 
                            .Exponent_Matching_input_Sign_A ( input_interim_ADD_LANE_A[2+exp+2*(man+2)] ),
                            .Exponent_Matching_input_Sign_B(  input_interim_ADD_LANE_B[2+exp+2*(man+2)]  ),
                            .Exponent_Matching_input_Exp_A(  input_interim_ADD_LANE_A[1+exp+2*(man+2): man+man+4] ),
                            .Exponent_Matching_input_Exp_B( input_interim_ADD_LANE_B[1+exp+2*(man+2): man+man+4]  ),
                            .Exponent_Matching_input_Mantissa_A( input_interim_ADD_LANE_A[man+man+3 : 0] ),
                            .Exponent_Matching_input_Mantissa_B( input_interim_ADD_LANE_B[man+man+3 : 0] ),
                            .Exponent_Matching_input_opcode( {  FMADD_SUBB_input_opcode[1] | FMADD_SUBB_input_opcode[4] | FMADD_SUBB_input_opcode[5] , FMADD_SUBB_input_opcode[0] | FMADD_SUBB_input_opcode[6] | FMADD_SUBB_input_opcode[3]}  ),
                            .Exponent_Matching_input_Underflow (underflow_FMUL & (~(FMADD_SUBB_input_opcode[0] | FMADD_SUBB_input_opcode[1]))),
                            .Exponent_Matching_output_Mantissa_A( output_interim_Exponent_Mathcing_Mantissa_A),
                            .Exponent_Matching_output_Mantissa_B( output_interim_Exponent_Mathcing_Mantissa_B),
                            .Exponent_Matching_output_Exp (output_interim_Exponent_Mathcing_Exponent),
                            .Exponent_Matching_output_Sign( output_interim_Exponent_Mathcing_Sign),
                            .Exponent_Matching_output_Guard (output_interim_Exponent_Mathcing_Guard),
                            .Exponent_Matching_output_Round( output_interim_Exponent_Mathcing_Round),
                            .Exponent_Matching_output_Sticky( output_interim_Exponent_Mathcing_Sticky),
                            .Exponent_Matching_output_Eff_Sub( output_interim_Exponent_Mathcing_Eff_sub),
                            .Exponent_Matching_output_Eff_add( output_interim_Exponent_Mathcing_Eff_add),
                            .Exponent_Matching_output_Exp_Diff_Check (output_interim_Exponent_Mathcing_Exp_Diff_Check),
                            .Exponent_Matching_output_A_gt_B (output_interim_Exponent_Mathcing_A_gt_B),
                            .Exponent_matching_output_A_eq_B_Check (output_interim_Exponent_Mathcing_A_eq_B)
                              );
defparam Exponent_Matching.std = std;
defparam Exponent_Matching.exp = exp;
defparam Exponent_Matching.man = man;


//Mantissa Addition
FMADD_Mantissa_Addition Mantissa_Addition (
                             .Mantissa_Addition_input_Mantissa_A( output_interim_Exponent_Mathcing_Mantissa_A),
                             .Mantissa_Addition_input_Mantissa_B( output_interim_Exponent_Mathcing_Mantissa_B),
                             .Mantissa_Addition_input_Eff_Sub( output_interim_Exponent_Mathcing_Eff_sub),
                             .Mantissa_Addition_output_Mantissa(output_interim_Mantissa_Addition_Mantissa ), 
                             .Mantissa_Addition_output_Carry(output_interim_Mantissa_Addition_Carry),
                             .Mantissa_Addition_input_Exp_Diff_Check (output_interim_Exponent_Mathcing_Exp_Diff_Check),
                             .Mantissa_Addition_input_A_gt_B(output_interim_Exponent_Mathcing_A_gt_B)
);
defparam Mantissa_Addition.std = std;
defparam Mantissa_Addition.exp = exp; 
defparam Mantissa_Addition.man = man;

//Post Normalization Module
FMADD_Post_Normalization_Add_Sub Post_Normalization_Add (
                                .Post_Normalization_input_Mantissa ( output_interim_Mantissa_Addition_Mantissa ),
                                .Post_Normalization_input_exponent ( output_interim_Exponent_Mathcing_Exponent),
                                .Post_Normalization_input_Carry ( output_interim_Mantissa_Addition_Carry),
                                .Post_Normalization_input_Eff_sub ( output_interim_Exponent_Mathcing_Eff_sub ),
                                .Post_Normalization_input_Eff_add ( output_interim_Exponent_Mathcing_Eff_add),
                                .Post_Normalization_input_Guard ( output_interim_Exponent_Mathcing_Guard),
                                .Post_Normalization_input_Round ( output_interim_Exponent_Mathcing_Round),
                                .Post_Normalization_input_Sticky ( output_interim_Exponent_Mathcing_Sticky ),
                                .Post_Normalization_output_Guard ( output_interim_Post_Norm_Add_Guard),
                                .Post_Normalization_output_Round (output_interim_Post_Norm_Add_Round),
                                .Post_Normalization_output_Sticky ( output_interim_Post_Norm_Add_Sticky),
                                .Post_Normalization_output_Mantissa ( output_interim_Post_Norm_Add_Mantissa ),
                                .Post_Normalization_output_exponent ( output_interim_Post_Norm_Add_Exponent)
);
defparam Post_Normalization_Add.std = std;
defparam Post_Normalization_Add.exp = exp;
defparam Post_Normalization_Add.man = man;
defparam Post_Normalization_Add.lzd = lzd;

//Rounding Mode Module
assign input_rounding_block_Add_frm =   (|FMADD_SUBB_input_opcode[6:3] | (|FMADD_SUBB_input_opcode[1:0]) ) ? FMADD_SUBB_input_Frm : 3'b000;

FMADD_Roudning_Block_Addition Rounding_Block_Add (
                           .Rounding_Block_input_Mantissa (output_interim_Post_Norm_Add_Mantissa) ,
                           .Rounding_Block_input_Exponent (output_interim_Post_Norm_Add_Exponent),
                           .Rounding_Block_input_Sign (output_interim_Exponent_Mathcing_Sign),
                           .Rounding_Block_input_Guard (output_interim_Post_Norm_Add_Guard),
                           .Rounding_Block_input_Round (output_interim_Post_Norm_Add_Round),
                           .Rounding_Block_input_Sticky (output_interim_Post_Norm_Add_Sticky),
                           .Rounding_Block_input_NX_flag_Mul (output_interim_post_normalization_mul_sticky & (~(FMADD_SUBB_input_opcode[0] | FMADD_SUBB_input_opcode[1] ))),
                           .Rounding_Block_input_Frm (input_rounding_block_Add_frm),
                           .Rounding_Block_input_A_eq_B(output_interim_Exponent_Mathcing_A_eq_B),
                           .Rounding_Block_input_Underflow_operand_A ((underflow_FMUL & (|FMADD_SUBB_input_opcode[6:3]))),
                           .Rounding_Block_output_Exponent (output_interim_Rounding_Block_Exp),
                           .Rounding_Block_output_Sign ( output_interim_Rounding_Block_Sign),
                           .Rounding_Block_output_Mantissa( output_interim_Rounding_Block_Mantissa ),
                           .Rounding_Block_output_S_Flags (output_interim_Rounding_Block_S_flags)
                          
);
defparam Rounding_Block_Add.std = std;
defparam Rounding_Block_Add.exp = exp;
defparam Rounding_Block_Add.man = man;

//Multiplication lane output ports
assign  FMADD_SUBB_output_IEEE_FMUL = ( (~FMADD_SUBB_input_opcode[2]) | (~rst_l) ) ?  { std+1 {1'b0} } : output_rounding_Block ;
assign  FMADD_SUBB_output_S_Flags_FMUL = (  ( FMADD_SUBB_input_opcode[2] ) & (rst_l)  ) ? output_interim_rounding_Block_S_Flag : 3'b000;

//addition Lane output POrts
assign FMADD_SUBB_output_IEEE_FMADD = (  ((|FMADD_SUBB_input_opcode[1:0]) | (|FMADD_SUBB_input_opcode[6:3]) ) & (rst_l) ) ? { output_interim_Rounding_Block_Sign, output_interim_Rounding_Block_Exp ,output_interim_Rounding_Block_Mantissa } :{ std+1 {1'b0} } ;
assign FMADD_SUBB_output_S_Flags_FMADD = ( ( (|FMADD_SUBB_input_opcode[1:0]) | (|FMADD_SUBB_input_opcode[6:3]) ) & (rst_l)  ) ? {output_interim_Rounding_Block_S_flags[1],output_interim_Rounding_Block_S_flags[2],output_interim_Rounding_Block_S_flags[0]} : 3'b00;


endmodule
