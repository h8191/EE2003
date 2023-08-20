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

    def num(self,ret=0):
        if (ret):
            return hex(eval('0b'+''.join(map(str,self.bits))))[2:].zfill(8)
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
        instr[6:0] = 0x6f
        load_rd()
        imm = reg(kwargs['imm']*2,21)
        instr[31:12] = imm[20:20]+imm[10:1]+imm[11:11]+imm[19:12]
        pass

    if kwargs['type'] == 'JALR':
        load_rd()
        load_r1()
        instr[14:12] = 0
        instr[31:20] = reg(kwargs['imm'],12).bits

    if kwargs['type'] in ['BEQ','BNE','BLT','BGE','BLTU','BGEU']:
        imm = reg(kwargs['imm']*2,32)

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
    return instr.num()

def neg(x,bits=20):
    return x if x>=0 else (1<<bits)+x

encoder(type='BEQ',rs1=0,rs2=0,imm=4)
encoder(type='BEQ',rs1=0,rs2=0,imm=20)
encoder(type='BEQ',rs1=0,rs2=0,imm=4)
encoder(type='BEQ',rs1=0,rs2=0,imm=0xffc)
encoder(type='BEQ',rs1=0,rs2=0,imm=4)
encoder(type='BEQ',rs1=0,rs2=0,imm=0xffc)
encoder(type='BEQ',rs1=0,rs2=0,imm=4)
encoder(type='BEQ',rs1=0,rs2=0,imm=0xffc)
encoder(type='BEQ',rs1=0,rs2=0,imm=4)
encoder(type='ADDI',rd=1,rs1=1,imm=1)
encoder(type='BEQ',rs1=0,rs2=0,imm=0xffa)
# encoder(type='')
quit()
encoder(type='BEQ',rs1=0,rs2=0,imm=4)
encoder(type='BEQ',rs1=0,rs2=0,imm=0xffc)
quit()

print(hex(2**12-4))
encoder(type='ADDI',rd=1,rs1=0,imm=0)
encoder(type='ADDI',rd=1,rs1=1,imm=1)
encoder(type='BEQ',rs1=1,rs2=0,imm=40)
encoder(type='BEQ',rs1=0,rs2=0,imm=0xfffc)
quit()
encoder(type='SW',rs2=0,rs1=0,imm=28)
encoder(type='LB',rd=1,rs1=0,imm=0)
encoder(type='LB',rd=2,rs1=1,imm=0)
encoder(type='LB',rd=3,rs1=2,imm=0)
encoder(type='LB',rd=4,rs1=3,imm=0)
quit()

# encoder(type='LW',rd=1,rs1=0,imm=0)
# encoder(type='LW',rd=2,rs1=0,imm=4)
# encoder(type='LW',rd=3,rs1=0,imm=8)
# encoder(type='LW',rd=4,rs1=0,imm=12)
# encoder(type='SW',rs1=0,rs2=1,imm=16)
# encoder(type='SW',rs1=0,rs2=2,imm=20)
# encoder(type='SW',rs1=0,rs2=3,imm=24)
# encoder(type='SW',rs1=0,rs2=4,imm=28)

# encoder(type='ADDI',rd=1,rs1=0,imm=0)
# encoder(type='ADDI',rd=2,rs1=0,imm=1)
# encoder(type='ADDI',rd=4,rs1=0,imm=0)
# encoder(type='ADDI',rd=5,rs1=0,imm=15)
# encoder(type='ADD',rd=3,rs1=1,rs2=2)
# encoder(type='SB',rs2=3,rs1=4,imm=0)
# encoder(type='ADDI',rd=4,rs1=4,imm=1)
# encoder(type='ADDI',rd=1,rs1=2,imm=0)
# encoder(type='ADDI',rd=2,rs1=3,imm=0)
# encoder(type='BNE',rs1=4,rs2=5,imm=neg(20,10))

# encoder(type='LB',rd=1,rs1=0,imm=0)
# encoder(type='LB',rd=2,rs1=1,imm=0)
# encoder(type='LB',rd=3,rs1=2,imm=0)
# encoder(type='LB',rd=4,rs1=3,imm=0)
# encoder(type='LB',rd=5,rs1=4,imm=0)
# encoder(type='LB',rd=6,rs1=5,imm=0)
# encoder(type='LB',rd=7,rs1=6,imm=0)
# encoder(type='LB',rd=8,rs1=7,imm=0)


# quit()
if __name__ == '__main__':
    #address where base address for accumulator
    encoder(type='ADDI',rd=31,rs1=0,imm=0)  # ADDI R30 R0 0 
    encoder(type='ADDI',rd=30,rs1=0,imm=512)#ADDI R30 R0 512
    encoder(type='ADDI',rd=29,rs1=0,imm=13)         #ADDI R29 R0 13
    encoder(type='ADDI',rd=28,rs1=0,imm=26)         #ADDI R28 R0 26
    encoder(type='SW',rs2=14,rs1=30,imm=0)  #SW R14 R30 0 #reset acc
    encoder(type='SW',rs2=29,rs1=30,imm=4)  #SW R29 R30 4 #add to accumulator
    encoder(type='SW',rs2=28,rs1=30,imm=4)  #SW R28 R30 4 #add to accumulator
    encoder(type='LW',rd=27,rs1=30,imm=8)   #LHU R27 R30 8 #read sum into R27
    encoder(type='LW',rd=26,rs1=30,imm=12)  #LBU R26 R30 12 #read count in R26
    encoder(type='ADD',rd=1,rs1=28,rs2=29)  #R1 = R28 + R29
    encoder(type='ADDI',rd=2,rs1=0,imm=2)   #R2 = 2
    encoder(type='BNE',rs1=27,rs2=1,imm=6) #BNE jump to x31 =1//check if sum matches
    encoder(type='BNE',rs1=26,rs2=2,imm=4) #BNE jump to x31 =1//check if count matches
    encoder(type='JAL',rd=10,imm=neg(-26,20))         #JAL store in R10 jummp to zero
    encoder(type='ADDI',rd=31,rs1=0,imm=1)  # ADDI R31 R0 1 
    #encoder(type='ADDI',rd=0,rs1=0,imm=0)  # ADDI R0 R0 1 
    pass
# print(hex(512))