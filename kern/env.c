/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <inc/mmu.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>
#include <inc/elf.h>

#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/monitor.h>
#include <kern/sched.h>
#include <kern/cpu.h>
#include <kern/kdebug.h>
#include <kern/macro.h>

#ifdef CONFIG_KSPACE
struct Env env_array[NENV];
struct Env *curenv = NULL;
struct Env *envs   = env_array; // All environments
#else
struct Env *envs   = NULL; // All environments
struct Env *curenv = NULL; // The current env
#endif
static struct Env *env_free_list; // Free environment list
                                  // (linked by Env->env_link)

#define ENVGENSHIFT 12 // >= LOGNENV

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

  // LAB 3 code
  env_free_list = NULL; // NULLing new env_list
  for (int i = NENV - 1; i >= 0; i--) {
    // initialization in for loop every new environment till max env met
    envs[i].env_status = ENV_FREE;
    envs[i].env_link   = env_free_list;
    envs[i].env_id     = 0;
    env_free_list      = &envs[i];
  }
  env_init_percpu();
  // LAB 3 code end
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
// Initialize the kernel virtual memory layout for environment e.
// Allocate a page directory, set e->env_pgdir accordingly,
// and initialize the kernel portion of the new environment's address space.
// Do NOT (yet) map anything into the user portion
// of the environment's virtual address space.
//
// Returns 0 on success, < 0 on error.  Errors include:
//	-E_NO_MEM if page directory or table could not be allocated.
//
static int
env_setup_vm(struct Env *e) {
  struct PageInfo *p = NULL;

  // Allocate a page for the page directory
  if (!(p = page_alloc(ALLOC_ZERO)))
    return -E_NO_MEM;

  // Now, set e->env_pgdir and initialize the page directory.
  //
  // Hint:
  //    - The VA space of all envs is identical above UTOP
  //	(except at UVPT, which we've set below).
  //	See inc/memlayout.h for permissions and layout.
  //	Can you use kern_pgdir as a template?  Hint: Yes.
  //	(Make sure you got the permissions right in Lab 7.)
  //    - The initial VA below UTOP is empty.
  //    - You do not need to make any more calls to page_alloc.
  //    - Note: In general, pp_ref is not maintained for
  //	physical pages mapped only above UTOP, but env_pgdir
  //	is an exception -- you need to increment env_pgdir's
  //	pp_ref for env_free to work correctly.
  //    - The functions in kern/pmap.h are handy.

  // LAB 8 code
  e->env_pml4e = page2kva(p);
  e->env_cr3   = page2pa(p);

  e->env_pml4e[1] = kern_pml4e[1];
  pa2page(PTE_ADDR(kern_pml4e[1]))->pp_ref++;

  e->env_pml4e[2] = e->env_cr3 | PTE_P | PTE_U;
  // LAB 8 code end

  return 0;
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
  int r;
  struct Env *e;

  if (!(e = env_free_list)) {
    return -E_NO_FREE_ENV;
  }

  // Allocate and set up the page directory for this environment.
  if ((r = env_setup_vm(e)) < 0)
    return r;

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
  e->env_type      = ENV_TYPE_USER;
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

  // LAB 3 code
  static int STACK_TOP = 0x2000000;
  e->env_tf.tf_rsp     = STACK_TOP - (e - envs) * 2 * PGSIZE;
  // LAB 3 code end

#else
  e->env_tf.tf_ds  = GD_UD | 3;
  e->env_tf.tf_es  = GD_UD | 3;
  e->env_tf.tf_ss  = GD_UD | 3;
  e->env_tf.tf_rsp = USTACKTOP;
  e->env_tf.tf_cs  = GD_UT | 3;
#endif

  e->env_tf.tf_rflags |= FL_IF;

  // You will set e->env_tf.tf_rip later.

  // Clear the page fault handler until user installs one.
  e->env_pgfault_upcall = 0;

  // Also clear the IPC receiving flag.
  e->env_ipc_recving = 0;

  // commit the allocation
  env_free_list = e->env_link;
  *newenv_store = e;

  cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

  return 0;
}

//
// Allocate len bytes of physical memory for environment env,
// and map it at virtual address va in the environment's address space.
// Does not zero or otherwise initialize the mapped pages in any way.
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len) {
  // (But only if you need it for load_icode.)
  //
  // Hint: It is easier to use region_alloc if the caller can pass
  //   'va' and 'len' values that are not page-aligned.
  //   You should round va down, and round (va + len) up.
  //   (Watch out for corner-cases!)

  // LAB 8 code
  void *end = ROUNDUP(va + len, PGSIZE);
  va        = ROUNDDOWN(va, PGSIZE);
  struct PageInfo *pi;

  while (va < end) {
    pi = page_alloc(ALLOC_ZERO);
    page_insert(e->env_pml4e, pi, va, PTE_U | PTE_W);
    va += PGSIZE;
  }
  // LAB 8 code end
}

