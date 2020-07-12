
# Generacja liczby względnie pierwszej do podanej w RDI RSI, lecz też mniejszej
# od podanej w RDX RCX
#
# C: uint128_t FindCoPrime(uint128_t a, uint128_t b)
# MODYFIKUJE REJESTRY: RSI, RAX, RDI, RSI  
# Zwraca w RDX RAX takie c że NWD(c,a) == 1 oraz c < b

.type FindCoPrime, @function 
.globl FindCoPrime

FindCoPrime:
	push %rbp 
	mov %rsp, %rbp 
	sub $64, %rsp 

	movq $0, -8(%rbp)
	movq $1, -16(%rbp)

	movq %rdi, -24(%rbp)
	movq %rsi, -32(%rbp) # phi 

	movq %rdx, -40(%rbp)
	movq %rcx, -48(%rbp) # n 
	xor %rbx, %rbx 
FindCoPrime_beg:
	
	movq -8(%rbp), %rdi 
	movq -16(%rbp), %rsi 
	addq 	$2, %rsi 
	adcq	$0, %rdi 
	movq %rdi, -8(%rbp) 
	movq %rsi, -16(%rbp)
	movq -24(%rbp), %rdx
	movq -32(%rbp), %rcx 	
	call EuclidesNWD  
	cmp $1, %rax 
	jne FindCoPrime_beg 
	movq -8(%rbp), %rdx   
	movq -16(%rbp), %rcx    
	movq -40(%rbp), %rdi    
	movq -48(%rbp), %rsi 
	cmpq	%rdi, %rdx
	sbbq	%rsi, %rcx
	setl	%al
	cmp $1, %al
	jne FindCoPrime_beg 
	movq -8(%rbp), %rdx   
	movq -16(%rbp), %rax   
	mov %rbp, %rsp 
	pop %rbp  
	ret 



# Generacja liczby odwrotnie modulo do podanej w RDX RCX * x mod RDI RSI 
#
# C: uint128_t FindINV(uint128_t a, uint128_t b)
# MODYFIKUJE REJESTRY: RSI, RAX, RDI, RSI, R8  
# Zwraca w RDX RAX takie x ze b * x mod a == 1 

.globl FindINV
.type FindINV, @function
FindINV:
	push %rbp 
	mov %rsp, %rbp
	sub $128, %rsp 

	movq %rdi, -8(%rbp)
	movq %rsi, -16(%rbp) 
	movq %rdx, -24(%rbp)
	movq %rcx, -32(%rbp)

	movq -8(%rbp), %rdi 
	movq -16(%rbp), %rsi 
	movq -24(%rbp), %rdx 
	movq -32(%rbp), %rcx 
	lea -80(%rbp), %r8 
	call FindXGCD 	
		
	movq 32(%r8), %rax 
	movq 40(%r8), %rdx 

	movq -8(%rbp), %rdi 
	movq -16(%rbp), %rsi 
	dec %rdx 	
		 
	addq %rsi, %rax 
	adcq %rdi, %rdx 

	mov %rbp, %rsp 
	pop %rbp 
	ret 

