CPU consists of 5 stages which are connected using buffers and wires.

speed of cpu is 43.64MHz,22.915ns

The byte address from 0 to 127 are mappped to DMEM and 512 to 527
are mapped to the peripheral(Accumulator).It generates Chip Enable
signals for DMEM and Accumulator and they are operated in negedge clk
because the enable signals and addresses won't be ready at posedge.

=====================================
Buffers:
If_Id,Id_Ex,Ex_Mem,Mem_Wb

Stage1:
generates iaddr,stores the value of pc
Assumes that pc Branch and JAL instructions will always branch,
and the pc is set to pc+imm in the next posedge.
If assumption is wrong, (which will be known after 2 cycles when
the instruction is in the EX stage), the ex stage will send the
correct address and the pc will be set to that address

for JALR since we can't predict the branch address we will set
pc = pc+4 and load the next two instructions in next 2 cycles
and after we read the output of EX(asynchronously) we will set
the correct value of pc

Stage2:
contiains Decocder RF and a state machine(for discarding instructions)
generates all control signals needed(including rs1,rs2).
 
****Stalling*****
1. branch 
When we make wrong prediction the state machine
is triggered, which will set the control signals for 
RF,DMEM,Branching,(for the next two instructions) to zero
effectively discarding the instruction from the pipeline.

2.Data Hazard
When we have instructions using rd of previous load instruction
we need to stall the instructions till the ld instruction is complete 
and this is done using combinational logic in ID stage

instr1 : Load 
instr2 : something that uses this rd
instr3 : ..... something

-----------------------------------------------------
without stalling
	  ID 	 |    EX         |   MEM
	instr3   |  instr2       |   Load instruction

with stalling
	  ID 	 |    EX         |   MEM
	instr2   |  No operation |   Load instruction

=================================================
This no operation is introduced by Hazard detector in ID

Stage3:
ALU,forwarder,next_pc_value,prediction validator

pc_update and validation:

This stage generates the next value of pc and if this doesn't match
what is predicted by the IF stage we will send control signals to:

stage1:	to set the value of pc
stage2:	to discard the next two instructions which are not supposed to execute
	by setting their opcode and other necessary control signals to zero

rf_data:

data that will be written into rf can be dmem_out,pc+4,pc+imm,alu_output
except for dmem_out the other three will be generated in this stage
so we have a flag(apart from we of RF) to say that data generated in this
stage will or will not be stored into RF.

This flag will be useful for deciding whether to forward the data in Ex_Mem

forwarder alu:
	will take rs1 rs2 and rv1 rv2 from Id_Ex and (address,validity_flag,rf_data)
	from Ex_Mem and Mem_Wb buffers.if the address matches and the validity_flag = 1
	The data from buffers will be taken Ex_Mem has high priority than Mem_wb
	since it is more recent

Stage4:
Shifter: Combinational logic to change the data read from and written
    into DMEM. Misaligned addresses will be adjusted to nearest addresses.

Stage5:
The inputs to RF are connected to stage4 wires rather than the buffer Mem_Wb.
As using the buffer will add 1 cycle between Ex and Wb
The buffer is only useful when forwarding not for wb

Division of Work:
EE17B061(P.Harsha Vardhan):
	Decoder,EX stage(Forwarding) and MEM stage(Shifter)
	verifying Predictions in Ex stage and
	Discard instructions in decode stage for wrong prediction of Branch
		
EE17B057(N.Jeevan Reddy): TestBench(same as the used for assignment 5)
	IF,ID(Hazard detection),WB stage
	Predicting(Assuming) Branches in IF stage                                          
	Connecting stages in CPU
	Top File