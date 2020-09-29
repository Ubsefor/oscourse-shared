
#ifndef JOS_INC_CPU_H
#define JOS_INC_CPU_H

#include <inc/types.h>
#include <inc/memlayout.h>
#include <inc/mmu.h>
#include <inc/env.h>

#define NCPU 1

extern struct Taskstate cpu_ts; // Used by x86 to find stack for interrupt

//kernel stack
extern unsigned char kstack[KSTKSIZE];

#endif
