#!/usr/bin/python3

import re
import subprocess
import os

INPUT_PATH  = 'lib/uapi.yap.pre'
OUTPUT_PATH = 'lib/uapi.yap'

SOURCE_PATH = 'tools/binding/run.c'
EXEC_PATH   = 'tools/binding/run.out'

INCLUDE_PATTERN    = r'#.*\n'
EXPRESSION_PATTERN = r'`(.*)`'


with open(INPUT_PATH, 'r') as f:
    src = f.read()


includes = re.findall(INCLUDE_PATTERN   , src)
exprs    = re.findall(EXPRESSION_PATTERN, src)

content = '\n\t'.join(f'print({expr});' for expr in exprs)
program = f"""
{''.join(includes)}
#include "runtime.c"

int main(void)
{{
\t{content}
}}
""".strip('\n')

with open(SOURCE_PATH, "w") as f:
    f.write(program)

subprocess.run(['cc', SOURCE_PATH, '-o', EXEC_PATH])
result = subprocess.run([EXEC_PATH], capture_output=True)

listing = iter(map(
    lambda x: str(int(x, 16)),
    result.stdout.decode('ascii').strip('\n').split('\n')
))

dst = re.sub(
    EXPRESSION_PATTERN, 
    lambda _: next(listing),
    re.sub(INCLUDE_PATTERN, '', src)
)

with open(OUTPUT_PATH, "w") as f:
    f.write(dst)

os.remove(SOURCE_PATH)
os.remove(EXEC_PATH)

