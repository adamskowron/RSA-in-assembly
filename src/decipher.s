
# w rdi ptr, rsi e, rdx n
.globl RsaEnc
.type RsaEnc, @function
RsaEnc: 
        push %rbp 
        mov %rsp, %rbp 
	subq $512,%rsp

	movq %rdi,-8(%rbp)
        movq %rsi,-16(%rbp)
        movq %rdx,-24(%rbp)

	movb $'r',-27(%rbp)
	movb $'b',-26(%rbp)
	movb $0,-25(%rbp)

	
	movq -8(%rbp),%rdi
	lea -27(%rbp),%rsi
	call fopen
	cmp $0, %rax 
	jne RsaEnc_cont 
	mov $STR_DEC_ERROR, %rdi 
	call printf
	jmp RsaEnc_out 
	

RsaEnc_cont:
	movq %rax, -296(%rbp)

	movb $'w',-35(%rbp)
	movb $'b',-34(%rbp)
	movb $0,-33(%rbp)


	movq -8(%rbp), %rsi 
	lea -288(%rbp),%rdi
	call strcpy

	movq %rax,%rdi
	call strlen
	lea -288(%rbp),%rdi
	addq %rax,%rdi

	movb $'E',(%rdi)
	movb $'N',1(%rdi)
	movb $'C',2(%rdi)
	movb $0,3(%rdi)

	lea -288(%rbp),%rdi
	lea -35(%rbp),%rsi
	call fopen
	movq %rax, -304(%rbp)
	
RsaEnc_read:
	lea -8(%rbp),%rdi
	movq $1,%rsi
	movq $4,%rdx
	movq -296(%rbp),%rcx
	call fread
	cmp $0, %rax 
	je RsaEnc_out
	
	xor %rdi, %rdi 
	movl -8(%rbp),%edi	#liczba t, kolejne 4 bajty pliku
	movq -16(%rbp),%rdx
	xorq %rsi,%rsi
	xorq %rcx,%rcx
	movq -24(%rbp),%r8
	call powModulo

	movq %rax,-32(%rbp)
	lea -32(%rbp),%rdi
	movq $8,%rsi
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

#
# uint64_t getFileSize(FILE* f)
#
.type getFileSize, @function
.globl getFileSize 
getFileSize: 
	push %rbp 
	mov %rsp, %rbp 
	sub $64, %rsp

	movq %rdi, -8(%rbp)

	xor %rsi, %rsi 
	movq $2, %rdx  
	call fseek
	
	xor %rax, %rax 
	movq -8(%rbp), %rdi 
	call ftell

	movq %rax, -16(%rbp)

	movq -8(%rbp), %rdi 
	xor %rdx, %rdx
	xor %rsi, %rsi 
	call fseek

	movq -16(%rbp), %rax 
	mov %rbp, %rsp 
	pop %rbp 
	ret 

# 
# C: bool deCipher(char* ptrSrc, uint128_t key_coPrime, uint128_t n);
# 
# 

.type deCipher, @function 
.globl deCipher
deCipher:
	push %rbp 
	mov %rsp, %rbp 
	sub $1024, %rsp 
	movq %rdi, -8(%rbp)

	movq %rsi, -16(%rbp) 
	movq %rdx, -24(%rbp)

	movq %rcx, -32(%rbp) 
	movq %r8, -40(%rbp)
	
	mov %rdi, %rsi 
	lea -296(%rbp), %rdi 
	call strcpy  
	mov %rax, %rdi 
	call strlen 
	lea -296(%rbp), %rdi
	add %rax, %rdi 
	movb $'O', (%rdi)
	movb $'U', 1(%rdi)
	movb $'T', 2(%rdi)
	movb $0, 3(%rdi)
		

	# Otwarcie pliku źrodłowego
	# =================
	movq -8(%rbp), %rdi 
	movb $'r', -43(%rbp)
	movb $'b', -42(%rbp)
	movb $0, -41(%rbp)
	xor %rax, %rax 
	lea -43(%rbp), %rsi 
	call fopen 
	cmp $0, %rax 
	jne deCipher_contpre 

	mov $STR_DEC_ERROR, %rdi 
	call printf 

	jmp deCipher_out 


deCipher_contpre: 
	# ================
	movq %rax, -304(%rbp)
		
	mov %rax, %rdi 
	call getFileSize 
	# =================
	movq %rax, -312(%rbp)


	# Otwarcie pliku docelowego
	# =================

	movb $'w', -43(%rbp)
	movb $'b', -42(%rbp)
	xor %rax, %rax
	lea -296(%rbp), %rdi
	lea -43(%rbp), %rsi 
	call fopen 
	# ================
	movq %rax, -320(%rbp)
	
	mov %rax, %rdi 
	call getFileSize 
	# =================
	movq %rax, -328(%rbp) 

deCipher_read:
	movq -304(%rbp), %rcx 
	lea -336(%rbp), %rdi 
	movq $8, %rsi 
	movq $1, %rdx 
	call fread
	cmp $0, %rax 
	je deCipher_out	
		
	movq -336(%rbp), %rdi
	movq -16(%rbp), %rsi 
	movq -24(%rbp), %rdx 
	movq -32(%rbp), %rcx 
	movq -40(%rbp), %r8
	call powModulo 
	
	movl %eax, -340(%rbp)
	lea -340(%rbp), %rdi 
	movq -320(%rbp), %rcx 
	movq $4, %rsi
	movq $1, %rdx 
	call fwrite

	jmp deCipher_read 

deCipher_out:
	movq -304(%rbp), %rdi 
	call fclose

	movq -320(%rbp), %rdi 
	call fclose
	mov %rbp, %rsp 
	pop %rbp 
	ret 

 
