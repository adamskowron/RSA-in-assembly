# w rdi ptr, rsi e, rdx n
.globl RsaEnc
.type RsaEnc, @RsaEnc
RsaEnc: 
        push %rbp 
        mov %rsp, %rbp 
	subq $512,%rsp

	movq %rdi,-8(%rbp)
        movq %rsi,-16(%rbp)
        movq %rdx,-24(%rbp)

	movb $'r',-25(%rbp)
	movb $'b',-26(%rbp)
	movb $0,-27(%rbp)

	lea -8(%rbp),%rdi
	lea -25(%rbp),%rsi
	call fopen
	movq %rax, -296(%rbp)

	movb $'w',-33(%rbp)
	movb $'b',-34(%rbp)
	movb $0,-35(%rbp)


	movq -8(%rbp), %rdi
	lea -288(%rbp),%rsi
	call strcpy

	lea -288(%rbp),%rdi
	movq %rax,%rdi
	call strlen
	lea -288(%rbp),%rdi
	addq %rax,%rdi

	movb $'E',(%rdi)
	movb $'N',1(%rdi)
	movb $'C',2(%rdi)
	movb $0,3(%rdi)

	lea -288(%rbp),%rdi
	lea -33(%rbp),%rsi
	call fopen
	movq %rax, -304(%rbp)

RsaEnc_read:
	lea -8(%rbp),%rdi
	movq $4,%rsi
	movq $1,%rdx
	movq -296(%rbp),%rcx
	call fread
	cmp $0, %rax 
	je RsaEnc_out
	
	movq -8(%rbp),%rdi	#liczba t, kolejne 4 bajty pliku
	movq -16(%rbp),%rdx
	xorq %rsi,%rsi
	xorq %rcx,%rcx
	movq -24(%rbp),%r8
	call powModulo
	

	movq %rax,-32(%rbp)
	lea -32(%rbp),%rdi
	movq $4,%rsi
	movq $1,%rdx
	movq -304(%rbp), %rcx 

	call fwrite
	jmp RsaEnc_read 

	# a^b mod n
	# RDI a, RSI RDX b, RCX R8 


RsaEnc_out:

	movq -296(%rbp), %rdi
	call fclose

	movq -304(%rbp), %rdi 
	call fclose 
        mov %rbp, %rsp 
        pop %rbp 
        ret 



