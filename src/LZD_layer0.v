// Copyright 2023 MERL-DSU

// Licensed under the Apache License, Version 2.0 (the "License"); you may not use 
// this file except in compliance with the License. You may obtain a copy of the License at

//   http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed under the 
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 

module LZD_layer_0 (L0_input_int, L0_output_pos_val);

input [31:0] L0_input_int;
output [31:0] L0_output_pos_val;

wire L0_wire_pos_0 , L0_wire_val_0 ;
wire L0_wire_pos_1 , L0_wire_val_1 ;
wire L0_wire_pos_2 , L0_wire_val_2 ;
wire L0_wire_pos_3 , L0_wire_val_3 ;
wire L0_wire_pos_4 , L0_wire_val_4 ;
wire L0_wire_pos_5 , L0_wire_val_5 ;
wire L0_wire_pos_6 , L0_wire_val_6 ;
wire L0_wire_pos_7 , L0_wire_val_7 ;
wire L0_wire_pos_8 , L0_wire_val_8;
wire L0_wire_pos_9 , L0_wire_val_9 ;
wire L0_wire_pos_10 , L0_wire_val_10 ;
wire L0_wire_pos_11 , L0_wire_val_11 ;
wire L0_wire_pos_12 , L0_wire_val_12 ;
wire L0_wire_pos_13 , L0_wire_val_13 ;
wire L0_wire_pos_14 , L0_wire_val_14 ;
wire L0_wire_pos_15 , L0_wire_val_15 ;

//Layer 0
FPU_LZD_comb L0_0  (.in_bits(L0_input_int[1:0]),   .out_pos(L0_wire_pos_0),  .out_val(L0_wire_val_0));
FPU_LZD_comb L0_1  (.in_bits(L0_input_int[3:2]),   .out_pos(L0_wire_pos_1),  .out_val(L0_wire_val_1));
FPU_LZD_comb L0_2  (.in_bits(L0_input_int[5:4]),   .out_pos(L0_wire_pos_2),  .out_val(L0_wire_val_2));
FPU_LZD_comb L0_3  (.in_bits(L0_input_int[7:6]),   .out_pos(L0_wire_pos_3),  .out_val(L0_wire_val_3));
FPU_LZD_comb L0_4  (.in_bits(L0_input_int[9:8]),   .out_pos(L0_wire_pos_4),  .out_val(L0_wire_val_4));
FPU_LZD_comb L0_5  (.in_bits(L0_input_int[11:10]), .out_pos(L0_wire_pos_5),  .out_val(L0_wire_val_5));
FPU_LZD_comb L0_6  (.in_bits(L0_input_int[13:12]), .out_pos(L0_wire_pos_6),  .out_val(L0_wire_val_6));
FPU_LZD_comb L0_7  (.in_bits(L0_input_int[15:14]), .out_pos(L0_wire_pos_7),  .out_val(L0_wire_val_7));
FPU_LZD_comb L0_8  (.in_bits(L0_input_int[17:16]), .out_pos(L0_wire_pos_8),  .out_val(L0_wire_val_8));
FPU_LZD_comb L0_9  (.in_bits(L0_input_int[19:18]), .out_pos(L0_wire_pos_9),  .out_val(L0_wire_val_9));
FPU_LZD_comb L0_10 (.in_bits(L0_input_int[21:20]), .out_pos(L0_wire_pos_10), .out_val(L0_wire_val_10));
FPU_LZD_comb L0_11 (.in_bits(L0_input_int[23:22]), .out_pos(L0_wire_pos_11), .out_val(L0_wire_val_11));
FPU_LZD_comb L0_12 (.in_bits(L0_input_int[25:24]), .out_pos(L0_wire_pos_12), .out_val(L0_wire_val_12));
FPU_LZD_comb L0_13 (.in_bits(L0_input_int[27:26]), .out_pos(L0_wire_pos_13), .out_val(L0_wire_val_13));
FPU_LZD_comb L0_14 (.in_bits(L0_input_int[29:28]), .out_pos(L0_wire_pos_14), .out_val(L0_wire_val_14));
FPU_LZD_comb L0_15 (.in_bits(L0_input_int[31:30]), .out_pos(L0_wire_pos_15), .out_val(L0_wire_val_15));

assign L0_output_pos_val = 
{L0_wire_val_15, L0_wire_pos_15,
 L0_wire_val_14, L0_wire_pos_14,
 L0_wire_val_13, L0_wire_pos_13,
 L0_wire_val_12, L0_wire_pos_12,
 L0_wire_val_11, L0_wire_pos_11,
 L0_wire_val_10, L0_wire_pos_10,
 L0_wire_val_9, L0_wire_pos_9, 
 L0_wire_val_8, L0_wire_pos_8, 
 L0_wire_val_7, L0_wire_pos_7, 
 L0_wire_val_6, L0_wire_pos_6, 
 L0_wire_val_5, L0_wire_pos_5, 
 L0_wire_val_4, L0_wire_pos_4, 
 L0_wire_val_3, L0_wire_pos_3, 
 L0_wire_val_2, L0_wire_pos_2, 
 L0_wire_val_1, L0_wire_pos_1,
 L0_wire_val_0, L0_wire_pos_0};


endmodule
