# Funkcja Eulera dla liczb pierwszych
# C: uint128_t GenEuler(uint128_t* a, uint128_t* b)
# a i b musza wskazywac na d o l n e  czesci
# fi(n * p) = (n-1)(p-1)
# Wynik: RAX : RDX
# 	L	H
# MODYFIKUJE REJESTRY:

.type GenEuler, @function 
.globl GenEuler
GenEuler:
	push %rbp 
	mov %rsp, %rbp
	sub $32, %rsp 
	mov %rsi ,-8(%rbp)
	mov %rdi, -16(%rbp) 

	movq (%rsi), %rdi   
	
	movq 8(%rsi), %rsi 


	subq 	$1, %rdi  
	sbbq	$0, %rsi  

	movq -16(%rbp), %rbx 

	movq 8(%rbx), %rcx 
	movq (%rbx), %rdx
 
	subq 	$1, %rcx   
	sbbq	$0, %rdx   


	imulq	%rdx, %rsi
	movq	%rdi, %rax
	imulq	%rdi, %rcx
	mulq	%rdx
	addq	%rsi, %rcx
	addq	%rcx, %rdx 
	mov %rbp, %rsp 
	pop %rbp 
	ret 


# Znajdz wzglednie pierwsza liczbe z A 
# Opuszczajac b wyników
# C: uint128_t FindNrst(uint128_t* a, uint128_t b)
# 
.globl FindNrst
.type FindNrst, @function 
FindNrst: 
	push %rbp 
	mov %rsp, %rbp 

	
	mov %rbp, %rsp 
	pop %rbp 
	ret 
