#
# This makefile system follows the structuring conventions
# recommended by Peter Miller in his excellent paper:
#
#	Recursive Make Considered Harmful
#	http://aegis.sourceforge.net/auug97.pdf
#
OBJDIR := obj
SHELL := /bin/bash

# UEFI firmware definitions
JOS_LOADER_DEPS := LoaderPkg/Loader/*.c LoaderPkg/Loader/*.h LoaderPkg/Loader/*.inf LoaderPkg/*.dsc LoaderPkg/*.dec
JOS_LOADER_BUILD := LoaderPkg/UDK/Build/LoaderPkg
ifeq ($(ARCHS),IA32)
OVMF_FIRMWARE := LoaderPkg/Binaries/OVMF-IA32.fd
JOS_LOADER := LoaderPkg/Binaries/Loader-IA32.efi
JOS_LOADER_DEPS += LoaderPkg/Loader/Ia32/*.nasm LoaderPkg/Loader/Ia32/*.c
JOS_BOOTER := BOOTIa32.efi
else
OVMF_FIRMWARE := LoaderPkg/Binaries/OVMF-X64.fd
JOS_LOADER := LoaderPkg/Binaries/Loader-X64.efi
JOS_LOADER_DEPS += LoaderPkg/Loader/X64/*.c
JOS_BOOTER := BOOTX64.efi
endif
JOS_ESP := LoaderPkg/ESP

# Run 'make V=1' to turn on verbose commands, or 'make V=0' to turn them off.
ifeq ($(V),1)
override V =
endif
ifeq ($(V),0)
override V = @
endif

-include conf/lab.mk
-include conf/env.mk

# Give UPAGES 20 PTSIZE
UPAGES_SIZE=$$(( 20*4096*512 ))

# Give FBUFF up to 1080p. For KSPACE mode we also
# need to align this value for 2MB pages as the
# mapping done in map_addr_early_boot cannot use
# 4K pages.
ifeq ($(shell test $(LAB) -le 6; echo $$?),0)
FBUFF_SIZE=0x1000000
else
FBUFF_SIZE=0xFD2000
endif

LABSETUP ?= ./

TOP = .

ifdef JOSLLVM

CC	:= clang -target x86_64-gnu-linux -pipe
AS	:= llvm-as
AR	:= llvm-ar
LD	:= ld.lld
OBJCOPY	:= llvm/gnu-objcopy
OBJDUMP	:= llvm-objdump
NM	:= llvm-nm

EXTRA_CFLAGS	:= $(EXTRA_CFLAGS) -Wno-self-assign -Wno-format-nonliteral -Wno-address-of-packed-member

GCC_LIB := $(shell $(CC) $(CFLAGS) -print-resource-dir)/lib/jetos/libclang_rt.builtins-x86_64.a

else

# Cross-compiler jos toolchain
#
# This Makefile will automatically use the cross-compiler toolchain
# installed as 'i386-jos-elf-*', if one exists.  If the host tools ('gcc',
# 'objdump', and so forth) compile for a 32-bit x86 ELF target, that will
# be detected as well.  If you have the right compiler toolchain installed
# using a different name, set GCCPREFIX explicitly in conf/env.mk

# try to infer the correct GCCPREFIX
ifndef GCCPREFIX
GCCPREFIX := $(shell if x86_64-jetos-elf-objdump -i 2>&1 | grep '^elf64-x86-64$$' >/dev/null 2>&1; \
	then echo 'x86_64-jetos-elf-'; \
	elif objdump -i 2>&1 | grep 'elf64-x86-64' >/dev/null 2>&1; \
	then echo ''; \
	else echo "***" 1>&2; \
	echo "*** Error: Couldn't find an x86_64-*-elf version of GCC/binutils." 1>&2; \
	echo "*** Is the directory with x86_64-jetos-elf-gcc in your PATH?" 1>&2; \
	echo "*** If your x86_64-*-elf toolchain is installed with a command" 1>&2; \
	echo "*** prefix other than 'x86_64-jetos-elf-', set your GCCPREFIX" 1>&2; \
	echo "*** environment variable to that prefix and run 'make' again." 1>&2; \
	echo "*** To turn off this error, run 'gmake GCCPREFIX= ...'." 1>&2; \
	echo "*** Perhaps you wanted to use llvm toolchain, in this case ensure" 1>&2; \
	echo "*** JOSLLVM environment variable is defined." 1>&2; \
	echo "***" 1>&2; exit 1; fi)
endif

CC	:= $(GCCPREFIX)gcc -fno-pic -pipe
AS	:= $(GCCPREFIX)as
AR	:= $(GCCPREFIX)ar
LD	:= $(GCCPREFIX)ld
OBJCOPY	:= $(GCCPREFIX)objcopy
OBJDUMP	:= $(GCCPREFIX)objdump
NM	:= $(GCCPREFIX)nm

EXTRA_CFLAGS	:= $(EXTRA_CFLAGS) -Wno-unused-but-set-variable

GCC_LIB := $(shell $(CC) $(CFLAGS) -print-libgcc-file-name)

endif

# Native commands
NCC	:= gcc $(CC_VER) -pipe
NATIVE_CFLAGS := $(CFLAGS) $(DEFS) $(LABDEFS) -I$(TOP) -MD -Wall
TAR	:= gtar
PERL	:= perl

# Try to infer the correct QEMU
ifndef QEMU
QEMU := $(shell if which qemu-system-x86_64 > /dev/null 2>&1; \
	then echo qemu-system-x86_64; exit; \
	elif which qemu-system-x86_64 > /dev/null 2>&1; \
	then echo qemu-system-x86_64; exit; \
	else \
	qemu=/Applications/Q.app/Contents/MacOS/x86_64-softmmu.app/Contents/MacOS/x86_64-softmmu; \
	if test -x $$qemu; then echo $$qemu; exit; fi; fi; \
	echo "***" 1>&2; \
	echo "*** Error: Couldn't find a working QEMU executable." 1>&2; \
	echo "*** Is the directory containing the qemu binary in your PATH" 1>&2; \
	echo "*** or have you tried setting the QEMU variable in conf/env.mk?" 1>&2; \
	echo "***" 1>&2; exit 1)
endif

# Try to generate a unique GDB port if it is not set already.
ifeq ($(GDBPORT),)
GDBPORT	:= $(shell expr `id -u` % 5000 + 25000)
endif

# Compiler flags
# -fno-builtin is required to avoid refs to undefined functions in the kernel.
CFLAGS := $(CFLAGS) $(DEFS) $(LABDEFS) -fno-builtin -I$(TOP) -MD
ifeq ($(D),1)
CFLAGS += -O0
else
# Only optimize to -O1 to discourage inlining, which complicates backtraces.
CFLAGS += -O1
endif
CFLAGS += -ffreestanding -fno-omit-frame-pointer -mno-red-zone
CFLAGS += -Wall -Wformat=2 -Wno-unused-function -Werror -g -gpubnames

# Add -fno-stack-protector if the option exists.
CFLAGS += $(shell $(CC) -fno-stack-protector -E -x c /dev/null >/dev/null 2>&1 && echo -fno-stack-protector)
CFLAGS += -DUPAGES_SIZE=$(UPAGES_SIZE)  -DFBUFF_SIZE=$(FBUFF_SIZE)
CFLAGS += $(EXTRA_CFLAGS)


KERN_SAN_CFLAGS :=
KERN_SAN_LDFLAGS :=

ifdef KASAN

CFLAGS += -DSAN_ENABLE_KASAN=1

# The definitions assume kernel base address at 0x8041600000, see kern/kernel.ld for details.
# SANITIZE_SHADOW_OFF is an offset from shadow base (SHADOW_BASE - (KERNBASE >> 3)).
# SANITIZE_SHADOW_SIZE of 32 MB allows 256 MB of addressible memory (due to byte granularity).
KERN_SAN_CFLAGS := -fsanitize=address -fsanitize-blacklist=llvm/blacklist.txt \
	-DSANITIZE_SHADOW_OFF=0x7077d40000 -DSANITIZE_SHADOW_BASE=0x8080000000 \
	-DSANITIZE_SHADOW_SIZE=0x8000000 -mllvm -asan-mapping-offset=0x7077d40000

KERN_SAN_LDFLAGS := --wrap memcpy  \
	--wrap memset  \
	--wrap memmove \
	--wrap bcopy   \
	--wrap bzero   \
	--wrap bcmp    \
	--wrap memcmp  \
	--wrap strcat  \
	--wrap strcpy  \
	--wrap strlcpy \
	--wrap strncpy \
	--wrap strlcat \
	--wrap strncat \
	--wrap strnlen \
	--wrap strlen

endif

ifdef KUBSAN

CFLAGS += -DSAN_ENABLE_KUBSAN=1

KERN_SAN_CFLAGS += -fsanitize=undefined \
	-fsanitize=implicit-integer-truncation \
	-fno-sanitize=function \
	-fno-sanitize=vptr \
	-fno-sanitize=return

endif

USER_SAN_CFLAGS :=
USER_SAN_LDFLAGS :=

ifdef UASAN

CFLAGS += -DSAN_ENABLE_UASAN=1

# The definitions assume user base address at 0x0, see user/user.ld for details.
# SANITIZE_SHADOW_SIZE 32 MB allows 256 MB of addressible memory (due to byte granularity).
# Extra page (+0x1000 to offset) avoids an optimisation via 'or' that assumes that unsigned wrap-around is impossible.
USER_SAN_CFLAGS := -fsanitize=address -fsanitize-blacklist=llvm/ublacklist.txt \
	-DSANITIZE_USER_SHADOW_OFF=0x21000000 -DSANITIZE_USER_SHADOW_BASE=0x21000000 \
	-DSANITIZE_USER_SHADOW_SIZE=0x3000000 -mllvm -asan-mapping-offset=0x21000000
# To let the kernel map the first environment we additionally expose the variables to it.
KERN_SAN_CFLAGS += -DSANITIZE_USER_SHADOW_OFF=0x21000000 \
	-DSANITIZE_USER_SHADOW_BASE=0x21000000 -DSANITIZE_USER_SHADOW_SIZE=0x3000000
USER_SAN_LDFLAGS := --wrap memcpy  \
	--wrap memset  \
	--wrap memmove \
	--wrap bcopy   \
	--wrap bzero   \
	--wrap bcmp    \
	--wrap memcmp  \
	--wrap strcat  \
	--wrap strcpy  \
	--wrap strlcpy \
	--wrap strncpy \
	--wrap strlcat \
	--wrap strncat \
	--wrap strnlen \
	--wrap strlen

endif

ifdef UUBSAN

CFLAGS += -DSAN_ENABLE_UUBSAN=1

USER_SAN_CFLAGS += -fsanitize=undefined \
	-fsanitize=implicit-integer-truncation \
	-fno-sanitize=function \
	-fno-sanitize=vptr \
	-fno-sanitize=return

endif

ifdef GRADE3_TEST
CFLAGS += -DGRADE3_TEST=$(GRADE3_TEST)
CFLAGS += -DGRADE3_FUNC=$(GRADE3_FUNC)
CFLAGS += -DGRADE3_FAIL=$(GRADE3_FAIL)
CFLAGS += -DGRADE3_PFX1=$(GRADE3_PFX1)
CFLAGS += -DGRADE3_PFX2=$(GRADE3_PFX2)
.SILENT:
endif

# Common linker flags
LDFLAGS := -m elf_x86_64 -z max-page-size=0x1000 --print-gc-sections

# Linker flags for JOS programs
ULDFLAGS := -T user/user.ld

# Lists that the */Makefrag makefile fragments will add to
OBJDIRS :=

