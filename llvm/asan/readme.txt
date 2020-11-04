Standalone LLVM ASAN runtime implementation mostly based on Apple KASAN implementation.
https://opensource.apple.com/source/xnu/xnu-4570.1.46/san/

The details regarding AddressSanitizer could be found on:
https://github.com/google/sanitizers/wiki/AddressSanitizer

JOS state:

KERNEL:
NO  Use after free
NO  Heap buffer overflow
OK  Stack buffer overflow
OK  Global buffer overflow
NO  Use after return
OK  Use after scope
NO  Initialization order bugs
NO  Memory leaks
