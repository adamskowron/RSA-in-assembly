
# Wywołanie TARa do wygenerowania archiwumz z lokalizacji źródłowej w RDI 
#
# C: void GenerateArhive(char* szSource)
# MODYFIKUJE REJESTRY: RSI, RAX, RDI, RSI  
# Zwraca w RAX lokalizacje nowego archiwum, w RDI kod błędu
.globl GenerateTAR 
.type GenerateTAR, @function
GenerateTAR: 
	push %rbp 
	mov %rsp, %rbp 
	sub $64, %rsp 	

	# GENERACJA GLOBALNEGO CIĄGU ZNAKÓW
	# =================
	mov %rdi, -16(%rbp)
	call strlen 		# Długość pierwotnego ciągu
	
	add $512, %rax
	mov %rax, %rdi 		# Dodanie stałej 512 w celu rozszerzenia

	call malloc 		# Alokowanie pamięci 512 + dłg. pierw.
	movq %rax, -24(%rbp) 	# Zachowaniei adresu nowego fragmentu pamięci
	 	
	mov %rax, %rdi   
	mov $TAR_PROTOTYPE, %rsi 
	call strcpy		# Skopiowanie pierwowzoru wywołania TARa do 
				# nowego miejsca w pamięci
	
	# tar -czvf 

	# MODYFIKACJA UZYSKANEGO CIĄGU
	# =================
	movq -16(%rbp), %rdi 
	call strlen 
	movq -16(%rbp), %rdi 
	add %rdi, %rax 	

	movb $'/', (%rax)
	movb $'a', 1(%rax) 
	movb $'.', 2(%rax)
	movb $'t', 3(%rax)
	movb $'g', 4(%rax)
	movb $'z', 5(%rax)
	movb $' ', 6(%rax)
	movb $0, 7(%rax) 	

	movq -16(%rbp), %rsi  
	movq -24(%rbp), %rdi 
	call strcat 		# Dołączanie /a.tgz tak aby powstał nowy
				# plik w podanej ścieżce
	 
	movq -16(%rbp), %rdi 
	call strlen
	sub $7, %rax  
	movq -16(%rbp), %rdi 
	add %rdi, %rax 	

	movb $0, (%rax)
	movb $0, 1(%rax) 
	movb $0, 2(%rax)
	movb $0, 3(%rax)
	movb $0, 4(%rax)
	movb $0, 5(%rax)
	movb $0, 6(%rax) 	
 
	movq -16(%rbp), %rsi  
	movq -24(%rbp), %rdi 
	call strcat 		# Podawanie (naprawionego) poprzedniego
				# ciągu znaków w celu przekazania folderu do
				# zarchiwizowania

	mov %rax, %rdi 
	call system		# Wywołanie TARa 
	  
	movq %rax, -32(%rbp)

	 
	movq -16(%rbp), %rax  	# w RAX adres na podaną lokalizacje
	movq -32(%rbp), %rdi  	# w RDI kod błędu TARa 

	
	mov %rbp, %rsp 
	pop %rbp 
	ret 	



# Nakładka na funkcję GenerateTAR; pobiera adres, który ma zostać
# zarchiwizowany
# 
# C: void LaunchTAR()
# MODYFIKUJE REJESTRY: RSI, RAX, RDI, RSI  
# Zwraca w RAX lokalizacje adresu ciągu na stosie, w RDI kod błędu
.globl LaunchTAR 
.type LaunchTAR, @function 
LaunchTAR:	
	push %rbp
	mov %rsp, %rbp 
	sub $512, %rsp

	mov $STR_TAR_TYPEIN, %rdi
	xor %rax, %rax 
	call printf 

	# POBRANIE ADRESU DOCELOWEGO
	# ============================

	movb $0, -1(%rbp)
	movb $'s', -2(%rbp)
	movb $'%', -3(%rbp) 
	lea -3(%rbp), %rdi 
	lea -256(%rbp), %rsi 
	call scanf 

	# GENERACJA ARCHIWUM
	# ============================		 	
	lea -256(%rbp), %rdi 
	call GenerateTAR
	movq %rdi, -264(%rbp)
	cmp $0, %rdi 
	je LaunchTAR_succed 
	jne LaunchTAR_check 

LaunchTAR_succed:
	lea -256(%rbp), %rdi 
	call strlen 

	lea -256(%rbp), %rdi 
	add %rdi, %rax   
	movb $'/', (%rax)
	movb $'a', 1(%rax) 
	movb $'.', 2(%rax)
	movb $'t', 3(%rax)
	movb $'g', 4(%rax)
	movb $'z', 5(%rax)
	movb $0, 6(%rax) 	# Dołączenie /a.tgz w celu wskazywania na nowo powstałe
				# archiwum 

	lea -256(%rbp), %rax 
LaunchTAR_out:

	movq -264(%rbp), %rdi
	mov %rbp, %rsp 
	pop %rbp 
	ret 

LaunchTAR_check: 		# Sprawdzenie kodu błędu TARa 
	cmp $256, %rdi		# Jeśli == 256 lub == 0, wszystko przeszło
	je LaunchTAR_succed 	# sprawnie
	mov $STR_TAR_ERROR, %rdi 
	call printf 
 	jmp LaunchTAR_out 
