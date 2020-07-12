# Potegowe dzielenie A modulo B
# C: uint64_t powModulo(uint64_t a, uint128_t b, uint128_t n)
# a^b mod n
# RDI a, RSI RDX b, RCX R8 n
# MODYFIKUJE  W S Z Y S T K I E  REJESTRY 
.globl powModulo
.type powModulo, @function 
powModulo:
	push %rbp 
	mov %rsp, %rbp 
	sub $256, %rsp 
				# Kopia zapasowa rejestrow (pusha)
	movq %rbx, -168(%rbp)
	movq %rcx, -176(%rbp)
	movq %r9,  -192(%rbp)
	movq %r10, -200(%rbp)
	movq %r11, -208(%rbp)
	movq %r12, -216(%rbp)
	movq %r13, -224(%rbp)
	movq %r14, -232(%rbp) 
	movq %r15, -240(%rbp)
	
	# Wywołaj div MODULO
	# Zachowywanie wartosci w rejestrach na stosie
	# ====================
	movq $0, -8(%rbp)	# dołączanie 0 z przodu, czyli
	movq %rdi, -16(%rbp)	# kownersja RDI (a) na uint128
	movq %rcx, -24(%rbp) 	
	movq %r8, -32(%rbp) 	
	movq %rsi, -40(%rbp) 	
	movq %rdx, -48(%rbp)	
	#====================
	
	lea -16(%rbp), %rdi  # Wywoływanie	
	lea -32(%rbp), %rsi  # a mod n 	
	call _DIVModulo 
	movq %rdx, -56(%rbp) 	# Zachowywanie  wyniku a mod n
	movq %rax, -64(%rbp)	# w nowym miejscu na stosie jako uint128

	# WYNIK: H:RDX - L:RAX 
	# =====================
	# Przywróć 
	movq -16(%rbp), %rdi 	
	movq -24(%rbp), %rcx 
	movq -32(%rbp), %r8 
	movq -40(%rbp), %rsi
	movq -48(%rbp), %rdx 
	# =====================

	mov %rsi, %rdi 
	call RetLength 
	cmp $0, %rax 
	jne  powModulo_setMax 
	je powModulo_setNoMax 
powModulo_setMax: 
	
	mov $63, %r15		# Jest to liczba 128 bitowa wiec bedziemy sprawdzac
	movq -16(%rbp), %rdi 	# pierwsza partie 64 bitow
	jmp powModulo_Cont 	# 
powModulo_setNoMax:
	mov %rdx, %rdi 
	call RetLength 		# Jest to liczba nie128bitowa wiec badamy jaka ma
	mov %rax, %r15 		# dlugosc
	movq -16(%rbp), %rdi 	
powModulo_Cont:
	# =====================
	mov $1, %rax 
	# result = 1 (rax) 
	# a = H: r9 L:r10 
	# x = H: r11 L:r12 

	movq -56(%rbp), %r9 	

	movq -64(%rbp), %r10  	# a = a mod n
				# wczytanie a ze stosu
	movq $1, -72(%rbp) 
	movq %r10, %r12 	# kopiowanie a = x
	movq %r9, %r11 		# x = a mod n

	xor %r14, %r14 
	movq %r14, -88(%rbp)	# ustawienie flagi na 0 wraz z alokacja na stosie 
	movq $0, -80(%rbp)	
	mov $1, %r13 		# 1 sluzaca do testowania poszczegolnych bitow
powModulo_loop: 
	mov -88(%rbp), %r14 	# sprawdzenie flagi czy pierwsze 64 bitow zostalo sprawdzone
	cmp $0, %r14  
	je  powModulo_first
	jne powModulo_sec
	
powModulo_sec:
	cmp $-1, %r15		# sprawdzenie czy dana partia 64 bitow zostala sprawdzona
	je powModulo_ex 
	
	mov %r13, %r14 
	andq %rsi, %r14  
	cmp $0, %r14 		
	jne powModulo_notZero 
	je powModulo_Zero 
powModulo_first:
	cmp $-1, %r15
	je powModule_turnsec 
 
	mov %r13, %r14 
	andq %rdx, %r14 
	cmp $0, %r14 
	jne powModulo_notZero 
	je powModulo_Zero 

