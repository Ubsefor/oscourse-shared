// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>

#include <kern/tsc.h>
#include <kern/timer.h>
#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/trap.h>

#define CMDBUF_SIZE 80 // enough for one VGA text line

struct Command {
  const char *name;
  const char *desc;
  // return -1 to force monitor to exit
  int (*func)(int argc, char **argv, struct Trapframe *tf);
};

// LAB 5: Your code here.
// Implement timer_start (mon_start), timer_stop (mon_stop), timer_freq (mon_frequency) commands.
// LAB 6: Your code here.
// Implement memory (mon_memory) command.
static struct Command commands[] = {
    {"help", "Display this list of commands", mon_help},
    {"hello", "Display greeting message", mon_hello},
    {"kerninfo", "Display information about the kernel", mon_kerninfo},

    // DELETED in LAB 5
    // {"mycommand", "Display output for my command", mon_mycommand},
    // DELETED in LAB 5 end

    // LAB 5 code
    {"timer_start", "Start timer", mon_start},
    {"timer_stop", "Stop timer", mon_stop},
    {"timer_freq", "Count processor frequency", mon_frequency},
    // LAB 5 code end

    // LAB 6 code
    {"memory", "Print list of all physical memory pages", mon_memory},
    // LAB 6 code end

    {"backtrace", "Print stack backtrace", mon_backtrace}};
#define NCOMMANDS (sizeof(commands) / sizeof(commands[0]))

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf) {
  int i;

  for (i = 0; i < NCOMMANDS; i++)
    cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  return 0;
}

int
mon_hello(int argc, char **argv, struct Trapframe *tf) {
  cprintf("Hello!\n");
  return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf) {
  extern char _head64[], entry[], etext[], edata[], end[];

  cprintf("Special kernel symbols:\n");
  cprintf("  _head64                  %08lx (phys)\n",
          (unsigned long)_head64);
  cprintf("  entry  %08lx (virt)  %08lx (phys)\n",
          (unsigned long)entry, (unsigned long)entry - KERNBASE);
  cprintf("  etext  %08lx (virt)  %08lx (phys)\n",
          (unsigned long)etext, (unsigned long)etext - KERNBASE);
  cprintf("  edata  %08lx (virt)  %08lx (phys)\n",
          (unsigned long)edata, (unsigned long)edata - KERNBASE);
  cprintf("  end    %08lx (virt)  %08lx (phys)\n",
          (unsigned long)end, (unsigned long)end - KERNBASE);
  cprintf("Kernel executable memory footprint: %luKB\n",
          (unsigned long)ROUNDUP(end - entry, 1024) / 1024);
  return 0;
}

// DELETED in LAB 5
// LAB 2 code
// int
// mon_mycommand(int argc, char **argv, struct Trapframe *tf) {
// cprintf("This is output for my command.\n");
// return 0;
// }
// LAB 2 code end
// DELETED in LAB 5 end

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf) {
  // LAB 2 code

  cprintf("Stack backtrace:\n");
  uint64_t rbp       = read_rbp();
  uintptr_t *pointer = (uintptr_t *)rbp;
  uint64_t rip;
  uint64_t buf;
  int digits_16;
  int code;
  struct Ripdebuginfo info;

  while (rbp != 0) {
    buf = rbp;

    // counting how many digits rbp has in hexadecimal representation
    digits_16 = 1;
    buf       = buf / 16;
    while (buf != 0) {
      digits_16++;
      buf = buf / 16;
    }

    cprintf("  rbp ");

    // first print additional zeroes
    for (int i = 1; i <= 16 - digits_16; i++) {
      cprintf("0");
    }
    cprintf("%lx", rbp);

    // get next rbp from stack
    rbp = *pointer;

    // get rip from stack
    pointer++;
    rip = *pointer;

    // counting how many digits rip has in hexadecimal representation
    buf       = rip;
    digits_16 = 1;
    buf       = buf / 16;
    while (buf != 0) {
      digits_16++;
      buf = buf / 16;
    }

    cprintf("  rip ");

    // first print additional zeroes
    for (int i = 1; i <= 16 - digits_16; i++) {
      cprintf("0");
    }
    cprintf("%lx\n", rip);

    // get and print debug info
    code = debuginfo_rip((uintptr_t)rip, (struct Ripdebuginfo *)&info);
    if (code == 0) {
      cprintf("         %s:%d: %s+%lu\n", info.rip_file, info.rip_line, info.rip_fn_name, rip - info.rip_fn_addr);
    } else {
      cprintf("Info not found");
    }

    pointer = (uintptr_t *)rbp;
  }

  // LAB 2 code end
  return 0;
}

// LAB 5 code
// Implement timer_start (mon_start), timer_stop (mon_stop), timer_freq (mon_frequency) commands.
int
mon_start(int argc, char **argv, struct Trapframe *tf) {
  // LAB 5 code
  if (argc != 2) {
    return 1;
  }
  timer_start(argv[1]);
  // LAB 5 code end

  return 0;
}

int
mon_stop(int argc, char **argv, struct Trapframe *tf) {
  // LAB 5 code
  timer_stop();
  // LAB 5 code end

  return 0;
}

int
mon_frequency(int argc, char **argv, struct Trapframe *tf) {
  // LAB 5 code
  if (argc != 2) {
    return 1;
  }
  timer_cpu_frequency(argv[1]);
  // LAB 5 code end

  return 0;
}
// LAB 5 code end

// LAB 6 code
// Implement memory (mon_memory) commands.
int
mon_memory(int argc, char **argv, struct Trapframe *tf) {
  size_t i;
  int is_cur_free;

  for (i = 1; i <= npages; i++) {
    is_cur_free = !page_is_allocated(&pages[i - 1]);
    cprintf("%lu", i);
    if ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
      while ((i < npages) && (page_is_allocated(&pages[i]) ^ is_cur_free)) {
        i++;
      }
      cprintf("..%lu", i);
    }
    cprintf(is_cur_free ? " FREE\n" : " ALLOCATED\n");
  }

  return 0;
}
// LAB 6 code end

/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS    16

static int
runcmd(char *buf, struct Trapframe *tf) {
  int argc;
  char *argv[MAXARGS];
  int i;

  // Parse the command buffer into whitespace-separated arguments
  argc       = 0;
  argv[argc] = 0;
  while (1) {
    // gobble whitespace
    while (*buf && strchr(WHITESPACE, *buf))
      *buf++ = 0;
    if (*buf == 0)
      break;

    // save and scan past next arg
    if (argc == MAXARGS - 1) {
      cprintf("Too many arguments (max %d)\n", MAXARGS);
      return 0;
    }
    argv[argc++] = buf;
    while (*buf && !strchr(WHITESPACE, *buf))
      buf++;
  }
  argv[argc] = 0;

  // Lookup and invoke the command
  if (argc == 0)
    return 0;
  for (i = 0; i < NCOMMANDS; i++) {
    if (strcmp(argv[0], commands[i].name) == 0)
      return commands[i].func(argc, argv, tf);
  }
  cprintf("Unknown command '%s'\n", argv[0]);
  return 0;
}

void
monitor(struct Trapframe *tf) {
  char *buf;

  cprintf("Welcome to the JOS kernel monitor!\n");
  cprintf("Type 'help' for a list of commands.\n");

  if (tf != NULL)
    print_trapframe(tf);

  while (1) {
    buf = readline("K> ");
    if (buf != NULL)
      if (runcmd(buf, tf) < 0)
        break;
  }
}