# Make sure that 'all' is the first target
all: .git/hooks/post-checkout .git/hooks/pre-commit

# Eliminate default suffix rules
.SUFFIXES:

# Delete target files if there is an error (or make is interrupted)
.DELETE_ON_ERROR:

# make it so that no intermediate .o files are ever deleted
.PRECIOUS:  $(OBJDIR)/kern/%.o \
	   $(OBJDIR)/lib/%.o $(OBJDIR)/fs/%.o $(OBJDIR)/net/%.o \
	   $(OBJDIR)/user/%.o \
	   $(OBJDIR)/prog/%.o

KERN_CFLAGS := $(CFLAGS) -DJOS_KERNEL -DLAB=$(LAB) -mcmodel=large -m64
USER_CFLAGS := $(CFLAGS) -DLAB=$(LAB) -mcmodel=large -m64
ifeq ($(CONFIG_KSPACE),y)
KERN_CFLAGS += -DCONFIG_KSPACE
USER_CFLAGS += -DCONFIG_KSPACE -DJOS_PROG
else
USER_CFLAGS += -DJOS_USER
endif

# Update .vars.X if variable X has changed since the last make run.
#
# Rules that use variable X should depend on $(OBJDIR)/.vars.X.  If
# the variable's value has changed, this will update the vars file and
# force a rebuild of the rule that depends on it.
$(OBJDIR)/.vars.%: FORCE
	@test -f $@ || touch $@
	$(V)echo "$($*)" | cmp -s $@ || echo "$($*)" > $@
