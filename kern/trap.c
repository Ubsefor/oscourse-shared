#include <inc/mmu.h>
#include <inc/x86.h>
#include <inc/assert.h>
#include <inc/string.h>

#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/env.h>
#include <kern/syscall.h>
#include <kern/sched.h>
#include <kern/kclock.h>
#include <kern/picirq.h>
#include <kern/cpu.h>
#include <kern/timer.h>

extern uintptr_t gdtdesc_64;
static struct Taskstate ts;
extern struct Segdesc gdt[];
extern long gdt_pd;

/* For debugging, so print_trapframe can distinguish between printing
 * a saved trapframe and printing the current trapframe and print some
 * additional information in the latter case.
 */
static struct Trapframe *last_tf;

/* Interrupt descriptor table.  (Must be built at run time because
 * shifted function addresses can't be represented in relocation records.)
 */
struct Gatedesc idt[256] = {{0}};
struct Pseudodesc idt_pd = {
    sizeof(idt) - 1, (uint64_t)idt};

static const char *
trapname(int trapno) {
  static const char *const excnames[] = {
      "Divide error",
      "Debug",
      "Non-Maskable Interrupt",
      "Breakpoint",
      "Overflow",
      "BOUND Range Exceeded",
      "Invalid Opcode",
      "Device Not Available",
      "Double Fault",
      "Coprocessor Segment Overrun",
      "Invalid TSS",
      "Segment Not Present",
      "Stack Fault",
      "General Protection",
      "Page Fault",
      "(unknown trap)",
      "x87 FPU Floating-Point Error",
      "Alignment Check",
      "Machine-Check",
      "SIMD Floating-Point Exception"};

  if (trapno < sizeof(excnames) / sizeof(excnames[0]))
    return excnames[trapno];
  if (trapno == T_SYSCALL)
    return "System call";
  if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
    return "Hardware Interrupt";
  return "(unknown trap)";
}

void
trap_init(void) {
  // extern struct Segdesc gdt[];
  // LAB 8: Your code here.

  // Per-CPU setup
  trap_init_percpu();
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void) {
  // Setup a TSS so that we get the right stack
  // when we trap to the kernel.
  ts.ts_esp0 = KSTACKTOP;

  // Initialize the TSS slot of the gdt.
  SETTSS((struct SystemSegdesc64 *)(&gdt[(GD_TSS0 >> 3)]), STS_T64A,
         (uint64_t)(&ts), sizeof(struct Taskstate), 0);

  // Load the TSS selector (like other segment selectors, the
  // bottom three bits are special; we leave them 0)
  ltr(GD_TSS0);

  // Load the IDT
  lidt(&idt_pd);
}

void
clock_idt_init(void) {
  extern void (*clock_thdlr)(void);
  // init idt structure
  SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, (uintptr_t)(&clock_thdlr), 0);
  SETGATE(idt[IRQ_OFFSET + IRQ_CLOCK], 0, GD_KT, (uintptr_t)(&clock_thdlr), 0);
  lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf) {
  cprintf("TRAP frame at %p\n", tf);
  print_regs(&tf->tf_regs);
  cprintf("  es   0x----%04x\n", tf->tf_es);
  cprintf("  ds   0x----%04x\n", tf->tf_ds);
  cprintf("  trap 0x%08lx %s\n", (unsigned long)tf->tf_trapno, trapname(tf->tf_trapno));
  // If this trap was a page fault that just happened
  // (so %cr2 is meaningful), print the faulting linear address.
  if (tf == last_tf && tf->tf_trapno == T_PGFLT)
    cprintf("  cr2  0x%08lx\n", (unsigned long)rcr2());
  cprintf("  err  0x%08lx", (unsigned long)tf->tf_err);
  // For page faults, print decoded fault error code:
  // U/K=fault occurred in user/kernel mode
  // W/R=a write/read caused the fault
  // PR=a protection violation caused the fault (NP=page not present).
  if (tf->tf_trapno == T_PGFLT)
    cprintf(" [%s, %s, %s]\n",
            tf->tf_err & 4 ? "user" : "kernel",
            tf->tf_err & 2 ? "write" : "read",
            tf->tf_err & 1 ? "protection" : "not-present");
  else
    cprintf("\n");
  cprintf("  rip  0x%08lx\n", (unsigned long)tf->tf_rip);
  cprintf("  cs   0x----%04x\n", tf->tf_cs);
  cprintf("  flag 0x%08lx\n", (unsigned long)tf->tf_rflags);
  if ((tf->tf_cs & 3) != 0) {
    cprintf("  rsp  0x%08lx\n", (unsigned long)tf->tf_rsp);
    cprintf("  ss   0x----%04x\n", tf->tf_ss);
  }
}