powModule_turnsec:		# przelaczenie na druga partie 64 bitwo B
	
	movq %rax, -96(%rbp) 
	
	mov %rsi, %rdi 
	call RetLength
	dec %rax  
	mov %rax, %r15 
 	movq -16(%rbp), %rdi 	
	mov $1, %r13		
	mov -88(%rbp), %r14 
	inc %r14 
	movq %r14, -88(%rbp)
	
	jmp powModulo_loop 

powModulo_ex:			
	movq -168(%rbp), %rbx 
	movq -176(%rbp), %rcx 
	movq -192(%rbp), %r9 
	movq -200(%rbp), %r10 
	movq -208(%rbp), %r11 
	movq -216(%rbp), %r12 
	movq -224(%rbp), %r13 
	movq -232(%rbp) , %r14 
	movq -240(%rbp), %r15
	mov -72(%rbp), %rax
	mov -80(%rbp), %rdx  
	mov %rbp, %rsp 
	pop %rbp 
	ret 
powModulo_notZero:
	movq %rdx, -48(%rbp)
	movq %rdi, -16(%rbp)
	movq %rsi, -40(%rbp)

	movq -72(%rbp), %rdi  
	movq -80(%rbp), %rsi 

	mov %r11, %rcx
	mov %r12, %rdx 
	# result = result * x
	# result = result mod 
	
	imulq	%rdx, %rsi 	# mnozenie x * result 128bit 
	movq	%rdi, %rax
	imulq	%rdi, %rcx
	mulq	%rdx
	addq	%rsi, %rcx
	addq	%rcx, %rdx
	 
	# 0 rax mod (n)rcx r8  
	movq %rdx, -56(%rbp)
	movq %rax, -64(%rbp) 
	lea -64(%rbp), %rdi
	lea -32(%rbp), %rsi 
	call _DIVModulo 
	mov %rax, -72(%rbp)
	mov %rdx, -80(%rbp)
	movq -48(%rbp), %rdx 
	movq -16(%rbp), %rdi 
	movq -40(%rbp), %rsi 

powModulo_Zero: 
	#x = x *x 
	# x =  x mod n	
	mov %rdi, -16(%rbp)
	mov %rdx, -48(%rbp)
	mov %rsi, -40(%rbp) 
	mov  %r12 , %rdi
	mov  %r11, %rsi 
	call pow2
	mov %rdx, %r11  
	mov %rax, %r12
	movq %r11, -56(%rbp)
	movq %r12, -64(%rbp) 
	lea -64(%rbp), %rdi
	lea -32(%rbp), %rsi 
	call _DIVModulo
	mov %rax, %r12 
	mov %rdx, %r11  
	mov -16(%rbp), %rdi 
	mov -48(%rbp), %rdx 
	mov -40(%rbp), %rsi 
	shl %r13 
	dec %r15
	jmp powModulo_loop 

pow2:
	# xxxxx
  	movq %rdi, %rax
  	imulq %rdi, %rsi
  	mulq %rdi
  	addq %rsi, %rsi
  	addq %rsi, %rdx
   	# xxxxxxx
	ret	

# Wyprowadz wynik A modulo B wykorzystujac DIV 
# C: uint64_t _DIVModulo(uint128_t* a, uint128_t* b)
#
# Modyfikuje rejestry: RAX, RDX, RDI, RSI   
.globl _DIVModulo 
.type _DIVModulo, @function 
_DIVModulo:  
	push %rbp 
	mov %rsp, %rbp 
	mov %rdi, %rax   
	mov %rsi, %rbx 

	movq (%rax), %rdi 
	movq 8(%rax), %rsi  
		
	movq (%rbx), %rdx 
	movq 8(%rbx), %rcx 	
	
	call __umodti3@PLT 


	mov %rbp, %rsp 
	pop %rbp 
	ret 

# Zwraca dlugosc A w bitach.
# C: uint64_t RetLength(uint64_t a)
# Modyfikowane rejestry: ŻADNE
.type RetLength, @function
RetLength: 
	push %rbp 
	mov %rsp, %rbp 
	sub $8, %rsp 
	xor %rax, %rax 
	movq %rdi ,-8(%rbp)	
	cmp $0, %rdi 
	je RetLength_out 	
