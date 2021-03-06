`timescale 1ns / 1ps
module SingleCycleCPU(
	input init,
	output done
);
reg clk;

initial
begin
	clk = 0;
	forever #10 clk = !clk;
end

wire [15:0] pc_out;
wire[8:0] fetched_instruction;
wire [15:0] readData0, readData1;
wire [15:0] result, taken, address;
wire [15:0] DataOut, dataToMem;
wire [3:0] readReg0, readReg1, write_jumpReg,ALUOp;
wire start, branch, write, move, MemtoReg, MemWrite, jump_sign, immediate;
wire [1:0] regToMem;

Fetch_Unit fetchUnit(
				.clk(clk),
				.pc_in(pc_out), //pc-in start 0
				.start(start),
				.branch(branch),
				.target(address),
				.taken(taken),
				.jump_sign(jump_sign),
				.pc_out(pc_out),
				.fetched_instruction(fetched_instruction),
				.init(init)
			);

			
Control_Unit control(
		 clk,
		 fetched_instruction,
		 start,
		 branch,
		 readReg0,
		 readReg1,
		 write_jumpReg,
		 write,
		 move,
		 ALUOp,
		 MemtoReg,
		 MemWrite,
		 regToMem,
		 jump_sign,
		 immediate,
		 set_quarter,
		 done
);

Regfile regfile( 
				.clk(clk),
				.write(write),
				.writeReg(write_jumpReg),
				.writeData(DataOut),
				.readReg0(readReg0),
				.readData0(readData0),
				.readReg1(readReg1),
				.readData1(readData1),
				.regToMem(regToMem),
				.dataToMem(dataToMem),
				.move(move),
				.immediate(immediate),
				.address(address),
				.set_quarter(set_quarter)
			);

ALU alu(
			.clk(clk),
			.operation(ALUOp),
			.readData0(readData0),
			.readData1(readData1),
			.result(result),
			.taken(taken)
);

RAM ram(
	.clk(clk),
	.DataAddress(result),
	.ReadMem(MemtoReg),
	.WriteMem(MemWrite),
	.DataIn(dataToMem),
	.DataOut(DataOut)
);


			
endmodule
