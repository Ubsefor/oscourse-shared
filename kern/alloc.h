#ifndef JOS_INC_ALLOC_H
#define JOS_INC_ALLOC_H

typedef long Align; /* for alignment to long boundary */

union header { /* block header */
  struct {
    union header *next; /* next block */
    union header *prev; /* prev block */
    unsigned size;      /* size of this block */
  } s;
  Align x; /* force alignment of blocks */
} __attribute__((packed));

typedef union header Header;

#endif
