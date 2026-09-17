.PHONY: stage0 stage1 bindings

stage1: stage0
	./compiler src/main.yap
	fasm build.asm compiler
	chmod +x compiler

stage0: bindings src/** lib/*
	./bootstrap.py src/main.yap
	fasm build.asm compiler
	chmod +x compiler


bindings:
	./tools/binding/gen.py


