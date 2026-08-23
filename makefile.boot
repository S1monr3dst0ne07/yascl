

stage1: stage0
	./compiler src/main.yap
	fasm build.asm compiler
	chmod +x compiler

stage0: src/** lib/*
	./bootstrap.py src/main.yap
	fasm build.asm compiler
	chmod +x compiler


