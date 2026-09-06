#!/usr/bin/python3

import ctypes
from dataclasses import dataclass as dc

class FreeBlock(ctypes.LittleEndianStructure):
    _fields_ = [
        ("units",   ctypes.c_uint64),
        ("size",    ctypes.c_uint64),
        ("next",    ctypes.c_uint64),
        ("padding", ctypes.c_uint64),
    ] + [("a" + str(n), ctypes.c_uint64) for n in range(4)]

    def print(self):
        print(f"units={self.units} \tsize={self.size} \tnext={self.next}")


@dc
class Heap:
    blocks : list[FreeBlock] 

    @staticmethod
    def read_blocks(f, count):
        return f.read(count * ctypes.sizeof(FreeBlock))

    @classmethod
    def read(cls, f):
        blocks = []

        while True:
            chunk = cls.read_blocks(f, 1)
            if not len(chunk): break

            fb = FreeBlock.from_buffer_copy(chunk)
            content_units = fb.units-1 #units includes the header
            cls.read_blocks(f, content_units)
            blocks.append(fb)

        return cls(blocks)

    def print(self):
        for block in self.blocks:
            block.print()



with open('core', 'rb') as f:
    heap = Heap.read(f)

heap.print() 
print(f"total blocks: {len(heap.blocks)}")

