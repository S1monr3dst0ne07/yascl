#!/usr/bin/python3

import re
import subprocess

INPUT_PATH  = 'lib/uapi.yap.pre'
OUTPUT_PATH = 'lib/uapi.yap'


with open(INPUT_PATH, 'r') as f:
    src = f.read()


includes = re.findall(r'#.*\n', src)
exprs    = re.findall(r'`(.*)`',  src)

content = '\n\t'.join(f'print({expr});' for expr in exprs)

program = f"""
{''.join(includes)}
#include "tools/binding/runtime.c"

int main(void)
{{
\t{content}
}}
""".strip('\n')

SOURCE_PATH = 'binding-print.c'
EXEC_PATH   = 'binding-print.out'

with open(SOURCE_PATH, "w") as f:
    f.write(program)

subprocess.run(['cc', SOURCE_PATH, '-o', EXEC_PATH])