RetLength_loop: 
	shr $1, %rdi 
	inc %rax 
	cmp $0, %rdi
	jne RetLength_loop 
RetLength_out:
	movq -8(%rbp), %rdi 
	mov %rbp, %rsp 
	pop %rbp
	ret



	


# Rozszerzony algorytm Euklidesa dla liczb a i b
# C: uint128_t[3]* FindXGCD(uint128_t a, uint128_t b)
# MODYFIKUJE REJESTRY: RSI, RAX, RDI, RSI  
# RDI, RSI a; RDX, RCX b
# Zwraca wskaźnik na liczby będące rozwiązaniem XGCD dla liczb a i b 
.globl FindXGCD
.type FindXGCD, @function
FindXGCD:
	push %rbp 
	mov %rsp, %rbp 
	sub $256, %rsp 
	movq %rdi, -8(%rbp) 
	movq %rsi, -16(%rbp) 

	movq %rdx, -24(%rbp)
	movq %rcx, -32(%rbp) 

	# aa = { 1 , 0 }
	movq $0, -40(%rbp)
	movq $1, -48(%rbp) 
	
	movq $0, -56(%rbp)
	movq $0, -64(%rbp) 
	
	#bb = { 0 , 1 }
	movq $0, -72(%rbp)
	movq $0, -80(%rbp) 
	
	movq $0, -88(%rbp)
	movq $1, -96(%rbp) 
	
	# q 
	movq $0, -104(%rbp)
	movq $2, -112(%rbp) 
	# r 
	movq $0, -120(%rbp)
	movq $0, -128(%rbp) 

	# 
	movq %r8, -136(%rbp)
	 
