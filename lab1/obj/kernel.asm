
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	a009                	j	8020000a <kern_init>

000000008020000a <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000a:	00004517          	auipc	a0,0x4
    8020000e:	00650513          	addi	a0,a0,6 # 80204010 <ticks>
    80200012:	00004617          	auipc	a2,0x4
    80200016:	01660613          	addi	a2,a2,22 # 80204028 <end>
int kern_init(void) {
    8020001a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001c:	8e09                	sub	a2,a2,a0
    8020001e:	4581                	li	a1,0
int kern_init(void) {
    80200020:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200022:	209000ef          	jal	ra,80200a2a <memset>

    cons_init();  // init the console
    80200026:	15a000ef          	jal	ra,80200180 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	a1658593          	addi	a1,a1,-1514 # 80200a40 <etext+0x4>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	a2e50513          	addi	a0,a0,-1490 # 80200a60 <etext+0x24>
    8020003a:	040000ef          	jal	ra,8020007a <cprintf>

    print_kerninfo();
    8020003e:	072000ef          	jal	ra,802000b0 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200042:	14e000ef          	jal	ra,80200190 <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200046:	0f8000ef          	jal	ra,8020013e <clock_init>

    intr_enable();  // enable irq interrupt
    8020004a:	140000ef          	jal	ra,8020018a <intr_enable>
    8020004e:	00100073          	ebreak
    
    asm volatile(".word 0x00100073");//ebreak指令的指令码
    80200052:	00100073          	ebreak
    asm volatile(".word 0x00100073");
    80200056:	ffff                	0xffff
    80200058:	ffff                	0xffff
    asm volatile(".word 0xffffffff");//非法指令码
    8020005a:	ffff                	0xffff
    8020005c:	ffff                	0xffff
    asm volatile(".word 0xffffffff");
    while (1)
    8020005e:	a001                	j	8020005e <kern_init+0x54>

0000000080200060 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200060:	1141                	addi	sp,sp,-16
    80200062:	e022                	sd	s0,0(sp)
    80200064:	e406                	sd	ra,8(sp)
    80200066:	842e                	mv	s0,a1
    cons_putc(c);
    80200068:	11a000ef          	jal	ra,80200182 <cons_putc>
    (*cnt)++;
    8020006c:	401c                	lw	a5,0(s0)
}
    8020006e:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200070:	2785                	addiw	a5,a5,1
    80200072:	c01c                	sw	a5,0(s0)
}
    80200074:	6402                	ld	s0,0(sp)
    80200076:	0141                	addi	sp,sp,16
    80200078:	8082                	ret

000000008020007a <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    8020007a:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    8020007c:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    80200080:	8e2a                	mv	t3,a0
    80200082:	f42e                	sd	a1,40(sp)
    80200084:	f832                	sd	a2,48(sp)
    80200086:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200088:	00000517          	auipc	a0,0x0
    8020008c:	fd850513          	addi	a0,a0,-40 # 80200060 <cputch>
    80200090:	004c                	addi	a1,sp,4
    80200092:	869a                	mv	a3,t1
    80200094:	8672                	mv	a2,t3
int cprintf(const char *fmt, ...) {
    80200096:	ec06                	sd	ra,24(sp)
    80200098:	e0ba                	sd	a4,64(sp)
    8020009a:	e4be                	sd	a5,72(sp)
    8020009c:	e8c2                	sd	a6,80(sp)
    8020009e:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    802000a0:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    802000a2:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    802000a4:	59a000ef          	jal	ra,8020063e <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    802000a8:	60e2                	ld	ra,24(sp)
    802000aa:	4512                	lw	a0,4(sp)
    802000ac:	6125                	addi	sp,sp,96
    802000ae:	8082                	ret

00000000802000b0 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000b0:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000b2:	00001517          	auipc	a0,0x1
    802000b6:	9b650513          	addi	a0,a0,-1610 # 80200a68 <etext+0x2c>
void print_kerninfo(void) {
    802000ba:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000bc:	fbfff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000c0:	00000597          	auipc	a1,0x0
    802000c4:	f4a58593          	addi	a1,a1,-182 # 8020000a <kern_init>
    802000c8:	00001517          	auipc	a0,0x1
    802000cc:	9c050513          	addi	a0,a0,-1600 # 80200a88 <etext+0x4c>
    802000d0:	fabff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000d4:	00001597          	auipc	a1,0x1
    802000d8:	96858593          	addi	a1,a1,-1688 # 80200a3c <etext>
    802000dc:	00001517          	auipc	a0,0x1
    802000e0:	9cc50513          	addi	a0,a0,-1588 # 80200aa8 <etext+0x6c>
    802000e4:	f97ff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000e8:	00004597          	auipc	a1,0x4
    802000ec:	f2858593          	addi	a1,a1,-216 # 80204010 <ticks>
    802000f0:	00001517          	auipc	a0,0x1
    802000f4:	9d850513          	addi	a0,a0,-1576 # 80200ac8 <etext+0x8c>
    802000f8:	f83ff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000fc:	00004597          	auipc	a1,0x4
    80200100:	f2c58593          	addi	a1,a1,-212 # 80204028 <end>
    80200104:	00001517          	auipc	a0,0x1
    80200108:	9e450513          	addi	a0,a0,-1564 # 80200ae8 <etext+0xac>
    8020010c:	f6fff0ef          	jal	ra,8020007a <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200110:	00004597          	auipc	a1,0x4
    80200114:	31758593          	addi	a1,a1,791 # 80204427 <end+0x3ff>
    80200118:	00000797          	auipc	a5,0x0
    8020011c:	ef278793          	addi	a5,a5,-270 # 8020000a <kern_init>
    80200120:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200124:	43f7d593          	srai	a1,a5,0x3f
}
    80200128:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020012a:	3ff5f593          	andi	a1,a1,1023
    8020012e:	95be                	add	a1,a1,a5
    80200130:	85a9                	srai	a1,a1,0xa
    80200132:	00001517          	auipc	a0,0x1
    80200136:	9d650513          	addi	a0,a0,-1578 # 80200b08 <etext+0xcc>
}
    8020013a:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020013c:	bf3d                	j	8020007a <cprintf>

000000008020013e <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    8020013e:	1141                	addi	sp,sp,-16
    80200140:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200142:	02000793          	li	a5,32
    80200146:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020014a:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    8020014e:	67e1                	lui	a5,0x18
    80200150:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200154:	953e                	add	a0,a0,a5
    80200156:	085000ef          	jal	ra,802009da <sbi_set_timer>
}
    8020015a:	60a2                	ld	ra,8(sp)
    ticks = 0;
    8020015c:	00004797          	auipc	a5,0x4
    80200160:	ea07ba23          	sd	zero,-332(a5) # 80204010 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200164:	00001517          	auipc	a0,0x1
    80200168:	9d450513          	addi	a0,a0,-1580 # 80200b38 <etext+0xfc>
}
    8020016c:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    8020016e:	b731                	j	8020007a <cprintf>

