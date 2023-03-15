// Copyright 2023 MERL-DSU

// Licensed under the Apache License, Version 2.0 (the "License"); you may not use 
// this file except in compliance with the License. You may obtain a copy of the License at

//   http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed under the 
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 

module LZD_layer_1 (L1_input_pos_val, L1_output_pos_val);

parameter layer = 1;

//Input of layer 1, Output from layer 0
input [31 :0]L1_input_pos_val;

//Output of layer 1, this will be Input to layer 2 
output [23 : 0] L1_output_pos_val;

//Wires
wire L1_wire_output_val_0, L1_wire_output_val_1, L1_wire_output_val_2, L1_wire_output_val_3, L1_wire_output_val_4, L1_wire_output_val_5, L1_wire_output_val_6, L1_wire_output_val_7;
wire [layer : 0] L1_wire_output_pos_0, L1_wire_output_pos_1, L1_wire_output_pos_2, L1_wire_output_pos_3, L1_wire_output_pos_4, L1_wire_output_pos_5, L1_wire_output_pos_6, L1_wire_output_pos_7;


FPU_LZD_mux L1_0 (.in_val_2(L1_input_pos_val[3]),  .in_pos_2(L1_input_pos_val[2]),  .in_val_1(L1_input_pos_val[1]),  .in_pos_1(L1_input_pos_val[0]),  .out_pos(L1_wire_output_pos_0), .out_val(L1_wire_output_val_0)); defparam L1_0.layer = 1;
FPU_LZD_mux L1_1 (.in_val_2(L1_input_pos_val[7]),  .in_pos_2(L1_input_pos_val[6]),  .in_val_1(L1_input_pos_val[5]),  .in_pos_1(L1_input_pos_val[4]),  .out_pos(L1_wire_output_pos_1), .out_val(L1_wire_output_val_1)); defparam L1_1.layer = 1;
FPU_LZD_mux L1_2 (.in_val_2(L1_input_pos_val[11]), .in_pos_2(L1_input_pos_val[10]), .in_val_1(L1_input_pos_val[9]),  .in_pos_1(L1_input_pos_val[8]),  .out_pos(L1_wire_output_pos_2), .out_val(L1_wire_output_val_2)); defparam L1_2.layer = 1;
FPU_LZD_mux L1_3 (.in_val_2(L1_input_pos_val[15]), .in_pos_2(L1_input_pos_val[14]), .in_val_1(L1_input_pos_val[13]), .in_pos_1(L1_input_pos_val[12]), .out_pos(L1_wire_output_pos_3), .out_val(L1_wire_output_val_3)); defparam L1_3.layer = 1;
FPU_LZD_mux L1_4 (.in_val_2(L1_input_pos_val[19]), .in_pos_2(L1_input_pos_val[18]), .in_val_1(L1_input_pos_val[17]), .in_pos_1(L1_input_pos_val[16]), .out_pos(L1_wire_output_pos_4), .out_val(L1_wire_output_val_4)); defparam L1_4.layer = 1;
FPU_LZD_mux L1_5 (.in_val_2(L1_input_pos_val[23]), .in_pos_2(L1_input_pos_val[22]), .in_val_1(L1_input_pos_val[21]), .in_pos_1(L1_input_pos_val[20]), .out_pos(L1_wire_output_pos_5), .out_val(L1_wire_output_val_5)); defparam L1_5.layer = 1;
FPU_LZD_mux L1_6 (.in_val_2(L1_input_pos_val[27]), .in_pos_2(L1_input_pos_val[26]), .in_val_1(L1_input_pos_val[25]), .in_pos_1(L1_input_pos_val[24]), .out_pos(L1_wire_output_pos_6), .out_val(L1_wire_output_val_6)); defparam L1_6.layer = 1;
FPU_LZD_mux L1_7 (.in_val_2(L1_input_pos_val[31]), .in_pos_2(L1_input_pos_val[30]), .in_val_1(L1_input_pos_val[29]), .in_pos_1(L1_input_pos_val[28]), .out_pos(L1_wire_output_pos_7), .out_val(L1_wire_output_val_7)); defparam L1_7.layer = 1;

assign L1_output_pos_val = 
{
 L1_wire_output_val_7, L1_wire_output_pos_7,
 L1_wire_output_val_6, L1_wire_output_pos_6,
 L1_wire_output_val_5, L1_wire_output_pos_5,
 L1_wire_output_val_4, L1_wire_output_pos_4,
 L1_wire_output_val_3, L1_wire_output_pos_3,
 L1_wire_output_val_2, L1_wire_output_pos_2,
 L1_wire_output_val_1, L1_wire_output_pos_1,
 L1_wire_output_val_0, L1_wire_output_pos_0};
endmodule
