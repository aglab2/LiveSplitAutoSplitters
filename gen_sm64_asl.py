import sys

def ptr_swap(ptr, table):
    c = ptr // 4
    o = ptr % 4
    os = table[o]
    assert os != -1, f"Failed to swap 0x{ptr:x} using {table}"
    return (c * 4 + os) & 0xffffff

# All pointers must be aligned on a size it will read
# It is not an x86 requirement but MIPS requirement
def ptr_swap8(ptr):
    return ptr_swap(ptr, [ 3, 2, 1, 0 ])

def ptr_swap16(ptr):
    return ptr_swap(ptr, [ 2, -1, 0, -1 ])

def ptr_swap32(ptr):
    return ptr_swap(ptr, [0, -1, -1, -1])

if len(sys.argv) != 4:
    print(f"Usage: {sys.argv[0]} MAP_PATH TMPL_PATH OUT_ASL_PATH")
    sys.exit(1)

map_path = sys.argv[1]
tmpl_path = sys.argv[2]
asl_path = sys.argv[3]

map = {}
with open(map_path) as map_file:
    for map_line in map_file:
        map_line_split = map_line.split()
        if len(map_line_split) != 2:
            continue

        map_addr_str = map_line_split[0]
        map_symbol = map_line_split[1]
        try:
            map_addr = int(map_addr_str, 0)
            map[map_symbol] = map_addr
        except:
            pass

tmpl = ""
with open(tmpl_path) as tmpl_file:
    tmpl = tmpl_file.read()

gMarioStates_numStars  = ptr_swap8 (map["gMarioStates"] + 0xAA)
gCurrLevelNum          = ptr_swap8 (map["gCurrLevelNum"])
gSequencePlayers_seqId = ptr_swap8 (map["gSequencePlayers"] + 0x5)
gMarioStates_action    = ptr_swap32(map["gMarioStates"] + 0xC)
gNumVblanks            = ptr_swap32(map["gNumVblanks"])
gSaveBufferSize        = 0x78
gSaveBuffer            = ptr_swap32(map["gSaveBuffer"])

asl = tmpl.format(
    gMarioStates_numStars = gMarioStates_numStars,
    gCurrLevelNum = gCurrLevelNum,
    gSequencePlayers_seqId = gSequencePlayers_seqId,
    gMarioStates_action = gMarioStates_action,
    gNumVblanks = gNumVblanks,
    gSaveBufferSize = gSaveBufferSize,
    gSaveBuffer = gSaveBuffer
)

with open(asl_path, 'w') as asl_file:
    asl_file.write(asl)