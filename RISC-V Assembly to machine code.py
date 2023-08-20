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

class reg(object):
    def __init__(self,value=None,bits=32):
        self.set(value,bits)
        self.length = bits

    def set(self,value,bits=32):
        if value==None:
            self.bits = [0]*bits
        else:
            self.bits = [int(i) for i in bin(value)[2:].zfill(bits)]

    def __setitem__(self,slc,x):
        start,stop = self.length-1-slc.start,self.length-slc.stop
        if type(x)==type(0):
            self.bits[start:stop] = [int(i) for i in bin(x)[2:].zfill(stop-start)]
        else:
            self.bits[start:stop] = x

    def __getitem__(self,slc):
        start,stop = self.length-1-slc.start,self.length-slc.stop
        return self.bits[start:stop]

    def num(self):
        print(hex(eval('0b'+''.join(map(str,self.bits))))[2:].zfill(8))

def encoder(**kwargs):
    instr = reg()
    def load_rd():
        instr[11:7] = reg(kwargs['rd'],5).bits

    def load_r1():
        instr[19:15] = reg(kwargs['rs1'],5).bits

    def load_r2():
        instr[24:20] = reg(kwargs['rs2'],5).bits

    if kwargs['type'] == 'LUI':
        instr[31:12] = reg(kwargs['imm'],20).bits
        load_rd()
        instr[6:0] = 0x37

    if kwargs['type'] == 'AUIPC':
        instr[31:12] = reg(kwargs['imm'],20).bits
        load_rd()
        instr[6:0] = 0x17
        
    if kwargs['type']=='JAL':
        instr[6:0] = 0x67
        pass

    if kwargs['type'] == 'JALR':
        load_rd()
        load_r1()
        instr[14:12] = 0
        instr[31:20] = reg(kwargs['imm'],12).bits

    if kwargs['type'] in ['BEQ','BNE','BLT','BGE','BLTU','BGEU']:
        imm = reg(kwargs['imm']*2,13)

        instr[11:7] = imm[4:1]+imm[11:11]
        instr[31:25] = imm[12:12]+imm[10:5]

        load_r1()
        load_r2()

        instr[14:12] = {'BEQ':0,'BNE':1,'BLT':4,'BGE':5,'BLTU':6,'BGEU':7}[kwargs['type']]
        instr[6:0] = 0x63

    if kwargs['type'] in ['LB','LH','LW','LBU','LHU']:
        instr[6:0] = 0x03
        load_rd()
        load_r1()
        instr[31:20] = reg(kwargs['imm'],12).bits;
        instr[14:12] = {'LB':0,'LH':1,'LW':2,'LBU':4,'LHU':5}[kwargs['type']]

    if kwargs['type'] in ['SB','SH','SW']:
        instr[6:0] = 0x23;
        load_r1()
        load_r2()
        imm = reg(kwargs['imm'],12)

        instr[14:12] = {'SB':0,'SH':1,'SW':2}[kwargs['type']]
        instr[31:25] = imm[11:5]
        instr[11:7] = imm[4:0]

    if kwargs['type'] in ['ADDI','SLTI','SLTIU','XORI','ORI','ANDI']:#['SLLI','SRLI','SRAI']:
        instr[6:0] = 0x13;
        load_r1()
        load_rd()
        instr[31:20] = reg(kwargs['imm'],12).bits
        instr[14:12] = {'ADDI':0,'SLTI':2,'SLTIU':3,'XORI':4,'ORI':6,'ANDI':7}[kwargs['type']]

    if kwargs['type'] in ['SLLI','SRLI','SRAI']:
        instr[6:0] = 0x13;
        load_r1()
        load_rd()
        instr[24:20] = kwargs['shamt']
        instr[14:12] = {'SLLI':1,'SRLI':5,'SRAI':5}[kwargs['type']]
        instr[31:25] = {'SLLI':0,'SRLI':0,'SRAI':0x20}[kwargs['type']]

    if kwargs['type'] in ['ADD','SUB','SLL','SLT','SLTU','XOR','SRL','SRA','OR','AND']:
        instr[6:0] = 0x33;
        load_r1()
        load_r2()
        load_rd()
        instr[14:12] = {'ADD':0,'SUB':0,'SLL':1,'SLT':2,'SLTU':3,
                        'XOR':4,'SRL':5,'SRA':5,'OR':6,'AND':7}[kwargs['type']]
        instr[31:25] = {'ADD':0,'SUB':0x20,'SLL':0,'SLT':0,'SLTU':0,
                        'XOR':0,'SRL':0,'SRA':0x20,'OR':0,'AND':0}[kwargs['type']]
    instr.num()

encoder(type='LUI',imm=0x800,rd=16)
encoder(type='BNE',imm=17,rs2=29,rs1=14)
encoder(type='LUI',imm=0xff0,rd=29)

encoder(type='ADDI',imm=0,rs1=0,rd=10)
encoder(type='ADDI',imm=1,rs1=0,rd=1)
encoder(type='ADDI',imm=28,rs1=1,rd=1)
encoder(type='LW',imm=0,rs1=1,rd=14)
encoder(type='LUI',imm=0xff0,rd=29)
encoder(type='ADDI',imm=0xff,rd=29,rs1=29)
print()

encoder(type='ADD',rs2=0,rd=0,rs1=0)
encoder(type='ADD',rs1=5,rs2=2,rd=4)
print()

encoder(type='LUI',imm=0xfffff,rd=1) #x1 = 0xfffff000
encoder(type='LUI',imm=0xffff,rd=3)  #x1 = 0x0ffff000
encoder(type='SUB',rs1=1,rs2=3,rd=2) #x2 = x1-x3
encoder(type='SW',rs1=0,rs2=4,imm=0) #rs2 in 0th word
encoder(type='LUI',imm=0xcd,rd=6)    #x6 = 0xcd000
encoder(type='SRLI',shamt=12,rs1=6,rd=7)    #x7 = 0xcd
encoder(type='SB',rs1=0,rs2=7,imm=5)        #dmemb[5] = 0xcd
