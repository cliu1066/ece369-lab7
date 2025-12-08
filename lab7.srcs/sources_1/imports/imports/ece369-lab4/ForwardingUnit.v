module ForwardingUnit (
    input [4:0] EX_Rs,
    input [4:0] EX_Rt,

    input [4:0] MEM_WriteReg,
    input [4:0] WB_WriteReg,
    input MEM_RegWrite,
    input MEM_MemRead,
    input WB_RegWrite,

    input EX_isStore,

    input [4:0] ID_Rs,
    input [4:0] ID_Rt,
    
    output [1:0] ForwardA,
    output [1:0] ForwardB,

    output [1:0] ForwardBranchA,
    output [1:0] ForwardBranchB,
    
    output [1:0] ForwardStore
);

    wire mem_rs_match = (MEM_WriteReg == EX_Rs) && MEM_RegWrite && (MEM_WriteReg != 5'd0);
    wire mem_rt_match = (MEM_WriteReg == EX_Rt) && MEM_RegWrite && (MEM_WriteReg != 5'd0);
    wire mem_id_rs_match = (MEM_WriteReg == ID_Rs) && MEM_RegWrite && (MEM_WriteReg != 5'd0) && !MEM_MemRead;
    wire mem_id_rt_match = (MEM_WriteReg == ID_Rt) && MEM_RegWrite && (MEM_WriteReg != 5'd0) && !MEM_MemRead;
    
    // WB stage forwarding conditions (single level)
    wire wb_rs_match = (WB_WriteReg == EX_Rs) && WB_RegWrite && (WB_WriteReg != 5'd0);
    wire wb_rt_match = (WB_WriteReg == EX_Rt) && WB_RegWrite && (WB_WriteReg != 5'd0);
    wire wb_id_rs_match = (WB_WriteReg == ID_Rs) && WB_RegWrite && (WB_WriteReg != 5'd0);
    wire wb_id_rt_match = (WB_WriteReg == ID_Rt) && WB_RegWrite && (WB_WriteReg != 5'd0);
    
    // ForwardA: 00=no forward, 01=WB, 10=MEM
    assign ForwardA = mem_rs_match ? 2'b10 : (wb_rs_match ? 2'b01 : 2'b00);
    
    // ForwardB: 00=no forward, 01=WB, 10=MEM
    assign ForwardB = mem_rt_match ? 2'b10 : (wb_rt_match ? 2'b01 : 2'b00);
    
    // ForwardStore: only when EX_isStore is active
    assign ForwardStore = !EX_isStore ? 2'b00 : 
                         (mem_rt_match ? 2'b10 : 
                         (wb_rt_match ? 2'b01 : 2'b00));
    
    // ForwardBranch: from non-load MEM or WB
    assign ForwardBranchA = mem_id_rs_match ? 2'b10 : (wb_id_rs_match ? 2'b01 : 2'b00);
    assign ForwardBranchB = mem_id_rt_match ? 2'b10 : (wb_id_rt_match ? 2'b01 : 2'b00);

endmodule