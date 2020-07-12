#nie przyjmuje zadnych argumentow, zwraca w rax losowa 32 bitowa lizcbe pierwsza wieksza niz 65535

.type GenRndPrime, @function 
.globl GenRndPrime
GenRndPrime:
	push %rbp
	mov %rsp, %rbp
	subq $64,%rsp

	# time(NULL);
	xor %rax, %rax  # zerowanie rax 
	call rand	# wywolanie rand();
	cmpq $0xffff,%rax
	jl add
	movq %rax, %rbx 
	#liczba losowa w eax
	andq $1,%rbx
	cmpq $0,%rbx
	jne skip

	incq %rax

	skip:

	movq %rax,-12(%rbp)

	checkprime:
	lea -12(%rbp),%rdi
	call CheckPrime
	cmpq $1,%rax
	jne sub

	movq -12(%rbp),%rax
	

	mov %rbp,%rsp
	pop %rbp
	ret

	sub:
	movq -12(%rbp),%rax
        subq $2,%rax
        movq %rax,-12(%rbp)
	jmp checkprime

	add:
	addq $0xffff,%rax
	jmp skip