.PRECIOUS: $(OBJDIR)/.vars.%
.PHONY: FORCE


# Include Makefrags for subdirectories
include kern/Makefrag
include lib/Makefrag
ifeq ($(CONFIG_KSPACE),y)
include prog/Makefrag
else
include user/Makefrag
endif

QEMUOPTS = -hda fat:rw:$(JOS_ESP) -serial mon:stdio -gdb tcp::$(GDBPORT)
QEMUOPTS += -m 8192M

QEMUOPTS += $(shell if $(QEMU) -display none -help | grep -q '^-D '; then echo '-D qemu.log'; fi)
IMAGES = $(OVMF_FIRMWARE) $(JOS_LOADER) $(OBJDIR)/kern/kernel $(JOS_ESP)/EFI/BOOT/kernel $(JOS_ESP)/EFI/BOOT/$(JOS_BOOTER)
QEMUOPTS += -bios $(OVMF_FIRMWARE)
# QEMUOPTS += -debugcon file:$(UEFIDIR)/debug.log -global isa-debugcon.iobase=0x402

define POST_CHECKOUT
#!/bin/sh -x
make clean
endef
export POST_CHECKOUT

define PRE_COMMIT
#!/bin/sh

if git diff --cached --name-only --diff-filter=DMR | grep -q grade
then
   echo "FAIL: Don't change grade files."
   exit 1
