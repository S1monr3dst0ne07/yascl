

do:
	./compiler prg/mandel-color.yap
	fasm build.asm build
	chmod +x build
	./build




