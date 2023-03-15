// Copyright 2023 MERL-DSU

// Licensed under the Apache License, Version 2.0 (the "License"); you may not use 
// this file except in compliance with the License. You may obtain a copy of the License at

//   http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software distributed under the 
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 

module FPU_LZD_64(LZD_64_input_int, LZD_64_output_pos);


parameter lzd = 4; // 3 for bfloat and I16, 4 for I32 and 5 for I64
parameter man = 22;

//This is layer 5 of LZD 64 and is also acting as main for LZD 64

input [man+1 : 0]LZD_64_input_int;

output [lzd : 0] LZD_64_output_pos;

wire [63 : 0]LZD_64_extended_input_int;
wire LZD_64_wire_val;//wire is connected to the valid output port of layer 5
wire [4 : 0] LZD_64_wire_output_pos_32_0, LZD_64_wire_output_pos_32_1;// wires will be used to connect 32 bit LZDs to the layer 5
wire LZD_64_wire_output_val_32_0, LZD_64_wire_output_val_32_1;// wires will be used to connect 32 bit LZDs to the layer 5
wire [5 : 0] LZD_64_wire_pos_interim_1;
wire [5 : 0] LZD_64_wire_pos_interim_2;
wire [6 : 0] LZD_64_wire_pos_interim_3;

//Extending mantissa to size 64
assign LZD_64_extended_input_int = ({ {(64-(man+2)){1'b0}},LZD_64_input_int }) ;

// 64 bit data is broken down into 32bits and is sent into 2 32bits LZDs, 
// output positions and valid signals of both the LZD are then sent into another layer 5
//32 LSB are sent into LZD 0, it is an instantiation of 32 bit LZD 
FPU_LZD_32 LZD_32_0 (
                    .LZD_32_input_int(LZD_64_extended_input_int[31:0]),
                    .LZD_32_output_pos(LZD_64_wire_output_pos_32_0),//output position coming for LZD which was given LSB 32 bits
                    .LZD_32_output_val(LZD_64_wire_output_val_32_0)
);
//32 MSB are sent into LZD 1, it is an instantiation of 32 bit LZD
FPU_LZD_32 LZD_32_1 (
                    .LZD_32_input_int(LZD_64_extended_input_int[63:32]),
                    .LZD_32_output_pos(LZD_64_wire_output_pos_32_1),//output position coming for LZD which was given MSB 32 bits
                    .LZD_32_output_val(LZD_64_wire_output_val_32_1)
);

//Output pos and valid signals from LZD1 and LZD0 is given to LZD mux which is layer number 5
FPU_LZD_mux LZD_64_L5 (
                      .in_pos_1(LZD_64_wire_output_pos_32_0),
                      .in_val_1(LZD_64_wire_output_val_32_0),
                      .in_pos_2(LZD_64_wire_output_pos_32_1),
                      .in_val_2(LZD_64_wire_output_val_32_1),
                      .out_pos(LZD_64_wire_pos_interim_1),
                      .out_val(LZD_64_wire_val)
);
defparam LZD_64_L5.layer = 5;

//ANDING position with valid since in case of all zero data valid is zero and ANDING it with pos will make pos zero too.
assign LZD_64_wire_pos_interim_2 = {
(LZD_64_wire_pos_interim_1[5] & LZD_64_wire_val),
(LZD_64_wire_pos_interim_1[4] & LZD_64_wire_val),
(LZD_64_wire_pos_interim_1[3] & LZD_64_wire_val),
(LZD_64_wire_pos_interim_1[2] & LZD_64_wire_val),
(LZD_64_wire_pos_interim_1[1] & LZD_64_wire_val),
(LZD_64_wire_pos_interim_1[0] & LZD_64_wire_val)
};


assign LZD_64_wire_pos_interim_3 = 
(man == 30) ? (({1'b0,LZD_64_wire_pos_interim_2}) + 7'b0100000) : //-32 for I2F
(man == 22) ? (({1'b0,LZD_64_wire_pos_interim_2}) + 7'b1011000) : //-40 for SP
(man == 9 ) ? (({1'b0,LZD_64_wire_pos_interim_2}) + 7'b1001011) : //-53 for IEEE16
(man == 6 ) ? (({1'b0,LZD_64_wire_pos_interim_2}) + 7'b1001000) : //-56 for Bf16
              (({1'b0,LZD_64_wire_pos_interim_2}) + 7'b1110101) ; //-11 for DP

assign LZD_64_output_pos = LZD_64_wire_pos_interim_3[lzd : 0];

endmodule



