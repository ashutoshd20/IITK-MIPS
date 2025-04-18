from typing import List, Tuple, Union

def reg(name: str) -> int:
    reg_map = {
        '$zero': 0, '$at': 1, '$v0': 2, '$v1': 3,
        '$a0': 4, '$a1': 5, '$a2': 6, '$a3': 7,
        '$t0': 8, '$t1': 9, '$t2': 10, '$t3': 11,
        '$t4': 12, '$t5': 13, '$t6': 14, '$t7': 15,
        '$s0': 16, '$s1': 17, '$s2': 18, '$s3': 19,
        '$s4': 20, '$s5': 21, '$s6': 22, '$s7': 23,
        '$t8': 24, '$t9': 25, '$gp': 28, '$sp': 29, '$fp': 30, '$ra': 31
    }
    if name in reg_map:
        return reg_map[name]
    raise ValueError(f"Unknown register: {name}")

def to_bin(val: int, bits: int) -> str:
    return format(val & ((1 << bits) - 1), f'0{bits}b')

def encode_custom_branch(rs, rt, offset_words, funct_code):
    if offset_words < -512 or offset_words > 511:
        raise ValueError("Offset out of range for 10-bit signed field")
    offset10 = offset_words & 0x3FF  # signed 10-bit
    full_imm = (offset10 << 6) | (funct_code & 0x3F)  # [15:6]=offset, [5:0]=funct
    return f"{to_bin(0x1F,6)}{to_bin(reg(rs),5)}{to_bin(reg(rt),5)}{to_bin(full_imm,16)}"

def encode_mips(instr: Tuple) -> str:
    op = instr[0].lower()
    r_type_map = {
        'add': 0x20, 'sub': 0x22, 'addu': 0x21, 'subu': 0x23,
        'and': 0x24, 'or': 0x25, 'xor': 0x26, 'sll': 0x00,
        'srl': 0x02, 'sra': 0x03, 'slt': 0x2A, 'mul': 0x18,
        'jr': 0x08
    }
    if op in r_type_map:
        if op == 'jr':
            rs = instr[1]
            return f"000000{to_bin(reg(rs),5)}000000000000000{to_bin(r_type_map[op],6)}"
        elif op in ['sll', 'srl', 'sra']:
            rd, rt, shamt = instr[1], instr[2], instr[3]
            return f"00000000000{to_bin(reg(rt),5)}{to_bin(reg(rd),5)}{to_bin(shamt,5)}{to_bin(r_type_map[op],6)}"
        else:
            rd, rs, rt = instr[1], instr[2], instr[3]
            return f"000000{to_bin(reg(rs),5)}{to_bin(reg(rt),5)}{to_bin(reg(rd),5)}00000{to_bin(r_type_map[op],6)}"

    i_type_map = {
        'addi': 0x08, 'addiu': 0x09, 'andi': 0x0C, 'ori': 0x0D,
        'xori': 0x0E, 'lui': 0x0F, 'lw': 0x23, 'sw': 0x2B,
        'beq': 0x04, 'bne': 0x05
    }
    if op in i_type_map:
        if op == 'lui':
            rt, imm = instr[1], instr[2]
            return f"{to_bin(i_type_map[op],6)}00000{to_bin(reg(rt),5)}{to_bin(imm,16)}"
        else:
            rt, rs, imm = instr[1], instr[2], instr[3]
            return f"{to_bin(i_type_map[op],6)}{to_bin(reg(rs),5)}{to_bin(reg(rt),5)}{to_bin(imm,16)}"

    if op in ['bgt', 'bgte', 'ble', 'bleq', 'bleu', 'bgtu']:
        func_map = {
            'bgt': 0x11, 'bgte': 0x12, 'ble': 0x13,
            'bleq': 0x14, 'bleu': 0x15, 'bgtu': 0x16
        }
        rs, rt, offset_words = instr[1], instr[2], instr[3]
        return encode_custom_branch(rs, rt, offset_words, func_map[op])

    if op == 'seq':
        rs, rt, rd = instr[1], instr[2], instr[3]
        return f"{to_bin(0x1F,6)}{to_bin(reg(rs),5)}{to_bin(reg(rt),5)}{to_bin(reg(rd),5)}00000{to_bin(0x18,6)}"

    if op in ['j', 'jal']:
        opcode = 0x02 if op == 'j' else 0x03
        return f"{to_bin(opcode,6)}{to_bin(instr[1],26)}"

    raise ValueError(f"Unknown instruction format: {instr}")

def assemble(instructions: List[Tuple[str, Union[str, int], Union[str, int], Union[str, int], Union[int, None]]]) -> List[str]:
    binaries = [encode_mips(instr) for instr in instructions]
    return [f"32'b{b}" for b in binaries]

# Example usage
if __name__ == "__main__":
    example = [
        ("addi", "$t0", "$zero", 1),   # $t0 = 1
        ("addi", "$t1", "$zero", 7),   # $t1 = 7
        ("addi", "$t2", "$zero", 25),  # $t2 = 25
        ("bgt", "$t1", "$t0", 3),      # if $t1 > $t0: jump 3 instructions
        ("addi", "$t3", "$t0", 0),     # swap $t0 <-> $t1
        ("addi", "$t0", "$t1", 0),
        ("addi", "$t1", "$t3", 0),
        ("addi", "$t0", "$t0", 0),     # no-op
        ("addi", "$t1", "$t1", 0),
        ("addi", "$t2", "$t2", 0),
    ]

    out = assemble(example)
    with open("output.txt", "w") as f:
        for i, binstr in enumerate(out):
            f.write(f"init_inst({i}, {binstr});\n")
            print(f"init_inst({i}, {binstr});")