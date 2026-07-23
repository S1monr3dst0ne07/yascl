#!/usr/bin/python3
import sys
from dataclasses import dataclass as dc


out = sys.stdin.read()
_, src = out.split("--- heap dump start ---")
heap_base = 0
dump = {}

for line in src.split('\n'):
    if not line.strip('\x00 '): continue
    key, value = line.strip('\x00').split('=')
    if key == "__heap_base":
        heap_base = int(value)
    else:
        dump[int(key) + heap_base] = int(value)



@dc
class Chunk:
    base : int
    len : int
    content : list[int]

chunks = []

index = heap_base
while index in dump:
    base = index
    len = dump[index]

    if len == 0:
        index += 1
        continue

    content = [dump[index + i + 1] for i in range(len-1)]
    index += len

    chunks.append(Chunk(base, len, content))
    

for chunk in chunks:
    print(chunk)






