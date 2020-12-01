/* See COPYRIGHT for copyright information. */

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/assert.h>
#include <inc/uefi.h>
#include <inc/memlayout.h>

#include <kern/monitor.h>
#include <kern/tsc.h>
#include <kern/console.h>
#include <kern/pmap.h>
#include <kern/env.h>
#include <kern/timer.h>
#include <kern/trap.h>
#include <kern/sched.h>
#include <kern/cpu.h>
#include <kern/picirq.h>
#include <kern/kclock.h>
#include <kern/kdebug.h>

void
timers_init(void) {
  timertab[0] = timer_rtc;
  timertab[1] = timer_pit;
  timertab[2] = timer_acpipm;
  timertab[3] = timer_hpet0;
  timertab[4] = timer_hpet1;

  for (int i = 0; i < MAX_TIMERS; i++) {
    if (timertab[i].timer_init != NULL) {
      timertab[i].timer_init();
    }
  }
}

void
timers_schedule(const char *name) {
  for (int i = 0; i < MAX_TIMERS; i++) {
    if (timertab[i].timer_name != NULL && strcmp(timertab[i].timer_name, name) == 0) {
      if (timertab[i].enable_interrupts != NULL) {
        timer_for_schedule = &timertab[i];
        timertab[i].enable_interrupts();
      } else {
        panic("Timer %s does not support interrupts\n", name);
      }
      return;
    }
  }

  panic("Timer %s does not exist\n", name);
}

pde_t *
alloc_pde_early_boot(void) {
  //Assume pde1, pde2 is already used.
  extern uintptr_t pdefreestart, pdefreeend;
  pde_t *ret;
  static uintptr_t pdefree = (uintptr_t)&pdefreestart;

  if (pdefree >= (uintptr_t)&pdefreeend)
    return NULL;

  ret = (pde_t *)pdefree;
  pdefree += PGSIZE;
  return ret;
}

void
map_addr_early_boot(uintptr_t addr, uintptr_t addr_phys, size_t sz) {
  extern uintptr_t pml4phys;
  pml4e_t *pml4 = &pml4phys;
  pdpe_t *pdpt;
  pde_t *pde;

  uintptr_t addr_curr, addr_curr_phys, addr_end;
  addr_curr      = ROUNDDOWN(addr, PTSIZE);
  addr_curr_phys = ROUNDDOWN(addr_phys, PTSIZE);
  addr_end       = ROUNDUP(addr + sz, PTSIZE);

  pdpt = (pdpe_t *)PTE_ADDR(pml4[PML4(addr_curr)]);
  for (; addr_curr < addr_end; addr_curr += PTSIZE, addr_curr_phys += PTSIZE) {
    pde = (pde_t *)PTE_ADDR(pdpt[PDPE(addr_curr)]);
    if (!pde) {
      pde                   = alloc_pde_early_boot();
      pdpt[PDPE(addr_curr)] = ((uintptr_t)pde) | PTE_P | PTE_W;
    }
    pde[PDX(addr_curr)] = addr_curr_phys | PTE_P | PTE_W | PTE_MBZ;
  }
}
// Additionally maps pml4 memory so that we dont get memory errors on accessing
// uefi_lp, MemMap, KASAN functions.
void
early_boot_pml4_init(void) {

  map_addr_early_boot((uintptr_t)uefi_lp, (uintptr_t)uefi_lp, sizeof(LOADER_PARAMS));
  map_addr_early_boot((uintptr_t)uefi_lp->MemoryMap, (uintptr_t)uefi_lp->MemoryMap, uefi_lp->MemoryMapSize);

#ifdef SANITIZE_SHADOW_BASE
  map_addr_early_boot(SANITIZE_SHADOW_BASE, SANITIZE_SHADOW_BASE - KERNBASE, SANITIZE_SHADOW_SIZE);
#endif

#if LAB <= 6
  map_addr_early_boot(FBUFFBASE, uefi_lp->FrameBufferBase, uefi_lp->FrameBufferSize);
#endif
}

void
i386_init(void) {
  extern char end[];

  early_boot_pml4_init();

  // Initialize the console.
  // Can't call cprintf until after we do this!
  cons_init();

  tsc_calibrate();

  cprintf("6828 decimal is %o octal!\n", 6828);
  cprintf("END: %p\n", end);

#ifndef CONFIG_KSPACE
  // Lab 6 memory management initialization functions
  mem_init();
#endif

  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
    (*ctor)();
    ctor++;
  }

  // LAB 5 code
  // pic_init();
  // rtc_init();
  // LAB 5 code end

#ifdef SANITIZE_SHADOW_BASE
  kasan_mem_init();
#endif

  timers_init();

  // Framebuffer init should be done after memory init.
  fb_init();
  cprintf("Framebuffer initialised\n");

  // user environment initialization functions
  env_init();
  trap_init();

  // choose the timer used for scheduling: hpet or pit
  timers_schedule("hpet0");

  clock_idt_init();

  // DELETED in LAB 5
  // LAB 4 code
  // pic_init();
  // rtc_init();

  // размаскирование на контроллере линии IRQ_CLOCK, по которой приходят прерывания от часов
  // irq_setmask_8259A(~(~irq_mask_8259A | (1 << IRQ_CLOCK)));
  // LAB 4 code end
  // DELETED in LAB 5 end

#ifdef CONFIG_KSPACE
  // Touch all you want.
  ENV_CREATE_KERNEL_TYPE(prog_test1);
  ENV_CREATE_KERNEL_TYPE(prog_test2);
  ENV_CREATE_KERNEL_TYPE(prog_test3);
  ENV_CREATE_KERNEL_TYPE(prog_test4);
  ENV_CREATE_KERNEL_TYPE(prog_test5);
  ENV_CREATE_KERNEL_TYPE(prog_test6);
#else
#if defined(TEST)
  // Don't touch -- used by grading script!
  ENV_CREATE(TEST, ENV_TYPE_USER);
#else
  // Touch all you want.
  // ENV_CREATE(user_hello, ENV_TYPE_USER);
  // ENV_CREATE(user_dumbfork, ENV_TYPE_USER);
#endif // TEST*
#endif
  // Schedule and run the first user environment!
  sched_yield();
}

/*
 * Variable panicstr contains argument to first call to panic; used as flag
 * to indicate that the kernel has already called panic.
 */
const char *panicstr = NULL;

/*
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  va_list ap;

  if (panicstr)
    goto dead;
  panicstr = fmt;

  // Be extra sure that the machine is in as reasonable state
  __asm __volatile("cli; cld");

  va_start(ap, fmt);
  cprintf("kernel panic at %s:%d: ", file, line);
  vcprintf(fmt, ap);
  cprintf("\n");
  va_end(ap);

dead:
  /* break into the kernel monitor */
  while (1)
    monitor(NULL);
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt, ...) {
  va_list ap;

  va_start(ap, fmt);
  cprintf("kernel warning at %s:%d: ", file, line);
  vcprintf(fmt, ap);
  cprintf("\n");
  va_end(ap);
}
