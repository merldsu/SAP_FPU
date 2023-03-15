// Copyright 2023 MERL-DSU

// Licensed under the Apache License, Version 2.0 (the "License"); you may not use 
// this file except in compliance with the License. You may obtain a copy of the License at

//   http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed under the 
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 

module LZD_layer_3 (L3_input_pos_val, L3_output_pos_val);

parameter layer = 3;

//Input of layer 3, Output from layer 2
input [15 :0]L3_input_pos_val;

//Output of layer 3, this will be Input to layer 4
output [9 : 0] L3_output_pos_val;

//Wires
wire L3_wire_output_val_0, L3_wire_output_val_1;
wire [layer : 0] L3_wire_output_pos_0, L3_wire_output_pos_1;


FPU_LZD_mux  L3_0  (.in_val_2(L3_input_pos_val[7]),   .in_pos_2(L3_input_pos_val[6:4]),   .in_val_1(L3_input_pos_val[3]),  .in_pos_1(L3_input_pos_val[2:0]),  .out_pos(L3_wire_output_pos_0), .out_val(L3_wire_output_val_0));  defparam L3_0.layer = 3;
FPU_LZD_mux  L3_1 (.in_val_2(L3_input_pos_val[15]),  .in_pos_2(L3_input_pos_val[14:12]),  .in_val_1(L3_input_pos_val[11]),  .in_pos_1(L3_input_pos_val[10:8]),  .out_pos(L3_wire_output_pos_1), .out_val(L3_wire_output_val_1));  defparam L3_1.layer = 3;

assign L3_output_pos_val = 
{L3_wire_output_val_1, L3_wire_output_pos_1,
 L3_wire_output_val_0, L3_wire_output_pos_0};
endmodule
