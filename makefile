


.PHONY: bootstrap run build

run: build
	./build

build: bootstrap
	fasm build.asm
	chmod +x build

bootstrap: 
	./bootstrap.py prg/hello.yap
