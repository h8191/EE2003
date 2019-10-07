def getops(x):
    a = ((x&(0x7f<<25))>>25,(x&(7<<12))>>12,x&0x7f)
    print([i for i in a])
    a = [bin(i) for i in a]
    return a

def b1(x=0x03d71963):
    #
    x = bin(x)[2:].zfill(32)
    a = (x[7:12],x[12:17],x[17:20],x[25:32],x[0]+x[24]+x[1:7]+x[20:24])
    # print([eval('0b'+i) for i in a])
    print({i:hex(eval('0b'+j)) for i,j in zip(['rs2','rs1','f3','op','imm'],a)})
    return a

def i1(x):
    x = bin(x)[2:].zfill(32)
    a = (x[:12],x[12:17],x[17:20],x[20:25],x[25:32])
    print({i:j for i,j in zip(['imm','rs1','f3','rd','op'],a)})

def r1(x):
    x = bin(x)[2:].zfill(32)
    a = (x[:7],x[7:12],x[12:17],x[17:20],x[20:25],x[25:32])
    print({i:j for i,j in zip(['f7','rs2','rs1','f3','rd','op'],a)})


with open('instr2.txt','r') as rf:
	for i in rf.read().split('\n'):
		if i=='':
			continue
		print(i)
		r1(eval('0x'+i))

