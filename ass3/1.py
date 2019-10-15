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
        load_rd()
        imm = reg(kwargs['imm'],20)
        instr[31:12] = imm[20:20]+imm[10:1]+imm[11:11]+imm[19:12]
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

# print('ALU testbench')
# encoder(type='LUI',rd=31,imm=0xfffff) #LUI x31 0xfffff
# encoder(type='ADDI',rd=31,rs1=30,imm=0xfff) #ADDI x31 x31 0xfff
# encoder(type='ADDI',rd=30,rs1=0,imm=0x0ee) #x30 = 0x00000eee
# encoder(type='SUB',rd=1,rs1=0,rs2=31) #SUB x1 0 x31
# encoder(type='XOR',rd=2,rs1=31,rs2=30)# x2 = =x31^x30
# encoder(type='XORI',rd=3,rs1=31,imm=0x0ee)# x2 = =x31^x0xeee
# encoder(type='BNE',rs1=2,rs2=3,imm=13)
# encoder(type='BEQ',rs1=2,rs2=3,imm=13)
# encoder(type='OR',rd=2,rs1=31,rs2=30)# x2 = =x31|x30
# encoder(type='ORI',rd=3,rs1=31,imm=0xeee)# x2 = =x31|x0xeee
# encoder(type='BLT',rs1=2,rs2=3,imm=12)
# encoder(type='AND',rd=2,rs1=31,rs2=30)# x2 = =x31^x30
# encoder(type='ANDI',rd=3,rs1=31,imm=0xeee)# x2 = =x31^x0xeee
# encoder(type='BLTU',rs1=2,rs2=3,imm=12)

# encoder()

encoder(type='ADDI',rd=0,rs1=0,imm=0)
encoder(type='ADD',rd=0,rs1=0,rs2=0)

quit()
print('load test bench')
encoder(type='LBU',rs1=0,rd=1,imm=0)#0
encoder(type='LBU',rs1=0,rd=2,imm=1)#0
encoder(type='LBU',rs1=0,rd=3,imm=2)#0
encoder(type='LBU',rs1=0,rd=4,imm=3)#0
encoder(type='LHU',rs1=0,rd=5,imm=4)#1
encoder(type='LHU',rs1=0,rd=6,imm=6)#1
encoder(type='LW',rs1=0,rd=7,imm=8)#8

encoder(type='SB',rs1=0,rs2=1,imm=12)#3
encoder(type='SB',rs1=0,rs2=2,imm=13)
encoder(type='SB',rs1=0,rs2=3,imm=14)
encoder(type='SB',rs1=0,rs2=4,imm=15)
encoder(type='SH',rs1=0,rs2=5,imm=16)#4
encoder(type='SH',rs1=0,rs2=6,imm=18)
encoder(type='SW',rs1=0,rs2=7,imm=20)#20

encoder(type='LB',rs1=0,rd=8,imm=0)#0
encoder(type='LB',rs1=0,rd=9,imm=1)
encoder(type='LB',rs1=0,rd=10,imm=2)
encoder(type='LB',rs1=0,rd=11,imm=3)
encoder(type='LH',rs1=0,rd=12,imm=4)#1 4 or 5(works if misaligned access if forced to align)
encoder(type='LH',rs1=0,rd=13,imm=6)#1 6 or 7

encoder(type='SB',rs1=0,rs2=8,imm=24)#6
encoder(type='SB',rs1=0,rs2=9,imm=25)
encoder(type='SB',rs1=0,rs2=10,imm=26)
encoder(type='SB',rs1=0,rs2=11,imm=27)
encoder(type='SH',rs1=0,rs2=12,imm=28)#7 28 or 29
encoder(type='SH',rs1=0,rs2=13,imm=30)#7 30 or 31
