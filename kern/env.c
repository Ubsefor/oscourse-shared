/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <inc/mmu.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>
#include <inc/elf.h>

#include <kern/env.h>
#include <kern/trap.h>
#include <kern/monitor.h>
#include <kern/sched.h>
#include <kern/cpu.h>
#include <kern/kdebug.h>

struct Env env_array[NENV];
struct Env *curenv = NULL;
struct Env *envs   = env_array;   // All environments
static struct Env *env_free_list; // Free environment list
                                  // (linked by Env->env_link)

#define ENVGENSHIFT 12 // >= LOGNENV

extern unsigned int bootstacktop;

// Global descriptor table.
//
// Set up global descriptor table (GDT) with separate segments for
// kernel mode and user mode.  Segments serve many purposes on the x86.
// We don't use any of their memory-mapping capabilities, but we need
// them to switch privilege levels.
//
// The kernel and user segments are identical except for the DPL.
// To load the SS register, the CPL must equal the DPL.  Thus,
// we must duplicate the segments for the user and the kernel.
//
// In particular, the last argument to the SEG macro used in the
// definition of gdt specifies the Descriptor Privilege Level (DPL)
// of that descriptor: 0 for kernel and 3 for user.
//
struct Segdesc gdt[2 * NCPU + 7] =
    {
        // 0x0 - unused (always faults -- for trapping NULL far pointers)
        SEG_NULL,

        // 0x8 - kernel code segment
        [GD_KT >> 3] = SEG64(STA_X | STA_R, 0x0, 0xffffffff, 0),

        // 0x10 - kernel data segment
        [GD_KD >> 3] = SEG64(STA_W, 0x0, 0xffffffff, 0),

        // 0x18 - kernel code segment 32bit
        [GD_KT32 >> 3] = SEG(STA_X | STA_R, 0x0, 0xffffffff, 0),

        // 0x20 - kernel data segment 32bit
        [GD_KD32 >> 3] = SEG(STA_W, 0x0, 0xffffffff, 0),

        // 0x28 - user code segment
        [GD_UT >> 3] = SEG64(STA_X | STA_R, 0x0, 0xffffffff, 3),

        // 0x30 - user data segment
        [GD_UD >> 3] = SEG64(STA_W, 0x0, 0xffffffff, 3),

        // Per-CPU TSS descriptors (starting from GD_TSS0) are initialized
        // in trap_init_percpu()
        [GD_TSS0 >> 3] = SEG_NULL,

        [8] = SEG_NULL //last 8 bytes of the tss since tss is 16 bytes long
};

struct Pseudodesc gdt_pd = {
    sizeof(gdt) - 1, (unsigned long)gdt};

//
// Converts an envid to an env pointer.
// If checkperm is set, the specified environment must be either the
// current environment or an immediate child of the current environment.
//
// RETURNS
//   0 on success, -E_BAD_ENV on error.
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm) {
  struct Env *e;

  // If envid is zero, return the current environment.
  if (envid == 0) {
    *env_store = curenv;
    return 0;
  }

  // Look up the Env structure via the index part of the envid,
  // then check the env_id field in that struct Env
  // to ensure that the envid is not stale
  // (i.e., does not refer to a _previous_ environment
  // that used the same slot in the envs[] array).
  e = &envs[ENVX(envid)];
  if (e->env_status == ENV_FREE || e->env_id != envid) {
    *env_store = 0;
    return -E_BAD_ENV;
  }

  // Check that the calling environment has legitimate permission
  // to manipulate the specified environment.
  // If checkperm is set, the specified environment
  // must be either the current environment
  // or an immediate child of the current environment.
  if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
    *env_store = 0;
    return -E_BAD_ENV;
  }

  *env_store = e;
  return 0;
}

// Mark all environments in 'envs' as free, set their env_ids to 0,
// and insert them into the env_free_list.
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void) {
  // Set up envs array
  // LAB 3: Your code here.

  env_free_list = NULL; // null new arr of envs

  for (int i = NENV - 1; i >= 0; i--) { // the de-facto initialization
    envs[i].env_link = env_free_list;
    envs[i].env_id   = 0;
    env_free_list    = &envs[i];
  }
  env_init_percpu();
}

