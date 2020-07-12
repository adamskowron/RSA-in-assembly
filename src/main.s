#Calling convention: rax , rdi , rsi, rdx 
#CDECL: RDI, RSI, RDX, RCX, R8, R9
.section .data 
.EQU SYSREAD, 0 
.EQU SYSWRITE, 1 
.EQU SYSEXIT, 60 
.EQU STDOUT, 1 
 
.EQU STDIN, 0 
 
.EQU EXIT_SUCCESS, 0
.globl STR_TAR_TYPEIN 
.globl STR_TAR_ERROR
.globl TAR_PROTOTYPE 
.globl STR_DEC_ERROR 
TAR_PROTOTYPE: .asciz "tar -czvf "
STR_DEC_END: .string "\n Zakonczono deszyfrowanie. \n"
# =================================
# TAR GENERATION
STR_TAR_SUCCESSFULL: .string "\n Pomyślnie wygenerowano archiwum. \n"
STR_TAR_ERROR: .string "\n Wystąpił błąd podczas generowania archiwum. \n"
STR_TAR_TYPEIN: .string "Proszę podać adres do spakowania, a następnie do zaszyfrowania bez znaku otwierającego kolejny folder \"\/\" . Zostanie on zapisany pod nazwa a.tgz w tym samym folderze.\n"
# =================================
# KEY GENERATION 
STR_KEY_OUTPUT: .string "\n NWD: %llu, XGCD: %llu, N: %llu \n Para liczb do szyfrowania %llu , %llu \n Para liczb do deszyfracji: %llu, %llu \n"
STR_KEY_PROCESS: .string "\nGenerowanie kluczy...\n"
STR_KEY_END: .string "\nZakończono szyfrowanie.\n"
# ==================================
STR_DEC_TYPEIN: .string "\n Podaj lokalizacje pliku do deszyfracji.\n"
STR_DEC_TYPEIN_KEY: .string "\n Podaj pare liczb służących do deszyfracji oddzielonych enterem (najpierw XGCD, pozniej N).\n"
STR_DEC_ERROR: .string "\nPodany plik nie istnieje lub nie udało się go otworzyć.\n"
STR_DEC_SCANF_FILN: .string "%256s"
STR_DEC_SCANF_NMB: .string "%llu"
# ===================================
STR_WEL_HELLO: .string "\n De \/ Szyfrowanie RSA \n Wprowadź 0 dla szyfrowania, 1 dla deszyfracji \n"
STR_WEL_SCANF: .string "%i"
# ===================================


.section .bss
	.lcomm LOC, 128
.section .text 
# Funkcja wprowadzająca w etap szyfrowania
# C: void BeginCipher(void)
# Modyfikowane rejestry: bez znaczenia (wywołanie z maina)
# 

.type BeginCipher, @function
.globl BeginCipher
BeginCipher: 
	push %rbp 
	movq %rsp, %rbp
	sub $128, %rsp 

		 
	mov $STR_KEY_PROCESS, %rdi 
	xor %rax, %rax 
	call printf 

	# GENERACJA KLUCZY
	# =====================
	xor %rdi, %rdi 
	call time 

	mov %rax, %rdi 
	call srand 

	call GenRndPrime 		# Generacja pierwszej liczby pierwszej 
	
	movq $0, -8(%rbp)
	movq %rax, -16(%rbp)

	call GenRndPrime 		# Drugiej liczby pierwszej

	movq $0, -24(%rbp)
	movq %rax, -32(%rbp)
	
	lea -16(%rbp), %rdi 
	lea -32(%rbp), %rsi 
	call GenEuler 			# Na uzyskanych poprzednich liczbach
					# wylicz Funkcję Eulera

	movq %rax, -40(%rbp) 		# Phi 

	movq -16(%rbp), %rax
	movq -32(%rbp), %rbx  
	mul %rbx  	     		
	movq %rax, -64(%rbp)		# Moduł

	movq -40(%rbp), %rsi 
	movq $0, %rdi   
	movq %rax, %rcx  		
	xor %rdx, %rdx  
	
		
	call FindCoPrime     		# Znajdź takie E że NWD(E, PHI) = 1
					# oraz e < N 
	movq %rax, -56(%rbp)

	
	mov -40(%rbp), %rsi 
	xor %rdi, %rdi 
	mov %rax, %rcx 
	xor %rdx, %rdx  
	call  FindINV	     		# Znajdź takie D że zachodzi 
					# e * D mod Phi = 1
	movq %rax, -72(%rbp)
	
	# ======================
	# WYPISANIE UZYSKANYCH KLUCZY
	# ======================
	movq -64(%rbp), %r10 	
	movq  $STR_KEY_OUTPUT, %rdi 	
	movq -56(%rbp), %rsi 
	movq -72(%rbp), %rdx 
	movq -64(%rbp), %rcx

	movq -56(%rbp), %r8
	movq -64(%rbp), %r9 
	pushq %r10 
	pushq %rax 
	 
	xor %rax, %rax  
	call printf
	popq %rax
	popq %rax 
	
	# =======================
	# GENERACJA ARCHIWUM
	# =======================	
	call LaunchTAR 

	cmp $0, %rdi 			# Jeśli kod błędu =/= 0, sprawdź czy jest równy 256
	jne BeginCipher_check 
	
