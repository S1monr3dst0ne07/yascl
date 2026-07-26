
TARGET=prg/test.yap

.PHONY: build run compiler


build: compiler
	./compiler $(TARGET)
	fasm subbuild.asm build
	chmod +x build

compiler: src/** lib/*
	./bootstrap.py src/main.yap
	fasm build.asm compiler
	chmod +x compiler
	@echo "\n\n\n"