// Load GDT and segment descriptors.
void
env_init_percpu(void) {
  lgdt(&gdt_pd);
  // The kernel never uses GS or FS, so we leave those set to
  // the user data segment.
  asm volatile("movw %%ax,%%gs" ::"a"(GD_UD | 3));
  asm volatile("movw %%ax,%%fs" ::"a"(GD_UD | 3));
  // The kernel does use ES, DS, and SS.  We'll change between
  // the kernel and user data segments as needed.
  asm volatile("movw %%ax,%%es" ::"a"(GD_KD));
  asm volatile("movw %%ax,%%ds" ::"a"(GD_KD));
  asm volatile("movw %%ax,%%ss" ::"a"(GD_KD));
  // Load the kernel text segment into CS.
  asm volatile("pushq %%rbx \n \t movabs $1f,%%rax \n \t pushq %%rax \n\t lretq \n 1:\n" ::"b"(GD_KT)
               : "cc", "memory");
  // For good measure, clear the local descriptor table (LDT),
  // since we don't use it.
  asm volatile("movw $0,%%ax \n lldt %%ax\n"
               :
               :
               : "cc", "memory");
}

//
// Allocates and initializes a new environment.
// On success, the new environment is stored in *newenv_store.
//
// Returns 0 on success, < 0 on failure.  Errors include:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id) {
  int32_t generation;
  struct Env *e;

  if (!(e = env_free_list)) {
    return -E_NO_FREE_ENV;
  }

  // Generate an env_id for this environment.
  generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
  if (generation <= 0) // Don't create a negative env_id.
    generation = 1 << ENVGENSHIFT;
  e->env_id = generation | (e - envs);

  // Set the basic status variables.
  e->env_parent_id = parent_id;
#ifdef CONFIG_KSPACE
  e->env_type = ENV_TYPE_KERNEL;
#else
#endif
  e->env_status = ENV_RUNNABLE;
  e->env_runs   = 0;

  // Clear out all the saved register state,
  // to prevent the register values
  // of a prior environment inhabiting this Env structure
  // from "leaking" into our new environment.
  memset(&e->env_tf, 0, sizeof(e->env_tf));

  // Set up appropriate initial values for the segment registers.
  // GD_UD is the user data (KD - kernel data) segment selector in the GDT, and
  // GD_UT is the user text (KT - kernel text) segment selector (see inc/memlayout.h).
  // The low 2 bits of each segment register contains the
  // Requestor Privilege Level (RPL); 3 means user mode, 0 - kernel mode.  When
  // we switch privilege levels, the hardware does various
  // checks involving the RPL and the Descriptor Privilege Level
  // (DPL) stored in the descriptors themselves.
#ifdef CONFIG_KSPACE
  e->env_tf.tf_ds = GD_KD | 0;
  e->env_tf.tf_es = GD_KD | 0;
  e->env_tf.tf_ss = GD_KD | 0;
  e->env_tf.tf_cs = GD_KT | 0;

  // LAB 3: Your code here.
  // Allocate stack for new task

  static uintptr_t STACK_TOP = 0x2000000; // basic stack pointer given us by exercise
  e->env_tf.tf_rsp = STACK_TOP;
  STACK_TOP -= 2 * PGSIZE; // stack goes brr

  e->env_tf.tf_rflags = read_rflags(); // init tf with cur rflags
#else
#endif
  // You will set e->env_tf.tf_rip later.

  // commit the allocation
  env_free_list = e->env_link;
  *newenv_store = e;

  cprintf( "[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id );

  return 0;
}

#ifdef CONFIG_KSPACE
static void
bind_functions(struct Env *e, uint8_t *binary) {
  //find_function from kdebug.c should be used
  // LAB 3: Your code here.

  // new necessary vars from ELF docs
  struct Elf *elf    = (struct Elf *) binary;
  struct Secthdr *sh = (struct Secthdr *) ( binary + elf->e_shoff );
  const char *shstr  = (char *) binary + sh[elf->e_shstrndx].sh_offset;

  // find string table
  size_t strtab = -1UL;
  for ( size_t i = 0; i < elf->e_shnum; i++ ) {
    if ( sh[i].sh_type == ELF_SHT_STRTAB && !strcmp( ".strtab", shstr + sh[i].sh_name ) ) {
      strtab = i;
      break;
    }
  }
  const char *strings = (char *) binary + sh[strtab].sh_offset;

  for ( size_t i = 0; i < elf->e_shnum; i++ ) {
    if ( sh[i].sh_type == ELF_SHT_SYMTAB ) {
      struct Elf64_Sym *syms = (struct Elf64_Sym *) ( binary + sh[i].sh_offset );
      size_t nsyms = sh[i].sh_size / sizeof(*syms);

      for ( size_t j = 0; j < nsyms; j++ ) {
        if ( ELF64_ST_BIND(syms[j].st_info) == STB_GLOBAL && ELF64_ST_TYPE(syms[j].st_info) == STT_OBJECT &&
              syms[j].st_size == sizeof(void *) ) { // handle these symbols, that are ELF
          const char *name = strings + syms[j].st_name;
          uintptr_t addr = find_function( name );

          if (addr) {
            memcpy( (void *) syms[j].st_value, &addr, sizeof(void *) );
          }
        }
      }
    }
  }
}
#endif