FindXGCD_begin:
	
	movq -8(%rbp), %rdi  
	movq -16(%rbp), %rsi  

	movq -24(%rbp), %rdx 
	movq -32(%rbp), %rcx
	 		
	call __udivti3@PLT
	movq %rax, -112(%rbp)
	movq %rdx, -104(%rbp) 
	movq -8(%rbp), %rdi 
	movq -16(%rbp), %rsi 
	
	movq -24(%rbp), %rdx 
	movq -32(%rbp), %rcx 
	call __umodti3@PLT 
	 
	movq %rdx, -16(%rbp) 
	movq %rax, -8(%rbp)
	# q = a / b 
	# a = a % b;
	movq -56(%rbp), %rdi 
	movq -64(%rbp), %rsi 

	movq -112(%rbp), %rdx 
	movq -104(%rbp), %rcx 
	# a * b 
	# rsi * rcx 
	 
	imulq	%rdx, %rsi
	movq	%rdi, %rax
	imulq	%rdi, %rcx
	mulq	%rdx
	addq	%rsi, %rcx
	addq	%rcx, %rdx
	mov %rdx, %rcx 	
	mov %rax, %rdx 

	movq -40(%rbp), %rdi   
	movq -48(%rbp), %rsi
	 	
	movq	%rdi, %r9
	movq	%rsi, %r10
	subq	%rdx, %r9
	sbbq	%rcx, %r10
	movq	%r9, %rax
	movq	%r10, %rdx

	
	movq %rax, -40(%rbp)
	movq %rdx, -48(%rbp) 	
	 
	
	# aa[0] = aa[0] - q*aa[1];


	movq -104(%rbp), %rdi  
	movq -112(%rbp), %rsi

	movq -96(%rbp), %rdx 
	movq -88(%rbp), %rcx 
	

	# rsi * rcx 
	 
	imulq	%rdx, %rsi
	movq	%rdi, %rax
	imulq	%rdi, %rcx
	mulq	%rdx
	addq	%rsi, %rcx
	addq	%rcx, %rdx 	

	mov %rdx, %rcx 	
	mov %rax, %rdx 

	movq -72(%rbp), %rdi   
	movq -80(%rbp), %rsi
	 

	# a - b
	# rsi - rcx 
	
	movq	%rdi, %r9
	movq	%rsi, %r10
	subq	%rdx, %r9
	sbbq	%rcx, %r10
	movq	%r9, %rcx
	movq	%r10, %rdx
	movq %rcx, -72(%rbp)
	movq %rdx, -80(%rbp) 


	movq -16(%rbp), %rsi 
	movq -8(%rbp), %rdi 
	call CheckZero
	
	cmp $1, %al 
	je FindXGCD_foundA

	# ==========================
	# B PART
	# TO BE FIXED ( A SWITCH B)
	# ==========================

	movq -8(%rbp), %rdx   
	movq -16(%rbp), %rcx  

	movq -24(%rbp), %rdi   
	movq -32(%rbp), %rsi
	# 	^^^ SWITCHED
	 		
	call __udivti3@PLT
	movq %rax, -112(%rbp)
	movq %rdx, -104(%rbp) 
	movq -8(%rbp), %rdx  
	movq -16(%rbp), %rcx 
	
	movq -24(%rbp), %rdi  
	movq -32(%rbp), %rsi 
	call __umodti3@PLT 
	 
	movq %rdx, -32(%rbp) 
	movq %rax, -24(%rbp)
	# q = b / a 
	# b = b % a;
	movq -40(%rbp), %rdi 
	movq -48(%rbp), %rsi 

	movq -112(%rbp), %rdx 
	movq -104(%rbp), %rcx 
	# a * b 
	# rsi * rcx 
	 
	imulq	%rdx, %rsi
	movq	%rdi, %rax
	imulq	%rdi, %rcx
	mulq	%rdx
	addq	%rsi, %rcx
	addq	%rcx, %rdx 	
	
	 
	mov %rdx, %rcx 	
	mov %rax, %rdx 

	movq -56(%rbp), %rdi   
	movq -64(%rbp), %rsi
	 	
	movq	%rdi, %r9
	movq	%rsi, %r10
	subq	%rdx, %r9
	sbbq	%rcx, %r10
	movq	%r9, %rax
	movq	%r10, %rdx
	movq %rax, -56(%rbp)
	movq %rdx, -64(%rbp) 	
	 
	
	# aa[1] = aa[1] - q*aa[0];


	movq -104(%rbp), %rdi  
	movq -112(%rbp), %rsi

	movq -80(%rbp), %rdx 
	movq -72(%rbp), %rcx 
	

	# rsi * rcx 
	 
	imulq	%rdx, %rsi
	movq	%rdi, %rax
	imulq	%rdi, %rcx
	mulq	%rdx
	addq	%rsi, %rcx
	addq	%rcx, %rdx 	

	 
	mov %rdx, %rcx 	
	mov %rax, %rdx 

	movq -88(%rbp), %rdi   
	movq -96(%rbp), %rsi
	 

	# a - b
	# rsi - rcx 
	
	movq	%rdi, %r9
	movq	%rsi, %r10
	subq	%rdx, %r9
	sbbq	%rcx, %r10
	movq	%r9, %rcx
	movq	%r10, %rdx
	
	movq %rcx, -88(%rbp)
	movq %rdx, -96(%rbp) 


	movq -32(%rbp), %rsi 
	movq -24(%rbp), %rdi 
	call CheckZero
	cmp $1, %al 
	je  FindXGCD_foundB

	jmp FindXGCD_begin
FindXGCD_out:
	mov %rbp, %rsp 
	pop %rbp 
	ret 

FindXGCD_foundA:
	
	mov -136(%rbp), %r8


	movq -24(%rbp), %rdx  
	movq -32(%rbp), %rcx 	
	movq %rcx, (%r8)
	movq %rdx, 8(%r8)

	movq -64(%rbp), %rax 
	movq -58(%rbp), %rbx 
	movq %rax, 16(%r8)
	movq %rbx, 24(%r8) 
	
	movq -96(%rbp), %rax 
	movq -88(%rbp), %rbx 
	movq %rax, 32(%r8)
	movq %rbx, 40(%r8) 
	jmp FindXGCD_out 
	
FindXGCD_foundB:
	
	mov -136(%rbp), %r8

	movq -8(%rbp), %rdx  
	movq -16(%rbp), %rcx 	
	movq %rcx, (%r8)
	movq %rdx, 8(%r8)

	movq -48(%rbp), %rax 
	movq -40(%rbp), %rbx 
	movq %rax, 16(%r8)
	movq %rbx, 24(%r8) 
	
	movq -80(%rbp), %rax 
	movq -72(%rbp), %rbx 
	movq %rax, 32(%r8)
	movq %rbx, 40(%r8) 
	jmp FindXGCD_out 
	
