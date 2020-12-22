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

/* Not sanitised functions needed for asan itself
 */

void *__nosan_memset(void *src, int c, size_t sz) {
  // We absolutely must implement this for ASAN functioning.
  volatile char *vptr = (volatile char *)(src);
  while (sz--) {
    *vptr++ = c;
  }
  return src;
}

void *__nosan_memcpy(void *dst, const void *src, size_t sz) {
  uint8_t *d = (uint8_t *)dst;
  uint8_t *s = (uint8_t *)src;

  for (size_t i = 0; i < sz; i++)
    d[i] = s[i];

  return dst;
}
