#!/usr/bin/python3
import sys
from dataclasses import dataclass as dc


out = sys.stdin.read()
preamble, src = out.split("--- heap dump start ---")
print(preamble)

dump = {}


for line in src.split('\n'):
    if not line.strip('\x00 '): continue
    key, value = line.strip('\x00').split('=')
    dump[int(key)] = int(value)

heap_base = min(dump.keys())



@dc
class Chunk:
    base : int
    len : int
    content : list[int]

chunks = []

magic = 100000000

addr = heap_base
while addr in dump:
    base = addr
    len = dump[addr]
    addr += 8

    if len > magic:
        len -= magic

    print(len)

    content = []
    for _ in range(len-1):
        content.append(dump[addr])
        addr += 8

    chunks.append(Chunk(base, len, content))
    

for chunk in chunks:
    print(chunk)






