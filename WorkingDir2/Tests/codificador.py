#!/usr/bin/env python3
# Rev 4
import sys

WORD_SIZE        = 32   # tamaño de las palabras
INSTRUCTION_SIZE = 2    # palabras que ocupan la instruccion
BLOCKS_TO_FILL   = 16   # Numero de lineas de BLOCKS_SIZE que llenar en la memoria
BLOCK_SIZE       = 8    # Numero de palabras por linea en la memoria

AVISO_MEMORIA_DATOS = """
-- Memoria de datos guardada en datos.hex.
-- Sustituyela por la del fichero RAM-D.vhd (o parecido).
"""[1:]

AVISO_MEMORIA_INSTRUCCIONES = """
-- Memoria de datos guardada en instrucciones.hex.
-- Sustituyela por la del fichero RAM-I.vhd (o parecido).
"""[1:]

# Si tienes una codificacion diferente cambiala aqui
CODIFICACION = {
    "LW":  "000010",
    "SW":  "000011",
    "BEQ": "000100",
    "ADD": "000001",
    "SUB": "000001",
    "NOP": "000000",
    "JAL": "000101",
    "RET": "000110",
    "RTE": "001000",
}

####### FUNCIONES DEL PROCESADOR #######

def lw(args: str):
    # parser
    rt, to_parse = args.split(',')
    inmd, rs = [ x.strip() for x in to_parse.split('(') ]
    rs = int(rs[1:-1])
    rt = int(rt.strip()[1:])
    inmd = int(inmd) << 2 # Vease RAM-D.vhd para el porque de el shifteado de dos bits

    # codificacion
    high = CODIFICACION["LW"] + bbin(rs, 5) + bbin(rt, 5)
    low  = dectobin(inmd)
    return bintohex(high + low)

def sw(args: str):
    # parser
    rt, to_parse = args.split(',')
    inmd, rs = [ x.strip() for x in to_parse.split('(') ]
    rs = int(rs[1:-1])
    rt = int(rt.strip()[1:])
    inmd = int(inmd) << 2 # Vease RAM-D.vhd para el porque de el shifteado de dos bits

    # codificacion
    high = CODIFICACION["SW"] + bbin(rs, 5) + bbin(rt, 5)
    low  = dectobin(inmd)
    return bintohex(high + low)

def beq(args: str):
    # parser
    rs, rt, inmd = [x.strip() for x in args.split(',')]
    rs, rt = [int(x.strip()[1:]) for x in [rs, rt]]
    inmd = int(inmd.strip())

    # codificacion
    high = CODIFICACION["BEQ"] + bbin(rs, 5) + bbin(rt, 5)
    low  = dectobin(inmd)
    return bintohex(high + low)

def add(args: str):
    # parser
    rd, rs, rt = [int(x.strip()[1:]) for x in args.split(',')]

    # codificacion
    funct = 0
    high = CODIFICACION["ADD"] + bbin(rs, 5) + bbin(rt, 5)
    low  = bbin(rd, 5) + bbin(0, 5) + bbin(funct, 6)
    return bintohex(high + low)

def sub(args: str):
    # parser
    rd, rs, rt = [int(x.strip()[1:]) for x in args.split(',')]

    # codificacion
    funct = 1
    high = CODIFICACION["SUB"] + bbin(rs, 5) + bbin(rt, 5)
    low  = bbin(rd, 5) + bbin(0, 5) + bbin(funct, 6)
    return bintohex(high + low)

def nop():
    return bintohex(bbin(0, WORD_SIZE))

def jal(args: str):
    # parser
    rt, inmd = [x.strip() for x in args.split(',')]
    rt = int(rt.strip()[1:])
    inmd = int(inmd.strip())

    # codificacion
    high = CODIFICACION["JAL"] + bbin(0, 5) + bbin(rt, 5)
    low  = dectobin(inmd)
    return bintohex(high + low)

def ret(args: str):
    # parser
    rs = [x.strip() for x in args.split(',')][0]
    rs = int(rs.strip()[1:])

    # codificacion
    high = CODIFICACION["RET"] + bbin(rs, 5) + bbin(0, 5)
    low  = bbin(0, 16)
    return bintohex(high + low)

