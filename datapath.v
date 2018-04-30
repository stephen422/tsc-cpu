`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/04/06 15:53:03
// Design Name: 
// Module Name: datapath
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "constants.v"
`define WORD_SIZE 16

module datapath
  #(parameter WORD_SIZE = `WORD_SIZE)
   (input                      clk,
    input                      reset_n,
    input                      pc_write,
    input                      pc_write_cond,
    input [1:0]                pc_src,
    input                      i_or_d,

    // IF constrol signals
    input                      ir_write,

    // ID control signals
    input                      output_write,

    // EX control signals
    input [3:0]                alu_op,
    input                      alu_src_a,
    input [1:0]                alu_src_b,
    input                      alu_src_swap, 
    input [1:0]                reg_dst, // resolved in ID, only saved now

    // MEM control signals
    input                      i_mem_read, 
    input                      d_mem_read, 
    input                      i_mem_write,
    input                      d_mem_write, 

    // WB control signals
    input                      reg_write,
    input [1:0]                reg_write_src,

    inout [WORD_SIZE-1:0]      i_data,
    inout [WORD_SIZE-1:0]      d_data,

    input                      input_ready,
    output [WORD_SIZE-1:0]     i_address,
    output [WORD_SIZE-1:0]     d_address,
    output reg [WORD_SIZE-1:0] num_inst,
    output reg [WORD_SIZE-1:0] output_port,
    output [3:0]               opcode,
    output [5:0]               func_code
);

   // Decoded info
   wire [1:0]                  rs, rt, rd;
   wire [7:0]                  imm;
   wire [11:0]                 target_addr;                    

   // register file
   wire [1:0]                  addr1, addr2, addr3;
   wire [WORD_SIZE-1:0]        data1, data2, writeData;

   // ALU
   wire [WORD_SIZE-1:0]        alu_temp_1, alu_temp_2; // operands before swap
   wire [WORD_SIZE-1:0]        alu_operand_1, alu_operand_2; // operands after swap
   wire [WORD_SIZE-1:0]        alu_result;

   // pipeline registers
   // (add to reset list below)

   // unconditional latches
   reg [WORD_SIZE-1:0]         pc, pc_id, pc_ex, pc_mem, pc_wb; // program counter
   reg [WORD_SIZE-1:0]         npc_id; // PC + 4 at IF/ID
   reg [WORD_SIZE-1:0]         npc_ex; // PC + 4 at ID/EX
   reg [WORD_SIZE-1:0]         IR; // instruction register
   reg [WORD_SIZE-1:0]         MDR_wb; // memory data register
   reg [WORD_SIZE-1:0]         rt_ex; // for reg_dst
   reg [WORD_SIZE-1:0]         rd_ex; // for reg_dst
   reg [WORD_SIZE-1:0]         a_ex, b_ex, b_mem;
   reg [WORD_SIZE-1:0]         alu_out_ex, alu_out_wb;
   reg [WORD_SIZE-1:0]         write_reg_mem, write_reg_wb;
   reg [WORD_SIZE-1:0]         imm_signed_ex, imm_signed_mem, imm_signed_wb;

   // control signal latches
   reg [3:0]                   alu_op_ex;
   reg                         alu_src_a_ex;
   reg [1:0]                   alu_src_b_ex;
   reg                         alu_src_swap_ex;
   reg [1:0]                   reg_dst_ex;
   reg                         i_mem_read_ex, i_mem_read_mem;
   reg                         d_mem_read_ex, d_mem_read_mem;
   reg                         i_mem_write_ex, i_mem_write_mem;
   reg                         d_mem_write_ex, d_mem_write_mem;
   reg                         reg_write_ex, reg_write_mem, reg_write_wb;
   reg                         reg_write_src_ex, reg_write_src_mem, reg_write_src_wb;
   

   ALU alu(.OP(alu_op_ex),
           .A(alu_operand_1),
           .B(alu_operand_2),
           .Cin(1'b0),
           .C(alu_result)
           /*.Cout()*/);

   RF rf(.write(reg_write_wb),
         .clk(clk),
         .reset_n(reset_n),
         .addr1(addr1),
         .addr2(addr2),
         .addr3(addr3),
         .data1(data1),
         .data2(data2),
         .data3(writeData));

   // IF stage
   // assign address = (i_or_d == 0) ? pc : alu_out_ex;
   assign i_address = pc;
   assign d_address = alu_out_ex;

   // ID stage
   assign opcode = IR[15:12];
   assign func_code = IR[5:0];
   assign rs = IR[11:10];
   assign rt = IR[9:8];
   assign rd = IR[7:6];
   assign imm = IR[7:0];
   assign target_addr = IR[11:0];
   assign addr1 = rs;
   assign addr2 = rt;
   
   // EX stage
   assign alu_temp_1 = (alu_src_a_ex == `ALUSRCA_PC) ? pc :
                     /*(alu_src_a_ex == `ALUSRCA_REG) ?*/ a_ex;
   assign alu_temp_2 = (alu_src_b_ex == `ALUSRCB_ONE) ? 1 :
                     (alu_src_b_ex == `ALUSRCB_REG) ? b_ex :
                     (alu_src_b_ex == `ALUSRCB_IMM) ? {{8{imm[7]}}, imm} :
                     /*(alu_src_b_ex == `ALUSRCB_ZERO) ?*/ 0;
   assign alu_operand_1 = alu_src_swap_ex ? alu_temp_2 : alu_temp_1;
   assign alu_operand_2 = alu_src_swap_ex ? alu_temp_1 : alu_temp_2;

   // MEM stage
   assign d_data = d_mem_write ? b_ex : {WORD_SIZE{1'bz}};

   // WB stage
   assign addr3 = write_reg_wb;
   assign writeData = (reg_write_src == `REGWRITESRC_IMM) ? imm_signed_wb : // {imm, 8'b0} :
                      (reg_write_src == `REGWRITESRC_REG) ? alu_out_wb :
                      (reg_write_src == `REGWRITESRC_MEM) ? MDR_wb :
                      /*(reg_write_src == `REGWRITESRC_PC) ?*/ pc_wb;

   // Register transfers
   always @(posedge clk) begin
      if (reset_n == 0) begin
         // reset all pipeline registers to zero for no unexpected surprises
         pc <= 0;
         npc_id <= 0;
         npc_ex <= 0;
         IR <= 0;
         MDR_wb <= 0;
         a_ex <= 0;
         b_ex <= 0;
         b_mem <= 0;
         alu_out_ex <= 0;
         // maybe set output_port to initially float
         output_port <= {WORD_SIZE{1'bz}};
      end
      else begin
         // PC update
         if (pc_write)
           pc <= pc + 1; // TODO: stall

         // ----------------------
         // unconditional latching
         // ----------------------

         // IF stage
         npc_id <= pc + 1; // adder for PC
         pc_id <= pc;

         // ID stage
         npc_ex <= npc_id;
         pc_ex <= pc_id;
         imm_signed_ex <= {imm, 8'b0};

         // EX stage
         pc_mem <= pc_ex;
         alu_out_ex <= alu_result;
         a_ex <= data1;
         b_ex <= data2;
         write_reg_mem <= (reg_dst == `REGDST_RT) ? rt_ex :
                          (reg_dst == `REGDST_RD) ? rd_ex :
                          /*(reg_dst == `REGDST_2) ?*/ 2'd2;
         imm_signed_mem <= imm_signed_ex;

         // MEM stage
         pc_wb <= pc_mem;
         MDR_wb <= d_data;
         write_reg_wb <= write_reg_mem;
         imm_signed_wb <= imm_signed_mem;

         // ----------------------
         // control signal latching
         // ----------------------

         // EX control signals
         alu_op_ex <= alu_op;
         alu_src_a_ex <= alu_src_a;
         alu_src_b_ex <= alu_src_b;
         alu_src_swap_ex <= alu_src_swap;
         reg_dst_ex <= reg_dst;

         // MEM control signals
         i_mem_read_ex <= i_mem_read;
         i_mem_read_mem <= i_mem_read_ex;
         d_mem_read_ex <= d_mem_read;
         d_mem_read_mem <= d_mem_read_ex;
         i_mem_write_ex <= i_mem_write;
         i_mem_write_mem <= i_mem_write_ex;
         d_mem_write_ex <= d_mem_write;
         d_mem_write_mem <= d_mem_write_ex;

         // WB control signals
         reg_write_ex <= reg_write;
         reg_write_mem <= reg_write_ex;
         reg_write_wb <= reg_write_mem;
         reg_write_src_ex <= reg_write_src;
         reg_write_src_mem <= reg_write_src_ex;
         reg_write_src_wb <= reg_write_src_mem;

         // instruction register
         if (ir_write) begin
            IR <= i_data;
         end

         // output port assertion
         if (output_write == 1) begin
            output_port <= data1;
         end

         // PC update
         // if (pc_write || (pc_write_cond && (alu_result != 0))) begin
         //    case (pc_src)
         //      `PCSRC_SEQ: pc <= alu_result;
         //      `PCSRC_JUMP: pc <= {pc[15:12], target_addr};
         //      `PCSRC_BRANCH: pc <= alu_out_ex;
         //      `PCSRC_REG: pc <= data1; // *before* b_ex
         //    endcase
         // end
      end
   end
endmodule
