#!/usr/bin/bash

# stage 0, bootstrap compiler
./bootstrap.py src/main.yap
fasm build.asm stage_zero
rm build.asm
chmod +x stage_zero

# stage 1, compile compiler with itself
./stage_zero src/main.yap stage_one

# stage 2, compile-compile compiler with itself
./stage_one src/main.yap stage_two


# now stage_one and stage_two should be identical
echo "----------------------"
echo ""
if diff stage_one stage_two; then
    echo "compiler valid!"
else
    echo "compiler invalid! (BAD BAD BAD)"
fi
echo ""

rm stage_zero*
rm stage_one*
rm stage_two*


