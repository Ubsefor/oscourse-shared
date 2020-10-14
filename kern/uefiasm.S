 /* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <kern/asm64.h>

/*
 * Copy "count" bytes from "src" to %rsp, using
 * "tmpindex" for a scratch counter and %rax
 */
#define COPY_STACK(src, count, tmpindex) \
	mov	$0, tmpindex	/* initial scratch counter */ ; \
copyloop: \
	mov	0(src,tmpindex,1), %rax	 /* copy one 64-bit word from source... */ ; \
	mov	%rax, 0(%rsp,tmpindex,1) /* ... to stack */ ; \
	add	$8, tmpindex		 /* increment counter */ ; \
	cmp	count, tmpindex		 /* exit it stack has been copied */ ; \
	jne copyloop

/*
	void
	pal_efi_call_in_64bit_mode_asm(uint64_t func,
	                           struct pal_efi_registers *efi_reg,
	                           void *stack_contents,
	                           size_t stack_contents_size)

	* Switch from compatibility mode to long mode, and
	* then execute the function pointer with the specified
	* register and stack contents (based at %rsp). Afterwards,
	* collect the return value, restore the original state,
	* and return.
*/
.code64

.text

.globl _efi_call_in_32bit_mode_asm
.type _efi_call_in_32bit_mode_asm, @function;
.align 2
_efi_call_in_32bit_mode_asm:
    pushq %rbp
    movq %rsp, %rbp
    /* save non-volatile registers */
	push	%rbx
	push	%r12
	push	%r13
	push	%r14
	push	%r15

	/* save parameters that we will need later */
	push	%rsi
	push	%rcx

	push	%rbp	/* save %rbp and align to 16-byte boundary */
				/* efi_reg in %rsi */
				/* stack_contents into %rdx */
				/* s_c_s into %rcx */
	sub	%rcx, %rsp	/* make room for stack contents */

	COPY_STACK(%rdx, %rcx, %r8)

	/*
	 * Here in long-mode, with high kernel addresses,
	 * but with the kernel double-mapped in the bottom 4GB.
	 * We now switch to compat mode and call into EFI.
	 */
	ENTER_COMPAT_MODE()

	call	*%edi			/* call EFI runtime */

	ENTER_64BIT_MODE()

	mov	-48(%rbp), %rsi		/* load efi_reg into %esi */
	mov	%rax, 32(%rsi)		/* save RAX back */

	mov	-56(%rbp), %rcx	/* load s_c_s into %rcx */
	add	%rcx, %rsp	/* discard stack contents */
	pop	%rbp		/* restore full 64-bit frame pointer */
				/* which the 32-bit EFI will have truncated */
				/* our full %rsp will be restored by EMARF */
	pop	%rcx
	pop	%rsi
	pop	%r15
	pop	%r14
	pop	%r13
	pop	%r12
	pop	%rbx

	leave
	ret
