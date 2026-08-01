

do:
	./compiler prg/test.yap
	fasm build.asm build
	chmod +x build
	./build


proxy:
	socat TCP-LISTEN:6000,fork UNIX-CONNECT:/tmp/.X11-unix/X1