//
// Set up the initial program binary, stack, and processor flags
// for a user process.
// This function is ONLY called during kernel initialization,
// before running the first environment.
//
// This function loads all loadable segments from the ELF binary image
// into the environment's user memory, starting at the appropriate
// virtual addresses indicated in the ELF program header.
// At the same time it clears to zero any portions of these segments
// that are marked in the program header as being mapped
// but not actually present in the ELF file - i.e., the program's bss section.
//
// All this is very similar to what our boot loader does, except the boot
// loader also needs to read the code from disk.  Take a look at
// boot/main.c to get ideas.
//
// load_icode panics if it encounters problems.
//  - How might load_icode fail?  What might be wrong with the given input?
//
static void
load_icode(struct Env *e, uint8_t *binary) {
  // Hints:
  //  Load each program segment into memory
  //  at the address specified in the ELF section header.
  //  You should only load segments with ph->p_type == ELF_PROG_LOAD.
  //  Each segment's address can be found in ph->p_va
  //  and its size in memory can be found in ph->p_memsz.
  //  The ph->p_filesz bytes from the ELF binary, starting at
  //  'binary + ph->p_offset', should be copied to address
  //  ph->p_va.  Any remaining memory bytes should be cleared to zero.
  //  (The ELF header should have ph->p_filesz <= ph->p_memsz.)
  //
  //  ELF segments are not necessarily page-aligned, but you can
  //  assume for this function that no two segments will touch
  //  the same page.
  //
  //  You must also do something with the program's entry point,
  //  to make sure that the environment starts executing there.
  //  What?  (See env_run() and env_pop_tf() below.)

  // LAB 3: Your code here.
  struct Elf *elf = ( struct Elf * )binary;
  if ( elf->e_magic != ELF_MAGIC ) { // doing some checks for wizardy
    cprintf( "ERR: JOS: Unexpected exec format!\n" );
    return;
  }

  struct Proghdr *ph = (struct Proghdr *) ( binary + elf->e_phoff ); // program header

  for (size_t i = 0; i < elf->e_phnum; i++) { // init the prog env
    if ( ph[i].p_type == ELF_PROG_LOAD ) {

      void *src = binary + ph[i].p_offset;
      void *dst = (void *) ph[i].p_va;

      size_t memsz  = ph[i].p_memsz;
      size_t filesz = MIN( ph[i].p_filesz, memsz );

      memcpy( dst, src, filesz );
      memset( dst + filesz, 0, memsz - filesz );
    }
  }

  e->env_tf.tf_rip = elf->e_entry;
  bind_functions( e, binary ); // launching actual code
}

//
// Allocates a new env with env_alloc, loads the named elf
// binary into it with load_icode, and sets its env_type.
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create( uint8_t *binary, enum EnvType type ) {
  // LAB 3: Your code here.

  struct Env *newenv;
  if ( env_alloc( &newenv, 0 ) < 0) {
    panic( "Can't allocate new environment" ); // test the allocation
  }

  newenv->env_type = type;

  load_icode( newenv, binary );
}

//
// Frees env e and all memory it uses.
//
void
env_free( struct Env *e ) {
  
  cprintf( "[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id ); 

  e->env_status = ENV_FREE; // return env to the free list
  e->env_link   = env_free_list;
  env_free_list = e;
}

//
// Frees environment e.
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) {
  // LAB 3: Your code here.
  // If e is currently running on other CPUs, we change its state to
  // ENV_DYING. A zombie environment will be freed the next time
  // it traps to the kernel.

  e->env_status = ENV_DYING; // finish him!
  if (e == curenv) {
    env_free(e); 
    sched_yield(); // fatality by freeing env
  }
}

#ifdef CONFIG_KSPACE
void
csys_exit(void) {
  env_destroy(curenv);
}

void
csys_yield(struct Trapframe *tf) {
  memcpy(&curenv->env_tf, tf, sizeof(struct Trapframe));
  sched_yield();
}
#endif

