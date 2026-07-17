#!/usr/bin/python3


import sys, os
from dataclasses import dataclass as dc
from typing import Literal, Any



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








def main():
    path = sys.argv[1]
    stream = tokenize(path)
    root = AstProg.parse(stream)
    print(root)





if __name__ == '__main__':
    main()