0000000080200170 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200170:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200174:	67e1                	lui	a5,0x18
    80200176:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    8020017a:	953e                	add	a0,a0,a5
    8020017c:	05f0006f          	j	802009da <sbi_set_timer>

0000000080200180 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    80200180:	8082                	ret

0000000080200182 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    80200182:	0ff57513          	zext.b	a0,a0
    80200186:	03b0006f          	j	802009c0 <sbi_console_putchar>

000000008020018a <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    8020018a:	100167f3          	csrrsi	a5,sstatus,2
    8020018e:	8082                	ret

0000000080200190 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200190:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    80200194:	00000797          	auipc	a5,0x0
    80200198:	38878793          	addi	a5,a5,904 # 8020051c <__alltraps>
    8020019c:	10579073          	csrw	stvec,a5
}
    802001a0:	8082                	ret

00000000802001a2 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a2:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    802001a4:	1141                	addi	sp,sp,-16
    802001a6:	e022                	sd	s0,0(sp)
    802001a8:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001aa:	00001517          	auipc	a0,0x1
    802001ae:	9ae50513          	addi	a0,a0,-1618 # 80200b58 <etext+0x11c>
void print_regs(struct pushregs *gpr) {
    802001b2:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001b4:	ec7ff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001b8:	640c                	ld	a1,8(s0)
    802001ba:	00001517          	auipc	a0,0x1
    802001be:	9b650513          	addi	a0,a0,-1610 # 80200b70 <etext+0x134>
    802001c2:	eb9ff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001c6:	680c                	ld	a1,16(s0)
    802001c8:	00001517          	auipc	a0,0x1
    802001cc:	9c050513          	addi	a0,a0,-1600 # 80200b88 <etext+0x14c>
    802001d0:	eabff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001d4:	6c0c                	ld	a1,24(s0)
    802001d6:	00001517          	auipc	a0,0x1
    802001da:	9ca50513          	addi	a0,a0,-1590 # 80200ba0 <etext+0x164>
    802001de:	e9dff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001e2:	700c                	ld	a1,32(s0)
    802001e4:	00001517          	auipc	a0,0x1
    802001e8:	9d450513          	addi	a0,a0,-1580 # 80200bb8 <etext+0x17c>
    802001ec:	e8fff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001f0:	740c                	ld	a1,40(s0)
    802001f2:	00001517          	auipc	a0,0x1
    802001f6:	9de50513          	addi	a0,a0,-1570 # 80200bd0 <etext+0x194>
    802001fa:	e81ff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001fe:	780c                	ld	a1,48(s0)
    80200200:	00001517          	auipc	a0,0x1
    80200204:	9e850513          	addi	a0,a0,-1560 # 80200be8 <etext+0x1ac>
    80200208:	e73ff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    8020020c:	7c0c                	ld	a1,56(s0)
    8020020e:	00001517          	auipc	a0,0x1
    80200212:	9f250513          	addi	a0,a0,-1550 # 80200c00 <etext+0x1c4>
    80200216:	e65ff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    8020021a:	602c                	ld	a1,64(s0)
    8020021c:	00001517          	auipc	a0,0x1
    80200220:	9fc50513          	addi	a0,a0,-1540 # 80200c18 <etext+0x1dc>
    80200224:	e57ff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200228:	642c                	ld	a1,72(s0)
    8020022a:	00001517          	auipc	a0,0x1
    8020022e:	a0650513          	addi	a0,a0,-1530 # 80200c30 <etext+0x1f4>
    80200232:	e49ff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    80200236:	682c                	ld	a1,80(s0)
    80200238:	00001517          	auipc	a0,0x1
    8020023c:	a1050513          	addi	a0,a0,-1520 # 80200c48 <etext+0x20c>
    80200240:	e3bff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200244:	6c2c                	ld	a1,88(s0)
    80200246:	00001517          	auipc	a0,0x1
    8020024a:	a1a50513          	addi	a0,a0,-1510 # 80200c60 <etext+0x224>
    8020024e:	e2dff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200252:	702c                	ld	a1,96(s0)
    80200254:	00001517          	auipc	a0,0x1
    80200258:	a2450513          	addi	a0,a0,-1500 # 80200c78 <etext+0x23c>
    8020025c:	e1fff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200260:	742c                	ld	a1,104(s0)
    80200262:	00001517          	auipc	a0,0x1
    80200266:	a2e50513          	addi	a0,a0,-1490 # 80200c90 <etext+0x254>
    8020026a:	e11ff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    8020026e:	782c                	ld	a1,112(s0)
    80200270:	00001517          	auipc	a0,0x1
    80200274:	a3850513          	addi	a0,a0,-1480 # 80200ca8 <etext+0x26c>
    80200278:	e03ff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    8020027c:	7c2c                	ld	a1,120(s0)
    8020027e:	00001517          	auipc	a0,0x1
    80200282:	a4250513          	addi	a0,a0,-1470 # 80200cc0 <etext+0x284>
    80200286:	df5ff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    8020028a:	604c                	ld	a1,128(s0)
    8020028c:	00001517          	auipc	a0,0x1
    80200290:	a4c50513          	addi	a0,a0,-1460 # 80200cd8 <etext+0x29c>
    80200294:	de7ff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200298:	644c                	ld	a1,136(s0)
    8020029a:	00001517          	auipc	a0,0x1
    8020029e:	a5650513          	addi	a0,a0,-1450 # 80200cf0 <etext+0x2b4>
    802002a2:	dd9ff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    802002a6:	684c                	ld	a1,144(s0)
    802002a8:	00001517          	auipc	a0,0x1
    802002ac:	a6050513          	addi	a0,a0,-1440 # 80200d08 <etext+0x2cc>
    802002b0:	dcbff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002b4:	6c4c                	ld	a1,152(s0)
    802002b6:	00001517          	auipc	a0,0x1
    802002ba:	a6a50513          	addi	a0,a0,-1430 # 80200d20 <etext+0x2e4>
    802002be:	dbdff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002c2:	704c                	ld	a1,160(s0)
    802002c4:	00001517          	auipc	a0,0x1
    802002c8:	a7450513          	addi	a0,a0,-1420 # 80200d38 <etext+0x2fc>
    802002cc:	dafff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002d0:	744c                	ld	a1,168(s0)
    802002d2:	00001517          	auipc	a0,0x1
    802002d6:	a7e50513          	addi	a0,a0,-1410 # 80200d50 <etext+0x314>
    802002da:	da1ff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002de:	784c                	ld	a1,176(s0)
    802002e0:	00001517          	auipc	a0,0x1
    802002e4:	a8850513          	addi	a0,a0,-1400 # 80200d68 <etext+0x32c>
    802002e8:	d93ff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002ec:	7c4c                	ld	a1,184(s0)
    802002ee:	00001517          	auipc	a0,0x1
    802002f2:	a9250513          	addi	a0,a0,-1390 # 80200d80 <etext+0x344>
    802002f6:	d85ff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002fa:	606c                	ld	a1,192(s0)
    802002fc:	00001517          	auipc	a0,0x1
    80200300:	a9c50513          	addi	a0,a0,-1380 # 80200d98 <etext+0x35c>
    80200304:	d77ff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    80200308:	646c                	ld	a1,200(s0)
    8020030a:	00001517          	auipc	a0,0x1
    8020030e:	aa650513          	addi	a0,a0,-1370 # 80200db0 <etext+0x374>
    80200312:	d69ff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    80200316:	686c                	ld	a1,208(s0)
    80200318:	00001517          	auipc	a0,0x1
    8020031c:	ab050513          	addi	a0,a0,-1360 # 80200dc8 <etext+0x38c>
    80200320:	d5bff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200324:	6c6c                	ld	a1,216(s0)
    80200326:	00001517          	auipc	a0,0x1
    8020032a:	aba50513          	addi	a0,a0,-1350 # 80200de0 <etext+0x3a4>
    8020032e:	d4dff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200332:	706c                	ld	a1,224(s0)
    80200334:	00001517          	auipc	a0,0x1
    80200338:	ac450513          	addi	a0,a0,-1340 # 80200df8 <etext+0x3bc>
    8020033c:	d3fff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200340:	746c                	ld	a1,232(s0)
    80200342:	00001517          	auipc	a0,0x1
    80200346:	ace50513          	addi	a0,a0,-1330 # 80200e10 <etext+0x3d4>
    8020034a:	d31ff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    8020034e:	786c                	ld	a1,240(s0)
    80200350:	00001517          	auipc	a0,0x1
    80200354:	ad850513          	addi	a0,a0,-1320 # 80200e28 <etext+0x3ec>
    80200358:	d23ff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020035c:	7c6c                	ld	a1,248(s0)
}
    8020035e:	6402                	ld	s0,0(sp)
    80200360:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200362:	00001517          	auipc	a0,0x1
    80200366:	ade50513          	addi	a0,a0,-1314 # 80200e40 <etext+0x404>
}
    8020036a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020036c:	b339                	j	8020007a <cprintf>