//
// Restores the register values in the Trapframe with the 'ret' instruction.
// This exits the kernel and starts executing some environment's code.
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf) {
#ifdef CONFIG_KSPACE
  static uintptr_t rip = 0;
  rip                  = tf->tf_rip;
  tf->tf_rflags &= ~FL_IF;

  asm volatile(
      "movq %c[rbx](%[tf]), %%rbx \n\t"
      "movq %c[rcx](%[tf]), %%rcx \n\t"
      "movq %c[rdx](%[tf]), %%rdx \n\t"
      "movq %c[rsi](%[tf]), %%rsi \n\t"
      "movq %c[rdi](%[tf]), %%rdi \n\t"
      "movq %c[rbp](%[tf]), %%rbp \n\t"
      "movq %c[rsp](%[tf]), %%rsp \n\t"
      "movq %c[rd8](%[tf]), %%r8 \n\t"
      "movq %c[rd9](%[tf]), %%r9 \n\t"
      "movq %c[rd10](%[tf]), %%r10 \n\t"
      "movq %c[rd11](%[tf]), %%r11 \n\t"
      "movq %c[rd12](%[tf]), %%r12 \n\t"
      "movq %c[rd13](%[tf]), %%r13 \n\t"
      "movq %c[rd14](%[tf]), %%r14 \n\t"
      "movq %c[rd15](%[tf]), %%r15 \n\t"
      "pushq %c[rip](%[tf])\n\t"
      "pushq %c[rflags](%[tf])\n\t"
      "movq %c[rax](%[tf]), %%rax\n\t"
      "popfq\n\t"
      "sti\n\t"
      "ret\n\t"
      :
      : [ tf ] "a"(tf),
        [ rip ] "i"(offsetof(struct Trapframe, tf_rip)),
        [ rax ] "i"(offsetof(struct Trapframe, tf_regs.reg_rax)),
        [ rbx ] "i"(offsetof(struct Trapframe, tf_regs.reg_rbx)),
        [ rcx ] "i"(offsetof(struct Trapframe, tf_regs.reg_rcx)),
        [ rdx ] "i"(offsetof(struct Trapframe, tf_regs.reg_rdx)),
        [ rsi ] "i"(offsetof(struct Trapframe, tf_regs.reg_rsi)),
        [ rdi ] "i"(offsetof(struct Trapframe, tf_regs.reg_rdi)),
        [ rbp ] "i"(offsetof(struct Trapframe, tf_regs.reg_rbp)),
        [ rd8 ] "i"(offsetof(struct Trapframe, tf_regs.reg_r8)),
        [ rd9 ] "i"(offsetof(struct Trapframe, tf_regs.reg_r9)),
        [ rd10 ] "i"(offsetof(struct Trapframe, tf_regs.reg_r10)),
        [ rd11 ] "i"(offsetof(struct Trapframe, tf_regs.reg_r11)),
        [ rd12 ] "i"(offsetof(struct Trapframe, tf_regs.reg_r12)),
        [ rd13 ] "i"(offsetof(struct Trapframe, tf_regs.reg_r13)),
        [ rd14 ] "i"(offsetof(struct Trapframe, tf_regs.reg_r14)),
        [ rd15 ] "i"(offsetof(struct Trapframe, tf_regs.reg_r15)),
        [ rflags ] "i"(offsetof(struct Trapframe, tf_rflags)),
        [ rsp ] "i"(offsetof(struct Trapframe, tf_rsp))
      : "cc", "memory", "ebx", "ecx", "edx", "esi", "edi");
#else
#endif
  panic("BUG"); /* mostly to placate the compiler */
}

//
// Context switch from curenv to env e.
// Note: if this is the first call to env_run, curenv is NULL.
//
// This function does not return.
//
void
env_run(struct Env *e) {
#ifdef CONFIG_KSPACE
  cprintf("envrun %s: %d\n",
          e->env_status == ENV_RUNNING ? "RUNNING" :
                                         e->env_status == ENV_RUNNABLE ? "RUNNABLE" : "(unknown)",
          ENVX(e->env_id));
#endif
  // Step 1: If this is a context switch (a new environment is running):
  //	   1. Set the current environment (if any) back to
  //	      ENV_RUNNABLE if it is ENV_RUNNING (think about
  //	      what other states it can be in),
  //	   2. Set 'curenv' to the new environment,
  //	   3. Set its status to ENV_RUNNING,
  //	   4. Update its 'env_runs' counter,
  // Step 2: Use env_pop_tf() to restore the environment's
  //	   registers and starting execution of process.

  // Hint: This function loads the new environment's state from
  //	e->env_tf.  Go back through the code you wrote above
  //	and make sure you have set the relevant parts of
  //	e->env_tf to sensible values.
  //
  // LAB 3: Your code here.

  if (curenv) {
    if ( curenv->env_status == ENV_DYING ) { // zombie?
      struct Env *old = curenv;

      env_free( curenv );
      if ( old == e ) {
        sched_yield();
      }

    } else if (curenv->env_status == ENV_RUNNING) {
      curenv->env_status = ENV_RUNNABLE;
    }
  }

  curenv             = e;   // this is normal condidions
  curenv->env_status = ENV_RUNNING;
  curenv->env_runs++;

  env_pop_tf(&curenv->env_tf);

  while(1) {}
}
