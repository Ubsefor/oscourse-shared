
obj/user/signedoverflow:     file format elf64-x86-64


Disassembly of section .text:

0000000000800000 <__text_start>:
.text
.globl _start
_start:
  // See if we were started with arguments on the stack
#ifndef CONFIG_KSPACE
  movabs $USTACKTOP, %rax
  800000:	48 b8 00 b0 ff ff 7f 	movabs $0x7fffffb000,%rax
  800007:	00 00 00 
  cmpq %rax,%rsp
  80000a:	48 39 c4             	cmp    %rax,%rsp
  jne args_exist
  80000d:	75 04                	jne    800013 <args_exist>

  // If not, push dummy argc/argv arguments.
  // This happens when we are loaded by the kernel,
  // because the kernel does not know about passing arguments.
  // Marking argc and argv as zero.
  pushq $0
  80000f:	6a 00                	pushq  $0x0
  pushq $0
  800011:	6a 00                	pushq  $0x0

0000000000800013 <args_exist>:

args_exist:
  movq 8(%rsp), %rsi
  800013:	48 8b 74 24 08       	mov    0x8(%rsp),%rsi
  movq (%rsp), %rdi
  800018:	48 8b 3c 24          	mov    (%rsp),%rdi
  movq $0, %rbp
  80001c:	48 c7 c5 00 00 00 00 	mov    $0x0,%rbp
  call libmain
  800023:	e8 28 00 00 00       	callq  800050 <libmain>
1:
  jmp 1b
  800028:	eb fe                	jmp    800028 <args_exist+0x15>

000000000080002a <umain>:
//Test for UBSAN support - signed integer overflow

#include <inc/lib.h>

void
umain(int argc, char **argv) {
  80002a:	55                   	push   %rbp
  80002b:	48 89 e5             	mov    %rsp,%rbp
  //Creating a 32-bit integer variable with the maximum integer value it can contain
  int a = 2147483647;
  //Trying to add 1 to the "a" variable and print its contents (which causes undefined behavior).
  //The "cprintf" function is sanitized by UBSAN because lib/Makefrag accesses the USER_SAN_CFLAGS variable.
  cprintf("%d\n", a + 1);
  80002e:	be 00 00 00 80       	mov    $0x80000000,%esi
  800033:	48 bf 00 14 80 00 00 	movabs $0x801400,%rdi
  80003a:	00 00 00 
  80003d:	b8 00 00 00 00       	mov    $0x0,%eax
  800042:	48 ba cf 01 80 00 00 	movabs $0x8001cf,%rdx
  800049:	00 00 00 
  80004c:	ff d2                	callq  *%rdx
}
  80004e:	5d                   	pop    %rbp
  80004f:	c3                   	retq   

0000000000800050 <libmain>:
#ifdef JOS_PROG
void (*volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv) {
  800050:	55                   	push   %rbp
  800051:	48 89 e5             	mov    %rsp,%rbp
  800054:	41 56                	push   %r14
  800056:	41 55                	push   %r13
  800058:	41 54                	push   %r12
  80005a:	53                   	push   %rbx
  80005b:	41 89 fd             	mov    %edi,%r13d
  80005e:	49 89 f6             	mov    %rsi,%r14
  // Perform global constructor initialisation (e.g. asan)
  // This must be done as early as possible
  extern void (*__ctors_start)();
  extern void (*__ctors_end)();
  void (**ctor)() = &__ctors_start;
  while (ctor < &__ctors_end) {
  800061:	48 ba 08 20 80 00 00 	movabs $0x802008,%rdx
  800068:	00 00 00 
  80006b:	48 b8 08 20 80 00 00 	movabs $0x802008,%rax
  800072:	00 00 00 
  800075:	48 39 c2             	cmp    %rax,%rdx
  800078:	73 23                	jae    80009d <libmain+0x4d>
  80007a:	48 89 d3             	mov    %rdx,%rbx
  80007d:	48 8d 40 ff          	lea    -0x1(%rax),%rax
  800081:	48 29 d0             	sub    %rdx,%rax
  800084:	48 c1 e8 03          	shr    $0x3,%rax
  800088:	4c 8d 64 c2 08       	lea    0x8(%rdx,%rax,8),%r12
    (*ctor)();
  80008d:	b8 00 00 00 00       	mov    $0x0,%eax
  800092:	ff 13                	callq  *(%rbx)
    ctor++;
  800094:	48 83 c3 08          	add    $0x8,%rbx
  while (ctor < &__ctors_end) {
  800098:	4c 39 e3             	cmp    %r12,%rbx
  80009b:	75 f0                	jne    80008d <libmain+0x3d>
  }

  // set thisenv to point at our Env structure in envs[].
  
  // LAB 8 code
  thisenv = &envs[ENVX(sys_getenvid())];
  80009d:	48 b8 61 10 80 00 00 	movabs $0x801061,%rax
  8000a4:	00 00 00 
  8000a7:	ff d0                	callq  *%rax
  8000a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ae:	48 8d 04 c0          	lea    (%rax,%rax,8),%rax
  8000b2:	48 c1 e0 05          	shl    $0x5,%rax
  8000b6:	48 ba 00 e0 22 3c 80 	movabs $0x803c22e000,%rdx
  8000bd:	00 00 00 
  8000c0:	48 01 d0             	add    %rdx,%rax
  8000c3:	48 a3 08 20 80 00 00 	movabs %rax,0x802008
  8000ca:	00 00 00 
  // LAB 8 code end

  // save the name of the program so that panic() can use it
  if (argc > 0)
  8000cd:	45 85 ed             	test   %r13d,%r13d
  8000d0:	7e 0d                	jle    8000df <libmain+0x8f>
    binaryname = argv[0];
  8000d2:	49 8b 06             	mov    (%r14),%rax
  8000d5:	48 a3 00 20 80 00 00 	movabs %rax,0x802000
  8000dc:	00 00 00 

  // call user main routine
  umain(argc, argv);
  8000df:	4c 89 f6             	mov    %r14,%rsi
  8000e2:	44 89 ef             	mov    %r13d,%edi
  8000e5:	48 b8 2a 00 80 00 00 	movabs $0x80002a,%rax
  8000ec:	00 00 00 
  8000ef:	ff d0                	callq  *%rax

  // exit
#ifdef JOS_PROG
  sys_exit();
#else
  exit();
  8000f1:	48 b8 06 01 80 00 00 	movabs $0x800106,%rax
  8000f8:	00 00 00 
  8000fb:	ff d0                	callq  *%rax
#endif
}
  8000fd:	5b                   	pop    %rbx
  8000fe:	41 5c                	pop    %r12
  800100:	41 5d                	pop    %r13
  800102:	41 5e                	pop    %r14
  800104:	5d                   	pop    %rbp
  800105:	c3                   	retq   

0000000000800106 <exit>:

#include <inc/lib.h>

void
exit(void) {
  800106:	55                   	push   %rbp
  800107:	48 89 e5             	mov    %rsp,%rbp
  sys_env_destroy(0);
  80010a:	bf 00 00 00 00       	mov    $0x0,%edi
  80010f:	48 b8 01 10 80 00 00 	movabs $0x801001,%rax
  800116:	00 00 00 
  800119:	ff d0                	callq  *%rax
}
  80011b:	5d                   	pop    %rbp
  80011c:	c3                   	retq   

000000000080011d <putch>:
  int cnt; // total bytes printed so far
  char buf[256];
};

static void
putch(int ch, struct printbuf *b) {
  80011d:	55                   	push   %rbp
  80011e:	48 89 e5             	mov    %rsp,%rbp
  800121:	53                   	push   %rbx
  800122:	48 83 ec 08          	sub    $0x8,%rsp
  800126:	48 89 f3             	mov    %rsi,%rbx
  b->buf[b->idx++] = ch;
  800129:	8b 06                	mov    (%rsi),%eax
  80012b:	8d 50 01             	lea    0x1(%rax),%edx
  80012e:	89 16                	mov    %edx,(%rsi)
  800130:	48 98                	cltq   
  800132:	40 88 7c 06 08       	mov    %dil,0x8(%rsi,%rax,1)
  if (b->idx == 256 - 1) {
  800137:	81 fa ff 00 00 00    	cmp    $0xff,%edx
  80013d:	74 0b                	je     80014a <putch+0x2d>
    sys_cputs(b->buf, b->idx);
    b->idx = 0;
  }
  b->cnt++;
  80013f:	83 43 04 01          	addl   $0x1,0x4(%rbx)
}
  800143:	48 83 c4 08          	add    $0x8,%rsp
  800147:	5b                   	pop    %rbx
  800148:	5d                   	pop    %rbp
  800149:	c3                   	retq   
    sys_cputs(b->buf, b->idx);
  80014a:	48 8d 7e 08          	lea    0x8(%rsi),%rdi
  80014e:	be ff 00 00 00       	mov    $0xff,%esi
  800153:	48 b8 c3 0f 80 00 00 	movabs $0x800fc3,%rax
  80015a:	00 00 00 
  80015d:	ff d0                	callq  *%rax
    b->idx = 0;
  80015f:	c7 03 00 00 00 00    	movl   $0x0,(%rbx)
  800165:	eb d8                	jmp    80013f <putch+0x22>

0000000000800167 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap) {
  800167:	55                   	push   %rbp
  800168:	48 89 e5             	mov    %rsp,%rbp
  80016b:	48 81 ec 10 01 00 00 	sub    $0x110,%rsp
  800172:	48 89 fa             	mov    %rdi,%rdx
  800175:	48 89 f1             	mov    %rsi,%rcx
  struct printbuf b;

  b.idx = 0;
  800178:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%rbp)
  80017f:	00 00 00 
  b.cnt = 0;
  800182:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%rbp)
  800189:	00 00 00 
  vprintfmt((void *)putch, &b, fmt, ap);
  80018c:	48 8d b5 f0 fe ff ff 	lea    -0x110(%rbp),%rsi
  800193:	48 bf 1d 01 80 00 00 	movabs $0x80011d,%rdi
  80019a:	00 00 00 
  80019d:	48 b8 8d 03 80 00 00 	movabs $0x80038d,%rax
  8001a4:	00 00 00 
  8001a7:	ff d0                	callq  *%rax
  sys_cputs(b.buf, b.idx);
  8001a9:	48 63 b5 f0 fe ff ff 	movslq -0x110(%rbp),%rsi
  8001b0:	48 8d 85 f0 fe ff ff 	lea    -0x110(%rbp),%rax
  8001b7:	48 8d 78 08          	lea    0x8(%rax),%rdi
  8001bb:	48 b8 c3 0f 80 00 00 	movabs $0x800fc3,%rax
  8001c2:	00 00 00 
  8001c5:	ff d0                	callq  *%rax

  return b.cnt;
}
  8001c7:	8b 85 f4 fe ff ff    	mov    -0x10c(%rbp),%eax
  8001cd:	c9                   	leaveq 
  8001ce:	c3                   	retq   

00000000008001cf <cprintf>:

int
cprintf(const char *fmt, ...) {
  8001cf:	55                   	push   %rbp
  8001d0:	48 89 e5             	mov    %rsp,%rbp
  8001d3:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  8001da:	48 89 b5 58 ff ff ff 	mov    %rsi,-0xa8(%rbp)
  8001e1:	48 89 95 60 ff ff ff 	mov    %rdx,-0xa0(%rbp)
  8001e8:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  8001ef:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  8001f6:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  8001fd:	84 c0                	test   %al,%al
  8001ff:	74 20                	je     800221 <cprintf+0x52>
  800201:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800205:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800209:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  80020d:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800211:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800215:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800219:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  80021d:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int cnt;

  va_start(ap, fmt);
  800221:	c7 85 38 ff ff ff 08 	movl   $0x8,-0xc8(%rbp)
  800228:	00 00 00 
  80022b:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800232:	00 00 00 
  800235:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800239:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800240:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800247:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  cnt = vcprintf(fmt, ap);
  80024e:	48 8d b5 38 ff ff ff 	lea    -0xc8(%rbp),%rsi
  800255:	48 b8 67 01 80 00 00 	movabs $0x800167,%rax
  80025c:	00 00 00 
  80025f:	ff d0                	callq  *%rax
  va_end(ap);

  return cnt;
}
  800261:	c9                   	leaveq 
  800262:	c3                   	retq   

