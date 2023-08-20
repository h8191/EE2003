//Completely initalize mem files when testing on FPGA

Division of Work:
EE17B061(P.Harsha Vardhan) TestCase and Peripheral(Accumulator)
EE17B057(N.Jeevan Reddy) Arbiter and Modified testbench

One loop of the code takes around 1us so set the simulation time to
3us or 2us to see the code looping

Memory Mapping:
The byte address from 0 to 127 are mappped to DMEM and 512 to 527
are mapped to the peripheral(Accumulator).It generates Chip Enable
signals for DMEM and Accumulator and they are operated in negedge clk
because the enable signals and addresses won't be ready at posedge.

The we to dmem is masked with the enable signal from arbiter to 
prevent unintended writes into dmem

data IO to cpu:
wdata from cpu is directly connected to both DMEM and Accumulator.
The rdata from DMEM and Accumulator are taken as inputs by the
arbiter and it generates a rdata which is sent to the CPU.

Accessing the Peripheral:
You can write into accumulator using any store instruction,
for this 4 bit write enable is reduced to 1 bit(we!=0)
Any load instructions can be used to read from accumulator.

Overview:
Reading Sum or Count won't write anything into the register.
When writing(adding or resetting) Rdata will be zero.


Testcase:
A MEM File is attached to test the accumulator
This will find Sigma(n) for n = 1 to 5 using both
CPU and Accumulator and 2 branch instructions are used to
check if the count and sum are correct for 5 iterations.
if any of the above two instructions fail. X31 will be 1.

The values are also stored in bytes(byte addressing) in DMEM from 1 to 5

TestBench for accumulator

00000f93 //ADDI R31 R0 0  reset x31
20000f13 //ADDI R30 R0 512 // to store base address in R30
00500e93 //ADDI R29 R0 10  //R29 = 10 The number of times loop needs to run
00000e13 //ADDI R28 R0 0   //R28 = 0
00000093 //ADDI R1 R0 0    //R1 = 0
01ef2223 //SW R30 R30 4    //add r30 in acc
00ef2023 //SW R14 R30 0    //reset acc
001e0e13 //ADDI R28 R28 1  //R28 = R28 + 1(iteration count)
01c080b3 //ADDI R1 R1 28   //accumuate in alu
01cf2223 //SW R28 R30 4    //add to accumulator
008f5d83 //LHU R27 R30 8   //read sum into R27
00cf4d03 //LBU R26 R30 12  //read count in R26
001d9a63 //BNE R27 R1 (offset = 20) jump to x31 =1 //check if sum matches
01cd1863 //BNE R26 R28 (offset = 16) jump to x31 =1 //check if count matches
01be0023 //SB R27 R28 0    //STORE SUM(R27) into DMEM
ffde10e3 //#BNE R28 R29 -16 // jump to R28 = R28 + 1
fc1ff56f //#JAL store in R10 jummp to first instr (NOP)
00100f93 //ADDI R31 R0 1 // x31 = 1

00000f93
20000f13
00500e93
00000e13
00000093
01ef2223
00ef2023
001e0e13
01c080b3
01cf2223
008f5d83
00cf4d03
001d9a63
01cd1863
01be0023
ffde10e3
fc1ff56f
00100f93