#ifdef SANITIZE_USER_SHADOW_BASE

//
// Map UVP shadow memory and create pages if necessary
//
struct PageInfo *uvpt_pages = NULL;
static void
uvpt_shadow_map(struct Env *e) {
  uintptr_t va_aligned, va_end_aligned;
  struct PageInfo *pg = uvpt_pages;
  struct PageInfo *pg_prev;
  if (!pg) {
    pg         = page_alloc(ALLOC_ZERO);
    uvpt_pages = pg;
  }

  va_aligned     = ROUNDDOWN((uintptr_t)SANITIZE_USER_VPT_SHADOW_BASE, PGSIZE);
  va_end_aligned = ROUNDUP((uintptr_t)SANITIZE_USER_VPT_SHADOW_BASE + SANITIZE_USER_VPT_SHADOW_SIZE, PGSIZE);

  for (; va_aligned < va_end_aligned; va_aligned += PGSIZE) {
    if (!pg) {
      pg               = page_alloc(ALLOC_ZERO);
      pg_prev->pp_link = pg;
    }
    if (page_insert(e->env_pml4e, pg, (void *)va_aligned,
                    PTE_P | PTE_U | PTE_W) < 0)
      panic("Cannot allocate any memory for uvpt shadow mem");

    pg_prev = pg;
    pg      = pg->pp_link;
  }
}
#endif