0000000000800263 <printnum>:
 * Print a number (base <= 16) in reverse order,
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
         unsigned long long num, unsigned base, int width, int padc) {
  800263:	55                   	push   %rbp
  800264:	48 89 e5             	mov    %rsp,%rbp
  800267:	41 57                	push   %r15
  800269:	41 56                	push   %r14
  80026b:	41 55                	push   %r13
  80026d:	41 54                	push   %r12
  80026f:	53                   	push   %rbx
  800270:	48 83 ec 18          	sub    $0x18,%rsp
  800274:	49 89 fc             	mov    %rdi,%r12
  800277:	49 89 f5             	mov    %rsi,%r13
  80027a:	48 89 55 c8          	mov    %rdx,-0x38(%rbp)
  80027e:	45 89 ce             	mov    %r9d,%r14d
  // first recursively print all preceding (more significant) digits
  if (num >= base) {
  800281:	41 89 cf             	mov    %ecx,%r15d
  800284:	49 39 d7             	cmp    %rdx,%r15
  800287:	76 45                	jbe    8002ce <printnum+0x6b>
    printnum(putch, putdat, num / base, base, width - 1, padc);
  } else {
    // print any needed pad characters before first digit
    while (--width > 0)
  800289:	41 8d 58 ff          	lea    -0x1(%r8),%ebx
  80028d:	85 db                	test   %ebx,%ebx
  80028f:	7e 0e                	jle    80029f <printnum+0x3c>
      putch(padc, putdat);
  800291:	4c 89 ee             	mov    %r13,%rsi
  800294:	44 89 f7             	mov    %r14d,%edi
  800297:	41 ff d4             	callq  *%r12
    while (--width > 0)
  80029a:	83 eb 01             	sub    $0x1,%ebx
  80029d:	75 f2                	jne    800291 <printnum+0x2e>
  }

  // then print this (the least significant) digit
  putch("0123456789abcdef"[num % base], putdat);
  80029f:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a8:	49 f7 f7             	div    %r15
  8002ab:	48 b8 0e 14 80 00 00 	movabs $0x80140e,%rax
  8002b2:	00 00 00 
  8002b5:	0f be 3c 10          	movsbl (%rax,%rdx,1),%edi
  8002b9:	4c 89 ee             	mov    %r13,%rsi
  8002bc:	41 ff d4             	callq  *%r12
}
  8002bf:	48 83 c4 18          	add    $0x18,%rsp
  8002c3:	5b                   	pop    %rbx
  8002c4:	41 5c                	pop    %r12
  8002c6:	41 5d                	pop    %r13
  8002c8:	41 5e                	pop    %r14
  8002ca:	41 5f                	pop    %r15
  8002cc:	5d                   	pop    %rbp
  8002cd:	c3                   	retq   
    printnum(putch, putdat, num / base, base, width - 1, padc);
  8002ce:	48 8b 45 c8          	mov    -0x38(%rbp),%rax
  8002d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d7:	49 f7 f7             	div    %r15
  8002da:	45 8d 40 ff          	lea    -0x1(%r8),%r8d
  8002de:	48 89 c2             	mov    %rax,%rdx
  8002e1:	48 b8 63 02 80 00 00 	movabs $0x800263,%rax
  8002e8:	00 00 00 
  8002eb:	ff d0                	callq  *%rax
  8002ed:	eb b0                	jmp    80029f <printnum+0x3c>

00000000008002ef <sprintputch>:
  int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b) {
  b->cnt++;
  8002ef:	83 46 10 01          	addl   $0x1,0x10(%rsi)
  if (b->buf < b->ebuf)
  8002f3:	48 8b 06             	mov    (%rsi),%rax
  8002f6:	48 3b 46 08          	cmp    0x8(%rsi),%rax
  8002fa:	73 0a                	jae    800306 <sprintputch+0x17>
    *b->buf++ = ch;
  8002fc:	48 8d 50 01          	lea    0x1(%rax),%rdx
  800300:	48 89 16             	mov    %rdx,(%rsi)
  800303:	40 88 38             	mov    %dil,(%rax)
}
  800306:	c3                   	retq   

0000000000800307 <printfmt>:
printfmt(void (*putch)(int, void *), void *putdat, const char *fmt, ...) {
  800307:	55                   	push   %rbp
  800308:	48 89 e5             	mov    %rsp,%rbp
  80030b:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800312:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800319:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800320:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800327:	84 c0                	test   %al,%al
  800329:	74 20                	je     80034b <printfmt+0x44>
  80032b:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  80032f:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800333:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800337:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  80033b:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  80033f:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800343:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800347:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_start(ap, fmt);
  80034b:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800352:	00 00 00 
  800355:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  80035c:	00 00 00 
  80035f:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800363:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  80036a:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800371:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  vprintfmt(putch, putdat, fmt, ap);
  800378:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  80037f:	48 b8 8d 03 80 00 00 	movabs $0x80038d,%rax
  800386:	00 00 00 
  800389:	ff d0                	callq  *%rax
}
  80038b:	c9                   	leaveq 
  80038c:	c3                   	retq   

