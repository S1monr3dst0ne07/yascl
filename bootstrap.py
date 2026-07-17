#!/usr/bin/python3


import sys, os
from dataclasses import dataclass as dc
from typing import Literal, Any

# 64-bit compiler
WORD_SIZE = 8


def tokenize(path):
    with open(path) as f:
        src = f.read()

    def get(char):
        match char:
            case x if x.isalpha(): return 'iden'
            case '_': return 'iden'
            case x if x.isdigit(): return 'numb'
            case '{': return 'bo'
            case '}': return 'bc'
            case '(': return 'po'
            case ')': return 'pc'
            case ';': return 'eos'
            case ' ' | '\t' | '\n': return 'format'
            case _: return 'symb'

    @dc
    class Streamer:
        toks : list[str]

        def peek(self):
            return self.toks[0]
        def pop(self):
            return self.toks.pop(0)
        def has(self):
            return len(self.toks) > 0
        def expect(self, should):
            be = self.pop()
            if be != should:
                print(f"Error: Expected `{should}` got `{be}`")
                sys.exit(1)

    toks = []
    buffer = ''
    string = False
    state = None
    for char in src:
        kind = get(char)

        if state != kind:
            if state not in (None, 'format'):
                toks.append(buffer)
            buffer = ''

        buffer += char
        state = kind

    
    return Streamer(toks)


@dc
class AstLeaf:
    value : Any
    kind : Literal['lit', 'var']

    @classmethod
    def parse(cls, stream):
        match stream.pop():
            case x if x.isdigit(): return cls(x, 'lit')
            case x if x.isalpha(): return cls(x, 'var')
            case x: print(x)

    def load(self, emit, scope): #load into rax
        match self.kind:
            case 'lit': emit(f'mov rax, {self.value}')
            case 'var': emit(f'mov rax, [vars + {scope[self.value]}]')

    def store(self, emit, scope): #store from rax
        match self.kind:
            case 'lit': 
                print("Error: Trying to store into literal value")
                sys.exit(1)
            case 'var':
                scope.alloc(self.value)
                emit(f'mov [vars + {scope[self.value]}], rax')




OPS = {'+':'add', '-':'sub'}

@dc
class AstExpr:
    left  : "AstExpr | AstLeaf"
    right : "AstExpr | AstLeaf"
    op    : Literal['add', 'sub']

    @classmethod
    def parse(cls, stream):
        left = AstLeaf.parse(stream)

        if stream.peek() not in OPS:
            return left

        op = OPS[stream.pop()]
        right = AstLeaf.parse(stream)
        return cls(left, right, op)

    def load(self, emit, scope):
        self.right.load(emit, scope)
        emit('push rax')
        self.left.load(emit, scope)
        emit('pop rbx')

        match self.op:
            case 'add': emit('add rax, rbx')
            case 'sub': emit('sub rax, rbx')






@dc
class AstPut:
    dst : AstExpr
    src : AstExpr

    @classmethod
    def parse(cls, stream):
        stream.expect('put')
        dst = AstExpr.parse(stream)
        stream.expect('=')
        src = AstExpr.parse(stream)
        stream.expect(';')
        return cls(dst, src)

    def compile(self, emit, scope):
        self.src.load(emit, scope)
        self.dst.store(emit, scope)

@dc
class AstCall:
    name : str
    params : list[str]

    @classmethod
    def parse(cls, stream):
        stream.expect('sub')
        name = stream.pop()
        stream.expect('(') #)
        
        params = []
        while stream.peek() != ')':
            params.append(stream.pop())
            if stream.peek() == ',':
                stream.pop()

        stream.expect(')')
        stream.expect(';')
        return cls(name, params)




@dc
class AstBlock:
    nodes : list

    @staticmethod
    def node(stream):
        match stream.peek():
            case 'put': return AstPut.parse(stream)
            case 'sub': return AstCall.parse(stream)
            case x:
                print(f"Error: Unknown node prefix: `{x}`")
                sys.exit(1)

    @classmethod
    def parse(cls, stream):
        stream.expect('{') #}

        nodes = []
        while stream.peek() != '}':
            nodes.append(cls.node(stream))

        stream.expect('}')
        return cls(nodes)

    def compile(self, emit, scope):
        for node in self.nodes:
            node.compile(emit, scope)


@dc
class AstFnDef:
    name   : str
    params : list[str]
    body   : AstBlock

    @classmethod
    def parse(cls, stream):
        stream.expect('fn')
        name = stream.pop()
        stream.expect('(') #)
        
        params = []
        while stream.peek() != ')':
            params.append(stream.pop())
            if stream.peek() == ',':
                stream.pop()

        stream.expect(')')
        body = AstBlock.parse(stream)
        return cls(name, params, body)

    @dc
    class _LocalScope:
        vars : dict[str, int] #variable name to address
        allocer : int = 0

        def alloc(self, name):
            if name in self.vars: return

            self.vars[name] = self.allocer * WORD_SIZE
            self.allocer += 1

        def __getitem__(self, name):
            return self.vars[name]


    def compile(self, emit):
        scope = self._LocalScope({})

        #!TODO implement ABI
        emit(f"{self.name}:")
        self.body.compile(emit, scope)
        emit("ret")


@dc
class AstProg:
    fns : list[AstFnDef]

    @classmethod
    def parse(cls, stream):
        
        fns = []

        while stream.has():
            match stream.peek():
                case 'fn': fns.append(AstFnDef.parse(stream))
                case x: print(x)

        return cls(fns)

    def compile(self, emit):
        for fn in self.fns:
            fn.compile(emit)


def runtime(emit):
    VAR_COUNT = 100 # concurrent local variables
    emit('format ELF64 executable')
    emit('entry start')
    emit(f'vars: \n\trq {VAR_COUNT}')
    emit(f"buf: \n\trb 4096 \n\tdb 10")
    emit('segment readable executable')
    emit("start:")
    emit("call main")
    emit("mov rdi, rax")
    emit("mov rax, 60")
    emit("syscall")


def main():
    path = sys.argv[1]
    stream = tokenize(path)
    root = AstProg.parse(stream)

    asm = []
    emitter = lambda x: asm.append(x)
    runtime(emitter)
    root.compile(emitter)

    with open('build.asm', 'w') as f:
        f.write('\n'.join(asm))




if __name__ == '__main__':
    main()
