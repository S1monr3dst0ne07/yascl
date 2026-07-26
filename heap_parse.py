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
    content : list[int]

chunks = []

addr = heap_base
while addr in dump:
    size = dump[addr+(8*2)]
    next = dump[addr+(8*3)]
    base = addr+(8*5)
    addr = next

    content = []
    for i in range(size - 5):
        content.append(dump[base + (8*i)])

    chunks.append(Chunk(base, content))
    

for chunk in chunks:
    print(chunk)