000000000080038d <vprintfmt>:
vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt, va_list ap) {
  80038d:	55                   	push   %rbp
  80038e:	48 89 e5             	mov    %rsp,%rbp
  800391:	41 57                	push   %r15
  800393:	41 56                	push   %r14
  800395:	41 55                	push   %r13
  800397:	41 54                	push   %r12
  800399:	53                   	push   %rbx
  80039a:	48 83 ec 48          	sub    $0x48,%rsp
  80039e:	49 89 fd             	mov    %rdi,%r13
  8003a1:	49 89 f7             	mov    %rsi,%r15
  8003a4:	49 89 d6             	mov    %rdx,%r14
  va_copy(aq, ap);
  8003a7:	f3 0f 6f 01          	movdqu (%rcx),%xmm0
  8003ab:	0f 11 45 b8          	movups %xmm0,-0x48(%rbp)
  8003af:	48 8b 41 10          	mov    0x10(%rcx),%rax
  8003b3:	48 89 45 c8          	mov    %rax,-0x38(%rbp)
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003b7:	49 8d 5e 01          	lea    0x1(%r14),%rbx
  8003bb:	41 0f b6 3e          	movzbl (%r14),%edi
  8003bf:	83 ff 25             	cmp    $0x25,%edi
  8003c2:	74 18                	je     8003dc <vprintfmt+0x4f>
      if (ch == '\0')
  8003c4:	85 ff                	test   %edi,%edi
  8003c6:	0f 84 8c 06 00 00    	je     800a58 <vprintfmt+0x6cb>
      putch(ch, putdat);
  8003cc:	4c 89 fe             	mov    %r15,%rsi
  8003cf:	41 ff d5             	callq  *%r13
    while ((ch = *(unsigned char *)fmt++) != '%') {
  8003d2:	49 89 de             	mov    %rbx,%r14
  8003d5:	eb e0                	jmp    8003b7 <vprintfmt+0x2a>
        for (fmt--; fmt[-1] != '%'; fmt--)
  8003d7:	49 89 de             	mov    %rbx,%r14
  8003da:	eb db                	jmp    8003b7 <vprintfmt+0x2a>
        precision = va_arg(aq, int);
  8003dc:	4c 8b 55 c8          	mov    -0x38(%rbp),%r10
    padc      = ' ';
  8003e0:	c6 45 a0 20          	movb   $0x20,-0x60(%rbp)
    altflag   = 0;
  8003e4:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%rbp)
    precision = -1;
  8003eb:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
    width     = -1;
  8003f1:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
    lflag     = 0;
  8003f5:	b9 00 00 00 00       	mov    $0x0,%ecx
        altflag = 1;
  8003fa:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800400:	41 b8 00 00 00 00    	mov    $0x0,%r8d
        padc = '0';
  800406:	bf 30 00 00 00       	mov    $0x30,%edi
        padc = '-';
  80040b:	be 2d 00 00 00       	mov    $0x2d,%esi
    switch (ch = *(unsigned char *)fmt++) {
  800410:	4c 8d 73 01          	lea    0x1(%rbx),%r14
  800414:	0f b6 13             	movzbl (%rbx),%edx
  800417:	8d 42 dd             	lea    -0x23(%rdx),%eax
  80041a:	3c 55                	cmp    $0x55,%al
  80041c:	0f 87 8b 05 00 00    	ja     8009ad <vprintfmt+0x620>
  800422:	0f b6 c0             	movzbl %al,%eax
  800425:	49 bb e0 14 80 00 00 	movabs $0x8014e0,%r11
  80042c:	00 00 00 
  80042f:	41 ff 24 c3          	jmpq   *(%r11,%rax,8)
  800433:	4c 89 f3             	mov    %r14,%rbx
        padc = '-';
  800436:	40 88 75 a0          	mov    %sil,-0x60(%rbp)
  80043a:	eb d4                	jmp    800410 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  80043c:	4c 89 f3             	mov    %r14,%rbx
        padc = '0';
  80043f:	40 88 7d a0          	mov    %dil,-0x60(%rbp)
  800443:	eb cb                	jmp    800410 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  800445:	0f b6 d2             	movzbl %dl,%edx
          precision = precision * 10 + ch - '0';
  800448:	44 8d 62 d0          	lea    -0x30(%rdx),%r12d
          ch        = *fmt;
  80044c:	0f be 43 01          	movsbl 0x1(%rbx),%eax
          if (ch < '0' || ch > '9')
  800450:	8d 50 d0             	lea    -0x30(%rax),%edx
  800453:	83 fa 09             	cmp    $0x9,%edx
  800456:	77 7e                	ja     8004d6 <vprintfmt+0x149>
        for (precision = 0;; ++fmt) {
  800458:	49 83 c6 01          	add    $0x1,%r14
          precision = precision * 10 + ch - '0';
  80045c:	43 8d 14 a4          	lea    (%r12,%r12,4),%edx
  800460:	44 8d 64 50 d0       	lea    -0x30(%rax,%rdx,2),%r12d
          ch        = *fmt;
  800465:	41 0f be 06          	movsbl (%r14),%eax
          if (ch < '0' || ch > '9')
  800469:	8d 50 d0             	lea    -0x30(%rax),%edx
  80046c:	83 fa 09             	cmp    $0x9,%edx
  80046f:	76 e7                	jbe    800458 <vprintfmt+0xcb>
        for (precision = 0;; ++fmt) {
  800471:	4c 89 f3             	mov    %r14,%rbx
  800474:	eb 19                	jmp    80048f <vprintfmt+0x102>
        precision = va_arg(aq, int);
  800476:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800479:	83 f8 2f             	cmp    $0x2f,%eax
  80047c:	77 2a                	ja     8004a8 <vprintfmt+0x11b>
  80047e:	89 c2                	mov    %eax,%edx
  800480:	4c 01 d2             	add    %r10,%rdx
  800483:	83 c0 08             	add    $0x8,%eax
  800486:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800489:	44 8b 22             	mov    (%rdx),%r12d
    switch (ch = *(unsigned char *)fmt++) {
  80048c:	4c 89 f3             	mov    %r14,%rbx
        if (width < 0)
  80048f:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  800493:	0f 89 77 ff ff ff    	jns    800410 <vprintfmt+0x83>
          width = precision, precision = -1;
  800499:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  80049d:	41 bc ff ff ff ff    	mov    $0xffffffff,%r12d
  8004a3:	e9 68 ff ff ff       	jmpq   800410 <vprintfmt+0x83>
        precision = va_arg(aq, int);
  8004a8:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8004ac:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8004b0:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8004b4:	eb d3                	jmp    800489 <vprintfmt+0xfc>
        if (width < 0)
  8004b6:	8b 45 ac             	mov    -0x54(%rbp),%eax
  8004b9:	85 c0                	test   %eax,%eax
  8004bb:	41 0f 48 c0          	cmovs  %r8d,%eax
  8004bf:	89 45 ac             	mov    %eax,-0x54(%rbp)
    switch (ch = *(unsigned char *)fmt++) {
  8004c2:	4c 89 f3             	mov    %r14,%rbx
  8004c5:	e9 46 ff ff ff       	jmpq   800410 <vprintfmt+0x83>
  8004ca:	4c 89 f3             	mov    %r14,%rbx
        altflag = 1;
  8004cd:	44 89 4d a8          	mov    %r9d,-0x58(%rbp)
        goto reswitch;
  8004d1:	e9 3a ff ff ff       	jmpq   800410 <vprintfmt+0x83>
    switch (ch = *(unsigned char *)fmt++) {
  8004d6:	4c 89 f3             	mov    %r14,%rbx
  8004d9:	eb b4                	jmp    80048f <vprintfmt+0x102>
        lflag++;
  8004db:	83 c1 01             	add    $0x1,%ecx
    switch (ch = *(unsigned char *)fmt++) {
  8004de:	4c 89 f3             	mov    %r14,%rbx
        goto reswitch;
  8004e1:	e9 2a ff ff ff       	jmpq   800410 <vprintfmt+0x83>
        putch(va_arg(aq, int), putdat);
  8004e6:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8004e9:	83 f8 2f             	cmp    $0x2f,%eax
  8004ec:	77 19                	ja     800507 <vprintfmt+0x17a>
  8004ee:	89 c2                	mov    %eax,%edx
  8004f0:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8004f4:	83 c0 08             	add    $0x8,%eax
  8004f7:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8004fa:	4c 89 fe             	mov    %r15,%rsi
  8004fd:	8b 3a                	mov    (%rdx),%edi
  8004ff:	41 ff d5             	callq  *%r13
        break;
  800502:	e9 b0 fe ff ff       	jmpq   8003b7 <vprintfmt+0x2a>
        putch(va_arg(aq, int), putdat);
  800507:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80050b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80050f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800513:	eb e5                	jmp    8004fa <vprintfmt+0x16d>
        err = va_arg(aq, int);
  800515:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800518:	83 f8 2f             	cmp    $0x2f,%eax
  80051b:	77 5b                	ja     800578 <vprintfmt+0x1eb>
  80051d:	89 c2                	mov    %eax,%edx
  80051f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800523:	83 c0 08             	add    $0x8,%eax
  800526:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800529:	8b 0a                	mov    (%rdx),%ecx
        if (err < 0)
  80052b:	89 c8                	mov    %ecx,%eax
  80052d:	c1 f8 1f             	sar    $0x1f,%eax
  800530:	31 c1                	xor    %eax,%ecx
  800532:	29 c1                	sub    %eax,%ecx
        if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800534:	83 f9 0b             	cmp    $0xb,%ecx
  800537:	7f 4d                	jg     800586 <vprintfmt+0x1f9>
  800539:	48 63 c1             	movslq %ecx,%rax
  80053c:	48 ba a0 17 80 00 00 	movabs $0x8017a0,%rdx
  800543:	00 00 00 
  800546:	48 8b 04 c2          	mov    (%rdx,%rax,8),%rax
  80054a:	48 85 c0             	test   %rax,%rax
  80054d:	74 37                	je     800586 <vprintfmt+0x1f9>
          printfmt(putch, putdat, "%s", p);
  80054f:	48 89 c1             	mov    %rax,%rcx
  800552:	48 ba 2f 14 80 00 00 	movabs $0x80142f,%rdx
  800559:	00 00 00 
  80055c:	4c 89 fe             	mov    %r15,%rsi
  80055f:	4c 89 ef             	mov    %r13,%rdi
  800562:	b8 00 00 00 00       	mov    $0x0,%eax
  800567:	48 bb 07 03 80 00 00 	movabs $0x800307,%rbx
  80056e:	00 00 00 
  800571:	ff d3                	callq  *%rbx
  800573:	e9 3f fe ff ff       	jmpq   8003b7 <vprintfmt+0x2a>
        err = va_arg(aq, int);
  800578:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80057c:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800580:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800584:	eb a3                	jmp    800529 <vprintfmt+0x19c>
          printfmt(putch, putdat, "error %d", err);
  800586:	48 ba 26 14 80 00 00 	movabs $0x801426,%rdx
  80058d:	00 00 00 
  800590:	4c 89 fe             	mov    %r15,%rsi
  800593:	4c 89 ef             	mov    %r13,%rdi
  800596:	b8 00 00 00 00       	mov    $0x0,%eax
  80059b:	48 bb 07 03 80 00 00 	movabs $0x800307,%rbx
  8005a2:	00 00 00 
  8005a5:	ff d3                	callq  *%rbx
  8005a7:	e9 0b fe ff ff       	jmpq   8003b7 <vprintfmt+0x2a>
        if ((p = va_arg(aq, char *)) == NULL)
  8005ac:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8005af:	83 f8 2f             	cmp    $0x2f,%eax
  8005b2:	77 4b                	ja     8005ff <vprintfmt+0x272>
  8005b4:	89 c2                	mov    %eax,%edx
  8005b6:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8005ba:	83 c0 08             	add    $0x8,%eax
  8005bd:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8005c0:	48 8b 02             	mov    (%rdx),%rax
  8005c3:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  8005c7:	48 85 c0             	test   %rax,%rax
  8005ca:	0f 84 05 04 00 00    	je     8009d5 <vprintfmt+0x648>
        if (width > 0 && padc != '-')
  8005d0:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8005d4:	7e 06                	jle    8005dc <vprintfmt+0x24f>
  8005d6:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8005da:	75 31                	jne    80060d <vprintfmt+0x280>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005dc:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  8005e0:	48 8d 58 01          	lea    0x1(%rax),%rbx
  8005e4:	0f b6 00             	movzbl (%rax),%eax
  8005e7:	0f be f8             	movsbl %al,%edi
  8005ea:	85 ff                	test   %edi,%edi
  8005ec:	0f 84 c3 00 00 00    	je     8006b5 <vprintfmt+0x328>
  8005f2:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8005f6:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8005fa:	e9 85 00 00 00       	jmpq   800684 <vprintfmt+0x2f7>
        if ((p = va_arg(aq, char *)) == NULL)
  8005ff:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800603:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800607:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80060b:	eb b3                	jmp    8005c0 <vprintfmt+0x233>
          for (width -= strnlen(p, precision); width > 0; width--)
  80060d:	49 63 f4             	movslq %r12d,%rsi
  800610:	48 89 c7             	mov    %rax,%rdi
  800613:	48 b8 64 0b 80 00 00 	movabs $0x800b64,%rax
  80061a:	00 00 00 
  80061d:	ff d0                	callq  *%rax
  80061f:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800622:	8b 75 ac             	mov    -0x54(%rbp),%esi
  800625:	85 f6                	test   %esi,%esi
  800627:	7e 22                	jle    80064b <vprintfmt+0x2be>
            putch(padc, putdat);
  800629:	0f be 5d a0          	movsbl -0x60(%rbp),%ebx
  80062d:	44 89 65 a0          	mov    %r12d,-0x60(%rbp)
  800631:	44 8b 65 ac          	mov    -0x54(%rbp),%r12d
  800635:	4c 89 fe             	mov    %r15,%rsi
  800638:	89 df                	mov    %ebx,%edi
  80063a:	41 ff d5             	callq  *%r13
          for (width -= strnlen(p, precision); width > 0; width--)
  80063d:	41 83 ec 01          	sub    $0x1,%r12d
  800641:	75 f2                	jne    800635 <vprintfmt+0x2a8>
  800643:	44 89 65 ac          	mov    %r12d,-0x54(%rbp)
  800647:	44 8b 65 a0          	mov    -0x60(%rbp),%r12d
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80064b:	48 8b 45 98          	mov    -0x68(%rbp),%rax
  80064f:	48 8d 58 01          	lea    0x1(%rax),%rbx
  800653:	0f b6 00             	movzbl (%rax),%eax
  800656:	0f be f8             	movsbl %al,%edi
  800659:	85 ff                	test   %edi,%edi
  80065b:	0f 84 56 fd ff ff    	je     8003b7 <vprintfmt+0x2a>
  800661:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800665:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800669:	eb 19                	jmp    800684 <vprintfmt+0x2f7>
            putch(ch, putdat);
  80066b:	4c 89 fe             	mov    %r15,%rsi
  80066e:	41 ff d5             	callq  *%r13
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800671:	41 83 ee 01          	sub    $0x1,%r14d
  800675:	48 83 c3 01          	add    $0x1,%rbx
  800679:	0f b6 43 ff          	movzbl -0x1(%rbx),%eax
  80067d:	0f be f8             	movsbl %al,%edi
  800680:	85 ff                	test   %edi,%edi
  800682:	74 29                	je     8006ad <vprintfmt+0x320>
  800684:	45 85 e4             	test   %r12d,%r12d
  800687:	78 06                	js     80068f <vprintfmt+0x302>
  800689:	41 83 ec 01          	sub    $0x1,%r12d
  80068d:	78 48                	js     8006d7 <vprintfmt+0x34a>
          if (altflag && (ch < ' ' || ch > '~'))
  80068f:	83 7d a8 00          	cmpl   $0x0,-0x58(%rbp)
  800693:	74 d6                	je     80066b <vprintfmt+0x2de>
  800695:	0f be c0             	movsbl %al,%eax
  800698:	83 e8 20             	sub    $0x20,%eax
  80069b:	83 f8 5e             	cmp    $0x5e,%eax
  80069e:	76 cb                	jbe    80066b <vprintfmt+0x2de>
            putch('?', putdat);
  8006a0:	4c 89 fe             	mov    %r15,%rsi
  8006a3:	bf 3f 00 00 00       	mov    $0x3f,%edi
  8006a8:	41 ff d5             	callq  *%r13
  8006ab:	eb c4                	jmp    800671 <vprintfmt+0x2e4>
  8006ad:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006b1:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
        for (; width > 0; width--)
  8006b5:	8b 5d ac             	mov    -0x54(%rbp),%ebx
  8006b8:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8006bc:	0f 8e f5 fc ff ff    	jle    8003b7 <vprintfmt+0x2a>
          putch(' ', putdat);
  8006c2:	4c 89 fe             	mov    %r15,%rsi
  8006c5:	bf 20 00 00 00       	mov    $0x20,%edi
  8006ca:	41 ff d5             	callq  *%r13
        for (; width > 0; width--)
  8006cd:	83 eb 01             	sub    $0x1,%ebx
  8006d0:	75 f0                	jne    8006c2 <vprintfmt+0x335>
  8006d2:	e9 e0 fc ff ff       	jmpq   8003b7 <vprintfmt+0x2a>
  8006d7:	44 89 75 ac          	mov    %r14d,-0x54(%rbp)
  8006db:	4c 8b 75 a0          	mov    -0x60(%rbp),%r14
  8006df:	eb d4                	jmp    8006b5 <vprintfmt+0x328>
  if (lflag >= 2)
  8006e1:	83 f9 01             	cmp    $0x1,%ecx
  8006e4:	7f 1d                	jg     800703 <vprintfmt+0x376>
  else if (lflag)
  8006e6:	85 c9                	test   %ecx,%ecx
  8006e8:	74 5e                	je     800748 <vprintfmt+0x3bb>
    return va_arg(*ap, long);
  8006ea:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8006ed:	83 f8 2f             	cmp    $0x2f,%eax
  8006f0:	77 48                	ja     80073a <vprintfmt+0x3ad>
  8006f2:	89 c2                	mov    %eax,%edx
  8006f4:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8006f8:	83 c0 08             	add    $0x8,%eax
  8006fb:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8006fe:	48 8b 1a             	mov    (%rdx),%rbx
  800701:	eb 17                	jmp    80071a <vprintfmt+0x38d>
    return va_arg(*ap, long long);
  800703:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800706:	83 f8 2f             	cmp    $0x2f,%eax
  800709:	77 21                	ja     80072c <vprintfmt+0x39f>
  80070b:	89 c2                	mov    %eax,%edx
  80070d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800711:	83 c0 08             	add    $0x8,%eax
  800714:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800717:	48 8b 1a             	mov    (%rdx),%rbx
        if ((long long)num < 0) {
  80071a:	48 85 db             	test   %rbx,%rbx
  80071d:	78 50                	js     80076f <vprintfmt+0x3e2>
        num = getint(&aq, lflag);
  80071f:	48 89 da             	mov    %rbx,%rdx
        base = 10;
  800722:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800727:	e9 b4 01 00 00       	jmpq   8008e0 <vprintfmt+0x553>
    return va_arg(*ap, long long);
  80072c:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800730:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800734:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800738:	eb dd                	jmp    800717 <vprintfmt+0x38a>
    return va_arg(*ap, long);
  80073a:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80073e:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800742:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800746:	eb b6                	jmp    8006fe <vprintfmt+0x371>
    return va_arg(*ap, int);
  800748:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80074b:	83 f8 2f             	cmp    $0x2f,%eax
  80074e:	77 11                	ja     800761 <vprintfmt+0x3d4>
  800750:	89 c2                	mov    %eax,%edx
  800752:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800756:	83 c0 08             	add    $0x8,%eax
  800759:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80075c:	48 63 1a             	movslq (%rdx),%rbx
  80075f:	eb b9                	jmp    80071a <vprintfmt+0x38d>
  800761:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800765:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800769:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80076d:	eb ed                	jmp    80075c <vprintfmt+0x3cf>
          putch('-', putdat);
  80076f:	4c 89 fe             	mov    %r15,%rsi
  800772:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800777:	41 ff d5             	callq  *%r13
          num = -(long long)num;
  80077a:	48 89 da             	mov    %rbx,%rdx
  80077d:	48 f7 da             	neg    %rdx
        base = 10;
  800780:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800785:	e9 56 01 00 00       	jmpq   8008e0 <vprintfmt+0x553>
  if (lflag >= 2)
  80078a:	83 f9 01             	cmp    $0x1,%ecx
  80078d:	7f 25                	jg     8007b4 <vprintfmt+0x427>
  else if (lflag)
  80078f:	85 c9                	test   %ecx,%ecx
  800791:	74 5e                	je     8007f1 <vprintfmt+0x464>
    return va_arg(*ap, unsigned long);
  800793:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800796:	83 f8 2f             	cmp    $0x2f,%eax
  800799:	77 48                	ja     8007e3 <vprintfmt+0x456>
  80079b:	89 c2                	mov    %eax,%edx
  80079d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007a1:	83 c0 08             	add    $0x8,%eax
  8007a4:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007a7:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007aa:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007af:	e9 2c 01 00 00       	jmpq   8008e0 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007b4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007b7:	83 f8 2f             	cmp    $0x2f,%eax
  8007ba:	77 19                	ja     8007d5 <vprintfmt+0x448>
  8007bc:	89 c2                	mov    %eax,%edx
  8007be:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007c2:	83 c0 08             	add    $0x8,%eax
  8007c5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8007c8:	48 8b 12             	mov    (%rdx),%rdx
        base = 10;
  8007cb:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007d0:	e9 0b 01 00 00       	jmpq   8008e0 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  8007d5:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007d9:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007dd:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007e1:	eb e5                	jmp    8007c8 <vprintfmt+0x43b>
    return va_arg(*ap, unsigned long);
  8007e3:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8007e7:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8007eb:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8007ef:	eb b6                	jmp    8007a7 <vprintfmt+0x41a>
    return va_arg(*ap, unsigned int);
  8007f1:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8007f4:	83 f8 2f             	cmp    $0x2f,%eax
  8007f7:	77 18                	ja     800811 <vprintfmt+0x484>
  8007f9:	89 c2                	mov    %eax,%edx
  8007fb:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8007ff:	83 c0 08             	add    $0x8,%eax
  800802:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800805:	8b 12                	mov    (%rdx),%edx
        base = 10;
  800807:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80080c:	e9 cf 00 00 00       	jmpq   8008e0 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  800811:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800815:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800819:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80081d:	eb e6                	jmp    800805 <vprintfmt+0x478>
  if (lflag >= 2)
  80081f:	83 f9 01             	cmp    $0x1,%ecx
  800822:	7f 25                	jg     800849 <vprintfmt+0x4bc>
  else if (lflag)
  800824:	85 c9                	test   %ecx,%ecx
  800826:	74 5b                	je     800883 <vprintfmt+0x4f6>
    return va_arg(*ap, unsigned long);
  800828:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80082b:	83 f8 2f             	cmp    $0x2f,%eax
  80082e:	77 45                	ja     800875 <vprintfmt+0x4e8>
  800830:	89 c2                	mov    %eax,%edx
  800832:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800836:	83 c0 08             	add    $0x8,%eax
  800839:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80083c:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  80083f:	b9 08 00 00 00       	mov    $0x8,%ecx
  800844:	e9 97 00 00 00       	jmpq   8008e0 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800849:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80084c:	83 f8 2f             	cmp    $0x2f,%eax
  80084f:	77 16                	ja     800867 <vprintfmt+0x4da>
  800851:	89 c2                	mov    %eax,%edx
  800853:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800857:	83 c0 08             	add    $0x8,%eax
  80085a:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80085d:	48 8b 12             	mov    (%rdx),%rdx
        base = 8;
  800860:	b9 08 00 00 00       	mov    $0x8,%ecx
  800865:	eb 79                	jmp    8008e0 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800867:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  80086b:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80086f:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800873:	eb e8                	jmp    80085d <vprintfmt+0x4d0>
    return va_arg(*ap, unsigned long);
  800875:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800879:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80087d:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  800881:	eb b9                	jmp    80083c <vprintfmt+0x4af>
    return va_arg(*ap, unsigned int);
  800883:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800886:	83 f8 2f             	cmp    $0x2f,%eax
  800889:	77 15                	ja     8008a0 <vprintfmt+0x513>
  80088b:	89 c2                	mov    %eax,%edx
  80088d:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800891:	83 c0 08             	add    $0x8,%eax
  800894:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800897:	8b 12                	mov    (%rdx),%edx
        base = 8;
  800899:	b9 08 00 00 00       	mov    $0x8,%ecx
  80089e:	eb 40                	jmp    8008e0 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  8008a0:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  8008a4:	48 8d 42 08          	lea    0x8(%rdx),%rax
  8008a8:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  8008ac:	eb e9                	jmp    800897 <vprintfmt+0x50a>
        putch('0', putdat);
  8008ae:	4c 89 fe             	mov    %r15,%rsi
  8008b1:	bf 30 00 00 00       	mov    $0x30,%edi
  8008b6:	41 ff d5             	callq  *%r13
        putch('x', putdat);
  8008b9:	4c 89 fe             	mov    %r15,%rsi
  8008bc:	bf 78 00 00 00       	mov    $0x78,%edi
  8008c1:	41 ff d5             	callq  *%r13
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  8008c4:	8b 45 b8             	mov    -0x48(%rbp),%eax
  8008c7:	83 f8 2f             	cmp    $0x2f,%eax
  8008ca:	77 34                	ja     800900 <vprintfmt+0x573>
  8008cc:	89 c2                	mov    %eax,%edx
  8008ce:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  8008d2:	83 c0 08             	add    $0x8,%eax
  8008d5:	89 45 b8             	mov    %eax,-0x48(%rbp)
  8008d8:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  8008db:	b9 10 00 00 00       	mov    $0x10,%ecx
        printnum(putch, putdat, num, base, width, padc);
  8008e0:	44 0f be 4d a0       	movsbl -0x60(%rbp),%r9d
  8008e5:	44 8b 45 ac          	mov    -0x54(%rbp),%r8d
  8008e9:	4c 89 fe             	mov    %r15,%rsi
  8008ec:	4c 89 ef             	mov    %r13,%rdi
  8008ef:	48 b8 63 02 80 00 00 	movabs $0x800263,%rax
  8008f6:	00 00 00 
  8008f9:	ff d0                	callq  *%rax
        break;
  8008fb:	e9 b7 fa ff ff       	jmpq   8003b7 <vprintfmt+0x2a>
        num  = (unsigned long long)(uintptr_t)va_arg(aq, void *);
  800900:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800904:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800908:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80090c:	eb ca                	jmp    8008d8 <vprintfmt+0x54b>
  if (lflag >= 2)
  80090e:	83 f9 01             	cmp    $0x1,%ecx
  800911:	7f 22                	jg     800935 <vprintfmt+0x5a8>
  else if (lflag)
  800913:	85 c9                	test   %ecx,%ecx
  800915:	74 58                	je     80096f <vprintfmt+0x5e2>
    return va_arg(*ap, unsigned long);
  800917:	8b 45 b8             	mov    -0x48(%rbp),%eax
  80091a:	83 f8 2f             	cmp    $0x2f,%eax
  80091d:	77 42                	ja     800961 <vprintfmt+0x5d4>
  80091f:	89 c2                	mov    %eax,%edx
  800921:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800925:	83 c0 08             	add    $0x8,%eax
  800928:	89 45 b8             	mov    %eax,-0x48(%rbp)
  80092b:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  80092e:	b9 10 00 00 00       	mov    $0x10,%ecx
  800933:	eb ab                	jmp    8008e0 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800935:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800938:	83 f8 2f             	cmp    $0x2f,%eax
  80093b:	77 16                	ja     800953 <vprintfmt+0x5c6>
  80093d:	89 c2                	mov    %eax,%edx
  80093f:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  800943:	83 c0 08             	add    $0x8,%eax
  800946:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800949:	48 8b 12             	mov    (%rdx),%rdx
        base = 16;
  80094c:	b9 10 00 00 00       	mov    $0x10,%ecx
  800951:	eb 8d                	jmp    8008e0 <vprintfmt+0x553>
    return va_arg(*ap, unsigned long long);
  800953:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800957:	48 8d 42 08          	lea    0x8(%rdx),%rax
  80095b:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80095f:	eb e8                	jmp    800949 <vprintfmt+0x5bc>
    return va_arg(*ap, unsigned long);
  800961:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800965:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800969:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80096d:	eb bc                	jmp    80092b <vprintfmt+0x59e>
    return va_arg(*ap, unsigned int);
  80096f:	8b 45 b8             	mov    -0x48(%rbp),%eax
  800972:	83 f8 2f             	cmp    $0x2f,%eax
  800975:	77 18                	ja     80098f <vprintfmt+0x602>
  800977:	89 c2                	mov    %eax,%edx
  800979:	48 03 55 c8          	add    -0x38(%rbp),%rdx
  80097d:	83 c0 08             	add    $0x8,%eax
  800980:	89 45 b8             	mov    %eax,-0x48(%rbp)
  800983:	8b 12                	mov    (%rdx),%edx
        base = 16;
  800985:	b9 10 00 00 00       	mov    $0x10,%ecx
  80098a:	e9 51 ff ff ff       	jmpq   8008e0 <vprintfmt+0x553>
    return va_arg(*ap, unsigned int);
  80098f:	48 8b 55 c0          	mov    -0x40(%rbp),%rdx
  800993:	48 8d 42 08          	lea    0x8(%rdx),%rax
  800997:	48 89 45 c0          	mov    %rax,-0x40(%rbp)
  80099b:	eb e6                	jmp    800983 <vprintfmt+0x5f6>
        putch(ch, putdat);
  80099d:	4c 89 fe             	mov    %r15,%rsi
  8009a0:	bf 25 00 00 00       	mov    $0x25,%edi
  8009a5:	41 ff d5             	callq  *%r13
        break;
  8009a8:	e9 0a fa ff ff       	jmpq   8003b7 <vprintfmt+0x2a>
        putch('%', putdat);
  8009ad:	4c 89 fe             	mov    %r15,%rsi
  8009b0:	bf 25 00 00 00       	mov    $0x25,%edi
  8009b5:	41 ff d5             	callq  *%r13
        for (fmt--; fmt[-1] != '%'; fmt--)
  8009b8:	80 7b ff 25          	cmpb   $0x25,-0x1(%rbx)
  8009bc:	0f 84 15 fa ff ff    	je     8003d7 <vprintfmt+0x4a>
  8009c2:	49 89 de             	mov    %rbx,%r14
  8009c5:	49 83 ee 01          	sub    $0x1,%r14
  8009c9:	41 80 7e ff 25       	cmpb   $0x25,-0x1(%r14)
  8009ce:	75 f5                	jne    8009c5 <vprintfmt+0x638>
  8009d0:	e9 e2 f9 ff ff       	jmpq   8003b7 <vprintfmt+0x2a>
        if (width > 0 && padc != '-')
  8009d5:	80 7d a0 2d          	cmpb   $0x2d,-0x60(%rbp)
  8009d9:	74 06                	je     8009e1 <vprintfmt+0x654>
  8009db:	83 7d ac 00          	cmpl   $0x0,-0x54(%rbp)
  8009df:	7f 21                	jg     800a02 <vprintfmt+0x675>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009e1:	bf 28 00 00 00       	mov    $0x28,%edi
  8009e6:	48 bb 20 14 80 00 00 	movabs $0x801420,%rbx
  8009ed:	00 00 00 
  8009f0:	b8 28 00 00 00       	mov    $0x28,%eax
  8009f5:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  8009f9:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  8009fd:	e9 82 fc ff ff       	jmpq   800684 <vprintfmt+0x2f7>
          for (width -= strnlen(p, precision); width > 0; width--)
  800a02:	49 63 f4             	movslq %r12d,%rsi
  800a05:	48 bf 1f 14 80 00 00 	movabs $0x80141f,%rdi
  800a0c:	00 00 00 
  800a0f:	48 b8 64 0b 80 00 00 	movabs $0x800b64,%rax
  800a16:	00 00 00 
  800a19:	ff d0                	callq  *%rax
  800a1b:	29 45 ac             	sub    %eax,-0x54(%rbp)
  800a1e:	8b 45 ac             	mov    -0x54(%rbp),%eax
          p = "(null)";
  800a21:	48 be 1f 14 80 00 00 	movabs $0x80141f,%rsi
  800a28:	00 00 00 
  800a2b:	48 89 75 98          	mov    %rsi,-0x68(%rbp)
          for (width -= strnlen(p, precision); width > 0; width--)
  800a2f:	85 c0                	test   %eax,%eax
  800a31:	0f 8f f2 fb ff ff    	jg     800629 <vprintfmt+0x29c>
        for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a37:	48 bb 20 14 80 00 00 	movabs $0x801420,%rbx
  800a3e:	00 00 00 
  800a41:	b8 28 00 00 00       	mov    $0x28,%eax
  800a46:	bf 28 00 00 00       	mov    $0x28,%edi
  800a4b:	4c 89 75 a0          	mov    %r14,-0x60(%rbp)
  800a4f:	44 8b 75 ac          	mov    -0x54(%rbp),%r14d
  800a53:	e9 2c fc ff ff       	jmpq   800684 <vprintfmt+0x2f7>
}
  800a58:	48 83 c4 48          	add    $0x48,%rsp
  800a5c:	5b                   	pop    %rbx
  800a5d:	41 5c                	pop    %r12
  800a5f:	41 5d                	pop    %r13
  800a61:	41 5e                	pop    %r14
  800a63:	41 5f                	pop    %r15
  800a65:	5d                   	pop    %rbp
  800a66:	c3                   	retq   

0000000000800a67 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap) {
  800a67:	55                   	push   %rbp
  800a68:	48 89 e5             	mov    %rsp,%rbp
  800a6b:	48 83 ec 20          	sub    $0x20,%rsp
  struct sprintbuf b = {buf, buf + n - 1, 0};
  800a6f:	48 89 7d e0          	mov    %rdi,-0x20(%rbp)
  800a73:	48 63 c6             	movslq %esi,%rax
  800a76:	48 8d 44 07 ff       	lea    -0x1(%rdi,%rax,1),%rax
  800a7b:	48 89 45 e8          	mov    %rax,-0x18(%rbp)
  800a7f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%rbp)

  if (buf == NULL || n < 1)
  800a86:	48 85 ff             	test   %rdi,%rdi
  800a89:	74 2a                	je     800ab5 <vsnprintf+0x4e>
  800a8b:	85 f6                	test   %esi,%esi
  800a8d:	7e 26                	jle    800ab5 <vsnprintf+0x4e>
    return -E_INVAL;

  // print the string to the buffer
  vprintfmt((void *)sprintputch, &b, fmt, ap);
  800a8f:	48 8d 75 e0          	lea    -0x20(%rbp),%rsi
  800a93:	48 bf ef 02 80 00 00 	movabs $0x8002ef,%rdi
  800a9a:	00 00 00 
  800a9d:	48 b8 8d 03 80 00 00 	movabs $0x80038d,%rax
  800aa4:	00 00 00 
  800aa7:	ff d0                	callq  *%rax

  // null terminate the buffer
  *b.buf = '\0';
  800aa9:	48 8b 45 e0          	mov    -0x20(%rbp),%rax
  800aad:	c6 00 00             	movb   $0x0,(%rax)

  return b.cnt;
  800ab0:	8b 45 f0             	mov    -0x10(%rbp),%eax
}
  800ab3:	c9                   	leaveq 
  800ab4:	c3                   	retq   
    return -E_INVAL;
  800ab5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800aba:	eb f7                	jmp    800ab3 <vsnprintf+0x4c>

0000000000800abc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...) {
  800abc:	55                   	push   %rbp
  800abd:	48 89 e5             	mov    %rsp,%rbp
  800ac0:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  800ac7:	48 89 8d 68 ff ff ff 	mov    %rcx,-0x98(%rbp)
  800ace:	4c 89 85 70 ff ff ff 	mov    %r8,-0x90(%rbp)
  800ad5:	4c 89 8d 78 ff ff ff 	mov    %r9,-0x88(%rbp)
  800adc:	84 c0                	test   %al,%al
  800ade:	74 20                	je     800b00 <snprintf+0x44>
  800ae0:	0f 29 45 80          	movaps %xmm0,-0x80(%rbp)
  800ae4:	0f 29 4d 90          	movaps %xmm1,-0x70(%rbp)
  800ae8:	0f 29 55 a0          	movaps %xmm2,-0x60(%rbp)
  800aec:	0f 29 5d b0          	movaps %xmm3,-0x50(%rbp)
  800af0:	0f 29 65 c0          	movaps %xmm4,-0x40(%rbp)
  800af4:	0f 29 6d d0          	movaps %xmm5,-0x30(%rbp)
  800af8:	0f 29 75 e0          	movaps %xmm6,-0x20(%rbp)
  800afc:	0f 29 7d f0          	movaps %xmm7,-0x10(%rbp)
  va_list ap;
  int rc;

  va_start(ap, fmt);
  800b00:	c7 85 38 ff ff ff 18 	movl   $0x18,-0xc8(%rbp)
  800b07:	00 00 00 
  800b0a:	c7 85 3c ff ff ff 30 	movl   $0x30,-0xc4(%rbp)
  800b11:	00 00 00 
  800b14:	48 8d 45 10          	lea    0x10(%rbp),%rax
  800b18:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  800b1f:	48 8d 85 50 ff ff ff 	lea    -0xb0(%rbp),%rax
  800b26:	48 89 85 48 ff ff ff 	mov    %rax,-0xb8(%rbp)
  rc = vsnprintf(buf, n, fmt, ap);
  800b2d:	48 8d 8d 38 ff ff ff 	lea    -0xc8(%rbp),%rcx
  800b34:	48 b8 67 0a 80 00 00 	movabs $0x800a67,%rax
  800b3b:	00 00 00 
  800b3e:	ff d0                	callq  *%rax
  va_end(ap);

  return rc;
}
  800b40:	c9                   	leaveq 
  800b41:	c3                   	retq   

0000000000800b42 <strlen>:

int
strlen(const char *s) {
  int n;

  for (n = 0; *s != '\0'; s++)
  800b42:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b45:	74 17                	je     800b5e <strlen+0x1c>
  800b47:	48 89 fa             	mov    %rdi,%rdx
  800b4a:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b4f:	29 f9                	sub    %edi,%ecx
    n++;
  800b51:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; *s != '\0'; s++)
  800b54:	48 83 c2 01          	add    $0x1,%rdx
  800b58:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b5b:	75 f4                	jne    800b51 <strlen+0xf>
  800b5d:	c3                   	retq   
  800b5e:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b63:	c3                   	retq   

0000000000800b64 <strnlen>:

int
strnlen(const char *s, size_t size) {
  int n;

  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b64:	48 85 f6             	test   %rsi,%rsi
  800b67:	74 24                	je     800b8d <strnlen+0x29>
  800b69:	80 3f 00             	cmpb   $0x0,(%rdi)
  800b6c:	74 25                	je     800b93 <strnlen+0x2f>
  800b6e:	48 01 fe             	add    %rdi,%rsi
  800b71:	48 89 fa             	mov    %rdi,%rdx
  800b74:	b9 01 00 00 00       	mov    $0x1,%ecx
  800b79:	29 f9                	sub    %edi,%ecx
    n++;
  800b7b:	8d 04 11             	lea    (%rcx,%rdx,1),%eax
  for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b7e:	48 83 c2 01          	add    $0x1,%rdx
  800b82:	48 39 f2             	cmp    %rsi,%rdx
  800b85:	74 11                	je     800b98 <strnlen+0x34>
  800b87:	80 3a 00             	cmpb   $0x0,(%rdx)
  800b8a:	75 ef                	jne    800b7b <strnlen+0x17>
  800b8c:	c3                   	retq   
  800b8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b92:	c3                   	retq   
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
}
  800b98:	c3                   	retq   

0000000000800b99 <strcpy>:

char *
strcpy(char *dst, const char *src) {
  800b99:	48 89 f8             	mov    %rdi,%rax
  char *ret;

  ret = dst;
  while ((*dst++ = *src++) != '\0')
  800b9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba1:	0f b6 0c 16          	movzbl (%rsi,%rdx,1),%ecx
  800ba5:	88 0c 10             	mov    %cl,(%rax,%rdx,1)
  800ba8:	48 83 c2 01          	add    $0x1,%rdx
  800bac:	84 c9                	test   %cl,%cl
  800bae:	75 f1                	jne    800ba1 <strcpy+0x8>
    /* do nothing */;
  return ret;
}
  800bb0:	c3                   	retq   

0000000000800bb1 <strcat>:

char *
strcat(char *dst, const char *src) {
  800bb1:	55                   	push   %rbp
  800bb2:	48 89 e5             	mov    %rsp,%rbp
  800bb5:	41 54                	push   %r12
  800bb7:	53                   	push   %rbx
  800bb8:	48 89 fb             	mov    %rdi,%rbx
  800bbb:	49 89 f4             	mov    %rsi,%r12
  int len = strlen(dst);
  800bbe:	48 b8 42 0b 80 00 00 	movabs $0x800b42,%rax
  800bc5:	00 00 00 
  800bc8:	ff d0                	callq  *%rax
  strcpy(dst + len, src);
  800bca:	48 63 f8             	movslq %eax,%rdi
  800bcd:	48 01 df             	add    %rbx,%rdi
  800bd0:	4c 89 e6             	mov    %r12,%rsi
  800bd3:	48 b8 99 0b 80 00 00 	movabs $0x800b99,%rax
  800bda:	00 00 00 
  800bdd:	ff d0                	callq  *%rax
  return dst;
}
  800bdf:	48 89 d8             	mov    %rbx,%rax
  800be2:	5b                   	pop    %rbx
  800be3:	41 5c                	pop    %r12
  800be5:	5d                   	pop    %rbp
  800be6:	c3                   	retq   

0000000000800be7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800be7:	48 89 f8             	mov    %rdi,%rax
  size_t i;
  char *ret;

  ret = dst;
  for (i = 0; i < size; i++) {
  800bea:	48 85 d2             	test   %rdx,%rdx
  800bed:	74 1f                	je     800c0e <strncpy+0x27>
  800bef:	48 01 fa             	add    %rdi,%rdx
  800bf2:	48 89 f9             	mov    %rdi,%rcx
    *dst++ = *src;
  800bf5:	48 83 c1 01          	add    $0x1,%rcx
  800bf9:	44 0f b6 06          	movzbl (%rsi),%r8d
  800bfd:	44 88 41 ff          	mov    %r8b,-0x1(%rcx)
    // If strlen(src) < size, null-pad 'dst' out to 'size' chars
    if (*src != '\0')
      src++;
  800c01:	41 80 f8 01          	cmp    $0x1,%r8b
  800c05:	48 83 de ff          	sbb    $0xffffffffffffffff,%rsi
  for (i = 0; i < size; i++) {
  800c09:	48 39 ca             	cmp    %rcx,%rdx
  800c0c:	75 e7                	jne    800bf5 <strncpy+0xe>
  }
  return ret;
}
  800c0e:	c3                   	retq   

0000000000800c0f <strlcpy>:
size_t
strlcpy(char *dst, const char *src, size_t size) {
  char *dst_in;

  dst_in = dst;
  if (size > 0) {
  800c0f:	48 89 f8             	mov    %rdi,%rax
  800c12:	48 85 d2             	test   %rdx,%rdx
  800c15:	74 36                	je     800c4d <strlcpy+0x3e>
    while (--size > 0 && *src != '\0')
  800c17:	48 83 fa 01          	cmp    $0x1,%rdx
  800c1b:	74 2d                	je     800c4a <strlcpy+0x3b>
  800c1d:	44 0f b6 06          	movzbl (%rsi),%r8d
  800c21:	45 84 c0             	test   %r8b,%r8b
  800c24:	74 24                	je     800c4a <strlcpy+0x3b>
  800c26:	48 8d 4e 01          	lea    0x1(%rsi),%rcx
  800c2a:	48 8d 54 16 ff       	lea    -0x1(%rsi,%rdx,1),%rdx
      *dst++ = *src++;
  800c2f:	48 83 c0 01          	add    $0x1,%rax
  800c33:	44 88 40 ff          	mov    %r8b,-0x1(%rax)
    while (--size > 0 && *src != '\0')
  800c37:	48 39 d1             	cmp    %rdx,%rcx
  800c3a:	74 0e                	je     800c4a <strlcpy+0x3b>
  800c3c:	48 83 c1 01          	add    $0x1,%rcx
  800c40:	44 0f b6 41 ff       	movzbl -0x1(%rcx),%r8d
  800c45:	45 84 c0             	test   %r8b,%r8b
  800c48:	75 e5                	jne    800c2f <strlcpy+0x20>
    *dst = '\0';
  800c4a:	c6 00 00             	movb   $0x0,(%rax)
  }
  return dst - dst_in;
  800c4d:	48 29 f8             	sub    %rdi,%rax
}
  800c50:	c3                   	retq   

0000000000800c51 <strcmp>:
  return dstlen + srclen;
}

int
strcmp(const char *p, const char *q) {
  while (*p && *p == *q)
  800c51:	0f b6 07             	movzbl (%rdi),%eax
  800c54:	84 c0                	test   %al,%al
  800c56:	74 17                	je     800c6f <strcmp+0x1e>
  800c58:	3a 06                	cmp    (%rsi),%al
  800c5a:	75 13                	jne    800c6f <strcmp+0x1e>
    p++, q++;
  800c5c:	48 83 c7 01          	add    $0x1,%rdi
  800c60:	48 83 c6 01          	add    $0x1,%rsi
  while (*p && *p == *q)
  800c64:	0f b6 07             	movzbl (%rdi),%eax
  800c67:	84 c0                	test   %al,%al
  800c69:	74 04                	je     800c6f <strcmp+0x1e>
  800c6b:	3a 06                	cmp    (%rsi),%al
  800c6d:	74 ed                	je     800c5c <strcmp+0xb>
  return (int)((unsigned char)*p - (unsigned char)*q);
  800c6f:	0f b6 c0             	movzbl %al,%eax
  800c72:	0f b6 16             	movzbl (%rsi),%edx
  800c75:	29 d0                	sub    %edx,%eax
}
  800c77:	c3                   	retq   

0000000000800c78 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n) {
  while (n > 0 && *p && *p == *q)
  800c78:	48 85 d2             	test   %rdx,%rdx
  800c7b:	74 2f                	je     800cac <strncmp+0x34>
  800c7d:	0f b6 07             	movzbl (%rdi),%eax
  800c80:	84 c0                	test   %al,%al
  800c82:	74 1f                	je     800ca3 <strncmp+0x2b>
  800c84:	3a 06                	cmp    (%rsi),%al
  800c86:	75 1b                	jne    800ca3 <strncmp+0x2b>
  800c88:	48 01 fa             	add    %rdi,%rdx
    n--, p++, q++;
  800c8b:	48 83 c7 01          	add    $0x1,%rdi
  800c8f:	48 83 c6 01          	add    $0x1,%rsi
  while (n > 0 && *p && *p == *q)
  800c93:	48 39 d7             	cmp    %rdx,%rdi
  800c96:	74 1a                	je     800cb2 <strncmp+0x3a>
  800c98:	0f b6 07             	movzbl (%rdi),%eax
  800c9b:	84 c0                	test   %al,%al
  800c9d:	74 04                	je     800ca3 <strncmp+0x2b>
  800c9f:	3a 06                	cmp    (%rsi),%al
  800ca1:	74 e8                	je     800c8b <strncmp+0x13>
  if (n == 0)
    return 0;
  else
    return (int)((unsigned char)*p - (unsigned char)*q);
  800ca3:	0f b6 07             	movzbl (%rdi),%eax
  800ca6:	0f b6 16             	movzbl (%rsi),%edx
  800ca9:	29 d0                	sub    %edx,%eax
}
  800cab:	c3                   	retq   
    return 0;
  800cac:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb1:	c3                   	retq   
  800cb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb7:	c3                   	retq   

0000000000800cb8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c) {
  800cb8:	89 f2                	mov    %esi,%edx
  for (; *s; s++)
  800cba:	0f b6 07             	movzbl (%rdi),%eax
  800cbd:	84 c0                	test   %al,%al
  800cbf:	74 1e                	je     800cdf <strchr+0x27>
    if (*s == c)
  800cc1:	40 38 c6             	cmp    %al,%sil
  800cc4:	74 1f                	je     800ce5 <strchr+0x2d>
  for (; *s; s++)
  800cc6:	48 83 c7 01          	add    $0x1,%rdi
  800cca:	0f b6 07             	movzbl (%rdi),%eax
  800ccd:	84 c0                	test   %al,%al
  800ccf:	74 08                	je     800cd9 <strchr+0x21>
    if (*s == c)
  800cd1:	38 d0                	cmp    %dl,%al
  800cd3:	75 f1                	jne    800cc6 <strchr+0xe>
  for (; *s; s++)
  800cd5:	48 89 f8             	mov    %rdi,%rax
      return (char *)s;
  return 0;
}
  800cd8:	c3                   	retq   
  return 0;
  800cd9:	b8 00 00 00 00       	mov    $0x0,%eax
  800cde:	c3                   	retq   
  800cdf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce4:	c3                   	retq   
    if (*s == c)
  800ce5:	48 89 f8             	mov    %rdi,%rax
  800ce8:	c3                   	retq   

0000000000800ce9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c) {
  800ce9:	48 89 f8             	mov    %rdi,%rax
  800cec:	89 f1                	mov    %esi,%ecx
  for (; *s; s++)
  800cee:	0f b6 17             	movzbl (%rdi),%edx
    if (*s == c)
  800cf1:	40 38 f2             	cmp    %sil,%dl
  800cf4:	74 13                	je     800d09 <strfind+0x20>
  800cf6:	84 d2                	test   %dl,%dl
  800cf8:	74 0f                	je     800d09 <strfind+0x20>
  for (; *s; s++)
  800cfa:	48 83 c0 01          	add    $0x1,%rax
  800cfe:	0f b6 10             	movzbl (%rax),%edx
    if (*s == c)
  800d01:	38 ca                	cmp    %cl,%dl
  800d03:	74 04                	je     800d09 <strfind+0x20>
  800d05:	84 d2                	test   %dl,%dl
  800d07:	75 f1                	jne    800cfa <strfind+0x11>
      break;
  return (char *)s;
}
  800d09:	c3                   	retq   

0000000000800d0a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n) {
  if (n == 0)
  800d0a:	48 85 d2             	test   %rdx,%rdx
  800d0d:	74 3a                	je     800d49 <memset+0x3f>
    return v;
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d0f:	48 89 f8             	mov    %rdi,%rax
  800d12:	48 09 d0             	or     %rdx,%rax
  800d15:	a8 03                	test   $0x3,%al
  800d17:	75 28                	jne    800d41 <memset+0x37>
    uint32_t k = c & 0xFFU;
  800d19:	40 0f b6 f6          	movzbl %sil,%esi
    k          = (k << 24U) | (k << 16U) | (k << 8U) | k;
  800d1d:	89 f0                	mov    %esi,%eax
  800d1f:	c1 e0 08             	shl    $0x8,%eax
  800d22:	89 f1                	mov    %esi,%ecx
  800d24:	c1 e1 18             	shl    $0x18,%ecx
  800d27:	41 89 f0             	mov    %esi,%r8d
  800d2a:	41 c1 e0 10          	shl    $0x10,%r8d
  800d2e:	44 09 c1             	or     %r8d,%ecx
  800d31:	09 ce                	or     %ecx,%esi
  800d33:	09 f0                	or     %esi,%eax
    asm volatile("cld; rep stosl\n" ::"D"(v), "a"(k), "c"(n / 4)
  800d35:	48 c1 ea 02          	shr    $0x2,%rdx
  800d39:	48 89 d1             	mov    %rdx,%rcx
  800d3c:	fc                   	cld    
  800d3d:	f3 ab                	rep stos %eax,%es:(%rdi)
  if ((int64_t)v % 4 == 0 && n % 4 == 0) {
  800d3f:	eb 08                	jmp    800d49 <memset+0x3f>
                 : "cc", "memory");
  } else
    asm volatile("cld; rep stosb\n" ::"D"(v), "a"(c), "c"(n)
  800d41:	89 f0                	mov    %esi,%eax
  800d43:	48 89 d1             	mov    %rdx,%rcx
  800d46:	fc                   	cld    
  800d47:	f3 aa                	rep stos %al,%es:(%rdi)
                 : "cc", "memory");
  return v;
}
  800d49:	48 89 f8             	mov    %rdi,%rax
  800d4c:	c3                   	retq   