else
   exit 0
fi
endef
export PRE_COMMIT

.git/hooks/post-checkout:
	@echo "$$POST_CHECKOUT" > $@
	@chmod +x $@

.git/hooks/pre-commit:
	@echo "$$PRE_COMMIT" > $@
	@chmod +x $@

.gdbinit: .gdbinit.tmpl
	sed "s/localhost:1234/localhost:$(GDBPORT)/" < $^ > $@

$(OVMF_FIRMWARE):
	LoaderPkg/build_ovmf.sh

$(JOS_LOADER): $(OVMF_FIRMWARE) $(JOS_LOADER_DEPS)
	LoaderPkg/build_ldr.sh

$(JOS_ESP)/EFI/BOOT/kernel: $(OBJDIR)/kern/kernel
	mkdir -p $(JOS_ESP)/EFI/BOOT
	cp $(OBJDIR)/kern/kernel $(JOS_ESP)/EFI/BOOT/kernel

$(JOS_ESP)/EFI/BOOT/$(JOS_BOOTER): $(JOS_LOADER)
	mkdir -p $(JOS_ESP)/EFI/BOOT
	cp $(JOS_LOADER) $(JOS_ESP)/EFI/BOOT/$(JOS_BOOTER)
	# cp $(JOSLOADER)/Loader.debug $(UEFIDIR)/EFI/BOOT/BOOTIA32.DEBUG