def rte():
    return bintohex(CODIFICACION["RTE"] + bbin(0, WORD_SIZE - len(CODIFICACION["RTE"])))

####### LOGICA PRINCIPAL #######

def main():
    if (len(sys.argv)) < 2:
        print(f"Uso: {sys.argv[0]} <fichero_asm>\nEjemplo: {sys.argv[0]} programa.asm")
        exit(2)
    f = open(sys.argv[1], "r")
    ram = ['X"{}"'.format(bintohex(bbin(0, WORD_SIZE)))] * BLOCKS_TO_FILL * BLOCK_SIZE # la inicializamos vacia
    instrucciones = []

    for line in f.readlines():
        line = line.split(';')[0].strip()   # quitamos los comentarios
        if (len(line) == 0):
            pass # ignoramos las lineas vacias
        elif (line.startswith('@')):
            at, value = line.split(':')
            at = int(at[1:].strip())
            value = int(value.strip())
            ram[at] = 'X"{}"'.format(bintohex(bbin(value, WORD_SIZE)))
        else:
            splits = [ x.upper() for x in line.split() ]
            args = "".join(splits[1:])
            match splits[0]:
                case "LW":
                    instrucciones.append(lw(args))
                case "SW":
                    instrucciones.append(sw(args))
                case "BEQ":
                    instrucciones.append(beq(args))
                case "ADD":
                    instrucciones.append(add(args))
                case "SUB":
                    instrucciones.append(sub(args))
                case "NOP":
                    instrucciones.append(nop())
                case "JAL":
                    instrucciones.append(jal(args))
                case "RET":
                    instrucciones.append(ret(args))
                case "RTE":
                    instrucciones.append(rte())
                case unknown:
                    print("Instrucción no reconocida: ", unknown)
                    exit(1)

    f.close()

    S_instruccciones = print_instructions(instrucciones)
    S_memoria = print_memory(ram)
    print(S_memoria)
    print()
    print(S_instruccciones)

    with open("datos.hex", 'w') as f:
        f.write(S_memoria)

    with open("instrucciones.hex", 'w') as f:
        f.write(S_instruccciones)

####### FUNCIONES DE AYUDA #######

def bbin(n: int, l: int):
    return normal(bin(n)[2:], l)


def normal(s: str, n: int):
    diff = n - len(s)
    if diff < 0:
        print("ERROR en s = ", s)
        exit(1)
    elif diff > 0:
        zero_pad = "0"*diff
        s = zero_pad + s

    return s

def bintohex(b: str):
    return normal(hex(int(b, 2))[2:], 8)

def dectobin(d: int):
    if d < 0:
        return bbin((-d ^ 0xffff) + 1, 16)
    else:
        return bbin(d, 16)

####### FUNCIONES DE FORMATO #######

def print_instructions(instrucciones):
    HEADER = "signal RAM : RamType :=          ( "
    PADDING_SIZE = 35
    PADDING = ' '*PADDING_SIZE

    S = ""
    block = 1
    for (i, instruccion) in enumerate(instrucciones):
        # X"00000000"
        if i > 0 and i % BLOCK_SIZE == 0:
            # new block
            S += "\n" + PADDING
            block += 1
        S += f"X\"{instruccion}\"" + ", "

    nx = BLOCK_SIZE - (len(instrucciones) % BLOCK_SIZE)
    S += 'X"{}", '.format(bintohex(bbin(0, WORD_SIZE))) * nx + '\n' + PADDING

    while block < BLOCKS_TO_FILL:
        S += 'X"{}", '.format(bintohex(bbin(0, WORD_SIZE))) * BLOCK_SIZE + '\n' + PADDING
        block += 1

    return AVISO_MEMORIA_INSTRUCCIONES + HEADER + S[:-(PADDING_SIZE + 3)] + ");\n"

def print_memory(ram):
    HEADER = "signal RAM : RamType :=          ( "
    PADDING_SIZE = 35
    PADDING = ' '*PADDING_SIZE

    S = ""
    for (i, memoria) in enumerate(ram):
        if i > 0 and i % BLOCK_SIZE == 0:
            S += "\n" + PADDING
        S += memoria + ", "

    return AVISO_MEMORIA_DATOS + HEADER + S[:-2] + ");\n"


if __name__ == "__main__":
    main()