0000000000800d4d <memmove>:

void *
memmove(void *dst, const void *src, size_t n) {
  800d4d:	48 89 f8             	mov    %rdi,%rax
  const char *s;
  char *d;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
  800d50:	48 39 fe             	cmp    %rdi,%rsi
  800d53:	73 40                	jae    800d95 <memmove+0x48>
  800d55:	48 8d 0c 16          	lea    (%rsi,%rdx,1),%rcx
  800d59:	48 39 f9             	cmp    %rdi,%rcx
  800d5c:	76 37                	jbe    800d95 <memmove+0x48>
    s += n;
    d += n;
  800d5e:	48 8d 3c 17          	lea    (%rdi,%rdx,1),%rdi
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d62:	48 89 fe             	mov    %rdi,%rsi
  800d65:	48 09 d6             	or     %rdx,%rsi
  800d68:	48 09 ce             	or     %rcx,%rsi
  800d6b:	40 f6 c6 03          	test   $0x3,%sil
  800d6f:	75 14                	jne    800d85 <memmove+0x38>
      asm volatile("std; rep movsl\n" ::"D"(d - 4), "S"(s - 4), "c"(n / 4)
  800d71:	48 83 ef 04          	sub    $0x4,%rdi
  800d75:	48 8d 71 fc          	lea    -0x4(%rcx),%rsi
  800d79:	48 c1 ea 02          	shr    $0x2,%rdx
  800d7d:	48 89 d1             	mov    %rdx,%rcx
  800d80:	fd                   	std    
  800d81:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800d83:	eb 0e                	jmp    800d93 <memmove+0x46>
                   : "cc", "memory");
    else
      asm volatile("std; rep movsb\n" ::"D"(d - 1), "S"(s - 1), "c"(n)
  800d85:	48 83 ef 01          	sub    $0x1,%rdi
  800d89:	48 8d 71 ff          	lea    -0x1(%rcx),%rsi
  800d8d:	48 89 d1             	mov    %rdx,%rcx
  800d90:	fd                   	std    
  800d91:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
    // Some versions of GCC rely on DF being clear
    asm volatile("cld" ::
  800d93:	fc                   	cld    
  800d94:	c3                   	retq   
                     : "cc");
  } else {
    if ((int64_t)s % 4 == 0 && (int64_t)d % 4 == 0 && n % 4 == 0)
  800d95:	48 89 c1             	mov    %rax,%rcx
  800d98:	48 09 d1             	or     %rdx,%rcx
  800d9b:	48 09 f1             	or     %rsi,%rcx
  800d9e:	f6 c1 03             	test   $0x3,%cl
  800da1:	75 0e                	jne    800db1 <memmove+0x64>
      asm volatile("cld; rep movsl\n" ::"D"(d), "S"(s), "c"(n / 4)
  800da3:	48 c1 ea 02          	shr    $0x2,%rdx
  800da7:	48 89 d1             	mov    %rdx,%rcx
  800daa:	48 89 c7             	mov    %rax,%rdi
  800dad:	fc                   	cld    
  800dae:	f3 a5                	rep movsl %ds:(%rsi),%es:(%rdi)
  800db0:	c3                   	retq   
                   : "cc", "memory");
    else
      asm volatile("cld; rep movsb\n" ::"D"(d), "S"(s), "c"(n)
  800db1:	48 89 c7             	mov    %rax,%rdi
  800db4:	48 89 d1             	mov    %rdx,%rcx
  800db7:	fc                   	cld    
  800db8:	f3 a4                	rep movsb %ds:(%rsi),%es:(%rdi)
                   : "cc", "memory");
  }
  return dst;
}
  800dba:	c3                   	retq   

