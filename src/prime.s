# Wyprowadz z podanej liczby z pSrc najblizsza, 128bitowa liczbe
# pierwsza i zachowaj ja pod pSrc 
#
# C: void MakePrime(unsigned __128bit* pSrc)
# MODYFIKUJE RERJESTRY: 

.globl CheckPrime
.type CheckPrime, @function
CheckPrime:
	 #a = 2 3 5 7 11 13 17 19 23 29 31 37 41
	push %rbp
	movq %rsp, %rbp

	# ==================================================
	#
	# POBRANIE LICZBY N
	#
	# ==================================================

	#pobranie liczby do rejestrow r8 i r9

	xorq %rcx,%rcx
	movq (%rdi,%rcx,8),%r8	#starsze bity
	#incq %rcx
	movq (%rdi,%rcx,8),%r9	#mlodsze bity
	xorq %r8,%r8

	decq %r9 #n-1


	movq %r8,%r14
	movq %r9,%r15

	movq %r9,%rdi 		#parametr b w a mod b jest staly i przekazany przez 2 rejestry
        movq %r8,%rsi
	xorq %r8,%r8		#licznik potegi dwojki,liczba s



        # ==================================================
        #
        # OBLICZENIE LICZBY S -MAKSYMALNEJ LICZZBY DZIELACEJ n-1
        #
        # ==================================================

	movq $1,%r10
	xorq %r9,%r9 #tymczasowa liczba o wartosci potegi dwojki bedzie przechowana w r9:r10

    movq %r14,%rdx
    movq %r15,%rcx
    xorq %r8,%r8

loopS:
	



	shldq $1,%r10,%r9 	#potega dwojki
	shlq %r10
	movq %r14,%rdi 		#starsze bity drugiego parametru jako liczba s
	movq %r15,%rsi		#mlodsze bity drugiego parametru
        xorq %rdx,%rdx      #starsza czesc
        movq %r10,%rcx        #mlodsza czesc


	pushq %r15
	pushq %r14
	pushq %r13
	pushq %r12
	pushq %r11
	pushq %r10
	pushq %r9
	pushq %r8
	pushq %rsi
	pushq %rdi
	pushq %rcx
	pushq %rbx
	pushq %rax

	call __umodti3@PLT	#wynik 2^s mod n-1 w rax

	popq %rax
	popq %rbx
	popq %rcx
	popq %rdi
	popq %rsi
	popq %r8
	popq %r9
	popq %r10
	popq %r11
	popq %r12
	popq %r13
	popq %r14
	popq %r15


	incq %r8		# zwiekszenie liczby s
	cmpq $0,%rdx 		#sprawdzenie czy wynik n-1 mod s to 0
	je set		#jesli liczba sie dzieli to wstaw jest to mozliwa liczba s
	continuepow:
	cmpq %r14,%r9		#porownanie starszy bitow
	jl loopS		#jesli starsze bity tymczasowej zmiennej sa mniejsze od n-1 to dalej petla 
	je check		#jesli takie same porownanie mlodszych bitow

	endpow:


	# ==================================================
        #
        # OBLICZENIE LICZBY D = n/2^s
        #
        # ==================================================

	#liczba s w rbx
      

	movq %rbx,%r10 #liczba s do r10
	xorq %rdx,%rdx
	movq %r14,%r8  
	incq %rdx
	xorq %r8,%r8	#!!!!!!!!!!!!!!!!
	movq %r15,%r9 #pobranie liczby n do r8::r9
	countingDloop:
	shrdq $1,%r8,%r9 #przesuniecie
	shrq %r8
	decq %r10
	cmpq $0,%r10
	jg countingDloop

	#liczba d w r8:r9
	#movq %rbx,%r10 #liczba s do r10


	#a = 2 3 5 7 11 13 17 19 23 29 31 37 41
	decq %rbx	#s-1 i jednoczesnie maksymalna liczba r
	xorq %r10,%r10 	#licznik liczby r
	#xorq %r11,%r11	#index tablicy A


	#pobranie liczby n do r12 i r13
        movq %r15,%r13 #mlodsze bity
        movq %r14,%r12 #starsze bity
        incq %r13 #n-1 -> n
	xorq %r12,%r12

	push $41
	push $37
	push $31
	push $29
	push $23
	push $19
	push $17
	push $13
	push $11
	push $7
	push $5
	push $3
	
	movq $2,%rdi	#pierwsza liczba a
	movq $-1,%r10
	xorq %r11,%r11

	testloop:

	#rbx = s-1
	#r10 = r
	#r11 = index A

	incq %r10   #zwiekszenie liczby r
        cmpq %rbx,%r10  #porownanie liczby r i s-1
        jg nextA

	
	continuetest:
        cmpq $0,%r10
        je skipshift

        shldq $1,%r8,%r9 #obliczenie d*2^r
        shlq %r8
        skipshift:
           #w rdi liczba A
     # C: uint64_t powModulo(uint64_t a, uint128_t b, uint128_t n)
	# a^b mod n
	# RDI a, RSI RDX b, RCX R8 n


	pushq %r15
	pushq %r14
	pushq %r13
	pushq %r12
	pushq %r11
	pushq %r10
	pushq %r9
	pushq %r8
	pushq %rsi
	pushq %rdi
	pushq %rcx
	pushq %rbx

        movq %r8,%rsi
        movq %r9,%rdx
	#w r14:r15 n-1
        movq %r12,%rcx
        movq %r13,%r8

	call powModulo


	popq %rbx
	popq %rcx
	popq %rdi
	popq %rsi
	popq %r8
	popq %r9
	popq %r10
	popq %r11
	popq %r12
	popq %r13
	popq %r14
	popq %r15

	#wynik w rdx:rax
        cmpq %rdx,%r14
        je equal #szansa na przerwanie
        jne testloop


	end:
    
	mov %rbp, %rsp 
	pop %rbp 
	ret

#----------------------------------------------
	equal:
	cmpq %rax,%r15
	je prime 
	jne testloop

	prime:
	movq $1,%rax	#liczba pierwsza funckja zwraca 1
	jmp end

	notprime:
	movq $0,%rax #liczba nie jest pierwsza, funkcja zwraca 0
	jmp end

	nextA:
	xorq %r10,%r10
	incq %r11
	cmpq $12,%r11	#liczba liczb a wynosi 12
	jge notprime
	pop %rdi	#kolejna liczba a jako 1 argument funkcji pow modulo
	jmp continuetest

	set:
	movq %r8,%rbx    # zachowanie liczby s w rbx
	jmp continuepow

	check:
	cmpq %r15,%r10
	jl loopS
	jge endpow