000000008020036e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    8020036e:	1141                	addi	sp,sp,-16
    80200370:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200372:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    80200374:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    80200376:	00001517          	auipc	a0,0x1
    8020037a:	ae250513          	addi	a0,a0,-1310 # 80200e58 <etext+0x41c>
void print_trapframe(struct trapframe *tf) {
    8020037e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200380:	cfbff0ef          	jal	ra,8020007a <cprintf>
    print_regs(&tf->gpr);
    80200384:	8522                	mv	a0,s0
    80200386:	e1dff0ef          	jal	ra,802001a2 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    8020038a:	10043583          	ld	a1,256(s0)
    8020038e:	00001517          	auipc	a0,0x1
    80200392:	ae250513          	addi	a0,a0,-1310 # 80200e70 <etext+0x434>
    80200396:	ce5ff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    8020039a:	10843583          	ld	a1,264(s0)
    8020039e:	00001517          	auipc	a0,0x1
    802003a2:	aea50513          	addi	a0,a0,-1302 # 80200e88 <etext+0x44c>
    802003a6:	cd5ff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    802003aa:	11043583          	ld	a1,272(s0)
    802003ae:	00001517          	auipc	a0,0x1
    802003b2:	af250513          	addi	a0,a0,-1294 # 80200ea0 <etext+0x464>
    802003b6:	cc5ff0ef          	jal	ra,8020007a <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003ba:	11843583          	ld	a1,280(s0)
}
    802003be:	6402                	ld	s0,0(sp)
    802003c0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003c2:	00001517          	auipc	a0,0x1
    802003c6:	af650513          	addi	a0,a0,-1290 # 80200eb8 <etext+0x47c>
}
    802003ca:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003cc:	b17d                	j	8020007a <cprintf>

