I am attaching a dmem file in this folder as there are some bugs
in the dmem posted on moodle.
I think there are a few of bugs in the imem2, one of the addi instructions
00800097            // addi ra,r0,0x8 should be 00800093
was wrong, rs1 + immediates used for 2 load word instruction point to the
same address(unless you are not left shifting immediate twice)
and you are expecting to read two different value.

I am not sure how to interpret the dmem inital data file given, so I wrote a new
dmem initialisation and a corresponding imem instr text
which is attached with the name instr3.txt,
it is working as expected

load the first 3 words of dmem into next 3 words using unsigned lb,lh,lw
and store them back into dmem using (sb,sh,sw), and used signed (lb,lh),sb,sh 