BeginCipher_cont:
	# =======================
	# ETAP SZYFROWANIA
	# =======================

	movq %rax, -80(%rbp) 		# zachowanie adresu nowo powstalego pliku
					# na stosie 
	movq -56(%rbp), %rsi 		# Klucz E
	movq -64(%rbp), %rdx 		# Klucz N
	movq -80(%rbp), %rdi 
	call RsaEnc 
	
BeginCipher_out:
	mov $STR_KEY_END , %rdi		
	call printf 

	mov %rbp, %rsp 
	pop %rbp 
	ret 

BeginCipher_check: 
	cmp $256, %rdi 
	je BeginCipher_cont 		# Jest równy, nic się poważnego nie stało
	jne BeginCipher_out 		# Nie jest, przerwij szyfrowanie

# Funkcja wprowadzająca w etap deSzyfrowania
# C: void BeginDeCipher(void)
# Modyfikowane rejestry: bez znaczenia (wywołanie z maina)
# 

.globl BeginDecipher
.type BeginDecipher, @function
BeginDecipher: 
	push %rbp 
	mov %rsp, %rbp 
	sub $1024, %rsp 
	
	# POBRANIE DANYCH WEJŚCIOWYCH
	# ====================
	mov $STR_DEC_TYPEIN, %rdi 
	xor %rax, %rax 
	call printf 

	mov $STR_DEC_SCANF_FILN, %rdi 
	lea -256(%rbp), %rsi 
	xor %rax, %rax  
	call scanf			# Nazwa pliku

	mov $STR_DEC_TYPEIN_KEY, %rdi 
	xor %rax, %rax 
	call printf 

	mov $STR_DEC_SCANF_NMB, %rdi 
	lea -272(%rbp), %rsi 
	call scanf 			# Klucz E (XGCD)
	
	
	mov $STR_DEC_SCANF_NMB, %rdi 
	lea -264(%rbp), %rsi 
	call scanf 			# Klucz N (iloczyn)

	# ======================
	# ROZPOCZĘCIE WŁAŚCIWEGO 
	# PROCESU DESZYFROWANIA
	# ======================
	xor %rcx, %rcx 
	xor %rsi, %rsi 
	movq -272(%rbp), %rdx 		# Załadowanie E 	  
	movq -264(%rbp), %r8 		# Załadowanie N
	lea -256(%rbp), %rdi 		# Wskaźnik na C-string na lokalizacje pliku
	call deCipher 
	
	movq $STR_DEC_END, %rdi
	xor %rax, %rax  	
	call printf 

	mov %rbp, %rsp 
	pop %rbp 
	ret  

# MAIN - W tym programie uruchomienie menu do przełączania pomiędzy
# szyfrowaniem a deszyfracją
#
# C: int main(void)
# Modyfikowane rejestry: bez znaczenia
# Zwraca: kod wykonania programu
	
.globl main 
.type main, @function 
main:
	push %rbp
	mov %rsp, %rbp 
	sub $128, %rsp
	

	mov $STR_WEL_HELLO, %rdi 
	call printf 			# Wypisanie zaproszenia
	
	# POBRANIE DOKONANEGO WYBORU
	# 0 - Szyfrowanie 1 - deSzyfrowanie
	# ==========================

main_type:
	mov $STR_WEL_SCANF, %rdi 
	lea -128(%rbp), %rsi 
	call scanf 
	xor %rax, %rax 
	movl -128(%rbp), %eax
	cmp $0, %eax 			# Jeśli wybór nie odpowiada ani 0, 1
	je main_cipher 			# ponownie powróć do wyboru
	cmp $1, %eax 
	je main_decipher 
	jne main_type  

main_cipher:
	call BeginCipher 
	jmp main_out 
main_decipher:
	call BeginDecipher 
main_out:
	mov %rbp, %rsp 
	pop %rbp 
	ret


# -18025
#1 1   
