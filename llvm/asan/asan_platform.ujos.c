/*
 * Institute for System Programming of the Russian Academy of Sciences
 * Copyright (C) 2017 ISPRAS
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation, Version 3.
 *
 * This program is distributed in the hope # that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 * See the GNU General Public License version 3 for more details.
 */

#include "asan.h"
#include "asan_internal.h"
#include "asan_memintrinsics.h"

#if !defined(SANITIZE_USER_SHADOW_BASE) ||                                     \
    !defined(SANITIZE_USER_SHADOW_SIZE) || !defined(SANITIZE_USER_SHADOW_OFF)
#error                                                                         \
    "You are to define SANITIZE_USER_SHADOW_BASE and SANITIZE_USER_SHADOW_SIZE for shadow memory support!"
#endif

// FIXME: Workaround terrible decision to use -nostdinc for building
// userspace...
#define __ASSEMBLER__
#include <inc/memlayout.h>
#include <inc/mmu.h>
#undef __ASSEMBLER__

// FIXME: We need to wrap all the custom allocators we use and track the
// allocated memory.
// There should probably be more of them (especially in the kernel).

extern uint8_t __data_start;
extern uint8_t __data_end;

extern uint8_t __rodata_start;
extern uint8_t __rodata_end;

extern uint8_t __bss_start;
extern uint8_t __bss_end;

void NORETURN _panic(const char *file, int line, const char *fmt, ...);

void platform_abort() { _panic("asan", 0, "platform_abort"); }

void platform_asan_init() {
  asan_internal_shadow_start = (uint8_t *)SANITIZE_USER_SHADOW_BASE;
  asan_internal_shadow_end =
      (uint8_t *)SANITIZE_USER_SHADOW_BASE + SANITIZE_USER_SHADOW_SIZE;
  asan_internal_shadow_off = (uint8_t *)SANITIZE_USER_SHADOW_OFF;

  asan_internal_shadow_extra_start = (uint8_t *)SANITIZE_USER_EXTRA_SHADOW_BASE;
  asan_internal_shadow_extra_end = (uint8_t *)SANITIZE_USER_EXTRA_SHADOW_BASE +
                                   SANITIZE_USER_EXTRA_SHADOW_SIZE;

  // Initially start with poisoning everything!
  __nosan_memset(asan_internal_shadow_start, ASAN_GLOBAL_RZ,
                 asan_internal_shadow_end - asan_internal_shadow_start);

  // Unpoison the vital areas!
  asan_internal_fill_range((uptr)&__data_start, &__data_end - &__data_start, 0);
  asan_internal_fill_range((uptr)&__rodata_start,
                           &__rodata_end - &__rodata_start, 0);
  asan_internal_fill_range((uptr)&__bss_start, &__bss_end - &__bss_start, 0);

  // Unpoison additional shadow area
  __nosan_memset((void *)asan_internal_shadow_extra_start, 0,
                 asan_internal_shadow_extra_end -
                     asan_internal_shadow_extra_start);
  __nosan_memset((void *)SANITIZE_USER_STACK_SHADOW_BASE, 0,
                 SANITIZE_USER_STACK_SHADOW_SIZE);
  __nosan_memset((void *)SANITIZE_USER_FS_SHADOW_BASE, 0,
                 SANITIZE_USER_FS_SHADOW_SIZE);
  __nosan_memset((void *)SANITIZE_USER_VPT_SHADOW_BASE, 0,
                 SANITIZE_USER_VPT_SHADOW_SIZE);
}

void platform_asan_unpoison(void *addr, uint32_t size) {
  asan_internal_fill_range((uptr)addr, size, 0);
}

void platform_asan_fatal(const char *msg, uptr p, size_t width,
                         unsigned access_type) {
  ASAN_LOG(
      "Fatal error: %s (addr 0x%lx within i/o size 0x%lx of type %u), tracing:",
      msg, (long)p, (long)width, access_type);

  ASAN_DEBUG_BREAK();

  DUMP_STACK_AT_LEVEL(p, 0);
  DUMP_STACK_AT_LEVEL(p, 1);
  DUMP_STACK_AT_LEVEL(p, 2);
  DUMP_STACK_AT_LEVEL(p, 3);
  DUMP_STACK_AT_LEVEL(p, 4);
  DUMP_STACK_AT_LEVEL(p, 5);
  DUMP_STACK_AT_LEVEL(p, 6);
  DUMP_STACK_AT_LEVEL(p, 7);
  DUMP_STACK_AT_LEVEL(p, 8);
  DUMP_STACK_AT_LEVEL(p, 9);
  DUMP_STACK_AT_LEVEL(p, 10);
  DUMP_STACK_AT_LEVEL(p, 11);
  DUMP_STACK_AT_LEVEL(p, 12);
  DUMP_STACK_AT_LEVEL(p, 13);
  DUMP_STACK_AT_LEVEL(p, 14);
  DUMP_STACK_AT_LEVEL(p, 15);

  ASAN_ABORT();
}

bool platform_asan_fakestack_enter(uint32_t *thread_id) {
  // TODO: implement!
  return true;
}

void platform_asan_fakestack_leave() {
  // TODO: implement!
}
