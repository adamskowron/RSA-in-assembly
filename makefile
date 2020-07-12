
SFlags = -g -S -static
Oflags = -g -c -static 
CC = gcc

objfiles = obj/main.o obj/tar.o obj/modulo.o obj/prime.o obj/euclides.o obj/rsa.o obj/euler.o obj/GenRndPrime.o obj/decipher.o

all:	genobj 
	@printf "Linking all..\\n"
	gcc -g -static -o main $(objfiles)
	@printf "Done.\\n"
	
genobj:	
	@printf "Generating OBJ files.\\n"
	gcc $(Oflags) -o obj/main.o src/main.s
	gcc $(Oflags) -o obj/tar.o src/tar.s
	gcc $(Oflags) -o obj/modulo.o src/modulo.s
	gcc $(Oflags) -o obj/prime.o src/prime.s
	gcc $(Oflags) -o obj/euclides.o src/euclides.s
	gcc $(Oflags) -o obj/rsa.o src/rsa.s	
	gcc $(Oflags) -o obj/GenRndPrime.o src/GenRndPrime.s
	gcc $(Oflags) -o obj/decipher.o src/decipher.s
	gcc $(Oflags) -o obj/euler.o src/euler.s
	@printf "Done.\\n"