void
print_regs(struct PushRegs *regs) {
  cprintf("  r15  0x%08lx\n", (unsigned long)regs->reg_r15);
  cprintf("  r14  0x%08lx\n", (unsigned long)regs->reg_r14);
  cprintf("  r13  0x%08lx\n", (unsigned long)regs->reg_r13);
  cprintf("  r12  0x%08lx\n", (unsigned long)regs->reg_r12);
  cprintf("  r11  0x%08lx\n", (unsigned long)regs->reg_r11);
  cprintf("  r10  0x%08lx\n", (unsigned long)regs->reg_r10);
  cprintf("  r9   0x%08lx\n", (unsigned long)regs->reg_r9);
  cprintf("  r8   0x%08lx\n", (unsigned long)regs->reg_r8);
  cprintf("  rdi  0x%08lx\n", (unsigned long)regs->reg_rdi);
  cprintf("  rsi  0x%08lx\n", (unsigned long)regs->reg_rsi);
  cprintf("  rbp  0x%08lx\n", (unsigned long)regs->reg_rbp);
  cprintf("  rbx  0x%08lx\n", (unsigned long)regs->reg_rbx);
  cprintf("  rdx  0x%08lx\n", (unsigned long)regs->reg_rdx);
  cprintf("  rcx  0x%08lx\n", (unsigned long)regs->reg_rcx);
  cprintf("  rax  0x%08lx\n", (unsigned long)regs->reg_rax);
}

static void
trap_dispatch(struct Trapframe *tf) {

  int64_t syscallno, a1, a2, a3, a4, a5, ret;
  if (tf->tf_trapno == T_SYSCALL) {
    syscallno           = tf->tf_regs.reg_rax;
    a1                  = tf->tf_regs.reg_rdx;
    a2                  = tf->tf_regs.reg_rcx;
    a3                  = tf->tf_regs.reg_rbx;
    a4                  = tf->tf_regs.reg_rdi;
    a5                  = tf->tf_regs.reg_rsi;
    ret                 = syscall(syscallno, a1, a2, a3, a4, a5);
    tf->tf_regs.reg_rax = ret;
    return;
  }

  // Handle processor exceptions.
  if (tf->tf_trapno == T_PGFLT) {
    page_fault_handler(tf);
    return;
  }

  if (tf->tf_trapno == T_BRKPT) {
    monitor(tf);
    return;
  }

  // Handle spurious interrupts
  // The hardware sometimes raises these because of noise on the
  // IRQ line or other reasons. We don't care.
  //
  if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
    cprintf("Spurious interrupt on irq 7\n");
    print_trapframe(tf);
    return;
  }

  // All timers are actually routed through this IRQ.
  if (tf->tf_trapno == IRQ_OFFSET + IRQ_CLOCK) {

    // LAB 4 Your code here.
    // rtc_check_status();
    // pic_send_eoi(IRQ_CLOCK);

    // читаем регистр статуса RTC и отправляем сигнал EOI на контроллер прерываний,
    // сигнализируя об окончании обработки прерывания
    // pic_send_eoi(rtc_check_status());

    timer_for_schedule->handle_interrupts();

    sched_yield();
    return;
  }

  print_trapframe(tf);
  if (!(tf->tf_cs & 0x3)) {
    panic("unhandled trap in kernel");
  } else {
    env_destroy(curenv);
  }
}

void
trap(struct Trapframe *tf) {
  // The environment may have set DF and some versions
  // of GCC rely on DF being clear
  asm volatile("cld" ::
                   : "cc");

  // Halt the CPU if some other CPU has called panic()
  extern char *panicstr;
  if (panicstr)
    asm volatile("hlt");

  // Check that interrupts are disabled.  If this assertion
  // fails, DO NOT be tempted to fix it by inserting a "cli" in
  // the interrupt path.
  assert(!(read_rflags() & FL_IF));

  if (debug) {
    cprintf("Incoming TRAP frame at %p\n", tf);
  }

  assert(curenv);

  // Garbage collect if current enviroment is a zombie
  if (curenv->env_status == ENV_DYING) {
    env_free(curenv);
    curenv = NULL;
    sched_yield();
  }

  // Copy trap frame (which is currently on the stack)
  // into 'curenv->env_tf', so that running the environment
  // will restart at the trap point.
  curenv->env_tf = *tf;
  // The trapframe on the stack should be ignored from here on.
  tf = &curenv->env_tf;

  // Record that tf is the last real trapframe so
  // print_trapframe can print some additional information.
  last_tf = tf;

  // Dispatch based on what type of trap occurred
  trap_dispatch(tf);

  // If we made it to this point, then no other environment was
  // scheduled, so we should return to the current environment
  // if doing so makes sense.
  if (curenv && curenv->env_status == ENV_RUNNING)
    env_run(curenv);
  else
    sched_yield();
}

void
page_fault_handler(struct Trapframe *tf) {
  uintptr_t fault_va;

  // Read processor's CR2 register to find the faulting address
  fault_va = rcr2();

  // Handle kernel-mode page faults.

  // LAB 8: Your code here.


}
