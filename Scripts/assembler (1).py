class Assembler:
    def __init__(self, input_file):
        self.input_file = input_file
        self.symbol_table = {}
        self.instructions = []
        self.data_definitions = []
        self.instruction_address = 0
        self.data_address = 0
        self.mode = "instructions"
        self.machine_code = []

    def assemble(self):
        self.first_pass()
        self.second_pass()
        self.write_cod_file()
        self.write_data_file()

    def first_pass(self):
        with open(self.input_file, 'r', encoding='utf-8') as f:
            lines = f.readlines()

        self.instructions = []
        self.data_definitions = []
        self.symbol_table = {}
        self.instruction_address = 0
        self.data_address = 0
        self.mode = "instructions"

        for raw_line in lines:
            line = raw_line.strip()
            # keep only ASCII
            line = line.encode('ascii', errors='ignore').decode()

            # skip empties & full-line comments
            if not line or line.startswith(('/', '#', '*')):
                continue

            # strip inline comments FIRST (now includes '*')
            for sep in ['//', '##', '#', '/', '*']:
                if sep in line:
                    line = line.split(sep)[0].strip()
            if not line:
                continue

            label = None
            if ':' in line:
                label, line = [part.strip() for part in line.split(':', 1)]

            tokens = line.split()
            if not tokens:
                # label-only line
                if label is not None:
                    if self.mode == "instructions":
                        self.symbol_table[label] = self.instruction_address
                    else:
                        self.symbol_table[label] = self.instruction_address + self.data_address
                continue

            # switch to data mode ONLY when first token is dc/ds
            if tokens[0] in ('dc', 'ds'):
                self.mode = "data"

            if self.mode == "instructions":
                if label is not None:
                    self.symbol_table[label] = self.instruction_address
                self.instructions.append(line)
                self.instruction_address += 1
            else:
                if label is not None:
                    self.symbol_table[label] = self.instruction_address + self.data_address
                self.data_definitions.append(line)
                if tokens[0] == 'dc':
                    self.data_address += 1
                elif tokens[0] == 'ds':
                    self.data_address += int(tokens[1])

    def second_pass(self):
        self.machine_code = []
        for idx, line in enumerate(self.instructions):
            try:
                code = self.parse_instruction(line, idx)
                if not code:
                    code = '????????'
            except Exception as e:
                print(f"[Line {idx+1}] Error parsing instruction '{line}': {e}")
                code = '????????'
            self.machine_code.append(code)

    def parse_instruction(self, line, current_pc):
        parts = line.split()
        mnemonic = parts[0].lower()

        if mnemonic == 'halt':
            return 'FC000000'

        if mnemonic == 'jalr':
            opcode = I_TYPE_OPCODES[mnemonic]
            if len(parts) == 3:
                rd = reg_to_num(parts[1])
                rs1 = reg_to_num(parts[2])
            else:
                rs1 = reg_to_num(parts[1])
                rd = 31  # default link register
            imm = 0
            return bin_to_hex(
                to_bin(opcode,6) + to_bin(rs1,5) + to_bin(rd,5) + to_bin(imm,16)
            )

        if mnemonic == 'jr':
            opcode = I_TYPE_OPCODES[mnemonic]
            rs1 = reg_to_num(parts[1])
            rd = 0
            imm = 0
            return bin_to_hex(
                to_bin(opcode,6) + to_bin(rs1,5) + to_bin(rd,5) + to_bin(imm,16)
            )

        # branches: label or numeric offset, RD=31 per your ISA
        if mnemonic in ['beqz', 'bnez']:
            opcode = I_TYPE_OPCODES[mnemonic]
            rs1 = reg_to_num(parts[1])
            rd = 31
            target = parts[2]
            try:
                offset = int(target, 0)
            except ValueError:
                if target not in self.symbol_table:
                    raise ValueError(f"Unknown label or offset: {target}")
                target_pc = self.symbol_table[target]
                offset = target_pc - (current_pc + 1)
            if not (-32768 <= offset <= 32767):
                raise ValueError(f"Branch offset out of range: {offset}")
            return bin_to_hex(
                to_bin(opcode,6) + to_bin(rs1,5) + to_bin(rd,5) + to_bin(offset,16)
            )

        # generic I-type (lw, sw, addi, lr, sc, swap, amoadd, etc.)
        if mnemonic in I_TYPE_OPCODES:
            opcode = I_TYPE_OPCODES[mnemonic]
            rs1 = reg_to_num(parts[2])
            rd  = reg_to_num(parts[1])
            imm = parse_immediate(parts[3], self.symbol_table)
            return bin_to_hex(
                to_bin(opcode,6) + to_bin(rs1,5) + to_bin(rd,5) + to_bin(imm,16)
            )

        # R-type
        if mnemonic in R_TYPE_FUNCTS:
            opcode = 0
            rs1 = reg_to_num(parts[2]) if len(parts) > 2 else 0
            rs2 = reg_to_num(parts[3]) if len(parts) > 3 else 0
            rd  = reg_to_num(parts[1])
            funct = R_TYPE_FUNCTS[mnemonic]
            return bin_to_hex(
                to_bin(opcode,6) + to_bin(rs1,5) + to_bin(rs2,5) + to_bin(rd,5) + to_bin(0,5) + to_bin(funct,6)
            )

        raise ValueError(f"Unknown instruction: {line}")

    def write_cod_file(self):
        # Use CRLF endings for compatibility with old loaders
        path = self.input_file.replace('.txt', '.COD')
        with open(path, 'w', newline='\r\n') as f:
            # --- CODE section ---
            f.write('.CODE\r\n')
            f.write('0x00000000\r\n')  # base address of instructions
            instr_count = len(self.instructions)  # anchor to source length
            f.write(f'0x{instr_count:08X}\r\n')
            for i in range(instr_count):
                mc = self.machine_code[i] if i < len(self.machine_code) else '????????'
                if mc == '????????':
                    f.write('0x????????\r\n')
                else:
                    f.write(f'0x{int(mc, 16):08X}\r\n')

            # --- DATA section: BASE then LENGTH (both in words) ---
            data_len = self.data_address
            f.write('.DATA\r\n')
            f.write(f'0x{instr_count:08X}\r\n')  # data BASE (immediately after code)
            f.write(f'0x{data_len:08X}\r\n')     # data LENGTH
            for line in self.data_definitions:
                t = line.split()
                if t[0] == 'ds':
                    for _ in range(int(t[1])):
                        f.write('0x00000000\r\n')
                elif t[0] == 'dc':
                    f.write(f'0x{int(t[1], 0):08X}\r\n')

            f.write('.DS\r\n')
            f.write('0X42 XML file date: XML file date: Wed 20/6/2012 6:49:12\r\n')

    def write_data_file(self):
        with open(self.input_file.replace('.txt', '.data'), 'w') as f:
            f.write('\t //\t\t\t* Instructions\n\n')
            for i, line in enumerate(self.instructions):
                hex_code = self.machine_code[i] if i < len(self.machine_code) else '????????'
                f.write(f'{hex_code} //\t{line}\n')
            f.write('\n\t //\t\t\t* destination area\n')
            for line in self.data_definitions:
                t = line.split()
                if t[0] == 'ds':
                    for _ in range(int(t[1])):
                        f.write('00000000 //\t' + line + '\n')
                elif t[0] == 'dc':
                    f.write(f'{int(t[1], 0):08X} //\t{line}\n')