00000000802003ce <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003ce:	11853783          	ld	a5,280(a0)
    802003d2:	472d                	li	a4,11
    802003d4:	0786                	slli	a5,a5,0x1
    802003d6:	8385                	srli	a5,a5,0x1
    802003d8:	06f76763          	bltu	a4,a5,80200446 <interrupt_handler+0x78>
    802003dc:	00001717          	auipc	a4,0x1
    802003e0:	bb470713          	addi	a4,a4,-1100 # 80200f90 <etext+0x554>
    802003e4:	078a                	slli	a5,a5,0x2
    802003e6:	97ba                	add	a5,a5,a4
    802003e8:	439c                	lw	a5,0(a5)
    802003ea:	97ba                	add	a5,a5,a4
    802003ec:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003ee:	00001517          	auipc	a0,0x1
    802003f2:	b4250513          	addi	a0,a0,-1214 # 80200f30 <etext+0x4f4>
    802003f6:	b151                	j	8020007a <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003f8:	00001517          	auipc	a0,0x1
    802003fc:	b1850513          	addi	a0,a0,-1256 # 80200f10 <etext+0x4d4>
    80200400:	b9ad                	j	8020007a <cprintf>
            cprintf("User software interrupt\n");
    80200402:	00001517          	auipc	a0,0x1
    80200406:	ace50513          	addi	a0,a0,-1330 # 80200ed0 <etext+0x494>
    8020040a:	b985                	j	8020007a <cprintf>
            cprintf("Supervisor software interrupt\n");
    8020040c:	00001517          	auipc	a0,0x1
    80200410:	ae450513          	addi	a0,a0,-1308 # 80200ef0 <etext+0x4b4>
    80200414:	b19d                	j	8020007a <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200416:	1141                	addi	sp,sp,-16
    80200418:	e406                	sd	ra,8(sp)
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
            //cprintf("Supervisor timer interrupt\n");
            clock_set_next_event();
    8020041a:	d57ff0ef          	jal	ra,80200170 <clock_set_next_event>
            ticks++;
    8020041e:	00004797          	auipc	a5,0x4
    80200422:	bf278793          	addi	a5,a5,-1038 # 80204010 <ticks>
    80200426:	6398                	ld	a4,0(a5)
            if(ticks==TICK_NUM) {
    80200428:	06400693          	li	a3,100
            ticks++;
    8020042c:	0705                	addi	a4,a4,1
    8020042e:	e398                	sd	a4,0(a5)
            if(ticks==TICK_NUM) {
    80200430:	639c                	ld	a5,0(a5)
    80200432:	00d78b63          	beq	a5,a3,80200448 <interrupt_handler+0x7a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200436:	60a2                	ld	ra,8(sp)
    80200438:	0141                	addi	sp,sp,16
    8020043a:	8082                	ret
            cprintf("Supervisor external interrupt\n");
    8020043c:	00001517          	auipc	a0,0x1
    80200440:	b3450513          	addi	a0,a0,-1228 # 80200f70 <etext+0x534>
    80200444:	b91d                	j	8020007a <cprintf>
            print_trapframe(tf);
    80200446:	b725                	j	8020036e <print_trapframe>
                cprintf("%dticks\n",TICK_NUM);
    80200448:	06400593          	li	a1,100
    8020044c:	00001517          	auipc	a0,0x1
    80200450:	b0450513          	addi	a0,a0,-1276 # 80200f50 <etext+0x514>
    80200454:	c27ff0ef          	jal	ra,8020007a <cprintf>
                num++;
    80200458:	00004797          	auipc	a5,0x4
    8020045c:	bc078793          	addi	a5,a5,-1088 # 80204018 <num>
    80200460:	6398                	ld	a4,0(a5)
                if(num==10) {
    80200462:	46a9                	li	a3,10
                num++;
    80200464:	0705                	addi	a4,a4,1
    80200466:	e398                	sd	a4,0(a5)
                ticks=0;
    80200468:	00004717          	auipc	a4,0x4
    8020046c:	ba073423          	sd	zero,-1112(a4) # 80204010 <ticks>
                if(num==10) {
    80200470:	639c                	ld	a5,0(a5)
    80200472:	fcd792e3          	bne	a5,a3,80200436 <interrupt_handler+0x68>
                    cprintf("shutdown\n");
    80200476:	00001517          	auipc	a0,0x1
    8020047a:	aea50513          	addi	a0,a0,-1302 # 80200f60 <etext+0x524>
    8020047e:	bfdff0ef          	jal	ra,8020007a <cprintf>
}
    80200482:	60a2                	ld	ra,8(sp)
    80200484:	0141                	addi	sp,sp,16
                    sbi_shutdown();
    80200486:	a3bd                	j	802009f4 <sbi_shutdown>

0000000080200488 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    80200488:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
    8020048c:	1141                	addi	sp,sp,-16
    8020048e:	e022                	sd	s0,0(sp)
    80200490:	e406                	sd	ra,8(sp)
    switch (tf->cause) {
    80200492:	470d                	li	a4,3
void exception_handler(struct trapframe *tf) {
    80200494:	842a                	mv	s0,a0
    switch (tf->cause) {
    80200496:	04e78663          	beq	a5,a4,802004e2 <exception_handler+0x5a>
    8020049a:	02f76c63          	bltu	a4,a5,802004d2 <exception_handler+0x4a>
    8020049e:	4709                	li	a4,2
    802004a0:	02e79563          	bne	a5,a4,802004ca <exception_handler+0x42>
             /* LAB1 CHALLENGE3   YOUR CODE :  */
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
           cprintf("Exception type:Illegal instruction\n");
    802004a4:	00001517          	auipc	a0,0x1
    802004a8:	b1c50513          	addi	a0,a0,-1252 # 80200fc0 <etext+0x584>
    802004ac:	bcfff0ef          	jal	ra,8020007a <cprintf>
           //输出指令异常类型为非法指令（Illegal instruction）
           cprintf("Illegal instruction caught at0x%x\n", tf->epc);
    802004b0:	10843583          	ld	a1,264(s0)
    802004b4:	00001517          	auipc	a0,0x1
    802004b8:	b3450513          	addi	a0,a0,-1228 # 80200fe8 <etext+0x5ac>
    802004bc:	bbfff0ef          	jal	ra,8020007a <cprintf>
           //输出触发异常的指令地址
           tf->epc+=4;
    802004c0:	10843783          	ld	a5,264(s0)
    802004c4:	0791                	addi	a5,a5,4
    802004c6:	10f43423          	sd	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004ca:	60a2                	ld	ra,8(sp)
    802004cc:	6402                	ld	s0,0(sp)
    802004ce:	0141                	addi	sp,sp,16
    802004d0:	8082                	ret
    switch (tf->cause) {
    802004d2:	17f1                	addi	a5,a5,-4
    802004d4:	471d                	li	a4,7
    802004d6:	fef77ae3          	bgeu	a4,a5,802004ca <exception_handler+0x42>
}
    802004da:	6402                	ld	s0,0(sp)
    802004dc:	60a2                	ld	ra,8(sp)
    802004de:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004e0:	b579                	j	8020036e <print_trapframe>
            cprintf("Exception type: breakpoint\n");
    802004e2:	00001517          	auipc	a0,0x1
    802004e6:	b2e50513          	addi	a0,a0,-1234 # 80201010 <etext+0x5d4>
    802004ea:	b91ff0ef          	jal	ra,8020007a <cprintf>
            cprintf("ebreak caught at0x%x\n", tf->epc);
    802004ee:	10843583          	ld	a1,264(s0)
    802004f2:	00001517          	auipc	a0,0x1
    802004f6:	b3e50513          	addi	a0,a0,-1218 # 80201030 <etext+0x5f4>
    802004fa:	b81ff0ef          	jal	ra,8020007a <cprintf>
            tf->epc+=4;
    802004fe:	10843783          	ld	a5,264(s0)
}
    80200502:	60a2                	ld	ra,8(sp)
            tf->epc+=4;
    80200504:	0791                	addi	a5,a5,4
    80200506:	10f43423          	sd	a5,264(s0)
}
    8020050a:	6402                	ld	s0,0(sp)
    8020050c:	0141                	addi	sp,sp,16
    8020050e:	8082                	ret

0000000080200510 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    80200510:	11853783          	ld	a5,280(a0)
    80200514:	0007c363          	bltz	a5,8020051a <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    80200518:	bf85                	j	80200488 <exception_handler>
        interrupt_handler(tf);
    8020051a:	bd55                	j	802003ce <interrupt_handler>

000000008020051c <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    8020051c:	14011073          	csrw	sscratch,sp
    80200520:	712d                	addi	sp,sp,-288
    80200522:	e002                	sd	zero,0(sp)
    80200524:	e406                	sd	ra,8(sp)
    80200526:	ec0e                	sd	gp,24(sp)
    80200528:	f012                	sd	tp,32(sp)
    8020052a:	f416                	sd	t0,40(sp)
    8020052c:	f81a                	sd	t1,48(sp)
    8020052e:	fc1e                	sd	t2,56(sp)
    80200530:	e0a2                	sd	s0,64(sp)
    80200532:	e4a6                	sd	s1,72(sp)
    80200534:	e8aa                	sd	a0,80(sp)
    80200536:	ecae                	sd	a1,88(sp)
    80200538:	f0b2                	sd	a2,96(sp)
    8020053a:	f4b6                	sd	a3,104(sp)
    8020053c:	f8ba                	sd	a4,112(sp)
    8020053e:	fcbe                	sd	a5,120(sp)
    80200540:	e142                	sd	a6,128(sp)
    80200542:	e546                	sd	a7,136(sp)
    80200544:	e94a                	sd	s2,144(sp)
    80200546:	ed4e                	sd	s3,152(sp)
    80200548:	f152                	sd	s4,160(sp)
    8020054a:	f556                	sd	s5,168(sp)
    8020054c:	f95a                	sd	s6,176(sp)
    8020054e:	fd5e                	sd	s7,184(sp)
    80200550:	e1e2                	sd	s8,192(sp)
    80200552:	e5e6                	sd	s9,200(sp)
    80200554:	e9ea                	sd	s10,208(sp)
    80200556:	edee                	sd	s11,216(sp)
    80200558:	f1f2                	sd	t3,224(sp)
    8020055a:	f5f6                	sd	t4,232(sp)
    8020055c:	f9fa                	sd	t5,240(sp)
    8020055e:	fdfe                	sd	t6,248(sp)
    80200560:	14001473          	csrrw	s0,sscratch,zero
    80200564:	100024f3          	csrr	s1,sstatus
    80200568:	14102973          	csrr	s2,sepc
    8020056c:	143029f3          	csrr	s3,stval
    80200570:	14202a73          	csrr	s4,scause
    80200574:	e822                	sd	s0,16(sp)
    80200576:	e226                	sd	s1,256(sp)
    80200578:	e64a                	sd	s2,264(sp)
    8020057a:	ea4e                	sd	s3,272(sp)
    8020057c:	ee52                	sd	s4,280(sp)

    move  a0, sp
    8020057e:	850a                	mv	a0,sp
    jal trap
    80200580:	f91ff0ef          	jal	ra,80200510 <trap>

0000000080200584 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    80200584:	6492                	ld	s1,256(sp)
    80200586:	6932                	ld	s2,264(sp)
    80200588:	10049073          	csrw	sstatus,s1
    8020058c:	14191073          	csrw	sepc,s2
    80200590:	60a2                	ld	ra,8(sp)
    80200592:	61e2                	ld	gp,24(sp)
    80200594:	7202                	ld	tp,32(sp)
    80200596:	72a2                	ld	t0,40(sp)
    80200598:	7342                	ld	t1,48(sp)
    8020059a:	73e2                	ld	t2,56(sp)
    8020059c:	6406                	ld	s0,64(sp)
    8020059e:	64a6                	ld	s1,72(sp)
    802005a0:	6546                	ld	a0,80(sp)
    802005a2:	65e6                	ld	a1,88(sp)
    802005a4:	7606                	ld	a2,96(sp)
    802005a6:	76a6                	ld	a3,104(sp)
    802005a8:	7746                	ld	a4,112(sp)
    802005aa:	77e6                	ld	a5,120(sp)
    802005ac:	680a                	ld	a6,128(sp)
    802005ae:	68aa                	ld	a7,136(sp)
    802005b0:	694a                	ld	s2,144(sp)
    802005b2:	69ea                	ld	s3,152(sp)
    802005b4:	7a0a                	ld	s4,160(sp)
    802005b6:	7aaa                	ld	s5,168(sp)
    802005b8:	7b4a                	ld	s6,176(sp)
    802005ba:	7bea                	ld	s7,184(sp)
    802005bc:	6c0e                	ld	s8,192(sp)
    802005be:	6cae                	ld	s9,200(sp)
    802005c0:	6d4e                	ld	s10,208(sp)
    802005c2:	6dee                	ld	s11,216(sp)
    802005c4:	7e0e                	ld	t3,224(sp)
    802005c6:	7eae                	ld	t4,232(sp)
    802005c8:	7f4e                	ld	t5,240(sp)
    802005ca:	7fee                	ld	t6,248(sp)
    802005cc:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802005ce:	10200073          	sret

00000000802005d2 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    802005d2:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005d6:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    802005d8:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005dc:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    802005de:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    802005e2:	f022                	sd	s0,32(sp)
    802005e4:	ec26                	sd	s1,24(sp)
    802005e6:	e84a                	sd	s2,16(sp)
    802005e8:	f406                	sd	ra,40(sp)
    802005ea:	e44e                	sd	s3,8(sp)
    802005ec:	84aa                	mv	s1,a0
    802005ee:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    802005f0:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    802005f4:	2a01                	sext.w	s4,s4
    if (num >= base) {
    802005f6:	03067e63          	bgeu	a2,a6,80200632 <printnum+0x60>
    802005fa:	89be                	mv	s3,a5
        while (-- width > 0)
    802005fc:	00805763          	blez	s0,8020060a <printnum+0x38>
    80200600:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    80200602:	85ca                	mv	a1,s2
    80200604:	854e                	mv	a0,s3
    80200606:	9482                	jalr	s1
        while (-- width > 0)
    80200608:	fc65                	bnez	s0,80200600 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    8020060a:	1a02                	slli	s4,s4,0x20
    8020060c:	00001797          	auipc	a5,0x1
    80200610:	a3c78793          	addi	a5,a5,-1476 # 80201048 <etext+0x60c>
    80200614:	020a5a13          	srli	s4,s4,0x20
    80200618:	9a3e                	add	s4,s4,a5
}
    8020061a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    8020061c:	000a4503          	lbu	a0,0(s4)
}
    80200620:	70a2                	ld	ra,40(sp)
    80200622:	69a2                	ld	s3,8(sp)
    80200624:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200626:	85ca                	mv	a1,s2
    80200628:	87a6                	mv	a5,s1
}
    8020062a:	6942                	ld	s2,16(sp)
    8020062c:	64e2                	ld	s1,24(sp)
    8020062e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    80200630:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
    80200632:	03065633          	divu	a2,a2,a6
    80200636:	8722                	mv	a4,s0
    80200638:	f9bff0ef          	jal	ra,802005d2 <printnum>
    8020063c:	b7f9                	j	8020060a <printnum+0x38>

000000008020063e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    8020063e:	7119                	addi	sp,sp,-128
    80200640:	f4a6                	sd	s1,104(sp)
    80200642:	f0ca                	sd	s2,96(sp)
    80200644:	ecce                	sd	s3,88(sp)
    80200646:	e8d2                	sd	s4,80(sp)
    80200648:	e4d6                	sd	s5,72(sp)
    8020064a:	e0da                	sd	s6,64(sp)
    8020064c:	fc5e                	sd	s7,56(sp)
    8020064e:	f06a                	sd	s10,32(sp)
    80200650:	fc86                	sd	ra,120(sp)
    80200652:	f8a2                	sd	s0,112(sp)
    80200654:	f862                	sd	s8,48(sp)
    80200656:	f466                	sd	s9,40(sp)
    80200658:	ec6e                	sd	s11,24(sp)
    8020065a:	892a                	mv	s2,a0
    8020065c:	84ae                	mv	s1,a1
    8020065e:	8d32                	mv	s10,a2
    80200660:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200662:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    80200666:	5b7d                	li	s6,-1
    80200668:	00001a97          	auipc	s5,0x1
    8020066c:	a14a8a93          	addi	s5,s5,-1516 # 8020107c <etext+0x640>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200670:	00001b97          	auipc	s7,0x1
    80200674:	be8b8b93          	addi	s7,s7,-1048 # 80201258 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200678:	000d4503          	lbu	a0,0(s10)
    8020067c:	001d0413          	addi	s0,s10,1
    80200680:	01350a63          	beq	a0,s3,80200694 <vprintfmt+0x56>
            if (ch == '\0') {
    80200684:	c121                	beqz	a0,802006c4 <vprintfmt+0x86>
            putch(ch, putdat);
    80200686:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200688:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    8020068a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020068c:	fff44503          	lbu	a0,-1(s0)
    80200690:	ff351ae3          	bne	a0,s3,80200684 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
    80200694:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    80200698:	02000793          	li	a5,32
        lflag = altflag = 0;
    8020069c:	4c81                	li	s9,0
    8020069e:	4881                	li	a7,0
        width = precision = -1;
    802006a0:	5c7d                	li	s8,-1
    802006a2:	5dfd                	li	s11,-1
    802006a4:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
    802006a8:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
    802006aa:	fdd6059b          	addiw	a1,a2,-35
    802006ae:	0ff5f593          	zext.b	a1,a1
    802006b2:	00140d13          	addi	s10,s0,1
    802006b6:	04b56263          	bltu	a0,a1,802006fa <vprintfmt+0xbc>
    802006ba:	058a                	slli	a1,a1,0x2
    802006bc:	95d6                	add	a1,a1,s5
    802006be:	4194                	lw	a3,0(a1)
    802006c0:	96d6                	add	a3,a3,s5
    802006c2:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    802006c4:	70e6                	ld	ra,120(sp)
    802006c6:	7446                	ld	s0,112(sp)
    802006c8:	74a6                	ld	s1,104(sp)
    802006ca:	7906                	ld	s2,96(sp)
    802006cc:	69e6                	ld	s3,88(sp)
    802006ce:	6a46                	ld	s4,80(sp)
    802006d0:	6aa6                	ld	s5,72(sp)
    802006d2:	6b06                	ld	s6,64(sp)
    802006d4:	7be2                	ld	s7,56(sp)
    802006d6:	7c42                	ld	s8,48(sp)
    802006d8:	7ca2                	ld	s9,40(sp)
    802006da:	7d02                	ld	s10,32(sp)
    802006dc:	6de2                	ld	s11,24(sp)
    802006de:	6109                	addi	sp,sp,128
    802006e0:	8082                	ret
            padc = '0';
    802006e2:	87b2                	mv	a5,a2
            goto reswitch;
    802006e4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802006e8:	846a                	mv	s0,s10
    802006ea:	00140d13          	addi	s10,s0,1
    802006ee:	fdd6059b          	addiw	a1,a2,-35
    802006f2:	0ff5f593          	zext.b	a1,a1
    802006f6:	fcb572e3          	bgeu	a0,a1,802006ba <vprintfmt+0x7c>
            putch('%', putdat);
    802006fa:	85a6                	mv	a1,s1
    802006fc:	02500513          	li	a0,37
    80200700:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    80200702:	fff44783          	lbu	a5,-1(s0)
    80200706:	8d22                	mv	s10,s0
    80200708:	f73788e3          	beq	a5,s3,80200678 <vprintfmt+0x3a>
    8020070c:	ffed4783          	lbu	a5,-2(s10)
    80200710:	1d7d                	addi	s10,s10,-1
    80200712:	ff379de3          	bne	a5,s3,8020070c <vprintfmt+0xce>
    80200716:	b78d                	j	80200678 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
    80200718:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
    8020071c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    80200720:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    80200722:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    80200726:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    8020072a:	02d86463          	bltu	a6,a3,80200752 <vprintfmt+0x114>
                ch = *fmt;
    8020072e:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
    80200732:	002c169b          	slliw	a3,s8,0x2
    80200736:	0186873b          	addw	a4,a3,s8
    8020073a:	0017171b          	slliw	a4,a4,0x1
    8020073e:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
    80200740:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
    80200744:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    80200746:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
    8020074a:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    8020074e:	fed870e3          	bgeu	a6,a3,8020072e <vprintfmt+0xf0>
            if (width < 0)
    80200752:	f40ddce3          	bgez	s11,802006aa <vprintfmt+0x6c>
                width = precision, precision = -1;
    80200756:	8de2                	mv	s11,s8
    80200758:	5c7d                	li	s8,-1
    8020075a:	bf81                	j	802006aa <vprintfmt+0x6c>
            if (width < 0)
    8020075c:	fffdc693          	not	a3,s11
    80200760:	96fd                	srai	a3,a3,0x3f
    80200762:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
    80200766:	00144603          	lbu	a2,1(s0)
    8020076a:	2d81                	sext.w	s11,s11
    8020076c:	846a                	mv	s0,s10
            goto reswitch;
    8020076e:	bf35                	j	802006aa <vprintfmt+0x6c>
            precision = va_arg(ap, int);
    80200770:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
    80200774:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    80200778:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
    8020077a:	846a                	mv	s0,s10
            goto process_precision;
    8020077c:	bfd9                	j	80200752 <vprintfmt+0x114>
    if (lflag >= 2) {
    8020077e:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200780:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    80200784:	01174463          	blt	a4,a7,8020078c <vprintfmt+0x14e>
    else if (lflag) {
    80200788:	1a088e63          	beqz	a7,80200944 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
    8020078c:	000a3603          	ld	a2,0(s4)
    80200790:	46c1                	li	a3,16
    80200792:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
    80200794:	2781                	sext.w	a5,a5
    80200796:	876e                	mv	a4,s11
    80200798:	85a6                	mv	a1,s1
    8020079a:	854a                	mv	a0,s2
    8020079c:	e37ff0ef          	jal	ra,802005d2 <printnum>
            break;
    802007a0:	bde1                	j	80200678 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
    802007a2:	000a2503          	lw	a0,0(s4)
    802007a6:	85a6                	mv	a1,s1
    802007a8:	0a21                	addi	s4,s4,8
    802007aa:	9902                	jalr	s2
            break;
    802007ac:	b5f1                	j	80200678 <vprintfmt+0x3a>
    if (lflag >= 2) {
    802007ae:	4705                	li	a4,1
            precision = va_arg(ap, int);
    802007b0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    802007b4:	01174463          	blt	a4,a7,802007bc <vprintfmt+0x17e>
    else if (lflag) {
    802007b8:	18088163          	beqz	a7,8020093a <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
    802007bc:	000a3603          	ld	a2,0(s4)
    802007c0:	46a9                	li	a3,10
    802007c2:	8a2e                	mv	s4,a1
    802007c4:	bfc1                	j	80200794 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
    802007c6:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    802007ca:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
    802007cc:	846a                	mv	s0,s10
            goto reswitch;
    802007ce:	bdf1                	j	802006aa <vprintfmt+0x6c>
            putch(ch, putdat);
    802007d0:	85a6                	mv	a1,s1
    802007d2:	02500513          	li	a0,37
    802007d6:	9902                	jalr	s2
            break;
    802007d8:	b545                	j	80200678 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
    802007da:	00144603          	lbu	a2,1(s0)
            lflag ++;
    802007de:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
    802007e0:	846a                	mv	s0,s10
            goto reswitch;
    802007e2:	b5e1                	j	802006aa <vprintfmt+0x6c>
    if (lflag >= 2) {
    802007e4:	4705                	li	a4,1
            precision = va_arg(ap, int);
    802007e6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    802007ea:	01174463          	blt	a4,a7,802007f2 <vprintfmt+0x1b4>
    else if (lflag) {
    802007ee:	14088163          	beqz	a7,80200930 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
    802007f2:	000a3603          	ld	a2,0(s4)
    802007f6:	46a1                	li	a3,8
    802007f8:	8a2e                	mv	s4,a1
    802007fa:	bf69                	j	80200794 <vprintfmt+0x156>
            putch('0', putdat);
    802007fc:	03000513          	li	a0,48
    80200800:	85a6                	mv	a1,s1
    80200802:	e03e                	sd	a5,0(sp)
    80200804:	9902                	jalr	s2
            putch('x', putdat);
    80200806:	85a6                	mv	a1,s1
    80200808:	07800513          	li	a0,120
    8020080c:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    8020080e:	0a21                	addi	s4,s4,8
            goto number;
    80200810:	6782                	ld	a5,0(sp)
    80200812:	46c1                	li	a3,16
            num = (unsigned long long)va_arg(ap, void *);
    80200814:	ff8a3603          	ld	a2,-8(s4)
            goto number;
    80200818:	bfb5                	j	80200794 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
    8020081a:	000a3403          	ld	s0,0(s4)
    8020081e:	008a0713          	addi	a4,s4,8
    80200822:	e03a                	sd	a4,0(sp)
    80200824:	14040263          	beqz	s0,80200968 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
    80200828:	0fb05763          	blez	s11,80200916 <vprintfmt+0x2d8>
    8020082c:	02d00693          	li	a3,45
    80200830:	0cd79163          	bne	a5,a3,802008f2 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200834:	00044783          	lbu	a5,0(s0)
    80200838:	0007851b          	sext.w	a0,a5
    8020083c:	cf85                	beqz	a5,80200874 <vprintfmt+0x236>
    8020083e:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200842:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200846:	000c4563          	bltz	s8,80200850 <vprintfmt+0x212>
    8020084a:	3c7d                	addiw	s8,s8,-1
    8020084c:	036c0263          	beq	s8,s6,80200870 <vprintfmt+0x232>
                    putch('?', putdat);
    80200850:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200852:	0e0c8e63          	beqz	s9,8020094e <vprintfmt+0x310>
    80200856:	3781                	addiw	a5,a5,-32
    80200858:	0ef47b63          	bgeu	s0,a5,8020094e <vprintfmt+0x310>
                    putch('?', putdat);
    8020085c:	03f00513          	li	a0,63
    80200860:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200862:	000a4783          	lbu	a5,0(s4)
    80200866:	3dfd                	addiw	s11,s11,-1
    80200868:	0a05                	addi	s4,s4,1
    8020086a:	0007851b          	sext.w	a0,a5
    8020086e:	ffe1                	bnez	a5,80200846 <vprintfmt+0x208>
            for (; width > 0; width --) {
    80200870:	01b05963          	blez	s11,80200882 <vprintfmt+0x244>
    80200874:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200876:	85a6                	mv	a1,s1
    80200878:	02000513          	li	a0,32
    8020087c:	9902                	jalr	s2
            for (; width > 0; width --) {
    8020087e:	fe0d9be3          	bnez	s11,80200874 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200882:	6a02                	ld	s4,0(sp)
    80200884:	bbd5                	j	80200678 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200886:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200888:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
    8020088c:	01174463          	blt	a4,a7,80200894 <vprintfmt+0x256>
    else if (lflag) {
    80200890:	08088d63          	beqz	a7,8020092a <vprintfmt+0x2ec>
        return va_arg(*ap, long);
    80200894:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
    80200898:	0a044d63          	bltz	s0,80200952 <vprintfmt+0x314>
            num = getint(&ap, lflag);
    8020089c:	8622                	mv	a2,s0
    8020089e:	8a66                	mv	s4,s9
    802008a0:	46a9                	li	a3,10
    802008a2:	bdcd                	j	80200794 <vprintfmt+0x156>
            err = va_arg(ap, int);
    802008a4:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802008a8:	4719                	li	a4,6
            err = va_arg(ap, int);
    802008aa:	0a21                	addi	s4,s4,8
            if (err < 0) {
    802008ac:	41f7d69b          	sraiw	a3,a5,0x1f
    802008b0:	8fb5                	xor	a5,a5,a3
    802008b2:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802008b6:	02d74163          	blt	a4,a3,802008d8 <vprintfmt+0x29a>
    802008ba:	00369793          	slli	a5,a3,0x3
    802008be:	97de                	add	a5,a5,s7
    802008c0:	639c                	ld	a5,0(a5)
    802008c2:	cb99                	beqz	a5,802008d8 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
    802008c4:	86be                	mv	a3,a5
    802008c6:	00000617          	auipc	a2,0x0
    802008ca:	7b260613          	addi	a2,a2,1970 # 80201078 <etext+0x63c>
    802008ce:	85a6                	mv	a1,s1
    802008d0:	854a                	mv	a0,s2
    802008d2:	0ce000ef          	jal	ra,802009a0 <printfmt>
    802008d6:	b34d                	j	80200678 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    802008d8:	00000617          	auipc	a2,0x0
    802008dc:	79060613          	addi	a2,a2,1936 # 80201068 <etext+0x62c>
    802008e0:	85a6                	mv	a1,s1
    802008e2:	854a                	mv	a0,s2
    802008e4:	0bc000ef          	jal	ra,802009a0 <printfmt>
    802008e8:	bb41                	j	80200678 <vprintfmt+0x3a>
                p = "(null)";
    802008ea:	00000417          	auipc	s0,0x0
    802008ee:	77640413          	addi	s0,s0,1910 # 80201060 <etext+0x624>
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008f2:	85e2                	mv	a1,s8
    802008f4:	8522                	mv	a0,s0
    802008f6:	e43e                	sd	a5,8(sp)
    802008f8:	116000ef          	jal	ra,80200a0e <strnlen>
    802008fc:	40ad8dbb          	subw	s11,s11,a0
    80200900:	01b05b63          	blez	s11,80200916 <vprintfmt+0x2d8>
                    putch(padc, putdat);
    80200904:	67a2                	ld	a5,8(sp)
    80200906:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020090a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    8020090c:	85a6                	mv	a1,s1
    8020090e:	8552                	mv	a0,s4
    80200910:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200912:	fe0d9ce3          	bnez	s11,8020090a <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200916:	00044783          	lbu	a5,0(s0)
    8020091a:	00140a13          	addi	s4,s0,1
    8020091e:	0007851b          	sext.w	a0,a5
    80200922:	d3a5                	beqz	a5,80200882 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
    80200924:	05e00413          	li	s0,94
    80200928:	bf39                	j	80200846 <vprintfmt+0x208>
        return va_arg(*ap, int);
    8020092a:	000a2403          	lw	s0,0(s4)
    8020092e:	b7ad                	j	80200898 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
    80200930:	000a6603          	lwu	a2,0(s4)
    80200934:	46a1                	li	a3,8
    80200936:	8a2e                	mv	s4,a1
    80200938:	bdb1                	j	80200794 <vprintfmt+0x156>
    8020093a:	000a6603          	lwu	a2,0(s4)
    8020093e:	46a9                	li	a3,10
    80200940:	8a2e                	mv	s4,a1
    80200942:	bd89                	j	80200794 <vprintfmt+0x156>
    80200944:	000a6603          	lwu	a2,0(s4)
    80200948:	46c1                	li	a3,16
    8020094a:	8a2e                	mv	s4,a1
    8020094c:	b5a1                	j	80200794 <vprintfmt+0x156>
                    putch(ch, putdat);
    8020094e:	9902                	jalr	s2
    80200950:	bf09                	j	80200862 <vprintfmt+0x224>
                putch('-', putdat);
    80200952:	85a6                	mv	a1,s1
    80200954:	02d00513          	li	a0,45
    80200958:	e03e                	sd	a5,0(sp)
    8020095a:	9902                	jalr	s2
                num = -(long long)num;
    8020095c:	6782                	ld	a5,0(sp)
    8020095e:	8a66                	mv	s4,s9
    80200960:	40800633          	neg	a2,s0
    80200964:	46a9                	li	a3,10
    80200966:	b53d                	j	80200794 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
    80200968:	03b05163          	blez	s11,8020098a <vprintfmt+0x34c>
    8020096c:	02d00693          	li	a3,45
    80200970:	f6d79de3          	bne	a5,a3,802008ea <vprintfmt+0x2ac>
                p = "(null)";
    80200974:	00000417          	auipc	s0,0x0
    80200978:	6ec40413          	addi	s0,s0,1772 # 80201060 <etext+0x624>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020097c:	02800793          	li	a5,40
    80200980:	02800513          	li	a0,40
    80200984:	00140a13          	addi	s4,s0,1
    80200988:	bd6d                	j	80200842 <vprintfmt+0x204>
    8020098a:	00000a17          	auipc	s4,0x0
    8020098e:	6d7a0a13          	addi	s4,s4,1751 # 80201061 <etext+0x625>
    80200992:	02800513          	li	a0,40
    80200996:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
    8020099a:	05e00413          	li	s0,94
    8020099e:	b565                	j	80200846 <vprintfmt+0x208>

00000000802009a0 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009a0:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    802009a2:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009a6:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009a8:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    802009aa:	ec06                	sd	ra,24(sp)
    802009ac:	f83a                	sd	a4,48(sp)
    802009ae:	fc3e                	sd	a5,56(sp)
    802009b0:	e0c2                	sd	a6,64(sp)
    802009b2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    802009b4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009b6:	c89ff0ef          	jal	ra,8020063e <vprintfmt>
}
    802009ba:	60e2                	ld	ra,24(sp)
    802009bc:	6161                	addi	sp,sp,80
    802009be:	8082                	ret

00000000802009c0 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
    802009c0:	4781                	li	a5,0
    802009c2:	00003717          	auipc	a4,0x3
    802009c6:	63e73703          	ld	a4,1598(a4) # 80204000 <SBI_CONSOLE_PUTCHAR>
    802009ca:	88ba                	mv	a7,a4
    802009cc:	852a                	mv	a0,a0
    802009ce:	85be                	mv	a1,a5
    802009d0:	863e                	mv	a2,a5
    802009d2:	00000073          	ecall
    802009d6:	87aa                	mv	a5,a0
int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
    802009d8:	8082                	ret

00000000802009da <sbi_set_timer>:
    __asm__ volatile (
    802009da:	4781                	li	a5,0
    802009dc:	00003717          	auipc	a4,0x3
    802009e0:	64473703          	ld	a4,1604(a4) # 80204020 <SBI_SET_TIMER>
    802009e4:	88ba                	mv	a7,a4
    802009e6:	852a                	mv	a0,a0
    802009e8:	85be                	mv	a1,a5
    802009ea:	863e                	mv	a2,a5
    802009ec:	00000073          	ecall
    802009f0:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
    802009f2:	8082                	ret

00000000802009f4 <sbi_shutdown>:
    __asm__ volatile (
    802009f4:	4781                	li	a5,0
    802009f6:	00003717          	auipc	a4,0x3
    802009fa:	61273703          	ld	a4,1554(a4) # 80204008 <SBI_SHUTDOWN>
    802009fe:	88ba                	mv	a7,a4
    80200a00:	853e                	mv	a0,a5
    80200a02:	85be                	mv	a1,a5
    80200a04:	863e                	mv	a2,a5
    80200a06:	00000073          	ecall
    80200a0a:	87aa                	mv	a5,a0


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    80200a0c:	8082                	ret

0000000080200a0e <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    80200a0e:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
    80200a10:	e589                	bnez	a1,80200a1a <strnlen+0xc>
    80200a12:	a811                	j	80200a26 <strnlen+0x18>
        cnt ++;
    80200a14:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200a16:	00f58863          	beq	a1,a5,80200a26 <strnlen+0x18>
    80200a1a:	00f50733          	add	a4,a0,a5
    80200a1e:	00074703          	lbu	a4,0(a4)
    80200a22:	fb6d                	bnez	a4,80200a14 <strnlen+0x6>
    80200a24:	85be                	mv	a1,a5
    }
    return cnt;
}
    80200a26:	852e                	mv	a0,a1
    80200a28:	8082                	ret

0000000080200a2a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200a2a:	ca01                	beqz	a2,80200a3a <memset+0x10>
    80200a2c:	962a                	add	a2,a2,a0
    char *p = s;
    80200a2e:	87aa                	mv	a5,a0
        *p ++ = c;
    80200a30:	0785                	addi	a5,a5,1
    80200a32:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200a36:	fec79de3          	bne	a5,a2,80200a30 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200a3a:	8082                	ret
