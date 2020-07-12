# Generowanie NWD(a, b)
# H   L      H   L 
# RDI RSI a, RDX RCX b
# C: uint128_t EuclidesNWD(uint128_t a, uint128_t b)
# REJESTRY MODYFIKOWANE RDI, RSI, RDX, RCX, RAX; WYNIK: L: RAX H: RDX 
.globl EuclidesNWD 
.type EuclidesNWD, @function
EuclidesNWD:
	push %rbp 
	mov %rsp, %rbp 
	sub $64, %rsp 
	
	movq %rdi, -8(%rbp)
	movq %rsi, -16(%rbp)

	movq %rdx, -24(%rbp) # b, 24 32
	movq %rcx, -32(%rbp) 

	movq %rdx, -40(%rbp) # pom , 40 , 48
	movq %rcx, -48(%rbp) 

	
EuclidesNWD_loop:
	
	movq -24(%rbp), %rdi  # b != 0
	movq -32(%rbp), %rsi 
	call CheckZero 
	cmp $1, %al 
	je EuclidesNWD_out 
	
	movq -32(%rbp), %rdi 
	movq -24(%rbp), %rsi 

	movq %rsi, -40(%rbp)
	movq %rdi, -48(%rbp) ; pom = b

	movq -16(%rbp), %rdi
	movq -8(%rbp), %rsi 
	
	movq -32(%rbp), %rdx  
	movq -24(%rbp), %rcx 
	 
	call __umodti3

	# RAX L RDX H
	movq %rax, -32(%rbp) # b = a % b
	movq %rdx, -24(%rbp) 
	
	movq -40(%rbp), %rdi 
	movq -48(%rbp), %rsi 
	
	movq %rdi , -8(%rbp) # a = pom 
	movq %rsi, -16(%rbp) 
	jmp EuclidesNWD_loop 

EuclidesNWD_out:
	movq -8(%rbp), %rdx 
	movq -16(%rbp), %rax 
	
	mov %rbp, %rsp 
	pop %rbp 
	ret 

# Sprawdzenie czy A jest równe 0
# NIE MA ZNACZENIA 
# RDI RSI 
# C: bool CheckZero(uint128_t a)
# MODYFIKUJE REJESTRY: AL (1 - jest zerem)
.globl CheckZero
.type CheckZero, @function
CheckZero: 
	push %rbp 
	mov %rsp, %rbp
	sub $1, %rsp 
	movb $0, -1(%rbp)

	cmp %rdi, %rsi 
	jne CheckZero_out 
	cmp $0, %rdi 
	jne CheckZero_out  
	movb $1, -1(%rbp)

CheckZero_out:
	xor %al, %al
	movb -1(%rbp), %al 
 	
	mov %rbp, %rsp 
	pop %rbp 
	ret 