# --- helpers ---

I_TYPE_OPCODES = {
    'lw':     0b100011,
    'sw':     0b101011,
    'addi':   0b001011,
    'sgti':   0b011001,
    'seqi':   0b011010,
    'sgei':   0b011011,
    'slti':   0b011100,
    'snei':   0b011101,
    'slei':   0b011110,
    'beqz':   0b000100,
    'bnez':   0b000101,
    'jr':     0b010110,
    'jalr':   0b010111,
    'lr':     0b100100,
    'sc':     0b101100,
    'swap':   0b101101,
    'amoadd': 0b101110
}

R_TYPE_FUNCTS = {
    'slli': 0b000000,
    'srli': 0b000010,
    'add':  0b100011,
    'sub':  0b000100,
    'and':  0b100100,
    'or':   0b100101,
    'xor':  0b100110,
    'xor5': 0b111011,

}

def reg_to_num(r):
    n = int(r.replace("R", ""))
    if not (0 <= n <= 31):
        raise ValueError(f"Invalid register number: {r}")
    return n

def to_bin(val, bits):
    if val < 0:
        val = (1 << bits) + val
    return format(val & ((1 << bits) - 1), f'0{bits}b')

def bin_to_hex(binary):
    return f"{int(binary, 2):08X}"

def parse_immediate(token, symbol_table):
    try:
        return int(token, 0)
    except ValueError:
        if token in symbol_table:
            return symbol_table[token]
        raise ValueError(f"Invalid immediate or label not found: {token}")


if __name__ == "__main__":
    asm = Assembler('dlx_prog.txt')
    asm.assemble()
    print("Assembly complete.")
