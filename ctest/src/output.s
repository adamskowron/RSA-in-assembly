	.file	"prime.c"
	.text
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"rb"
	.section	.text.startup,"ax",@progbits
	.p2align 4,,15
	.globl	main
	.type	main, @function
main:
.LFB24:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	leaq	.LC0(%rip), %rsi
	pushq	%rbx
	.cfi_def_cfa_offset 24
	.cfi_offset 3, -24
	subq	$409672, %rsp
	.cfi_def_cfa_offset 409696
	movdqa	.LC1(%rip), %xmm0
	movq	%fs:40, %rax
	movq	%rax, 409656(%rsp)
	xorl	%eax, %eax
	movq	%rsp, %rdi
	movl	$28777, %eax
	movb	$0, 34(%rsp)
	movaps	%xmm0, (%rsp)
	movdqa	.LC2(%rip), %xmm0
	leaq	48(%rsp), %rbx
	movw	%ax, 32(%rsp)
	movaps	%xmm0, 16(%rsp)
	call	fopen@PLT
	movq	%rax, %rbp
	.p2align 4,,10
	.p2align 3
.L2:
	movq	%rbp, %rcx
	movl	$1, %edx
	movl	$8, %esi
	movq	%rbx, %rdi
	call	fread@PLT
	testq	%rax, %rax
	je	.L2
	xorl	%eax, %eax
	movq	409656(%rsp), %rdx
	xorq	%fs:40, %rdx
	jne	.L8
	addq	$409672, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 24
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	ret
.L8:
	.cfi_restore_state
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE24:
	.size	main, .-main
	.section	.rodata.cst16,"aM",@progbits,16
	.align 16
.LC1:
	.quad	8027155498508707887
	.quad	8083807895292764530
	.align 16
.LC2:
	.quad	8083735292926718583
	.quad	8804092386707402610
	.ident	"GCC: (GNU) 8.1.0"
	.section	.note.GNU-stack,"",@progbits
