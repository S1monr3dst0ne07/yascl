
TARGET=prg/test.yap

.PHONY: build

compiler: src/* lib/*
	./bootstrap.py src/main.yap
	fasm build.asm compiler
	chmod +x compiler


build: compiler
	./compiler $(TARGET)
	fasm build.asm build
	chmod +x build




