.PHONY: stage0 stage1 bindings

stage1: stage0 src/** lib/*
	./compiler src/main.yap yascl
	rm compiler

stage0: bindings src/** lib/*
	./bootstrap.py src/main.yap
	fasm build.asm compiler
	chmod +x compiler

bindings:
	./tools/binding/gen.py