#ifdef CONFIG_KSPACE
static void
bind_functions(struct Env *e, uint8_t *binary) {
  // find_function from kdebug.c should be used
  // LAB 3 code

  struct Elf *elf    = (struct Elf *)binary;
  struct Secthdr *sh = (struct Secthdr *)(binary + elf->e_shoff);
  const char *shstr  = (char *)binary + sh[elf->e_shstrndx].sh_offset;

  // Find string table
  size_t strtab = -1UL;
  for (size_t i = 0; i < elf->e_shnum; i++) {
    if (sh[i].sh_type == ELF_SHT_STRTAB && !strcmp(".strtab", shstr + sh[i].sh_name)) {
      strtab = i;
      break;
    }
  }
  const char *strings = (char *)binary + sh[strtab].sh_offset;

  for (size_t i = 0; i < elf->e_shnum; i++) {
    if (sh[i].sh_type == ELF_SHT_SYMTAB) {
      struct Elf64_Sym *syms = (struct Elf64_Sym *)(binary + sh[i].sh_offset);

      size_t nsyms = sh[i].sh_size / sizeof(*syms);

      for (size_t j = 0; j < nsyms; j++) {
        // Only handle symbols that we know how to bind
        if (ELF64_ST_BIND(syms[j].st_info) == STB_GLOBAL &&
            ELF64_ST_TYPE(syms[j].st_info) == STT_OBJECT &&
            syms[j].st_size == sizeof(void *)) {
          const char *name = strings + syms[j].st_name;
          uintptr_t addr   = find_function(name);

          if (addr) {
            memcpy((void *)syms[j].st_value, &addr, sizeof(void *));
          }
        }
      }
    }
  }
  // LAB 3 code end
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
// Finally, this function maps one page for the program's initial stack.
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
  //  Use functions from the previous labs to allocate and map pages.
  //
  //  All page protection bits should be user read/write for now.
  //  ELF segments are not necessarily page-aligned, but you can
  //  assume for this function that no two segments will touch
  //  the same page.
  //
  //  You may find a function like region_alloc useful.
  //
  //  Loading the segments is much simpler if you can move data
  //  directly into the virtual addresses stored in the ELF binary.
  //  So which page directory should be in force during
  //  this function?
  //
  //  You must also do something with the program's entry point,
  //  to make sure that the environment starts executing there.
  //  What?  (See env_run() and env_pop_tf() below.)

  // LAB 3 code, modified in LAB 8
  // из чего состоит Elf и Proghdr смотри в Elf64.h. Elf - это структура выполняемого фаила
  struct Elf *elf = (struct Elf *)binary; // binary приодится к типу указателя на структуру ELF
  if (elf->e_magic != ELF_MAGIC) {
    cprintf("Unexpected ELF format\n");
    return;
  }

  struct Proghdr *ph = (struct Proghdr *)(binary + elf->e_phoff); // Proghdr = prog header. Он лежит со смещением elf->e_phoff относительно начала фаила

  lcr3(e->env_cr3);
  for (size_t i = 0; i < elf->e_phnum; i++) { // elf->e_phnum - Число заголовков программы. Если у файла нет таблицы заголовков программы, это поле содержит 0.
    if (ph[i].p_type == ELF_PROG_LOAD) {

      void *src = (void *)(binary + ph[i].p_offset);
      void *dst = (void *)ph[i].p_va;

      size_t memsz  = ph[i].p_memsz;
      size_t filesz = MIN(ph[i].p_filesz, memsz);

      region_alloc(e, (void *)dst, memsz);

      memcpy(dst, src, filesz);
      memset(dst + filesz, 0, memsz - filesz); // обнуление памяти по адресу dst + filesz, где количество нулей = memsz - filesz. Т.е. зануляем всю выделенную память сегмента кода, оставшуюяся после копирования src. Возможно, эта строка не нужна
    }
  }

  lcr3(kern_cr3);
  e->env_tf.tf_rip = elf->e_entry; //Виртуальный адрес точки входа, которому система передает управление при запуске процесса. в регистр rip записываем адрес точки входа для выполнения процесса
#ifdef CONFIG_KSPACE
  bind_functions(e, binary); // Вызывается bind_functions, который связывает все что мы сделали выше (инициализация среды) с "кодом" самого процесса
#endif
  // LAB 3 code end

  // LAB 8 code
  region_alloc(e, (void *)(USTACKTOP - USTACKSIZE), USTACKSIZE);
  // LAB 8 code end

  // LAB 8: One more hint for implementing sanitizers.
#ifdef SANITIZE_USER_SHADOW_BASE
  cprintf("Allocating shadow base %p:%p\n", (void *)(SANITIZE_USER_SHADOW_BASE), (void *)(SANITIZE_USER_SHADOW_BASE + SANITIZE_USER_SHADOW_SIZE));
  region_alloc(e, (void *)SANITIZE_USER_SHADOW_BASE, SANITIZE_USER_SHADOW_SIZE);
  // Our stack and pagetables are special, as they use higher addresses, so they gets a separate shadow.
  cprintf("Allocating shadow ustack %p:%p\n", (void *)(SANITIZE_USER_STACK_SHADOW_BASE), (void *)(SANITIZE_USER_STACK_SHADOW_BASE + SANITIZE_USER_STACK_SHADOW_SIZE));
  region_alloc(e, (void *)SANITIZE_USER_STACK_SHADOW_BASE, SANITIZE_USER_STACK_SHADOW_SIZE);
  cprintf("Allocating shadow uextra %p:%p\n", (void *)(SANITIZE_USER_EXTRA_SHADOW_BASE), (void *)(SANITIZE_USER_EXTRA_SHADOW_BASE + SANITIZE_USER_EXTRA_SHADOW_SIZE));
  region_alloc(e, (void *)SANITIZE_USER_EXTRA_SHADOW_BASE, SANITIZE_USER_EXTRA_SHADOW_SIZE);
  cprintf("Allocating shadow fs %p:%p\n", (void *)(SANITIZE_USER_FS_SHADOW_BASE), (void *)(SANITIZE_USER_FS_SHADOW_BASE + SANITIZE_USER_FS_SHADOW_SIZE));
  region_alloc(e, (void *)SANITIZE_USER_FS_SHADOW_BASE, SANITIZE_USER_FS_SHADOW_SIZE);
  cprintf("Allocating shadow vpt %p:%p\n", (void *)(SANITIZE_USER_VPT_SHADOW_BASE), (void *)(SANITIZE_USER_VPT_SHADOW_BASE + SANITIZE_USER_VPT_SHADOW_SIZE));
  uvpt_shadow_map(e);
#endif
}

//
// Allocates a new env with env_alloc, loads the named elf
// binary into it with load_icode, and sets its env_type.
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type) {

  // LAB 3 code
  struct Env *newenv;
  if (env_alloc(&newenv, 0) < 0) {
    panic("Can't allocate new environment"); // попытка выделить среду – если нет – вылет по панике ядра
  }

  newenv->env_type = type;

  load_icode(newenv, binary); // load instruction code
  // LAB 3 code end

  // LAB 10 code
  if (type == ENV_TYPE_FS) {
    newenv->env_tf.tf_rflags |= FL_IOPL_3;
  }
  // LAB 10 code end
}