0000000000800dbb <memcpy>:
  return dst;
}
#endif

void *
memcpy(void *dst, const void *src, size_t n) {
  800dbb:	55                   	push   %rbp
  800dbc:	48 89 e5             	mov    %rsp,%rbp
  return memmove(dst, src, n);
  800dbf:	48 b8 4d 0d 80 00 00 	movabs $0x800d4d,%rax
  800dc6:	00 00 00 
  800dc9:	ff d0                	callq  *%rax
}
  800dcb:	5d                   	pop    %rbp
  800dcc:	c3                   	retq   

0000000000800dcd <strlcat>:
strlcat(char *restrict dst, const char *restrict src, size_t maxlen) {
  800dcd:	55                   	push   %rbp
  800dce:	48 89 e5             	mov    %rsp,%rbp
  800dd1:	41 57                	push   %r15
  800dd3:	41 56                	push   %r14
  800dd5:	41 55                	push   %r13
  800dd7:	41 54                	push   %r12
  800dd9:	53                   	push   %rbx
  800dda:	48 83 ec 08          	sub    $0x8,%rsp
  800dde:	49 89 fe             	mov    %rdi,%r14
  800de1:	49 89 f7             	mov    %rsi,%r15
  800de4:	49 89 d5             	mov    %rdx,%r13
  const size_t srclen = strlen(src);
  800de7:	48 89 f7             	mov    %rsi,%rdi
  800dea:	48 b8 42 0b 80 00 00 	movabs $0x800b42,%rax
  800df1:	00 00 00 
  800df4:	ff d0                	callq  *%rax
  800df6:	48 63 d8             	movslq %eax,%rbx
  const size_t dstlen = strnlen(dst, maxlen);
  800df9:	4c 89 ee             	mov    %r13,%rsi
  800dfc:	4c 89 f7             	mov    %r14,%rdi
  800dff:	48 b8 64 0b 80 00 00 	movabs $0x800b64,%rax
  800e06:	00 00 00 
  800e09:	ff d0                	callq  *%rax
  800e0b:	4c 63 e0             	movslq %eax,%r12
    return maxlen + srclen;
  800e0e:	4a 8d 04 2b          	lea    (%rbx,%r13,1),%rax
  if (dstlen == maxlen)
  800e12:	4d 39 e5             	cmp    %r12,%r13
  800e15:	74 26                	je     800e3d <strlcat+0x70>
  if (srclen < maxlen - dstlen) {
  800e17:	4c 89 e8             	mov    %r13,%rax
  800e1a:	4c 29 e0             	sub    %r12,%rax
  800e1d:	48 39 d8             	cmp    %rbx,%rax
  800e20:	76 2a                	jbe    800e4c <strlcat+0x7f>
    memcpy(dst + dstlen, src, srclen + 1);
  800e22:	48 8d 53 01          	lea    0x1(%rbx),%rdx
  800e26:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e2a:	4c 89 fe             	mov    %r15,%rsi
  800e2d:	48 b8 bb 0d 80 00 00 	movabs $0x800dbb,%rax
  800e34:	00 00 00 
  800e37:	ff d0                	callq  *%rax
  return dstlen + srclen;
  800e39:	4a 8d 04 23          	lea    (%rbx,%r12,1),%rax
}
  800e3d:	48 83 c4 08          	add    $0x8,%rsp
  800e41:	5b                   	pop    %rbx
  800e42:	41 5c                	pop    %r12
  800e44:	41 5d                	pop    %r13
  800e46:	41 5e                	pop    %r14
  800e48:	41 5f                	pop    %r15
  800e4a:	5d                   	pop    %rbp
  800e4b:	c3                   	retq   
    memcpy(dst + dstlen, src, maxlen - 1);
  800e4c:	49 83 ed 01          	sub    $0x1,%r13
  800e50:	4b 8d 3c 26          	lea    (%r14,%r12,1),%rdi
  800e54:	4c 89 ea             	mov    %r13,%rdx
  800e57:	4c 89 fe             	mov    %r15,%rsi
  800e5a:	48 b8 bb 0d 80 00 00 	movabs $0x800dbb,%rax
  800e61:	00 00 00 
  800e64:	ff d0                	callq  *%rax
    dst[dstlen + maxlen - 1] = '\0';
  800e66:	4d 01 ee             	add    %r13,%r14
  800e69:	43 c6 04 26 00       	movb   $0x0,(%r14,%r12,1)
  800e6e:	eb c9                	jmp    800e39 <strlcat+0x6c>

0000000000800e70 <memcmp>:
int
memcmp(const void *v1, const void *v2, size_t n) {
  const uint8_t *s1 = (const uint8_t *)v1;
  const uint8_t *s2 = (const uint8_t *)v2;

  while (n-- > 0) {
  800e70:	48 85 d2             	test   %rdx,%rdx
  800e73:	74 3a                	je     800eaf <memcmp+0x3f>
    if (*s1 != *s2)
  800e75:	0f b6 0f             	movzbl (%rdi),%ecx
  800e78:	44 0f b6 06          	movzbl (%rsi),%r8d
  800e7c:	44 38 c1             	cmp    %r8b,%cl
  800e7f:	75 1d                	jne    800e9e <memcmp+0x2e>
  800e81:	b8 01 00 00 00       	mov    $0x1,%eax
  while (n-- > 0) {
  800e86:	48 39 d0             	cmp    %rdx,%rax
  800e89:	74 1e                	je     800ea9 <memcmp+0x39>
    if (*s1 != *s2)
  800e8b:	0f b6 0c 07          	movzbl (%rdi,%rax,1),%ecx
  800e8f:	48 83 c0 01          	add    $0x1,%rax
  800e93:	44 0f b6 44 06 ff    	movzbl -0x1(%rsi,%rax,1),%r8d
  800e99:	44 38 c1             	cmp    %r8b,%cl
  800e9c:	74 e8                	je     800e86 <memcmp+0x16>
      return (int)*s1 - (int)*s2;
  800e9e:	0f b6 c1             	movzbl %cl,%eax
  800ea1:	45 0f b6 c0          	movzbl %r8b,%r8d
  800ea5:	44 29 c0             	sub    %r8d,%eax
  800ea8:	c3                   	retq   
    s1++, s2++;
  }

  return 0;
  800ea9:	b8 00 00 00 00       	mov    $0x0,%eax
  800eae:	c3                   	retq   
  800eaf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eb4:	c3                   	retq   

0000000000800eb5 <memfind>:

void *
memfind(const void *s, int c, size_t n) {
  const void *ends = (const char *)s + n;
  800eb5:	48 8d 04 17          	lea    (%rdi,%rdx,1),%rax
  for (; s < ends; s++)
  800eb9:	48 39 c7             	cmp    %rax,%rdi
  800ebc:	73 19                	jae    800ed7 <memfind+0x22>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ebe:	89 f2                	mov    %esi,%edx
  800ec0:	40 38 37             	cmp    %sil,(%rdi)
  800ec3:	74 16                	je     800edb <memfind+0x26>
  for (; s < ends; s++)
  800ec5:	48 83 c7 01          	add    $0x1,%rdi
  800ec9:	48 39 f8             	cmp    %rdi,%rax
  800ecc:	74 08                	je     800ed6 <memfind+0x21>
    if (*(const unsigned char *)s == (unsigned char)c)
  800ece:	38 17                	cmp    %dl,(%rdi)
  800ed0:	75 f3                	jne    800ec5 <memfind+0x10>
  for (; s < ends; s++)
  800ed2:	48 89 f8             	mov    %rdi,%rax
      break;
  return (void *)s;
}
  800ed5:	c3                   	retq   
  800ed6:	c3                   	retq   
  for (; s < ends; s++)
  800ed7:	48 89 f8             	mov    %rdi,%rax
  800eda:	c3                   	retq   
    if (*(const unsigned char *)s == (unsigned char)c)
  800edb:	48 89 f8             	mov    %rdi,%rax
  800ede:	c3                   	retq   

0000000000800edf <strtol>:
strtol(const char *s, char **endptr, int base) {
  int neg  = 0;
  long val = 0;

  // gobble initial whitespace
  while (*s == ' ' || *s == '\t')
  800edf:	0f b6 07             	movzbl (%rdi),%eax
  800ee2:	3c 20                	cmp    $0x20,%al
  800ee4:	74 04                	je     800eea <strtol+0xb>
  800ee6:	3c 09                	cmp    $0x9,%al
  800ee8:	75 0f                	jne    800ef9 <strtol+0x1a>
    s++;
  800eea:	48 83 c7 01          	add    $0x1,%rdi
  while (*s == ' ' || *s == '\t')
  800eee:	0f b6 07             	movzbl (%rdi),%eax
  800ef1:	3c 20                	cmp    $0x20,%al
  800ef3:	74 f5                	je     800eea <strtol+0xb>
  800ef5:	3c 09                	cmp    $0x9,%al
  800ef7:	74 f1                	je     800eea <strtol+0xb>

  // plus/minus sign
  if (*s == '+')
  800ef9:	3c 2b                	cmp    $0x2b,%al
  800efb:	74 2b                	je     800f28 <strtol+0x49>
  int neg  = 0;
  800efd:	41 b9 00 00 00 00    	mov    $0x0,%r9d
    s++;
  else if (*s == '-')
  800f03:	3c 2d                	cmp    $0x2d,%al
  800f05:	74 2d                	je     800f34 <strtol+0x55>
    s++, neg = 1;

  // hex or octal base prefix
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f07:	f7 c2 ef ff ff ff    	test   $0xffffffef,%edx
  800f0d:	75 0f                	jne    800f1e <strtol+0x3f>
  800f0f:	80 3f 30             	cmpb   $0x30,(%rdi)
  800f12:	74 2c                	je     800f40 <strtol+0x61>
    s += 2, base = 16;
  else if (base == 0 && s[0] == '0')
    s++, base = 8;
  else if (base == 0)
    base = 10;
  800f14:	85 d2                	test   %edx,%edx
  800f16:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f1b:	0f 44 d0             	cmove  %eax,%edx
  800f1e:	b8 00 00 00 00       	mov    $0x0,%eax
      dig = *s - 'A' + 10;
    else
      break;
    if (dig >= base)
      break;
    s++, val = (val * base) + dig;
  800f23:	4c 63 d2             	movslq %edx,%r10
  800f26:	eb 5c                	jmp    800f84 <strtol+0xa5>
    s++;
  800f28:	48 83 c7 01          	add    $0x1,%rdi
  int neg  = 0;
  800f2c:	41 b9 00 00 00 00    	mov    $0x0,%r9d
  800f32:	eb d3                	jmp    800f07 <strtol+0x28>
    s++, neg = 1;
  800f34:	48 83 c7 01          	add    $0x1,%rdi
  800f38:	41 b9 01 00 00 00    	mov    $0x1,%r9d
  800f3e:	eb c7                	jmp    800f07 <strtol+0x28>
  if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f40:	80 7f 01 78          	cmpb   $0x78,0x1(%rdi)
  800f44:	74 0f                	je     800f55 <strtol+0x76>
  else if (base == 0 && s[0] == '0')
  800f46:	85 d2                	test   %edx,%edx
  800f48:	75 d4                	jne    800f1e <strtol+0x3f>
    s++, base = 8;
  800f4a:	48 83 c7 01          	add    $0x1,%rdi
  800f4e:	ba 08 00 00 00       	mov    $0x8,%edx
  800f53:	eb c9                	jmp    800f1e <strtol+0x3f>
    s += 2, base = 16;
  800f55:	48 83 c7 02          	add    $0x2,%rdi
  800f59:	ba 10 00 00 00       	mov    $0x10,%edx
  800f5e:	eb be                	jmp    800f1e <strtol+0x3f>
    else if (*s >= 'a' && *s <= 'z')
  800f60:	44 8d 41 9f          	lea    -0x61(%rcx),%r8d
  800f64:	41 80 f8 19          	cmp    $0x19,%r8b
  800f68:	77 2f                	ja     800f99 <strtol+0xba>
      dig = *s - 'a' + 10;
  800f6a:	44 0f be c1          	movsbl %cl,%r8d
  800f6e:	41 8d 48 a9          	lea    -0x57(%r8),%ecx
    if (dig >= base)
  800f72:	39 d1                	cmp    %edx,%ecx
  800f74:	7d 37                	jge    800fad <strtol+0xce>
    s++, val = (val * base) + dig;
  800f76:	48 83 c7 01          	add    $0x1,%rdi
  800f7a:	49 0f af c2          	imul   %r10,%rax
  800f7e:	48 63 c9             	movslq %ecx,%rcx
  800f81:	48 01 c8             	add    %rcx,%rax
    if (*s >= '0' && *s <= '9')
  800f84:	0f b6 0f             	movzbl (%rdi),%ecx
  800f87:	44 8d 41 d0          	lea    -0x30(%rcx),%r8d
  800f8b:	41 80 f8 09          	cmp    $0x9,%r8b
  800f8f:	77 cf                	ja     800f60 <strtol+0x81>
      dig = *s - '0';
  800f91:	0f be c9             	movsbl %cl,%ecx
  800f94:	83 e9 30             	sub    $0x30,%ecx
  800f97:	eb d9                	jmp    800f72 <strtol+0x93>
    else if (*s >= 'A' && *s <= 'Z')
  800f99:	44 8d 41 bf          	lea    -0x41(%rcx),%r8d
  800f9d:	41 80 f8 19          	cmp    $0x19,%r8b
  800fa1:	77 0a                	ja     800fad <strtol+0xce>
      dig = *s - 'A' + 10;
  800fa3:	44 0f be c1          	movsbl %cl,%r8d
  800fa7:	41 8d 48 c9          	lea    -0x37(%r8),%ecx
  800fab:	eb c5                	jmp    800f72 <strtol+0x93>
    // we don't properly detect overflow!
  }

  if (endptr)
  800fad:	48 85 f6             	test   %rsi,%rsi
  800fb0:	74 03                	je     800fb5 <strtol+0xd6>
    *endptr = (char *)s;
  800fb2:	48 89 3e             	mov    %rdi,(%rsi)
  return (neg ? -val : val);
  800fb5:	48 89 c2             	mov    %rax,%rdx
  800fb8:	48 f7 da             	neg    %rdx
  800fbb:	45 85 c9             	test   %r9d,%r9d
  800fbe:	48 0f 45 c2          	cmovne %rdx,%rax
}
  800fc2:	c3                   	retq   

0000000000800fc3 <sys_cputs>:

  return ret;
}

void
sys_cputs(const char *s, size_t len) {
  800fc3:	55                   	push   %rbp
  800fc4:	48 89 e5             	mov    %rsp,%rbp
  800fc7:	53                   	push   %rbx
  800fc8:	48 89 fa             	mov    %rdi,%rdx
  800fcb:	48 89 f1             	mov    %rsi,%rcx
  asm volatile("int %1\n"
  800fce:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd3:	48 89 c3             	mov    %rax,%rbx
  800fd6:	48 89 c7             	mov    %rax,%rdi
  800fd9:	48 89 c6             	mov    %rax,%rsi
  800fdc:	cd 30                	int    $0x30
  syscall(SYS_cputs, 0, (uint64_t)s, len, 0, 0, 0);
}
  800fde:	5b                   	pop    %rbx
  800fdf:	5d                   	pop    %rbp
  800fe0:	c3                   	retq   

0000000000800fe1 <sys_cgetc>:

int
sys_cgetc(void) {
  800fe1:	55                   	push   %rbp
  800fe2:	48 89 e5             	mov    %rsp,%rbp
  800fe5:	53                   	push   %rbx
  asm volatile("int %1\n"
  800fe6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800feb:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff0:	48 89 ca             	mov    %rcx,%rdx
  800ff3:	48 89 cb             	mov    %rcx,%rbx
  800ff6:	48 89 cf             	mov    %rcx,%rdi
  800ff9:	48 89 ce             	mov    %rcx,%rsi
  800ffc:	cd 30                	int    $0x30
  return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ffe:	5b                   	pop    %rbx
  800fff:	5d                   	pop    %rbp
  801000:	c3                   	retq   

0000000000801001 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid) {
  801001:	55                   	push   %rbp
  801002:	48 89 e5             	mov    %rsp,%rbp
  801005:	53                   	push   %rbx
  801006:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80100a:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80100d:	be 00 00 00 00       	mov    $0x0,%esi
  801012:	b8 03 00 00 00       	mov    $0x3,%eax
  801017:	48 89 f1             	mov    %rsi,%rcx
  80101a:	48 89 f3             	mov    %rsi,%rbx
  80101d:	48 89 f7             	mov    %rsi,%rdi
  801020:	cd 30                	int    $0x30
  if (check && ret > 0)
  801022:	48 85 c0             	test   %rax,%rax
  801025:	7f 07                	jg     80102e <sys_env_destroy+0x2d>
}
  801027:	48 83 c4 08          	add    $0x8,%rsp
  80102b:	5b                   	pop    %rbx
  80102c:	5d                   	pop    %rbp
  80102d:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  80102e:	49 89 c0             	mov    %rax,%r8
  801031:	b9 03 00 00 00       	mov    $0x3,%ecx
  801036:	48 ba 00 18 80 00 00 	movabs $0x801800,%rdx
  80103d:	00 00 00 
  801040:	be 22 00 00 00       	mov    $0x22,%esi
  801045:	48 bf 1f 18 80 00 00 	movabs $0x80181f,%rdi
  80104c:	00 00 00 
  80104f:	b8 00 00 00 00       	mov    $0x0,%eax
  801054:	49 b9 0e 13 80 00 00 	movabs $0x80130e,%r9
  80105b:	00 00 00 
  80105e:	41 ff d1             	callq  *%r9

0000000000801061 <sys_getenvid>:

envid_t
sys_getenvid(void) {
  801061:	55                   	push   %rbp
  801062:	48 89 e5             	mov    %rsp,%rbp
  801065:	53                   	push   %rbx
  asm volatile("int %1\n"
  801066:	b9 00 00 00 00       	mov    $0x0,%ecx
  80106b:	b8 02 00 00 00       	mov    $0x2,%eax
  801070:	48 89 ca             	mov    %rcx,%rdx
  801073:	48 89 cb             	mov    %rcx,%rbx
  801076:	48 89 cf             	mov    %rcx,%rdi
  801079:	48 89 ce             	mov    %rcx,%rsi
  80107c:	cd 30                	int    $0x30
  return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80107e:	5b                   	pop    %rbx
  80107f:	5d                   	pop    %rbp
  801080:	c3                   	retq   

0000000000801081 <sys_yield>:

void
sys_yield(void) {
  801081:	55                   	push   %rbp
  801082:	48 89 e5             	mov    %rsp,%rbp
  801085:	53                   	push   %rbx
  asm volatile("int %1\n"
  801086:	b9 00 00 00 00       	mov    $0x0,%ecx
  80108b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801090:	48 89 ca             	mov    %rcx,%rdx
  801093:	48 89 cb             	mov    %rcx,%rbx
  801096:	48 89 cf             	mov    %rcx,%rdi
  801099:	48 89 ce             	mov    %rcx,%rsi
  80109c:	cd 30                	int    $0x30
  syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80109e:	5b                   	pop    %rbx
  80109f:	5d                   	pop    %rbp
  8010a0:	c3                   	retq   

00000000008010a1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm) {
  8010a1:	55                   	push   %rbp
  8010a2:	48 89 e5             	mov    %rsp,%rbp
  8010a5:	53                   	push   %rbx
  8010a6:	48 83 ec 08          	sub    $0x8,%rsp
  8010aa:	48 89 f1             	mov    %rsi,%rcx
  int r = syscall(SYS_page_alloc, 1, envid, (uint64_t)va, perm, 0, 0);
  8010ad:	4c 63 c7             	movslq %edi,%r8
  8010b0:	48 63 da             	movslq %edx,%rbx
  asm volatile("int %1\n"
  8010b3:	be 00 00 00 00       	mov    $0x0,%esi
  8010b8:	b8 04 00 00 00       	mov    $0x4,%eax
  8010bd:	4c 89 c2             	mov    %r8,%rdx
  8010c0:	48 89 f7             	mov    %rsi,%rdi
  8010c3:	cd 30                	int    $0x30
  if (check && ret > 0)
  8010c5:	48 85 c0             	test   %rax,%rax
  8010c8:	7f 07                	jg     8010d1 <sys_page_alloc+0x30>
  // Unpoison the allocated page
  if (!r)
    platform_asan_unpoison(ROUNDDOWN(va, PGSIZE), PGSIZE);
#endif
  return r;
}
  8010ca:	48 83 c4 08          	add    $0x8,%rsp
  8010ce:	5b                   	pop    %rbx
  8010cf:	5d                   	pop    %rbp
  8010d0:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8010d1:	49 89 c0             	mov    %rax,%r8
  8010d4:	b9 04 00 00 00       	mov    $0x4,%ecx
  8010d9:	48 ba 00 18 80 00 00 	movabs $0x801800,%rdx
  8010e0:	00 00 00 
  8010e3:	be 22 00 00 00       	mov    $0x22,%esi
  8010e8:	48 bf 1f 18 80 00 00 	movabs $0x80181f,%rdi
  8010ef:	00 00 00 
  8010f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f7:	49 b9 0e 13 80 00 00 	movabs $0x80130e,%r9
  8010fe:	00 00 00 
  801101:	41 ff d1             	callq  *%r9

0000000000801104 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm) {
  801104:	55                   	push   %rbp
  801105:	48 89 e5             	mov    %rsp,%rbp
  801108:	53                   	push   %rbx
  801109:	48 83 ec 08          	sub    $0x8,%rsp
  80110d:	41 89 f9             	mov    %edi,%r9d
  801110:	49 89 f2             	mov    %rsi,%r10
  801113:	48 89 cf             	mov    %rcx,%rdi
  return syscall(SYS_page_map, 1, srcenv, (uint64_t)srcva, dstenv, (uint64_t)dstva, perm);
  801116:	4d 63 c9             	movslq %r9d,%r9
  801119:	48 63 da             	movslq %edx,%rbx
  80111c:	49 63 f0             	movslq %r8d,%rsi
  asm volatile("int %1\n"
  80111f:	b8 05 00 00 00       	mov    $0x5,%eax
  801124:	4c 89 ca             	mov    %r9,%rdx
  801127:	4c 89 d1             	mov    %r10,%rcx
  80112a:	cd 30                	int    $0x30
  if (check && ret > 0)
  80112c:	48 85 c0             	test   %rax,%rax
  80112f:	7f 07                	jg     801138 <sys_page_map+0x34>
}
  801131:	48 83 c4 08          	add    $0x8,%rsp
  801135:	5b                   	pop    %rbx
  801136:	5d                   	pop    %rbp
  801137:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801138:	49 89 c0             	mov    %rax,%r8
  80113b:	b9 05 00 00 00       	mov    $0x5,%ecx
  801140:	48 ba 00 18 80 00 00 	movabs $0x801800,%rdx
  801147:	00 00 00 
  80114a:	be 22 00 00 00       	mov    $0x22,%esi
  80114f:	48 bf 1f 18 80 00 00 	movabs $0x80181f,%rdi
  801156:	00 00 00 
  801159:	b8 00 00 00 00       	mov    $0x0,%eax
  80115e:	49 b9 0e 13 80 00 00 	movabs $0x80130e,%r9
  801165:	00 00 00 
  801168:	41 ff d1             	callq  *%r9

000000000080116b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va) {
  80116b:	55                   	push   %rbp
  80116c:	48 89 e5             	mov    %rsp,%rbp
  80116f:	53                   	push   %rbx
  801170:	48 83 ec 08          	sub    $0x8,%rsp
  801174:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_page_unmap, 1, envid, (uint64_t)va, 0, 0, 0);
  801177:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80117a:	be 00 00 00 00       	mov    $0x0,%esi
  80117f:	b8 06 00 00 00       	mov    $0x6,%eax
  801184:	48 89 f3             	mov    %rsi,%rbx
  801187:	48 89 f7             	mov    %rsi,%rdi
  80118a:	cd 30                	int    $0x30
  if (check && ret > 0)
  80118c:	48 85 c0             	test   %rax,%rax
  80118f:	7f 07                	jg     801198 <sys_page_unmap+0x2d>
}
  801191:	48 83 c4 08          	add    $0x8,%rsp
  801195:	5b                   	pop    %rbx
  801196:	5d                   	pop    %rbp
  801197:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801198:	49 89 c0             	mov    %rax,%r8
  80119b:	b9 06 00 00 00       	mov    $0x6,%ecx
  8011a0:	48 ba 00 18 80 00 00 	movabs $0x801800,%rdx
  8011a7:	00 00 00 
  8011aa:	be 22 00 00 00       	mov    $0x22,%esi
  8011af:	48 bf 1f 18 80 00 00 	movabs $0x80181f,%rdi
  8011b6:	00 00 00 
  8011b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011be:	49 b9 0e 13 80 00 00 	movabs $0x80130e,%r9
  8011c5:	00 00 00 
  8011c8:	41 ff d1             	callq  *%r9

00000000008011cb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status) {
  8011cb:	55                   	push   %rbp
  8011cc:	48 89 e5             	mov    %rsp,%rbp
  8011cf:	53                   	push   %rbx
  8011d0:	48 83 ec 08          	sub    $0x8,%rsp
  return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8011d4:	48 63 d7             	movslq %edi,%rdx
  8011d7:	48 63 ce             	movslq %esi,%rcx
  asm volatile("int %1\n"
  8011da:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011df:	b8 08 00 00 00       	mov    $0x8,%eax
  8011e4:	48 89 df             	mov    %rbx,%rdi
  8011e7:	48 89 de             	mov    %rbx,%rsi
  8011ea:	cd 30                	int    $0x30
  if (check && ret > 0)
  8011ec:	48 85 c0             	test   %rax,%rax
  8011ef:	7f 07                	jg     8011f8 <sys_env_set_status+0x2d>
}
  8011f1:	48 83 c4 08          	add    $0x8,%rsp
  8011f5:	5b                   	pop    %rbx
  8011f6:	5d                   	pop    %rbp
  8011f7:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8011f8:	49 89 c0             	mov    %rax,%r8
  8011fb:	b9 08 00 00 00       	mov    $0x8,%ecx
  801200:	48 ba 00 18 80 00 00 	movabs $0x801800,%rdx
  801207:	00 00 00 
  80120a:	be 22 00 00 00       	mov    $0x22,%esi
  80120f:	48 bf 1f 18 80 00 00 	movabs $0x80181f,%rdi
  801216:	00 00 00 
  801219:	b8 00 00 00 00       	mov    $0x0,%eax
  80121e:	49 b9 0e 13 80 00 00 	movabs $0x80130e,%r9
  801225:	00 00 00 
  801228:	41 ff d1             	callq  *%r9

000000000080122b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall) {
  80122b:	55                   	push   %rbp
  80122c:	48 89 e5             	mov    %rsp,%rbp
  80122f:	53                   	push   %rbx
  801230:	48 83 ec 08          	sub    $0x8,%rsp
  801234:	48 89 f1             	mov    %rsi,%rcx
  return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint64_t)upcall, 0, 0, 0);
  801237:	48 63 d7             	movslq %edi,%rdx
  asm volatile("int %1\n"
  80123a:	be 00 00 00 00       	mov    $0x0,%esi
  80123f:	b8 09 00 00 00       	mov    $0x9,%eax
  801244:	48 89 f3             	mov    %rsi,%rbx
  801247:	48 89 f7             	mov    %rsi,%rdi
  80124a:	cd 30                	int    $0x30
  if (check && ret > 0)
  80124c:	48 85 c0             	test   %rax,%rax
  80124f:	7f 07                	jg     801258 <sys_env_set_pgfault_upcall+0x2d>
}
  801251:	48 83 c4 08          	add    $0x8,%rsp
  801255:	5b                   	pop    %rbx
  801256:	5d                   	pop    %rbp
  801257:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  801258:	49 89 c0             	mov    %rax,%r8
  80125b:	b9 09 00 00 00       	mov    $0x9,%ecx
  801260:	48 ba 00 18 80 00 00 	movabs $0x801800,%rdx
  801267:	00 00 00 
  80126a:	be 22 00 00 00       	mov    $0x22,%esi
  80126f:	48 bf 1f 18 80 00 00 	movabs $0x80181f,%rdi
  801276:	00 00 00 
  801279:	b8 00 00 00 00       	mov    $0x0,%eax
  80127e:	49 b9 0e 13 80 00 00 	movabs $0x80130e,%r9
  801285:	00 00 00 
  801288:	41 ff d1             	callq  *%r9

000000000080128b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint64_t value, void *srcva, int perm) {
  80128b:	55                   	push   %rbp
  80128c:	48 89 e5             	mov    %rsp,%rbp
  80128f:	53                   	push   %rbx
  801290:	49 89 f0             	mov    %rsi,%r8
  801293:	48 89 d3             	mov    %rdx,%rbx
  return syscall(SYS_ipc_try_send, 0, envid, value, (uint64_t)srcva, perm, 0);
  801296:	48 63 d7             	movslq %edi,%rdx
  801299:	48 63 f9             	movslq %ecx,%rdi
  asm volatile("int %1\n"
  80129c:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012a1:	be 00 00 00 00       	mov    $0x0,%esi
  8012a6:	4c 89 c1             	mov    %r8,%rcx
  8012a9:	cd 30                	int    $0x30
}
  8012ab:	5b                   	pop    %rbx
  8012ac:	5d                   	pop    %rbp
  8012ad:	c3                   	retq   

00000000008012ae <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva) {
  8012ae:	55                   	push   %rbp
  8012af:	48 89 e5             	mov    %rsp,%rbp
  8012b2:	53                   	push   %rbx
  8012b3:	48 83 ec 08          	sub    $0x8,%rsp
  8012b7:	48 89 fa             	mov    %rdi,%rdx
  asm volatile("int %1\n"
  8012ba:	be 00 00 00 00       	mov    $0x0,%esi
  8012bf:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012c4:	48 89 f1             	mov    %rsi,%rcx
  8012c7:	48 89 f3             	mov    %rsi,%rbx
  8012ca:	48 89 f7             	mov    %rsi,%rdi
  8012cd:	cd 30                	int    $0x30
  if (check && ret > 0)
  8012cf:	48 85 c0             	test   %rax,%rax
  8012d2:	7f 07                	jg     8012db <sys_ipc_recv+0x2d>
  return syscall(SYS_ipc_recv, 1, (uint64_t)dstva, 0, 0, 0, 0);
}
  8012d4:	48 83 c4 08          	add    $0x8,%rsp
  8012d8:	5b                   	pop    %rbx
  8012d9:	5d                   	pop    %rbp
  8012da:	c3                   	retq   
    panic("syscall %ld returned %ld (> 0)", (long)num, (long)ret);
  8012db:	49 89 c0             	mov    %rax,%r8
  8012de:	b9 0c 00 00 00       	mov    $0xc,%ecx
  8012e3:	48 ba 00 18 80 00 00 	movabs $0x801800,%rdx
  8012ea:	00 00 00 
  8012ed:	be 22 00 00 00       	mov    $0x22,%esi
  8012f2:	48 bf 1f 18 80 00 00 	movabs $0x80181f,%rdi
  8012f9:	00 00 00 
  8012fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801301:	49 b9 0e 13 80 00 00 	movabs $0x80130e,%r9
  801308:	00 00 00 
  80130b:	41 ff d1             	callq  *%r9

000000000080130e <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...) {
  80130e:	55                   	push   %rbp
  80130f:	48 89 e5             	mov    %rsp,%rbp
  801312:	41 56                	push   %r14
  801314:	41 55                	push   %r13
  801316:	41 54                	push   %r12
  801318:	53                   	push   %rbx
  801319:	48 81 ec d0 00 00 00 	sub    $0xd0,%rsp
  801320:	49 89 fd             	mov    %rdi,%r13
  801323:	41 89 f6             	mov    %esi,%r14d
  801326:	49 89 d4             	mov    %rdx,%r12
  801329:	48 89 8d 48 ff ff ff 	mov    %rcx,-0xb8(%rbp)
  801330:	4c 89 85 50 ff ff ff 	mov    %r8,-0xb0(%rbp)
  801337:	4c 89 8d 58 ff ff ff 	mov    %r9,-0xa8(%rbp)
  80133e:	84 c0                	test   %al,%al
  801340:	74 26                	je     801368 <_panic+0x5a>
  801342:	0f 29 85 60 ff ff ff 	movaps %xmm0,-0xa0(%rbp)
  801349:	0f 29 8d 70 ff ff ff 	movaps %xmm1,-0x90(%rbp)
  801350:	0f 29 55 80          	movaps %xmm2,-0x80(%rbp)
  801354:	0f 29 5d 90          	movaps %xmm3,-0x70(%rbp)
  801358:	0f 29 65 a0          	movaps %xmm4,-0x60(%rbp)
  80135c:	0f 29 6d b0          	movaps %xmm5,-0x50(%rbp)
  801360:	0f 29 75 c0          	movaps %xmm6,-0x40(%rbp)
  801364:	0f 29 7d d0          	movaps %xmm7,-0x30(%rbp)
  va_list ap;

  va_start(ap, fmt);
  801368:	c7 85 18 ff ff ff 18 	movl   $0x18,-0xe8(%rbp)
  80136f:	00 00 00 
  801372:	c7 85 1c ff ff ff 30 	movl   $0x30,-0xe4(%rbp)
  801379:	00 00 00 
  80137c:	48 8d 45 10          	lea    0x10(%rbp),%rax
  801380:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  801387:	48 8d 85 30 ff ff ff 	lea    -0xd0(%rbp),%rax
  80138e:	48 89 85 28 ff ff ff 	mov    %rax,-0xd8(%rbp)

  // Print the panic message
  cprintf("[%08x] user panic in %s at %s:%d: ",
  801395:	48 b8 00 20 80 00 00 	movabs $0x802000,%rax
  80139c:	00 00 00 
  80139f:	48 8b 18             	mov    (%rax),%rbx
  8013a2:	48 b8 61 10 80 00 00 	movabs $0x801061,%rax
  8013a9:	00 00 00 
  8013ac:	ff d0                	callq  *%rax
  8013ae:	45 89 f0             	mov    %r14d,%r8d
  8013b1:	4c 89 e9             	mov    %r13,%rcx
  8013b4:	48 89 da             	mov    %rbx,%rdx
  8013b7:	89 c6                	mov    %eax,%esi
  8013b9:	48 bf 30 18 80 00 00 	movabs $0x801830,%rdi
  8013c0:	00 00 00 
  8013c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c8:	48 bb cf 01 80 00 00 	movabs $0x8001cf,%rbx
  8013cf:	00 00 00 
  8013d2:	ff d3                	callq  *%rbx
          sys_getenvid(), binaryname, file, line);
  vcprintf(fmt, ap);
  8013d4:	48 8d b5 18 ff ff ff 	lea    -0xe8(%rbp),%rsi
  8013db:	4c 89 e7             	mov    %r12,%rdi
  8013de:	48 b8 67 01 80 00 00 	movabs $0x800167,%rax
  8013e5:	00 00 00 
  8013e8:	ff d0                	callq  *%rax
  cprintf("\n");
  8013ea:	48 bf 02 14 80 00 00 	movabs $0x801402,%rdi
  8013f1:	00 00 00 
  8013f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f9:	ff d3                	callq  *%rbx

  // Cause a breakpoint exception
  while (1)
    asm volatile("int3");
  8013fb:	cc                   	int3   
  while (1)
  8013fc:	eb fd                	jmp    8013fb <_panic+0xed>
  8013fe:	66 90                	xchg   %ax,%ax
