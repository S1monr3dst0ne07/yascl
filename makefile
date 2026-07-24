
TARGET=prg/test.yap

.PHONY: build run compiler

run: compiler
	./compiler


build: compiler
	./compiler $(TARGET)
	fasm build.asm build
	chmod +x build

compiler: src/** lib/*
	./bootstrap.py src/main.yap
	fasm build.asm compiler
	chmod +x compiler