//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e) {
#ifndef CONFIG_KSPACE
  pdpe_t *pdpe;
  pde_t *pgdir;
  pte_t *pt;
  uint64_t pdeno_limit;
  uint64_t pdeno, pteno, pdpeno;
  physaddr_t pa;

  // If freeing the current environment, switch to kern_pgdir
  // before freeing the page directory, just in case the page
  // gets reused.
  if (e == curenv)
    lcr3(kern_cr3);
#endif

  // Note the environment's demise.
  cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

#ifndef CONFIG_KSPACE
  // Flush all mapped pages in the user portion of the address space
  static_assert(UTOP % PTSIZE == 0, "Misaligned UTOP");

  //UTOP < PDPE[1] start, so all mapped memory should be in first PDPE
  pdpe = KADDR(PTE_ADDR(e->env_pml4e[0]));
  for (pdpeno = 0; pdpeno <= PDPE(UTOP); pdpeno++) {
    // only look at mapped page directory pointer index
    if (!(pdpe[pdpeno] & PTE_P))
      continue;

    pgdir       = KADDR(PTE_ADDR(pdpe[pdpeno]));
    pdeno_limit = pdpeno == PDPE(UTOP) ? PDX(UTOP) : NPDPENTRIES;
    for (pdeno = 0; pdeno < pdeno_limit; pdeno++) {

      // only look at mapped page tables
      if (!(pgdir[pdeno] & PTE_P))
        continue;

      // find the pa and va of the page table
      pa = PTE_ADDR(pgdir[pdeno]);
      pt = (pte_t *)KADDR(pa);

      // unmap all PTEs in this page table
      for (pteno = 0; pteno <= PTX(~0); pteno++) {
        if (pt[pteno] & PTE_P)
          page_remove(e->env_pml4e, PGADDR((uint64_t)0,
                                           pdpeno, pdeno, pteno, 0));
      }

      // free the page table itself
      pgdir[pdeno] = 0;
      page_decref(pa2page(pa));
    }

    // free the page directory
    pa           = PTE_ADDR(pdpe[pdpeno]);
    pdpe[pdpeno] = 0;
    page_decref(pa2page(pa));
  }
  // free the page directory pointer
  page_decref(pa2page(PTE_ADDR(e->env_pml4e[0])));
  // free the page map level 4 (PML4)
  e->env_pml4e[0] = 0;
  pa              = e->env_cr3;
  e->env_pml4e    = 0;
  e->env_cr3      = 0;
  page_decref(pa2page(pa));
#endif
  // return the environment to the free list
  e->env_status = ENV_FREE;
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
  // If e is currently running on other CPUs, we change its state to
  // ENV_DYING. A zombie environment will be freed the next time
  // it traps to the kernel.

  // LAB 3 code
  e->env_status = ENV_DYING;
  env_free(e);
  if (e == curenv) {
    sched_yield();
  }
  // LAB 3 code end
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
  __asm __volatile("movq %0,%%rsp\n" POPA
                   "movw (%%rsp),%%es\n"
                   "movw 8(%%rsp),%%ds\n"
                   "addq $16,%%rsp\n"
                   "\taddq $16,%%rsp\n" /* skip tf_trapno and tf_errcode */
                   "\tiretq"
                   :
                   : "g"(tf)
                   : "memory");
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
  //	   5. Use lcr3() to switch to its address space.
  // Step 2: Use env_pop_tf() to restore the environment's
  //	   registers and starting execution of process.

  // Hint: This function loads the new environment's state from
  //	e->env_tf.  Go back through the code you wrote above
  //	and make sure you have set the relevant parts of
  //	e->env_tf to sensible values.
  //

  // LAB 3 code
  if (curenv) {                            // if curenv == False, значит, какого-нибудь исполняемого процесса нет
    if (curenv->env_status == ENV_DYING) { // если процесс стал зомби
      struct Env *old = curenv;            // ставим старый адрес
      env_free(curenv);                    // самурай запятнал свой env – убираем его в ножны дабы стереть кровь
      if (old == e) {                      // e - аргумент функции, который к нам пришел
        sched_yield();                     // переключение системными вызовами
      }
    } else if (curenv->env_status == ENV_RUNNING) { // если процесс можем запустить
      curenv->env_status = ENV_RUNNABLE;            // запускаем процесс
    }
  }

  curenv             = e;           // текущая среда – е
  curenv->env_status = ENV_RUNNING; // устанавливаем статус среды на "выполняется"
  curenv->env_runs++;               // обновляем количество работающих контекстов

  // LAB 8 code
  lcr3(curenv->env_cr3);
  // LAB 8 code end

  // LAB 3 code
  env_pop_tf(&curenv->env_tf);
  // LAB 3 code end

  while (1) {}
}
