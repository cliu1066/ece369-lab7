// HazardDetectionUnit.v
// Handles: load-use stalls (including stores), optional ALU-ALU stalls when forwarding disabled,
// branch-related stalls, and branch/jump flushes.

module HazardDetectionUnit (
    input EX_MemRead,        // EX stage is a load
    input EX_RegWrite,       // EX stage will write a register
    input [4:0]  EX_Rd,      // EX stage destination register (rt for load, rd for R-type depending on encoding)
    input MEM_MemRead,       // MEM stage is a load (used for branch checks)
    input [4:0] MEM_Rd,
    input [4:0] WB_Rd,

    input [4:0] ID_Rs,
    input [4:0] ID_Rt,
    input ID_UsesRtAsSrc,    // 1 if ID instruction uses rt as a source (sw, beq)
    input Branch_ID,         // 1 if ID instruction is a branch (beq/bne)
    input Jump_ID,           // 1 if ID is a jump (for IF/ID flush)

    output PC_Write,
    output IF_ID_Write,
    output ID_EX_Flush,
    output IF_ID_Flush
);
    
    wire ex_rd_valid = (EX_Rd != 5'd0);
    wire mem_rd_valid = (MEM_Rd != 5'd0);
    
    // EX stage matches (for load-use detection)
    wire ex_rs_match = ex_rd_valid && (EX_Rd == ID_Rs);
    wire ex_rt_match = ex_rd_valid && (EX_Rd == ID_Rt);
    
    // MEM stage matches (for branch hazards)
    wire mem_rs_match = mem_rd_valid && (MEM_Rd == ID_Rs);
    wire mem_rt_match = mem_rd_valid && (MEM_Rd == ID_Rt);
    
    // Load-use hazard: EX stage load with register dependency
    wire load_use_rs = EX_MemRead && ex_rs_match;
    wire load_use_rt = EX_MemRead && ID_UsesRtAsSrc && ex_rt_match;
    wire load_use_hazard = load_use_rs || load_use_rt;
    
    // Branch hazards: need data from EX (load or ALU) or MEM (load)
    wire branch_ex_dependency = Branch_ID && (ex_rs_match || ex_rt_match);
    wire branch_ex_stall = branch_ex_dependency && (EX_MemRead || EX_RegWrite);
    wire branch_mem_load = Branch_ID && MEM_MemRead && (mem_rs_match || mem_rt_match);
    wire branch_hazard = branch_ex_stall || branch_mem_load;
    
    wire needs_stall = load_use_hazard || branch_hazard;
    
    assign PC_Write = !needs_stall;
    assign IF_ID_Write = !needs_stall;
    assign ID_EX_Flush = needs_stall;
    assign IF_ID_Flush = Jump_ID;  // Separate from stall logic

endmodule