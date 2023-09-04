localparam INST_LUI				= 7'b0110111,
		   INST_AUIPC		   	= 7'b0010111,
		   INST_JAL			 	= 7'b1101111,
		   INST_JALR			= 7'b1100111,
		   INST_GROUP_BRANCH	= 7'b1100011,
		   INST_GROUP_LOAD		= 7'b0000011,
		   INST_GROUP_STORE		= 7'b0100011,
		   INST_GROUP_ARLOG_IMM	= 7'b0010011,
		   INST_GROUP_ARLOG		= 7'b0110011,
		   INST_GROUP_MISC_MEM	= 7'b0001111,
		   INST_GROUP_SYSTEM	= 7'b1110011;

localparam INST_BRANCH_FUNCT3_EQ   	= 3'b000,
		   INST_BRANCH_FUNCT3_NEQ	= 3'b001,
		   INST_BRANCH_FUNCT3_LT   	= 3'b100,
		   INST_BRANCH_FUNCT3_GE   	= 3'b101,
		   INST_BRANCH_FUNCT3_LTU  	= 3'b110,
		   INST_BRANCH_FUNCT3_GEU  	= 3'b111;

localparam INST_LOAD_FUNCT3_BYTE	   	= 3'b000,
		   INST_LOAD_FUNCT3_HALF	   	= 3'b001,
		   INST_LOAD_FUNCT3_WORD	   	= 3'b010,
		   INST_LOAD_FUNCT3_BYTE_UNS	= 3'b100,
		   INST_LOAD_FUNCT3_HALF_UNS	= 3'b101;

localparam INST_STORE_FUNCT3_BYTE	= 3'b000,
		   INST_STORE_FUNCT3_HALF	= 3'b001,
		   INST_STORE_FUNCT3_WORD	= 3'b010;

localparam INST_ARLOG_FUNCT_ADD    	= 10'b0000000000,
		   INST_ARLOG_FUNCT_SUB    	= 10'b0100000000,
		   INST_ARLOG_FUNCT_SLL    	= 10'b0000000001,
		   INST_ARLOG_FUNCT_SLT    	= 10'b0000000010,
		   INST_ARLOG_FUNCT_SLTU	= 10'b0000000011,
		   INST_ARLOG_FUNCT_XOR    	= 10'b0000000100,
		   INST_ARLOG_FUNCT_SRL    	= 10'b0000000101,
		   INST_ARLOG_FUNCT_SRA    	= 10'b0100000101,
		   INST_ARLOG_FUNCT_OR     	= 10'b0000000110,
		   INST_ARLOG_FUNCT_AND    	= 10'b0000000111,
		   INST_ARLOG_FUNCT_MUL    	= 10'b0000001000,
		   INST_ARLOG_FUNCT_MULH   	= 10'b0000001001,
		   INST_ARLOG_FUNCT_MULHSU 	= 10'b0000001010,
		   INST_ARLOG_FUNCT_MULHU  	= 10'b0000001011,
		   INST_ARLOG_FUNCT_DIV    	= 10'b0000001100,
		   INST_ARLOG_FUNCT_DIVU   	= 10'b0000001101,
		   INST_ARLOG_FUNCT_REM    	= 10'b0000001110,
		   INST_ARLOG_FUNCT_REMU   	= 10'b0000001111;

localparam INST_SYSTEM_FUNCT3_CSRRW		= 3'b001,
		   INST_SYSTEM_FUNCT3_CSRRS		= 3'b010,
		   INST_SYSTEM_FUNCT3_CSRRC	 	= 3'b011,
		   INST_SYSTEM_FUNCT3_CSRRWI 	= 3'b101,
		   INST_SYSTEM_FUNCT3_CSRRSI	= 3'b110,
		   INST_SYSTEM_FUNCT3_CSRRCI	= 3'b111;

// TODO: Add for FENCE, FENCE.TSO, PAUSE, ECALL, EBREAK