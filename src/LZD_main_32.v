// Copyright 2023 MERL-DSU

// Licensed under the Apache License, Version 2.0 (the "License"); you may not use 
// this file except in compliance with the License. You may obtain a copy of the License at

//   http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed under the 
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 

module FPU_LZD_32 (LZD_32_input_int, LZD_32_output_pos, LZD_32_output_val);

//This is the main for 32 bit LZD, 2 of these modules will be instantiated in 64bit LZD main to make a 64 bit LZD
parameter layer = 1;

input [31 : 0]LZD_32_input_int;

output [4: 0]LZD_32_output_pos;
output LZD_32_output_val;

wire [31 : 0] LZD_32_wire_output_L0;
wire [23 : 0] LZD_32_wire_output_L1;
wire [15 : 0] LZD_32_wire_output_L2;
wire [9  : 0] LZD_32_wire_output_L3;

//Layer 0
LZD_layer_0 L0 (.L0_input_int(LZD_32_input_int), .L0_output_pos_val(LZD_32_wire_output_L0));

//Layer 1
LZD_layer_1 L1 (.L1_input_pos_val(LZD_32_wire_output_L0), .L1_output_pos_val(LZD_32_wire_output_L1));

//Layer 2
LZD_layer_2 L2 (.L2_input_pos_val(LZD_32_wire_output_L1), .L2_output_pos_val(LZD_32_wire_output_L2));

//Layer 3
LZD_layer_3 L3 (.L3_input_pos_val(LZD_32_wire_output_L2), .L3_output_pos_val(LZD_32_wire_output_L3));

//Layer 4
LZD_layer_4 L4 (.L4_input_pos_val(LZD_32_wire_output_L3), .L4_output_pos(LZD_32_output_pos), .L4_output_valid(LZD_32_output_val));

endmodule
