#!/usr/bin/bash

function compile 
{
    time $1 $2
    mv build.asm $3
    fasm $3 $4
    chmod +x $4
}

# stage 0, bootstrap compiler
compile "./bootstrap.py" "src/main.yap" "stage_zero.asm" "stage_zero"

# stage 1, compile compiler with itself
compile "./stage_zero" "src/main.yap" "stage_one.asm" "stage_one"

# stage 2, compile-compile compiler with itself
compile "./stage_one" "src/main.yap" "stage_two.asm" "stage_two"

# now stage_one and stage_two should be identical
if diff stage_one stage_two; then
    echo "compiler valid!"
else
    echo "compiler invalid!"
fi

rm stage_zero*
rm stage_one*
rm stage_two*