pre-qemu: $(IMAGES) .gdbinit

qemu: pre-qemu
	$(QEMU) $(QEMUOPTS)

qemu-oscheck: $(IMAGES) pre-qemu
	$(QEMU) $(QEMUOPTS) -oscourse

qemu-oscheck-nox-gdb: $(IMAGES) pre-qemu
	@echo "***"
	@echo "*** Now run 'gdb'." 1>&2
	@echo "***"
	$(QEMU) -nographic $(QEMUOPTS) -S -oscourse

qemu-nox: $(IMAGES) pre-qemu
	@echo "***"
	@echo "*** Use Ctrl-a x to exit qemu"
	@echo "***"
	$(QEMU) -display none $(QEMUOPTS)

qemu-gdb: $(IMAGES) pre-qemu
	@echo "***"
	@echo "*** Now run 'gdb'." 1>&2
	@echo "***"
	$(QEMU) $(QEMUOPTS) -S

qemu-nox-gdb: $(IMAGES) pre-qemu
	@echo "***"
	@echo "*** Now run 'gdb'." 1>&2
	@echo "***"
	$(QEMU) -display none $(QEMUOPTS) -S

print-qemu:
	@echo $(QEMU)

print-gdbport:
	@echo $(GDBPORT)

format:
	@find . -name *.[ch] -not -path "./LoaderPkg/*" -exec clang-format -i {} \;

# For deleting the build
clean:
	rm -rf $(OBJDIR) .gdbinit jos.in qemu.log $(JOS_LOADER) $(JOS_LOADER_BUILD) $(JOS_ESP)

realclean: clean
	rm -rf lab$(LAB).tar.gz \
		jos.out $(wildcard jos.out.*) \
		qemu.pcap $(wildcard qemu.pcap.*)

distclean: realclean
	rm -f .git/hooks/pre-commit .git/hooks/post-checkout $(OVMF_FIRMWARE) LoaderPkg/efibuild.sh

ifneq ($(V),@)
GRADEFLAGS += -v
endif

grade:
	@echo $(MAKE) clean
	@$(MAKE) clean || \
	  (echo "'make clean' failed.  HINT: Do you have another running instance of JOS?" && exit 1)
	ARCHS=X64 ./grade-lab$(LAB) $(GRADEFLAGS)
	@echo $(MAKE) clean
	@$(MAKE) clean || \
	  (echo "'make clean' failed.  HINT: Do you have another running instance of JOS?" && exit 1)
	ARCHS=IA32 ./grade-lab$(LAB) $(GRADEFLAGS)

# For test runs

prep-%:
	$(V)$(MAKE) "INIT_CFLAGS=${INIT_CFLAGS} -DTEST=`case $* in *_*) echo $*;; *) echo user_$*;; esac`" $(IMAGES)

run-%-nox-gdb: prep-% pre-qemu
	$(QEMU) -display none $(QEMUOPTS) -S

run-%-gdb: prep-% pre-qemu
	$(QEMU) $(QEMUOPTS) -S

run-%-nox: prep-% pre-qemu
	$(QEMU) -display none $(QEMUOPTS)

run-%: prep-% pre-qemu
	$(QEMU) $(QEMUOPTS)

# This magic automatically generates makefile dependencies
# for header files included from C source files we compile,
# and keeps those dependencies up-to-date every time we recompile.
# See 'mergedep.pl' for more information.
$(OBJDIR)/.deps: $(foreach dir, $(OBJDIRS), $(wildcard $(OBJDIR)/$(dir)/*.d))
	@mkdir -p $(@D)
	@$(PERL) mergedep.pl $@ $^

-include $(OBJDIR)/.deps

always:
	@:

.PHONY: all always clean realclean distclean grade
