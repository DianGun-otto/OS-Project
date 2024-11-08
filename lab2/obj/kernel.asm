
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fe650513          	addi	a0,a0,-26 # ffffffffc0206018 <buddy_longest>
ffffffffc020003a:	00046617          	auipc	a2,0x46
ffffffffc020003e:	44e60613          	addi	a2,a2,1102 # ffffffffc0246488 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	630010ef          	jal	ra,ffffffffc020167a <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	63e50513          	addi	a0,a0,1598 # ffffffffc0201690 <etext+0x4>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	725000ef          	jal	ra,ffffffffc0200f8a <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200084:	401c                	lw	a5,0(s0)
}
ffffffffc0200086:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
}
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a4:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a6:	0e4010ef          	jal	ra,ffffffffc020118a <vprintfmt>
    return cnt;
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000da:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	0ae010ef          	jal	ra,ffffffffc020118a <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020013c:	00001517          	auipc	a0,0x1
ffffffffc0200140:	57450513          	addi	a0,a0,1396 # ffffffffc02016b0 <etext+0x24>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00001517          	auipc	a0,0x1
ffffffffc0200156:	57e50513          	addi	a0,a0,1406 # ffffffffc02016d0 <etext+0x44>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00001597          	auipc	a1,0x1
ffffffffc0200162:	52e58593          	addi	a1,a1,1326 # ffffffffc020168c <etext>
ffffffffc0200166:	00001517          	auipc	a0,0x1
ffffffffc020016a:	58a50513          	addi	a0,a0,1418 # ffffffffc02016f0 <etext+0x64>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	ea658593          	addi	a1,a1,-346 # ffffffffc0206018 <buddy_longest>
ffffffffc020017a:	00001517          	auipc	a0,0x1
ffffffffc020017e:	59650513          	addi	a0,a0,1430 # ffffffffc0201710 <etext+0x84>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00046597          	auipc	a1,0x46
ffffffffc020018a:	30258593          	addi	a1,a1,770 # ffffffffc0246488 <end>
ffffffffc020018e:	00001517          	auipc	a0,0x1
ffffffffc0200192:	5a250513          	addi	a0,a0,1442 # ffffffffc0201730 <etext+0xa4>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00046597          	auipc	a1,0x46
ffffffffc020019e:	6ed58593          	addi	a1,a1,1773 # ffffffffc0246887 <end+0x3ff>
ffffffffc02001a2:	00000797          	auipc	a5,0x0
ffffffffc02001a6:	e9078793          	addi	a5,a5,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ae:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b8:	95be                	add	a1,a1,a5
ffffffffc02001ba:	85a9                	srai	a1,a1,0xa
ffffffffc02001bc:	00001517          	auipc	a0,0x1
ffffffffc02001c0:	59450513          	addi	a0,a0,1428 # ffffffffc0201750 <etext+0xc4>
}
ffffffffc02001c4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c6:	b5f5                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001c8 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ca:	00001617          	auipc	a2,0x1
ffffffffc02001ce:	5b660613          	addi	a2,a2,1462 # ffffffffc0201780 <etext+0xf4>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	5c250513          	addi	a0,a0,1474 # ffffffffc0201798 <etext+0x10c>
void print_stackframe(void) {
ffffffffc02001de:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e0:	1cc000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001e4 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001e4:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001e6:	00001617          	auipc	a2,0x1
ffffffffc02001ea:	5ca60613          	addi	a2,a2,1482 # ffffffffc02017b0 <etext+0x124>
ffffffffc02001ee:	00001597          	auipc	a1,0x1
ffffffffc02001f2:	5e258593          	addi	a1,a1,1506 # ffffffffc02017d0 <etext+0x144>
ffffffffc02001f6:	00001517          	auipc	a0,0x1
ffffffffc02001fa:	5e250513          	addi	a0,a0,1506 # ffffffffc02017d8 <etext+0x14c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00001617          	auipc	a2,0x1
ffffffffc0200208:	5e460613          	addi	a2,a2,1508 # ffffffffc02017e8 <etext+0x15c>
ffffffffc020020c:	00001597          	auipc	a1,0x1
ffffffffc0200210:	60458593          	addi	a1,a1,1540 # ffffffffc0201810 <etext+0x184>
ffffffffc0200214:	00001517          	auipc	a0,0x1
ffffffffc0200218:	5c450513          	addi	a0,a0,1476 # ffffffffc02017d8 <etext+0x14c>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00001617          	auipc	a2,0x1
ffffffffc0200224:	60060613          	addi	a2,a2,1536 # ffffffffc0201820 <etext+0x194>
ffffffffc0200228:	00001597          	auipc	a1,0x1
ffffffffc020022c:	61858593          	addi	a1,a1,1560 # ffffffffc0201840 <etext+0x1b4>
ffffffffc0200230:	00001517          	auipc	a0,0x1
ffffffffc0200234:	5a850513          	addi	a0,a0,1448 # ffffffffc02017d8 <etext+0x14c>
ffffffffc0200238:	e7bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc020023c:	60a2                	ld	ra,8(sp)
ffffffffc020023e:	4501                	li	a0,0
ffffffffc0200240:	0141                	addi	sp,sp,16
ffffffffc0200242:	8082                	ret

ffffffffc0200244 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200244:	1141                	addi	sp,sp,-16
ffffffffc0200246:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200248:	ef3ff0ef          	jal	ra,ffffffffc020013a <print_kerninfo>
    return 0;
}
ffffffffc020024c:	60a2                	ld	ra,8(sp)
ffffffffc020024e:	4501                	li	a0,0
ffffffffc0200250:	0141                	addi	sp,sp,16
ffffffffc0200252:	8082                	ret

ffffffffc0200254 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200254:	1141                	addi	sp,sp,-16
ffffffffc0200256:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200258:	f71ff0ef          	jal	ra,ffffffffc02001c8 <print_stackframe>
    return 0;
}
ffffffffc020025c:	60a2                	ld	ra,8(sp)
ffffffffc020025e:	4501                	li	a0,0
ffffffffc0200260:	0141                	addi	sp,sp,16
ffffffffc0200262:	8082                	ret

ffffffffc0200264 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200264:	7115                	addi	sp,sp,-224
ffffffffc0200266:	ed5e                	sd	s7,152(sp)
ffffffffc0200268:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020026a:	00001517          	auipc	a0,0x1
ffffffffc020026e:	5e650513          	addi	a0,a0,1510 # ffffffffc0201850 <etext+0x1c4>
kmonitor(struct trapframe *tf) {
ffffffffc0200272:	ed86                	sd	ra,216(sp)
ffffffffc0200274:	e9a2                	sd	s0,208(sp)
ffffffffc0200276:	e5a6                	sd	s1,200(sp)
ffffffffc0200278:	e1ca                	sd	s2,192(sp)
ffffffffc020027a:	fd4e                	sd	s3,184(sp)
ffffffffc020027c:	f952                	sd	s4,176(sp)
ffffffffc020027e:	f556                	sd	s5,168(sp)
ffffffffc0200280:	f15a                	sd	s6,160(sp)
ffffffffc0200282:	e962                	sd	s8,144(sp)
ffffffffc0200284:	e566                	sd	s9,136(sp)
ffffffffc0200286:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200288:	e2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020028c:	00001517          	auipc	a0,0x1
ffffffffc0200290:	5ec50513          	addi	a0,a0,1516 # ffffffffc0201878 <etext+0x1ec>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00001c17          	auipc	s8,0x1
ffffffffc02002a6:	646c0c13          	addi	s8,s8,1606 # ffffffffc02018e8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00001917          	auipc	s2,0x1
ffffffffc02002ae:	5f690913          	addi	s2,s2,1526 # ffffffffc02018a0 <etext+0x214>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00001497          	auipc	s1,0x1
ffffffffc02002b6:	5f648493          	addi	s1,s1,1526 # ffffffffc02018a8 <etext+0x21c>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00001b17          	auipc	s6,0x1
ffffffffc02002c0:	5f4b0b13          	addi	s6,s6,1524 # ffffffffc02018b0 <etext+0x224>
        argv[argc ++] = buf;
ffffffffc02002c4:	00001a17          	auipc	s4,0x1
ffffffffc02002c8:	50ca0a13          	addi	s4,s4,1292 # ffffffffc02017d0 <etext+0x144>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	23c010ef          	jal	ra,ffffffffc020150c <readline>
ffffffffc02002d4:	842a                	mv	s0,a0
ffffffffc02002d6:	dd65                	beqz	a0,ffffffffc02002ce <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d8:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002dc:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002de:	e1bd                	bnez	a1,ffffffffc0200344 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002e0:	fe0c87e3          	beqz	s9,ffffffffc02002ce <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	00001d17          	auipc	s10,0x1
ffffffffc02002ea:	602d0d13          	addi	s10,s10,1538 # ffffffffc02018e8 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	352010ef          	jal	ra,ffffffffc0201646 <strcmp>
ffffffffc02002f8:	c919                	beqz	a0,ffffffffc020030e <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	2405                	addiw	s0,s0,1
ffffffffc02002fc:	0b540063          	beq	s0,s5,ffffffffc020039c <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	000d3503          	ld	a0,0(s10)
ffffffffc0200304:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	33e010ef          	jal	ra,ffffffffc0201646 <strcmp>
ffffffffc020030c:	f57d                	bnez	a0,ffffffffc02002fa <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020030e:	00141793          	slli	a5,s0,0x1
ffffffffc0200312:	97a2                	add	a5,a5,s0
ffffffffc0200314:	078e                	slli	a5,a5,0x3
ffffffffc0200316:	97e2                	add	a5,a5,s8
ffffffffc0200318:	6b9c                	ld	a5,16(a5)
ffffffffc020031a:	865e                	mv	a2,s7
ffffffffc020031c:	002c                	addi	a1,sp,8
ffffffffc020031e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200322:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200324:	fa0555e3          	bgez	a0,ffffffffc02002ce <kmonitor+0x6a>
}
ffffffffc0200328:	60ee                	ld	ra,216(sp)
ffffffffc020032a:	644e                	ld	s0,208(sp)
ffffffffc020032c:	64ae                	ld	s1,200(sp)
ffffffffc020032e:	690e                	ld	s2,192(sp)
ffffffffc0200330:	79ea                	ld	s3,184(sp)
ffffffffc0200332:	7a4a                	ld	s4,176(sp)
ffffffffc0200334:	7aaa                	ld	s5,168(sp)
ffffffffc0200336:	7b0a                	ld	s6,160(sp)
ffffffffc0200338:	6bea                	ld	s7,152(sp)
ffffffffc020033a:	6c4a                	ld	s8,144(sp)
ffffffffc020033c:	6caa                	ld	s9,136(sp)
ffffffffc020033e:	6d0a                	ld	s10,128(sp)
ffffffffc0200340:	612d                	addi	sp,sp,224
ffffffffc0200342:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	8526                	mv	a0,s1
ffffffffc0200346:	31e010ef          	jal	ra,ffffffffc0201664 <strchr>
ffffffffc020034a:	c901                	beqz	a0,ffffffffc020035a <kmonitor+0xf6>
ffffffffc020034c:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200350:	00040023          	sb	zero,0(s0)
ffffffffc0200354:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200356:	d5c9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200358:	b7f5                	j	ffffffffc0200344 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020035a:	00044783          	lbu	a5,0(s0)
ffffffffc020035e:	d3c9                	beqz	a5,ffffffffc02002e0 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200360:	033c8963          	beq	s9,s3,ffffffffc0200392 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200364:	003c9793          	slli	a5,s9,0x3
ffffffffc0200368:	0118                	addi	a4,sp,128
ffffffffc020036a:	97ba                	add	a5,a5,a4
ffffffffc020036c:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200370:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200374:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200376:	e591                	bnez	a1,ffffffffc0200382 <kmonitor+0x11e>
ffffffffc0200378:	b7b5                	j	ffffffffc02002e4 <kmonitor+0x80>
ffffffffc020037a:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020037e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200380:	d1a5                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200382:	8526                	mv	a0,s1
ffffffffc0200384:	2e0010ef          	jal	ra,ffffffffc0201664 <strchr>
ffffffffc0200388:	d96d                	beqz	a0,ffffffffc020037a <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	00044583          	lbu	a1,0(s0)
ffffffffc020038e:	d9a9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200390:	bf55                	j	ffffffffc0200344 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020039a:	b7e9                	j	ffffffffc0200364 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	53250513          	addi	a0,a0,1330 # ffffffffc02018d0 <etext+0x244>
ffffffffc02003a6:	d0dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc02003aa:	b715                	j	ffffffffc02002ce <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00046317          	auipc	t1,0x46
ffffffffc02003b0:	08430313          	addi	t1,t1,132 # ffffffffc0246430 <is_panic>
ffffffffc02003b4:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	020e1a63          	bnez	t3,ffffffffc02003fc <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003d2:	8432                	mv	s0,a2
ffffffffc02003d4:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d6:	862e                	mv	a2,a1
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00001517          	auipc	a0,0x1
ffffffffc02003de:	55650513          	addi	a0,a0,1366 # ffffffffc0201930 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00001517          	auipc	a0,0x1
ffffffffc02003f4:	38850513          	addi	a0,a0,904 # ffffffffc0201778 <etext+0xec>
ffffffffc02003f8:	cbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e63ff0ef          	jal	ra,ffffffffc0200264 <kmonitor>
    while (1) {
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x54>

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	1ba010ef          	jal	ra,ffffffffc02015da <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00046797          	auipc	a5,0x46
ffffffffc020042a:	0007b923          	sd	zero,18(a5) # ffffffffc0246438 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	52250513          	addi	a0,a0,1314 # ffffffffc0201950 <commands+0x68>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	1940106f          	j	ffffffffc02015da <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	1700106f          	j	ffffffffc02015c0 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	1a00106f          	j	ffffffffc02015f4 <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	37878793          	addi	a5,a5,888 # ffffffffc02007e0 <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	00001517          	auipc	a0,0x1
ffffffffc0200482:	4f250513          	addi	a0,a0,1266 # ffffffffc0201970 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	4fa50513          	addi	a0,a0,1274 # ffffffffc0201988 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	50450513          	addi	a0,a0,1284 # ffffffffc02019a0 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	50e50513          	addi	a0,a0,1294 # ffffffffc02019b8 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	51850513          	addi	a0,a0,1304 # ffffffffc02019d0 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	52250513          	addi	a0,a0,1314 # ffffffffc02019e8 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	52c50513          	addi	a0,a0,1324 # ffffffffc0201a00 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	53650513          	addi	a0,a0,1334 # ffffffffc0201a18 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	54050513          	addi	a0,a0,1344 # ffffffffc0201a30 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	54a50513          	addi	a0,a0,1354 # ffffffffc0201a48 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	55450513          	addi	a0,a0,1364 # ffffffffc0201a60 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	55e50513          	addi	a0,a0,1374 # ffffffffc0201a78 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	56850513          	addi	a0,a0,1384 # ffffffffc0201a90 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	57250513          	addi	a0,a0,1394 # ffffffffc0201aa8 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	57c50513          	addi	a0,a0,1404 # ffffffffc0201ac0 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	58650513          	addi	a0,a0,1414 # ffffffffc0201ad8 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	59050513          	addi	a0,a0,1424 # ffffffffc0201af0 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	59a50513          	addi	a0,a0,1434 # ffffffffc0201b08 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	5a450513          	addi	a0,a0,1444 # ffffffffc0201b20 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	5ae50513          	addi	a0,a0,1454 # ffffffffc0201b38 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	5b850513          	addi	a0,a0,1464 # ffffffffc0201b50 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	5c250513          	addi	a0,a0,1474 # ffffffffc0201b68 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	5cc50513          	addi	a0,a0,1484 # ffffffffc0201b80 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	5d650513          	addi	a0,a0,1494 # ffffffffc0201b98 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	5e050513          	addi	a0,a0,1504 # ffffffffc0201bb0 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	5ea50513          	addi	a0,a0,1514 # ffffffffc0201bc8 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	5f450513          	addi	a0,a0,1524 # ffffffffc0201be0 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	5fe50513          	addi	a0,a0,1534 # ffffffffc0201bf8 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	60850513          	addi	a0,a0,1544 # ffffffffc0201c10 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	61250513          	addi	a0,a0,1554 # ffffffffc0201c28 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	61c50513          	addi	a0,a0,1564 # ffffffffc0201c40 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	62250513          	addi	a0,a0,1570 # ffffffffc0201c58 <commands+0x370>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00001517          	auipc	a0,0x1
ffffffffc020064e:	62650513          	addi	a0,a0,1574 # ffffffffc0201c70 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00001517          	auipc	a0,0x1
ffffffffc0200666:	62650513          	addi	a0,a0,1574 # ffffffffc0201c88 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	62e50513          	addi	a0,a0,1582 # ffffffffc0201ca0 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	63650513          	addi	a0,a0,1590 # ffffffffc0201cb8 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	63a50513          	addi	a0,a0,1594 # ffffffffc0201cd0 <commands+0x3e8>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76763          	bltu	a4,a5,ffffffffc020071a <interrupt_handler+0x78>
ffffffffc02006b0:	00001717          	auipc	a4,0x1
ffffffffc02006b4:	6e870713          	addi	a4,a4,1768 # ffffffffc0201d98 <commands+0x4b0>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c2:	00001517          	auipc	a0,0x1
ffffffffc02006c6:	68650513          	addi	a0,a0,1670 # ffffffffc0201d48 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	65c50513          	addi	a0,a0,1628 # ffffffffc0201d28 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	61250513          	addi	a0,a0,1554 # ffffffffc0201ce8 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	62850513          	addi	a0,a0,1576 # ffffffffc0201d08 <commands+0x420>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
             /* LAB1 EXERCISE2   2213219 张高 :  */
            clock_set_next_event();
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            if(++ticks%TICK_NUM == 0){
ffffffffc02006f2:	00046697          	auipc	a3,0x46
ffffffffc02006f6:	d4668693          	addi	a3,a3,-698 # ffffffffc0246438 <ticks>
ffffffffc02006fa:	629c                	ld	a5,0(a3)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	e29c                	sd	a5,0(a3)
ffffffffc0200708:	cb11                	beqz	a4,ffffffffc020071c <interrupt_handler+0x7a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020070a:	60a2                	ld	ra,8(sp)
ffffffffc020070c:	0141                	addi	sp,sp,16
ffffffffc020070e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200710:	00001517          	auipc	a0,0x1
ffffffffc0200714:	66850513          	addi	a0,a0,1640 # ffffffffc0201d78 <commands+0x490>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc020071a:	b725                	j	ffffffffc0200642 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020071c:	06400593          	li	a1,100
ffffffffc0200720:	00001517          	auipc	a0,0x1
ffffffffc0200724:	64850513          	addi	a0,a0,1608 # ffffffffc0201d68 <commands+0x480>
ffffffffc0200728:	98bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            	num++;
ffffffffc020072c:	00046797          	auipc	a5,0x46
ffffffffc0200730:	d1478793          	addi	a5,a5,-748 # ffffffffc0246440 <num>
ffffffffc0200734:	6398                	ld	a4,0(a5)
            	if(num == 10){
ffffffffc0200736:	46a9                	li	a3,10
            	num++;
ffffffffc0200738:	0705                	addi	a4,a4,1
ffffffffc020073a:	e398                	sd	a4,0(a5)
            	if(num == 10){
ffffffffc020073c:	639c                	ld	a5,0(a5)
ffffffffc020073e:	fcd796e3          	bne	a5,a3,ffffffffc020070a <interrupt_handler+0x68>
}
ffffffffc0200742:	60a2                	ld	ra,8(sp)
ffffffffc0200744:	0141                	addi	sp,sp,16
            	   sbi_shutdown();
ffffffffc0200746:	6cb0006f          	j	ffffffffc0201610 <sbi_shutdown>

ffffffffc020074a <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
ffffffffc020074a:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc020074e:	1141                	addi	sp,sp,-16
ffffffffc0200750:	e022                	sd	s0,0(sp)
ffffffffc0200752:	e406                	sd	ra,8(sp)
    switch (tf->cause) {
ffffffffc0200754:	470d                	li	a4,3
void exception_handler(struct trapframe *tf) {
ffffffffc0200756:	842a                	mv	s0,a0
    switch (tf->cause) {
ffffffffc0200758:	04e78663          	beq	a5,a4,ffffffffc02007a4 <exception_handler+0x5a>
ffffffffc020075c:	02f76c63          	bltu	a4,a5,ffffffffc0200794 <exception_handler+0x4a>
ffffffffc0200760:	4709                	li	a4,2
ffffffffc0200762:	02e79563          	bne	a5,a4,ffffffffc020078c <exception_handler+0x42>
             /* LAB1 CHALLENGE3   2211289 张铭 :  */
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
           cprintf("Exception type:Illegal instruction\n");
ffffffffc0200766:	00001517          	auipc	a0,0x1
ffffffffc020076a:	66250513          	addi	a0,a0,1634 # ffffffffc0201dc8 <commands+0x4e0>
ffffffffc020076e:	945ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
           //输出指令异常类型为非法指令（Illegal instruction）
           cprintf("Illegal instruction caught at0x%x\n", tf->epc);
ffffffffc0200772:	10843583          	ld	a1,264(s0)
ffffffffc0200776:	00001517          	auipc	a0,0x1
ffffffffc020077a:	67a50513          	addi	a0,a0,1658 # ffffffffc0201df0 <commands+0x508>
ffffffffc020077e:	935ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
           //输出触发异常的指令地址
           tf->epc+=4;
ffffffffc0200782:	10843783          	ld	a5,264(s0)
ffffffffc0200786:	0791                	addi	a5,a5,4
ffffffffc0200788:	10f43423          	sd	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020078c:	60a2                	ld	ra,8(sp)
ffffffffc020078e:	6402                	ld	s0,0(sp)
ffffffffc0200790:	0141                	addi	sp,sp,16
ffffffffc0200792:	8082                	ret
    switch (tf->cause) {
ffffffffc0200794:	17f1                	addi	a5,a5,-4
ffffffffc0200796:	471d                	li	a4,7
ffffffffc0200798:	fef77ae3          	bgeu	a4,a5,ffffffffc020078c <exception_handler+0x42>
}
ffffffffc020079c:	6402                	ld	s0,0(sp)
ffffffffc020079e:	60a2                	ld	ra,8(sp)
ffffffffc02007a0:	0141                	addi	sp,sp,16
            print_trapframe(tf);
ffffffffc02007a2:	b545                	j	ffffffffc0200642 <print_trapframe>
            cprintf("Exception type: breakpoint\n");
ffffffffc02007a4:	00001517          	auipc	a0,0x1
ffffffffc02007a8:	67450513          	addi	a0,a0,1652 # ffffffffc0201e18 <commands+0x530>
ffffffffc02007ac:	907ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            cprintf("ebreak caught at0x%x\n", tf->epc);
ffffffffc02007b0:	10843583          	ld	a1,264(s0)
ffffffffc02007b4:	00001517          	auipc	a0,0x1
ffffffffc02007b8:	68450513          	addi	a0,a0,1668 # ffffffffc0201e38 <commands+0x550>
ffffffffc02007bc:	8f7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            tf->epc+=4;
ffffffffc02007c0:	10843783          	ld	a5,264(s0)
}
ffffffffc02007c4:	60a2                	ld	ra,8(sp)
            tf->epc+=4;
ffffffffc02007c6:	0791                	addi	a5,a5,4
ffffffffc02007c8:	10f43423          	sd	a5,264(s0)
}
ffffffffc02007cc:	6402                	ld	s0,0(sp)
ffffffffc02007ce:	0141                	addi	sp,sp,16
ffffffffc02007d0:	8082                	ret

ffffffffc02007d2 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc02007d2:	11853783          	ld	a5,280(a0)
ffffffffc02007d6:	0007c363          	bltz	a5,ffffffffc02007dc <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02007da:	bf85                	j	ffffffffc020074a <exception_handler>
        interrupt_handler(tf);
ffffffffc02007dc:	b5d9                	j	ffffffffc02006a2 <interrupt_handler>
	...

ffffffffc02007e0 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc02007e0:	14011073          	csrw	sscratch,sp
ffffffffc02007e4:	712d                	addi	sp,sp,-288
ffffffffc02007e6:	e002                	sd	zero,0(sp)
ffffffffc02007e8:	e406                	sd	ra,8(sp)
ffffffffc02007ea:	ec0e                	sd	gp,24(sp)
ffffffffc02007ec:	f012                	sd	tp,32(sp)
ffffffffc02007ee:	f416                	sd	t0,40(sp)
ffffffffc02007f0:	f81a                	sd	t1,48(sp)
ffffffffc02007f2:	fc1e                	sd	t2,56(sp)
ffffffffc02007f4:	e0a2                	sd	s0,64(sp)
ffffffffc02007f6:	e4a6                	sd	s1,72(sp)
ffffffffc02007f8:	e8aa                	sd	a0,80(sp)
ffffffffc02007fa:	ecae                	sd	a1,88(sp)
ffffffffc02007fc:	f0b2                	sd	a2,96(sp)
ffffffffc02007fe:	f4b6                	sd	a3,104(sp)
ffffffffc0200800:	f8ba                	sd	a4,112(sp)
ffffffffc0200802:	fcbe                	sd	a5,120(sp)
ffffffffc0200804:	e142                	sd	a6,128(sp)
ffffffffc0200806:	e546                	sd	a7,136(sp)
ffffffffc0200808:	e94a                	sd	s2,144(sp)
ffffffffc020080a:	ed4e                	sd	s3,152(sp)
ffffffffc020080c:	f152                	sd	s4,160(sp)
ffffffffc020080e:	f556                	sd	s5,168(sp)
ffffffffc0200810:	f95a                	sd	s6,176(sp)
ffffffffc0200812:	fd5e                	sd	s7,184(sp)
ffffffffc0200814:	e1e2                	sd	s8,192(sp)
ffffffffc0200816:	e5e6                	sd	s9,200(sp)
ffffffffc0200818:	e9ea                	sd	s10,208(sp)
ffffffffc020081a:	edee                	sd	s11,216(sp)
ffffffffc020081c:	f1f2                	sd	t3,224(sp)
ffffffffc020081e:	f5f6                	sd	t4,232(sp)
ffffffffc0200820:	f9fa                	sd	t5,240(sp)
ffffffffc0200822:	fdfe                	sd	t6,248(sp)
ffffffffc0200824:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200828:	100024f3          	csrr	s1,sstatus
ffffffffc020082c:	14102973          	csrr	s2,sepc
ffffffffc0200830:	143029f3          	csrr	s3,stval
ffffffffc0200834:	14202a73          	csrr	s4,scause
ffffffffc0200838:	e822                	sd	s0,16(sp)
ffffffffc020083a:	e226                	sd	s1,256(sp)
ffffffffc020083c:	e64a                	sd	s2,264(sp)
ffffffffc020083e:	ea4e                	sd	s3,272(sp)
ffffffffc0200840:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200842:	850a                	mv	a0,sp
    jal trap
ffffffffc0200844:	f8fff0ef          	jal	ra,ffffffffc02007d2 <trap>

ffffffffc0200848 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200848:	6492                	ld	s1,256(sp)
ffffffffc020084a:	6932                	ld	s2,264(sp)
ffffffffc020084c:	10049073          	csrw	sstatus,s1
ffffffffc0200850:	14191073          	csrw	sepc,s2
ffffffffc0200854:	60a2                	ld	ra,8(sp)
ffffffffc0200856:	61e2                	ld	gp,24(sp)
ffffffffc0200858:	7202                	ld	tp,32(sp)
ffffffffc020085a:	72a2                	ld	t0,40(sp)
ffffffffc020085c:	7342                	ld	t1,48(sp)
ffffffffc020085e:	73e2                	ld	t2,56(sp)
ffffffffc0200860:	6406                	ld	s0,64(sp)
ffffffffc0200862:	64a6                	ld	s1,72(sp)
ffffffffc0200864:	6546                	ld	a0,80(sp)
ffffffffc0200866:	65e6                	ld	a1,88(sp)
ffffffffc0200868:	7606                	ld	a2,96(sp)
ffffffffc020086a:	76a6                	ld	a3,104(sp)
ffffffffc020086c:	7746                	ld	a4,112(sp)
ffffffffc020086e:	77e6                	ld	a5,120(sp)
ffffffffc0200870:	680a                	ld	a6,128(sp)
ffffffffc0200872:	68aa                	ld	a7,136(sp)
ffffffffc0200874:	694a                	ld	s2,144(sp)
ffffffffc0200876:	69ea                	ld	s3,152(sp)
ffffffffc0200878:	7a0a                	ld	s4,160(sp)
ffffffffc020087a:	7aaa                	ld	s5,168(sp)
ffffffffc020087c:	7b4a                	ld	s6,176(sp)
ffffffffc020087e:	7bea                	ld	s7,184(sp)
ffffffffc0200880:	6c0e                	ld	s8,192(sp)
ffffffffc0200882:	6cae                	ld	s9,200(sp)
ffffffffc0200884:	6d4e                	ld	s10,208(sp)
ffffffffc0200886:	6dee                	ld	s11,216(sp)
ffffffffc0200888:	7e0e                	ld	t3,224(sp)
ffffffffc020088a:	7eae                	ld	t4,232(sp)
ffffffffc020088c:	7f4e                	ld	t5,240(sp)
ffffffffc020088e:	7fee                	ld	t6,248(sp)
ffffffffc0200890:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200892:	10200073          	sret

ffffffffc0200896 <buddy_system_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200896:	00045797          	auipc	a5,0x45
ffffffffc020089a:	78278793          	addi	a5,a5,1922 # ffffffffc0246018 <free_area>
ffffffffc020089e:	e79c                	sd	a5,8(a5)
ffffffffc02008a0:	e39c                	sd	a5,0(a5)
}

static void
buddy_system_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc02008a2:	0007a823          	sw	zero,16(a5)
}
ffffffffc02008a6:	8082                	ret

ffffffffc02008a8 <buddy_system_max_alloc>:
}

static size_t
buddy_system_max_alloc() {
    return buddy_longest[0];  // 根节点的值代表最大可用块
}
ffffffffc02008a8:	00005517          	auipc	a0,0x5
ffffffffc02008ac:	77056503          	lwu	a0,1904(a0) # ffffffffc0206018 <buddy_longest>
ffffffffc02008b0:	8082                	ret

ffffffffc02008b2 <buddy2_init>:
    if (!IS_POWER_OF_2(size)) size = next_power_of_2(size);
ffffffffc02008b2:	fff5071b          	addiw	a4,a0,-1
void buddy2_init(unsigned size) {
ffffffffc02008b6:	1141                	addi	sp,sp,-16
    if (!IS_POWER_OF_2(size)) size = next_power_of_2(size);
ffffffffc02008b8:	00e577b3          	and	a5,a0,a4
void buddy2_init(unsigned size) {
ffffffffc02008bc:	e022                	sd	s0,0(sp)
ffffffffc02008be:	e406                	sd	ra,8(sp)
    if (!IS_POWER_OF_2(size)) size = next_power_of_2(size);
ffffffffc02008c0:	2781                	sext.w	a5,a5
ffffffffc02008c2:	842a                	mv	s0,a0
ffffffffc02008c4:	c38d                	beqz	a5,ffffffffc02008e6 <buddy2_init+0x34>
    v |= v >> 1;
ffffffffc02008c6:	0017541b          	srliw	s0,a4,0x1
ffffffffc02008ca:	8c59                	or	s0,s0,a4
    v |= v >> 2;
ffffffffc02008cc:	0024579b          	srliw	a5,s0,0x2
ffffffffc02008d0:	8c5d                	or	s0,s0,a5
    v |= v >> 4;
ffffffffc02008d2:	0044579b          	srliw	a5,s0,0x4
ffffffffc02008d6:	8c5d                	or	s0,s0,a5
    v |= v >> 8;
ffffffffc02008d8:	0084579b          	srliw	a5,s0,0x8
ffffffffc02008dc:	8c5d                	or	s0,s0,a5
    v |= v >> 16;
ffffffffc02008de:	0104559b          	srliw	a1,s0,0x10
ffffffffc02008e2:	8c4d                	or	s0,s0,a1
    return v + 1;
ffffffffc02008e4:	2405                	addiw	s0,s0,1
    cprintf("length = %d\n", size);
ffffffffc02008e6:	85a2                	mv	a1,s0
ffffffffc02008e8:	00001517          	auipc	a0,0x1
ffffffffc02008ec:	56850513          	addi	a0,a0,1384 # ffffffffc0201e50 <commands+0x568>
ffffffffc02008f0:	fc2ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    node_size = size * 2;
ffffffffc02008f4:	0014161b          	slliw	a2,s0,0x1
    buddy_size = size;
ffffffffc02008f8:	00046797          	auipc	a5,0x46
ffffffffc02008fc:	b487a823          	sw	s0,-1200(a5) # ffffffffc0246448 <buddy_size>
    for (i = 0; i < 2 * size - 1; ++i) {
ffffffffc0200900:	00005697          	auipc	a3,0x5
ffffffffc0200904:	71868693          	addi	a3,a3,1816 # ffffffffc0206018 <buddy_longest>
ffffffffc0200908:	fff6059b          	addiw	a1,a2,-1
ffffffffc020090c:	4781                	li	a5,0
            node_size /= 2;
ffffffffc020090e:	873e                	mv	a4,a5
        if (IS_POWER_OF_2(i + 1))
ffffffffc0200910:	2785                	addiw	a5,a5,1
ffffffffc0200912:	8f7d                	and	a4,a4,a5
ffffffffc0200914:	e319                	bnez	a4,ffffffffc020091a <buddy2_init+0x68>
            node_size /= 2;
ffffffffc0200916:	0016561b          	srliw	a2,a2,0x1
        buddy_longest[i] = node_size;
ffffffffc020091a:	c290                	sw	a2,0(a3)
    for (i = 0; i < 2 * size - 1; ++i) {
ffffffffc020091c:	0691                	addi	a3,a3,4
ffffffffc020091e:	feb798e3          	bne	a5,a1,ffffffffc020090e <buddy2_init+0x5c>
}
ffffffffc0200922:	60a2                	ld	ra,8(sp)
ffffffffc0200924:	6402                	ld	s0,0(sp)
ffffffffc0200926:	0141                	addi	sp,sp,16
ffffffffc0200928:	8082                	ret

ffffffffc020092a <buddy_system_init_memmap>:
buddy_system_init_memmap(struct Page *base, size_t n) {
ffffffffc020092a:	1101                	addi	sp,sp,-32
ffffffffc020092c:	ec06                	sd	ra,24(sp)
ffffffffc020092e:	e822                	sd	s0,16(sp)
ffffffffc0200930:	e426                	sd	s1,8(sp)
ffffffffc0200932:	e04a                	sd	s2,0(sp)
    assert(n > 0);
ffffffffc0200934:	c9cd                	beqz	a1,ffffffffc02009e6 <buddy_system_init_memmap+0xbc>
    buddy2_init(n);
ffffffffc0200936:	0005891b          	sext.w	s2,a1
ffffffffc020093a:	842a                	mv	s0,a0
ffffffffc020093c:	854a                	mv	a0,s2
ffffffffc020093e:	84ae                	mv	s1,a1
ffffffffc0200940:	f73ff0ef          	jal	ra,ffffffffc02008b2 <buddy2_init>
    cprintf("length = %d\n", n);
ffffffffc0200944:	85a6                	mv	a1,s1
ffffffffc0200946:	00001517          	auipc	a0,0x1
ffffffffc020094a:	50a50513          	addi	a0,a0,1290 # ffffffffc0201e50 <commands+0x568>
ffffffffc020094e:	f64ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (; p != base + n; p++) {
ffffffffc0200952:	00249793          	slli	a5,s1,0x2
ffffffffc0200956:	009786b3          	add	a3,a5,s1
ffffffffc020095a:	068e                	slli	a3,a3,0x3
ffffffffc020095c:	96a2                	add	a3,a3,s0
ffffffffc020095e:	02d40063          	beq	s0,a3,ffffffffc020097e <buddy_system_init_memmap+0x54>
ffffffffc0200962:	87a2                	mv	a5,s0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200964:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0200966:	8b05                	andi	a4,a4,1
ffffffffc0200968:	cf39                	beqz	a4,ffffffffc02009c6 <buddy_system_init_memmap+0x9c>
        p->flags = p->property = 0;
ffffffffc020096a:	0007a823          	sw	zero,16(a5)
ffffffffc020096e:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200972:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++) {
ffffffffc0200976:	02878793          	addi	a5,a5,40
ffffffffc020097a:	fed795e3          	bne	a5,a3,ffffffffc0200964 <buddy_system_init_memmap+0x3a>
    base->property = n;
ffffffffc020097e:	01242823          	sw	s2,16(s0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200982:	4789                	li	a5,2
ffffffffc0200984:	00840713          	addi	a4,s0,8
ffffffffc0200988:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020098c:	00045797          	auipc	a5,0x45
ffffffffc0200990:	68c78793          	addi	a5,a5,1676 # ffffffffc0246018 <free_area>
ffffffffc0200994:	4b98                	lw	a4,16(a5)
    if (list_empty(&free_list))
ffffffffc0200996:	6794                	ld	a3,8(a5)
    nr_free += n;
ffffffffc0200998:	0127073b          	addw	a4,a4,s2
ffffffffc020099c:	cb98                	sw	a4,16(a5)
    if (list_empty(&free_list))
ffffffffc020099e:	00f68863          	beq	a3,a5,ffffffffc02009ae <buddy_system_init_memmap+0x84>
}
ffffffffc02009a2:	60e2                	ld	ra,24(sp)
ffffffffc02009a4:	6442                	ld	s0,16(sp)
ffffffffc02009a6:	64a2                	ld	s1,8(sp)
ffffffffc02009a8:	6902                	ld	s2,0(sp)
ffffffffc02009aa:	6105                	addi	sp,sp,32
ffffffffc02009ac:	8082                	ret
        list_add(&free_list, &(base->page_link));
ffffffffc02009ae:	01840793          	addi	a5,s0,24
}
ffffffffc02009b2:	60e2                	ld	ra,24(sp)
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
    elm->next = next;
ffffffffc02009b4:	f014                	sd	a3,32(s0)
    elm->prev = prev;
ffffffffc02009b6:	ec14                	sd	a3,24(s0)
ffffffffc02009b8:	6442                	ld	s0,16(sp)
    prev->next = next->prev = elm;
ffffffffc02009ba:	e29c                	sd	a5,0(a3)
ffffffffc02009bc:	e69c                	sd	a5,8(a3)
ffffffffc02009be:	64a2                	ld	s1,8(sp)
ffffffffc02009c0:	6902                	ld	s2,0(sp)
ffffffffc02009c2:	6105                	addi	sp,sp,32
ffffffffc02009c4:	8082                	ret
        assert(PageReserved(p));
ffffffffc02009c6:	00001697          	auipc	a3,0x1
ffffffffc02009ca:	4da68693          	addi	a3,a3,1242 # ffffffffc0201ea0 <commands+0x5b8>
ffffffffc02009ce:	00001617          	auipc	a2,0x1
ffffffffc02009d2:	49a60613          	addi	a2,a2,1178 # ffffffffc0201e68 <commands+0x580>
ffffffffc02009d6:	08500593          	li	a1,133
ffffffffc02009da:	00001517          	auipc	a0,0x1
ffffffffc02009de:	4a650513          	addi	a0,a0,1190 # ffffffffc0201e80 <commands+0x598>
ffffffffc02009e2:	9cbff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc02009e6:	00001697          	auipc	a3,0x1
ffffffffc02009ea:	47a68693          	addi	a3,a3,1146 # ffffffffc0201e60 <commands+0x578>
ffffffffc02009ee:	00001617          	auipc	a2,0x1
ffffffffc02009f2:	47a60613          	addi	a2,a2,1146 # ffffffffc0201e68 <commands+0x580>
ffffffffc02009f6:	07f00593          	li	a1,127
ffffffffc02009fa:	00001517          	auipc	a0,0x1
ffffffffc02009fe:	48650513          	addi	a0,a0,1158 # ffffffffc0201e80 <commands+0x598>
ffffffffc0200a02:	9abff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200a06 <buddy2_alloc>:
    if (size <= 0)
ffffffffc0200a06:	c955                	beqz	a0,ffffffffc0200aba <buddy2_alloc+0xb4>
    else if (!IS_POWER_OF_2(size)) {
ffffffffc0200a08:	fff5071b          	addiw	a4,a0,-1
ffffffffc0200a0c:	00e577b3          	and	a5,a0,a4
ffffffffc0200a10:	2781                	sext.w	a5,a5
ffffffffc0200a12:	e7d5                	bnez	a5,ffffffffc0200abe <buddy2_alloc+0xb8>
    if (buddy_longest[index] < size)
ffffffffc0200a14:	00005617          	auipc	a2,0x5
ffffffffc0200a18:	60460613          	addi	a2,a2,1540 # ffffffffc0206018 <buddy_longest>
ffffffffc0200a1c:	421c                	lw	a5,0(a2)
ffffffffc0200a1e:	08a7ec63          	bltu	a5,a0,ffffffffc0200ab6 <buddy2_alloc+0xb0>
    for (node_size = buddy_size; node_size != size; node_size /= 2) {
ffffffffc0200a22:	00046817          	auipc	a6,0x46
ffffffffc0200a26:	a2682803          	lw	a6,-1498(a6) # ffffffffc0246448 <buddy_size>
ffffffffc0200a2a:	0b050b63          	beq	a0,a6,ffffffffc0200ae0 <buddy2_alloc+0xda>
ffffffffc0200a2e:	86c2                	mv	a3,a6
    unsigned index = 0;
ffffffffc0200a30:	4781                	li	a5,0
        if (buddy_longest[LEFT_LEAF(index)] >= size)
ffffffffc0200a32:	0017959b          	slliw	a1,a5,0x1
ffffffffc0200a36:	0015879b          	addiw	a5,a1,1
ffffffffc0200a3a:	02079893          	slli	a7,a5,0x20
ffffffffc0200a3e:	01e8d713          	srli	a4,a7,0x1e
ffffffffc0200a42:	9732                	add	a4,a4,a2
ffffffffc0200a44:	4318                	lw	a4,0(a4)
    for (node_size = buddy_size; node_size != size; node_size /= 2) {
ffffffffc0200a46:	0016d69b          	srliw	a3,a3,0x1
        if (buddy_longest[LEFT_LEAF(index)] >= size)
ffffffffc0200a4a:	00a77463          	bgeu	a4,a0,ffffffffc0200a52 <buddy2_alloc+0x4c>
            index = RIGHT_LEAF(index);
ffffffffc0200a4e:	0025879b          	addiw	a5,a1,2
    for (node_size = buddy_size; node_size != size; node_size /= 2) {
ffffffffc0200a52:	fed510e3          	bne	a0,a3,ffffffffc0200a32 <buddy2_alloc+0x2c>
    offset = (index + 1) * node_size - buddy_size;
ffffffffc0200a56:	0017871b          	addiw	a4,a5,1
ffffffffc0200a5a:	02a7053b          	mulw	a0,a4,a0
    buddy_longest[index] = 0;
ffffffffc0200a5e:	02079693          	slli	a3,a5,0x20
ffffffffc0200a62:	01e6d713          	srli	a4,a3,0x1e
ffffffffc0200a66:	9732                	add	a4,a4,a2
ffffffffc0200a68:	00072023          	sw	zero,0(a4)
    return offset;
ffffffffc0200a6c:	4105053b          	subw	a0,a0,a6
    while (index) {
ffffffffc0200a70:	c7a1                	beqz	a5,ffffffffc0200ab8 <buddy2_alloc+0xb2>
        index = PARENT(index);
ffffffffc0200a72:	37fd                	addiw	a5,a5,-1
        buddy_longest[index] = MAX(buddy_longest[LEFT_LEAF(index)], buddy_longest[RIGHT_LEAF(index)]);
ffffffffc0200a74:	ffe7f713          	andi	a4,a5,-2
ffffffffc0200a78:	ffe7f693          	andi	a3,a5,-2
ffffffffc0200a7c:	2709                	addiw	a4,a4,2
ffffffffc0200a7e:	2685                	addiw	a3,a3,1
ffffffffc0200a80:	1702                	slli	a4,a4,0x20
ffffffffc0200a82:	02069593          	slli	a1,a3,0x20
ffffffffc0200a86:	9301                	srli	a4,a4,0x20
ffffffffc0200a88:	01e5d693          	srli	a3,a1,0x1e
ffffffffc0200a8c:	070a                	slli	a4,a4,0x2
ffffffffc0200a8e:	9732                	add	a4,a4,a2
ffffffffc0200a90:	96b2                	add	a3,a3,a2
ffffffffc0200a92:	428c                	lw	a1,0(a3)
ffffffffc0200a94:	4314                	lw	a3,0(a4)
ffffffffc0200a96:	0017d71b          	srliw	a4,a5,0x1
ffffffffc0200a9a:	070a                	slli	a4,a4,0x2
ffffffffc0200a9c:	0006889b          	sext.w	a7,a3
ffffffffc0200aa0:	0005881b          	sext.w	a6,a1
        index = PARENT(index);
ffffffffc0200aa4:	0017d79b          	srliw	a5,a5,0x1
        buddy_longest[index] = MAX(buddy_longest[LEFT_LEAF(index)], buddy_longest[RIGHT_LEAF(index)]);
ffffffffc0200aa8:	9732                	add	a4,a4,a2
ffffffffc0200aaa:	0108f363          	bgeu	a7,a6,ffffffffc0200ab0 <buddy2_alloc+0xaa>
ffffffffc0200aae:	86ae                	mv	a3,a1
ffffffffc0200ab0:	c314                	sw	a3,0(a4)
    while (index) {
ffffffffc0200ab2:	f3e1                	bnez	a5,ffffffffc0200a72 <buddy2_alloc+0x6c>
ffffffffc0200ab4:	8082                	ret
        return -1;
ffffffffc0200ab6:	557d                	li	a0,-1
}
ffffffffc0200ab8:	8082                	ret
        size = 1;
ffffffffc0200aba:	4505                	li	a0,1
ffffffffc0200abc:	bfa1                	j	ffffffffc0200a14 <buddy2_alloc+0xe>
    v |= v >> 1;
ffffffffc0200abe:	0017551b          	srliw	a0,a4,0x1
ffffffffc0200ac2:	8d59                	or	a0,a0,a4
    v |= v >> 2;
ffffffffc0200ac4:	0025579b          	srliw	a5,a0,0x2
ffffffffc0200ac8:	8d5d                	or	a0,a0,a5
    v |= v >> 4;
ffffffffc0200aca:	0045579b          	srliw	a5,a0,0x4
ffffffffc0200ace:	8d5d                	or	a0,a0,a5
    v |= v >> 8;
ffffffffc0200ad0:	0085579b          	srliw	a5,a0,0x8
ffffffffc0200ad4:	8d5d                	or	a0,a0,a5
    v |= v >> 16;
ffffffffc0200ad6:	0105579b          	srliw	a5,a0,0x10
ffffffffc0200ada:	8d5d                	or	a0,a0,a5
    return v + 1;
ffffffffc0200adc:	2505                	addiw	a0,a0,1
ffffffffc0200ade:	bf1d                	j	ffffffffc0200a14 <buddy2_alloc+0xe>
    buddy_longest[index] = 0;
ffffffffc0200ae0:	00005797          	auipc	a5,0x5
ffffffffc0200ae4:	5207ac23          	sw	zero,1336(a5) # ffffffffc0206018 <buddy_longest>
ffffffffc0200ae8:	4501                	li	a0,0
ffffffffc0200aea:	8082                	ret

ffffffffc0200aec <buddy_system_alloc_pages>:
buddy_system_alloc_pages(size_t n) {
ffffffffc0200aec:	1141                	addi	sp,sp,-16
ffffffffc0200aee:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200af0:	c515                	beqz	a0,ffffffffc0200b1c <buddy_system_alloc_pages+0x30>
    size_t offset = buddy2_alloc(n);
ffffffffc0200af2:	2501                	sext.w	a0,a0
ffffffffc0200af4:	f13ff0ef          	jal	ra,ffffffffc0200a06 <buddy2_alloc>
    if (offset == -1) return NULL; // 分配失败
ffffffffc0200af8:	57fd                	li	a5,-1
ffffffffc0200afa:	00f50f63          	beq	a0,a5,ffffffffc0200b18 <buddy_system_alloc_pages+0x2c>
    page = page + offset;
ffffffffc0200afe:	00251793          	slli	a5,a0,0x2
ffffffffc0200b02:	953e                	add	a0,a0,a5
ffffffffc0200b04:	050e                	slli	a0,a0,0x3
ffffffffc0200b06:	1521                	addi	a0,a0,-24
ffffffffc0200b08:	00045797          	auipc	a5,0x45
ffffffffc0200b0c:	5187b783          	ld	a5,1304(a5) # ffffffffc0246020 <free_area+0x8>
ffffffffc0200b10:	953e                	add	a0,a0,a5
}
ffffffffc0200b12:	60a2                	ld	ra,8(sp)
ffffffffc0200b14:	0141                	addi	sp,sp,16
ffffffffc0200b16:	8082                	ret
    if (offset == -1) return NULL; // 分配失败
ffffffffc0200b18:	4501                	li	a0,0
ffffffffc0200b1a:	bfe5                	j	ffffffffc0200b12 <buddy_system_alloc_pages+0x26>
    assert(n > 0);
ffffffffc0200b1c:	00001697          	auipc	a3,0x1
ffffffffc0200b20:	34468693          	addi	a3,a3,836 # ffffffffc0201e60 <commands+0x578>
ffffffffc0200b24:	00001617          	auipc	a2,0x1
ffffffffc0200b28:	34460613          	addi	a2,a2,836 # ffffffffc0201e68 <commands+0x580>
ffffffffc0200b2c:	09400593          	li	a1,148
ffffffffc0200b30:	00001517          	auipc	a0,0x1
ffffffffc0200b34:	35050513          	addi	a0,a0,848 # ffffffffc0201e80 <commands+0x598>
ffffffffc0200b38:	875ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200b3c <buddy2_free>:
    assert(offset < buddy_size);
ffffffffc0200b3c:	00046717          	auipc	a4,0x46
ffffffffc0200b40:	90c72703          	lw	a4,-1780(a4) # ffffffffc0246448 <buddy_size>
ffffffffc0200b44:	0ae57363          	bgeu	a0,a4,ffffffffc0200bea <buddy2_free+0xae>
    index = offset + buddy_size - 1;
ffffffffc0200b48:	fff7079b          	addiw	a5,a4,-1
ffffffffc0200b4c:	9fa9                	addw	a5,a5,a0
    for (; buddy_longest[index]; index = PARENT(index)) {
ffffffffc0200b4e:	02079693          	slli	a3,a5,0x20
ffffffffc0200b52:	00005517          	auipc	a0,0x5
ffffffffc0200b56:	4c650513          	addi	a0,a0,1222 # ffffffffc0206018 <buddy_longest>
ffffffffc0200b5a:	01e6d713          	srli	a4,a3,0x1e
ffffffffc0200b5e:	972a                	add	a4,a4,a0
ffffffffc0200b60:	4318                	lw	a4,0(a4)
ffffffffc0200b62:	c351                	beqz	a4,ffffffffc0200be6 <buddy2_free+0xaa>
        if (index == 0)
ffffffffc0200b64:	c3c1                	beqz	a5,ffffffffc0200be4 <buddy2_free+0xa8>
        node_size *= 2;
ffffffffc0200b66:	4709                	li	a4,2
ffffffffc0200b68:	a021                	j	ffffffffc0200b70 <buddy2_free+0x34>
ffffffffc0200b6a:	0017171b          	slliw	a4,a4,0x1
        if (index == 0)
ffffffffc0200b6e:	cbbd                	beqz	a5,ffffffffc0200be4 <buddy2_free+0xa8>
    for (; buddy_longest[index]; index = PARENT(index)) {
ffffffffc0200b70:	37fd                	addiw	a5,a5,-1
ffffffffc0200b72:	0017d69b          	srliw	a3,a5,0x1
ffffffffc0200b76:	068a                	slli	a3,a3,0x2
ffffffffc0200b78:	96aa                	add	a3,a3,a0
ffffffffc0200b7a:	4294                	lw	a3,0(a3)
ffffffffc0200b7c:	0017d79b          	srliw	a5,a5,0x1
ffffffffc0200b80:	f6ed                	bnez	a3,ffffffffc0200b6a <buddy2_free+0x2e>
    buddy_longest[index] = node_size;
ffffffffc0200b82:	02079613          	slli	a2,a5,0x20
ffffffffc0200b86:	01e65693          	srli	a3,a2,0x1e
ffffffffc0200b8a:	96aa                	add	a3,a3,a0
ffffffffc0200b8c:	c298                	sw	a4,0(a3)
    while (index) {
ffffffffc0200b8e:	cbb9                	beqz	a5,ffffffffc0200be4 <buddy2_free+0xa8>
        index = PARENT(index);
ffffffffc0200b90:	37fd                	addiw	a5,a5,-1
ffffffffc0200b92:	0017d61b          	srliw	a2,a5,0x1
        right_longest = buddy_longest[RIGHT_LEAF(index)];
ffffffffc0200b96:	0016069b          	addiw	a3,a2,1
        left_longest = buddy_longest[LEFT_LEAF(index)];
ffffffffc0200b9a:	ffe7f593          	andi	a1,a5,-2
        right_longest = buddy_longest[RIGHT_LEAF(index)];
ffffffffc0200b9e:	0016969b          	slliw	a3,a3,0x1
        left_longest = buddy_longest[LEFT_LEAF(index)];
ffffffffc0200ba2:	2585                	addiw	a1,a1,1
        right_longest = buddy_longest[RIGHT_LEAF(index)];
ffffffffc0200ba4:	1682                	slli	a3,a3,0x20
        left_longest = buddy_longest[LEFT_LEAF(index)];
ffffffffc0200ba6:	02059813          	slli	a6,a1,0x20
        right_longest = buddy_longest[RIGHT_LEAF(index)];
ffffffffc0200baa:	9281                	srli	a3,a3,0x20
        left_longest = buddy_longest[LEFT_LEAF(index)];
ffffffffc0200bac:	01e85593          	srli	a1,a6,0x1e
        right_longest = buddy_longest[RIGHT_LEAF(index)];
ffffffffc0200bb0:	068a                	slli	a3,a3,0x2
ffffffffc0200bb2:	96aa                	add	a3,a3,a0
        left_longest = buddy_longest[LEFT_LEAF(index)];
ffffffffc0200bb4:	95aa                	add	a1,a1,a0
        right_longest = buddy_longest[RIGHT_LEAF(index)];
ffffffffc0200bb6:	0006a803          	lw	a6,0(a3)
        left_longest = buddy_longest[LEFT_LEAF(index)];
ffffffffc0200bba:	418c                	lw	a1,0(a1)
        node_size *= 2;
ffffffffc0200bbc:	0017171b          	slliw	a4,a4,0x1
        index = PARENT(index);
ffffffffc0200bc0:	0017d79b          	srliw	a5,a5,0x1
        if (left_longest + right_longest == node_size)
ffffffffc0200bc4:	010588bb          	addw	a7,a1,a6
ffffffffc0200bc8:	86ba                	mv	a3,a4
ffffffffc0200bca:	00e88863          	beq	a7,a4,ffffffffc0200bda <buddy2_free+0x9e>
            buddy_longest[index] = MAX(left_longest, right_longest);
ffffffffc0200bce:	0005869b          	sext.w	a3,a1
ffffffffc0200bd2:	0105f463          	bgeu	a1,a6,ffffffffc0200bda <buddy2_free+0x9e>
ffffffffc0200bd6:	0008069b          	sext.w	a3,a6
ffffffffc0200bda:	1602                	slli	a2,a2,0x20
ffffffffc0200bdc:	8279                	srli	a2,a2,0x1e
ffffffffc0200bde:	962a                	add	a2,a2,a0
ffffffffc0200be0:	c214                	sw	a3,0(a2)
    while (index) {
ffffffffc0200be2:	f7dd                	bnez	a5,ffffffffc0200b90 <buddy2_free+0x54>
ffffffffc0200be4:	8082                	ret
    node_size = 1;
ffffffffc0200be6:	4705                	li	a4,1
ffffffffc0200be8:	bf69                	j	ffffffffc0200b82 <buddy2_free+0x46>
void buddy2_free(unsigned offset) {
ffffffffc0200bea:	1141                	addi	sp,sp,-16
    assert(offset < buddy_size);
ffffffffc0200bec:	00001697          	auipc	a3,0x1
ffffffffc0200bf0:	2c468693          	addi	a3,a3,708 # ffffffffc0201eb0 <commands+0x5c8>
ffffffffc0200bf4:	00001617          	auipc	a2,0x1
ffffffffc0200bf8:	27460613          	addi	a2,a2,628 # ffffffffc0201e68 <commands+0x580>
ffffffffc0200bfc:	05c00593          	li	a1,92
ffffffffc0200c00:	00001517          	auipc	a0,0x1
ffffffffc0200c04:	28050513          	addi	a0,a0,640 # ffffffffc0201e80 <commands+0x598>
void buddy2_free(unsigned offset) {
ffffffffc0200c08:	e406                	sd	ra,8(sp)
    assert(offset < buddy_size);
ffffffffc0200c0a:	fa2ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200c0e <buddy_system_free_pages>:
    assert(n > 0);
ffffffffc0200c0e:	c18d                	beqz	a1,ffffffffc0200c30 <buddy_system_free_pages+0x22>
    if (base == NULL) {
ffffffffc0200c10:	cd19                	beqz	a0,ffffffffc0200c2e <buddy_system_free_pages+0x20>
    struct Page *page = le2page(le, page_link);
ffffffffc0200c12:	00045797          	auipc	a5,0x45
ffffffffc0200c16:	40e7b783          	ld	a5,1038(a5) # ffffffffc0246020 <free_area+0x8>
ffffffffc0200c1a:	17a1                	addi	a5,a5,-24
    size_t offset = base - page; // 计算偏移量
ffffffffc0200c1c:	8d1d                	sub	a0,a0,a5
ffffffffc0200c1e:	850d                	srai	a0,a0,0x3
ffffffffc0200c20:	00002797          	auipc	a5,0x2
ffffffffc0200c24:	8587b783          	ld	a5,-1960(a5) # ffffffffc0202478 <error_string+0x38>
    buddy2_free(offset);
ffffffffc0200c28:	02f5053b          	mulw	a0,a0,a5
ffffffffc0200c2c:	bf01                	j	ffffffffc0200b3c <buddy2_free>
ffffffffc0200c2e:	8082                	ret
buddy_system_free_pages(struct Page *base, size_t n) {
ffffffffc0200c30:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200c32:	00001697          	auipc	a3,0x1
ffffffffc0200c36:	22e68693          	addi	a3,a3,558 # ffffffffc0201e60 <commands+0x578>
ffffffffc0200c3a:	00001617          	auipc	a2,0x1
ffffffffc0200c3e:	22e60613          	addi	a2,a2,558 # ffffffffc0201e68 <commands+0x580>
ffffffffc0200c42:	0a100593          	li	a1,161
ffffffffc0200c46:	00001517          	auipc	a0,0x1
ffffffffc0200c4a:	23a50513          	addi	a0,a0,570 # ffffffffc0201e80 <commands+0x598>
buddy_system_free_pages(struct Page *base, size_t n) {
ffffffffc0200c4e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200c50:	f5cff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200c54 <buddy_system_check>:
    free_page(p1);
    free_page(p2);
}

// 检查函数
static void buddy_system_check() {
ffffffffc0200c54:	7139                	addi	sp,sp,-64
    cprintf("开始 buddy system 测试...\n");
ffffffffc0200c56:	00001517          	auipc	a0,0x1
ffffffffc0200c5a:	27250513          	addi	a0,a0,626 # ffffffffc0201ec8 <commands+0x5e0>
static void buddy_system_check() {
ffffffffc0200c5e:	fc06                	sd	ra,56(sp)
ffffffffc0200c60:	ec4e                	sd	s3,24(sp)
ffffffffc0200c62:	f822                	sd	s0,48(sp)
ffffffffc0200c64:	f426                	sd	s1,40(sp)
ffffffffc0200c66:	f04a                	sd	s2,32(sp)
ffffffffc0200c68:	e852                	sd	s4,16(sp)
ffffffffc0200c6a:	e456                	sd	s5,8(sp)
    cprintf("开始 buddy system 测试...\n");
ffffffffc0200c6c:	c46ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    size_t offset = buddy2_alloc(n);
ffffffffc0200c70:	6521                	lui	a0,0x8
ffffffffc0200c72:	d95ff0ef          	jal	ra,ffffffffc0200a06 <buddy2_alloc>
    if (offset == -1) return NULL; // 分配失败
ffffffffc0200c76:	59fd                	li	s3,-1
ffffffffc0200c78:	2d350c63          	beq	a0,s3,ffffffffc0200f50 <buddy_system_check+0x2fc>
    return listelm->next;
ffffffffc0200c7c:	00045497          	auipc	s1,0x45
ffffffffc0200c80:	39c48493          	addi	s1,s1,924 # ffffffffc0246018 <free_area>
    page = page + offset;
ffffffffc0200c84:	00251793          	slli	a5,a0,0x2
ffffffffc0200c88:	6480                	ld	s0,8(s1)
ffffffffc0200c8a:	953e                	add	a0,a0,a5
ffffffffc0200c8c:	050e                	slli	a0,a0,0x3
ffffffffc0200c8e:	1521                	addi	a0,a0,-24
ffffffffc0200c90:	942a                	add	s0,s0,a0

    // 测试1: 全内存分配和释放
    struct Page* p_all = buddy_system_alloc_pages(32768);
    if (p_all == NULL) {
ffffffffc0200c92:	2a040f63          	beqz	s0,ffffffffc0200f50 <buddy_system_check+0x2fc>
        cprintf("测试1: 全内存分配测试失败！\n");
        return;
    } else {
        cprintf("测试1: 全内存分配测试通过!\n");
ffffffffc0200c96:	00001517          	auipc	a0,0x1
ffffffffc0200c9a:	28250513          	addi	a0,a0,642 # ffffffffc0201f18 <commands+0x630>
ffffffffc0200c9e:	c14ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    struct Page *page = le2page(le, page_link);
ffffffffc0200ca2:	6488                	ld	a0,8(s1)
    size_t offset = base - page; // 计算偏移量
ffffffffc0200ca4:	00001917          	auipc	s2,0x1
ffffffffc0200ca8:	7d493903          	ld	s2,2004(s2) # ffffffffc0202478 <error_string+0x38>
    struct Page *page = le2page(le, page_link);
ffffffffc0200cac:	1521                	addi	a0,a0,-24
    size_t offset = base - page; // 计算偏移量
ffffffffc0200cae:	40a40533          	sub	a0,s0,a0
ffffffffc0200cb2:	850d                	srai	a0,a0,0x3
    buddy2_free(offset);
ffffffffc0200cb4:	0325053b          	mulw	a0,a0,s2
ffffffffc0200cb8:	e85ff0ef          	jal	ra,ffffffffc0200b3c <buddy2_free>
    size_t offset = buddy2_alloc(n);
ffffffffc0200cbc:	6521                	lui	a0,0x8
ffffffffc0200cbe:	0505                	addi	a0,a0,1
ffffffffc0200cc0:	d47ff0ef          	jal	ra,ffffffffc0200a06 <buddy2_alloc>
    if (offset == -1) return NULL; // 分配失败
ffffffffc0200cc4:	03350863          	beq	a0,s3,ffffffffc0200cf4 <buddy_system_check+0xa0>
    page = page + offset;
ffffffffc0200cc8:	00251793          	slli	a5,a0,0x2
ffffffffc0200ccc:	97aa                	add	a5,a5,a0
ffffffffc0200cce:	6498                	ld	a4,8(s1)
ffffffffc0200cd0:	078e                	slli	a5,a5,0x3
ffffffffc0200cd2:	17a1                	addi	a5,a5,-24
ffffffffc0200cd4:	97ba                	add	a5,a5,a4
    // 测试2: 边界条件测试，超过总内存大小分配应失败
    struct Page* p_alll = buddy_system_alloc_pages(32769);
    if (p_alll == NULL) {
        cprintf("测试2: 边界条件测试通过！\n");
    } else {
        cprintf("测试2: 边界条件测试失败！\n");
ffffffffc0200cd6:	00001517          	auipc	a0,0x1
ffffffffc0200cda:	38a50513          	addi	a0,a0,906 # ffffffffc0202060 <commands+0x778>
    if (p_alll == NULL) {
ffffffffc0200cde:	cb99                	beqz	a5,ffffffffc0200cf4 <buddy_system_check+0xa0>
    //     return;
    // }
    // cprintf("块合并测试通过...\n");

    cprintf("buddy system 测试完成.\n");
}
ffffffffc0200ce0:	7442                	ld	s0,48(sp)
ffffffffc0200ce2:	70e2                	ld	ra,56(sp)
ffffffffc0200ce4:	74a2                	ld	s1,40(sp)
ffffffffc0200ce6:	7902                	ld	s2,32(sp)
ffffffffc0200ce8:	69e2                	ld	s3,24(sp)
ffffffffc0200cea:	6a42                	ld	s4,16(sp)
ffffffffc0200cec:	6aa2                	ld	s5,8(sp)
ffffffffc0200cee:	6121                	addi	sp,sp,64
        cprintf("测试2: 边界条件测试失败！\n");
ffffffffc0200cf0:	bc2ff06f          	j	ffffffffc02000b2 <cprintf>
        cprintf("测试2: 边界条件测试通过！\n");
ffffffffc0200cf4:	00001517          	auipc	a0,0x1
ffffffffc0200cf8:	24c50513          	addi	a0,a0,588 # ffffffffc0201f40 <commands+0x658>
ffffffffc0200cfc:	bb6ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    size_t offset = buddy2_alloc(n);
ffffffffc0200d00:	6511                	lui	a0,0x4
ffffffffc0200d02:	e8050513          	addi	a0,a0,-384 # 3e80 <kern_entry-0xffffffffc01fc180>
ffffffffc0200d06:	d01ff0ef          	jal	ra,ffffffffc0200a06 <buddy2_alloc>
    if (offset == -1) return NULL; // 分配失败
ffffffffc0200d0a:	57fd                	li	a5,-1
ffffffffc0200d0c:	26f50063          	beq	a0,a5,ffffffffc0200f6c <buddy_system_check+0x318>
    page = page + offset;
ffffffffc0200d10:	00251793          	slli	a5,a0,0x2
ffffffffc0200d14:	0084b983          	ld	s3,8(s1)
ffffffffc0200d18:	953e                	add	a0,a0,a5
ffffffffc0200d1a:	050e                	slli	a0,a0,0x3
ffffffffc0200d1c:	1521                	addi	a0,a0,-24
ffffffffc0200d1e:	99aa                	add	s3,s3,a0
    return buddy_longest[0];  // 根节点的值代表最大可用块
ffffffffc0200d20:	00005417          	auipc	s0,0x5
ffffffffc0200d24:	2f840413          	addi	s0,s0,760 # ffffffffc0206018 <buddy_longest>
    cprintf("max_alloc = %d\n", n1);
ffffffffc0200d28:	400c                	lw	a1,0(s0)
ffffffffc0200d2a:	00001517          	auipc	a0,0x1
ffffffffc0200d2e:	23e50513          	addi	a0,a0,574 # ffffffffc0201f68 <commands+0x680>
ffffffffc0200d32:	b80ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    size_t offset = buddy2_alloc(n);
ffffffffc0200d36:	6505                	lui	a0,0x1
ffffffffc0200d38:	77050513          	addi	a0,a0,1904 # 1770 <kern_entry-0xffffffffc01fe890>
ffffffffc0200d3c:	ccbff0ef          	jal	ra,ffffffffc0200a06 <buddy2_alloc>
    if (offset == -1) return NULL; // 分配失败
ffffffffc0200d40:	57fd                	li	a5,-1
ffffffffc0200d42:	22f50763          	beq	a0,a5,ffffffffc0200f70 <buddy_system_check+0x31c>
    page = page + offset;
ffffffffc0200d46:	00251793          	slli	a5,a0,0x2
ffffffffc0200d4a:	0084ba03          	ld	s4,8(s1)
ffffffffc0200d4e:	953e                	add	a0,a0,a5
ffffffffc0200d50:	050e                	slli	a0,a0,0x3
ffffffffc0200d52:	1521                	addi	a0,a0,-24
ffffffffc0200d54:	9a2a                	add	s4,s4,a0
    cprintf("max_alloc = %d\n", n2);
ffffffffc0200d56:	400c                	lw	a1,0(s0)
ffffffffc0200d58:	00001517          	auipc	a0,0x1
ffffffffc0200d5c:	21050513          	addi	a0,a0,528 # ffffffffc0201f68 <commands+0x680>
ffffffffc0200d60:	b52ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    size_t offset = buddy2_alloc(n);
ffffffffc0200d64:	6509                	lui	a0,0x2
ffffffffc0200d66:	32850513          	addi	a0,a0,808 # 2328 <kern_entry-0xffffffffc01fdcd8>
ffffffffc0200d6a:	c9dff0ef          	jal	ra,ffffffffc0200a06 <buddy2_alloc>
    if (offset == -1) return NULL; // 分配失败
ffffffffc0200d6e:	57fd                	li	a5,-1
ffffffffc0200d70:	1ef50c63          	beq	a0,a5,ffffffffc0200f68 <buddy_system_check+0x314>
    page = page + offset;
ffffffffc0200d74:	00251793          	slli	a5,a0,0x2
ffffffffc0200d78:	0084ba83          	ld	s5,8(s1)
ffffffffc0200d7c:	953e                	add	a0,a0,a5
ffffffffc0200d7e:	050e                	slli	a0,a0,0x3
ffffffffc0200d80:	1521                	addi	a0,a0,-24
ffffffffc0200d82:	9aaa                	add	s5,s5,a0
    cprintf("max_alloc = %d\n", n3);
ffffffffc0200d84:	400c                	lw	a1,0(s0)
ffffffffc0200d86:	00001517          	auipc	a0,0x1
ffffffffc0200d8a:	1e250513          	addi	a0,a0,482 # ffffffffc0201f68 <commands+0x680>
ffffffffc0200d8e:	b24ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (p1 == NULL || p2 == NULL || p3 == NULL) {
ffffffffc0200d92:	1c098463          	beqz	s3,ffffffffc0200f5a <buddy_system_check+0x306>
ffffffffc0200d96:	000a0463          	beqz	s4,ffffffffc0200d9e <buddy_system_check+0x14a>
ffffffffc0200d9a:	1a0a9163          	bnez	s5,ffffffffc0200f3c <buddy_system_check+0x2e8>
        cprintf("测试3: 连续分配测试通过！\n");
ffffffffc0200d9e:	00001517          	auipc	a0,0x1
ffffffffc0200da2:	2ea50513          	addi	a0,a0,746 # ffffffffc0202088 <commands+0x7a0>
ffffffffc0200da6:	b0cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    struct Page *page = le2page(le, page_link);
ffffffffc0200daa:	6488                	ld	a0,8(s1)
ffffffffc0200dac:	1521                	addi	a0,a0,-24
    size_t offset = base - page; // 计算偏移量
ffffffffc0200dae:	40a98533          	sub	a0,s3,a0
ffffffffc0200db2:	850d                	srai	a0,a0,0x3
    buddy2_free(offset);
ffffffffc0200db4:	0325053b          	mulw	a0,a0,s2
ffffffffc0200db8:	d85ff0ef          	jal	ra,ffffffffc0200b3c <buddy2_free>
    if (base == NULL) {
ffffffffc0200dbc:	000a0b63          	beqz	s4,ffffffffc0200dd2 <buddy_system_check+0x17e>
    struct Page *page = le2page(le, page_link);
ffffffffc0200dc0:	6488                	ld	a0,8(s1)
ffffffffc0200dc2:	1521                	addi	a0,a0,-24
    size_t offset = base - page; // 计算偏移量
ffffffffc0200dc4:	40aa0533          	sub	a0,s4,a0
ffffffffc0200dc8:	850d                	srai	a0,a0,0x3
    buddy2_free(offset);
ffffffffc0200dca:	0325053b          	mulw	a0,a0,s2
ffffffffc0200dce:	d6fff0ef          	jal	ra,ffffffffc0200b3c <buddy2_free>
    if (base == NULL) {
ffffffffc0200dd2:	000a8b63          	beqz	s5,ffffffffc0200de8 <buddy_system_check+0x194>
    struct Page *page = le2page(le, page_link);
ffffffffc0200dd6:	6488                	ld	a0,8(s1)
ffffffffc0200dd8:	1521                	addi	a0,a0,-24
    size_t offset = base - page; // 计算偏移量
ffffffffc0200dda:	40aa8533          	sub	a0,s5,a0
ffffffffc0200dde:	850d                	srai	a0,a0,0x3
    buddy2_free(offset);
ffffffffc0200de0:	0325053b          	mulw	a0,a0,s2
ffffffffc0200de4:	d59ff0ef          	jal	ra,ffffffffc0200b3c <buddy2_free>
    cprintf("max_alloc = %d\n", n);
ffffffffc0200de8:	400c                	lw	a1,0(s0)
ffffffffc0200dea:	00001517          	auipc	a0,0x1
ffffffffc0200dee:	17e50513          	addi	a0,a0,382 # ffffffffc0201f68 <commands+0x680>
ffffffffc0200df2:	ac0ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    size_t offset = buddy2_alloc(n);
ffffffffc0200df6:	6511                	lui	a0,0x4
ffffffffc0200df8:	e8050513          	addi	a0,a0,-384 # 3e80 <kern_entry-0xffffffffc01fc180>
ffffffffc0200dfc:	c0bff0ef          	jal	ra,ffffffffc0200a06 <buddy2_alloc>
    if (offset == -1) return NULL; // 分配失败
ffffffffc0200e00:	57fd                	li	a5,-1
ffffffffc0200e02:	16f50963          	beq	a0,a5,ffffffffc0200f74 <buddy_system_check+0x320>
    page = page + offset;
ffffffffc0200e06:	00251793          	slli	a5,a0,0x2
ffffffffc0200e0a:	0084b983          	ld	s3,8(s1)
ffffffffc0200e0e:	953e                	add	a0,a0,a5
ffffffffc0200e10:	050e                	slli	a0,a0,0x3
ffffffffc0200e12:	1521                	addi	a0,a0,-24
ffffffffc0200e14:	99aa                	add	s3,s3,a0
    cprintf("max_alloc = %d\n", n4);
ffffffffc0200e16:	400c                	lw	a1,0(s0)
ffffffffc0200e18:	00001517          	auipc	a0,0x1
ffffffffc0200e1c:	15050513          	addi	a0,a0,336 # ffffffffc0201f68 <commands+0x680>
ffffffffc0200e20:	a92ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    size_t offset = buddy2_alloc(n);
ffffffffc0200e24:	6505                	lui	a0,0x1
ffffffffc0200e26:	77050513          	addi	a0,a0,1904 # 1770 <kern_entry-0xffffffffc01fe890>
ffffffffc0200e2a:	bddff0ef          	jal	ra,ffffffffc0200a06 <buddy2_alloc>
    if (offset == -1) return NULL; // 分配失败
ffffffffc0200e2e:	57fd                	li	a5,-1
ffffffffc0200e30:	14f50463          	beq	a0,a5,ffffffffc0200f78 <buddy_system_check+0x324>
    page = page + offset;
ffffffffc0200e34:	00251793          	slli	a5,a0,0x2
ffffffffc0200e38:	0084ba03          	ld	s4,8(s1)
ffffffffc0200e3c:	953e                	add	a0,a0,a5
ffffffffc0200e3e:	050e                	slli	a0,a0,0x3
ffffffffc0200e40:	1521                	addi	a0,a0,-24
ffffffffc0200e42:	9a2a                	add	s4,s4,a0
    cprintf("max_alloc = %d\n", n5);
ffffffffc0200e44:	400c                	lw	a1,0(s0)
ffffffffc0200e46:	00001517          	auipc	a0,0x1
ffffffffc0200e4a:	12250513          	addi	a0,a0,290 # ffffffffc0201f68 <commands+0x680>
ffffffffc0200e4e:	a64ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    size_t offset = buddy2_alloc(n);
ffffffffc0200e52:	6509                	lui	a0,0x2
ffffffffc0200e54:	f4050513          	addi	a0,a0,-192 # 1f40 <kern_entry-0xffffffffc01fe0c0>
ffffffffc0200e58:	bafff0ef          	jal	ra,ffffffffc0200a06 <buddy2_alloc>
    if (offset == -1) return NULL; // 分配失败
ffffffffc0200e5c:	57fd                	li	a5,-1
ffffffffc0200e5e:	10f50f63          	beq	a0,a5,ffffffffc0200f7c <buddy_system_check+0x328>
    page = page + offset;
ffffffffc0200e62:	00251793          	slli	a5,a0,0x2
ffffffffc0200e66:	0084ba83          	ld	s5,8(s1)
ffffffffc0200e6a:	953e                	add	a0,a0,a5
ffffffffc0200e6c:	050e                	slli	a0,a0,0x3
ffffffffc0200e6e:	1521                	addi	a0,a0,-24
ffffffffc0200e70:	9aaa                	add	s5,s5,a0
    cprintf("max_alloc = %d\n", n6);
ffffffffc0200e72:	400c                	lw	a1,0(s0)
ffffffffc0200e74:	00001517          	auipc	a0,0x1
ffffffffc0200e78:	0f450513          	addi	a0,a0,244 # ffffffffc0201f68 <commands+0x680>
ffffffffc0200e7c:	a36ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (p4 == NULL || p5 == NULL || p6 == NULL) {
ffffffffc0200e80:	0c098363          	beqz	s3,ffffffffc0200f46 <buddy_system_check+0x2f2>
ffffffffc0200e84:	0c0a0163          	beqz	s4,ffffffffc0200f46 <buddy_system_check+0x2f2>
ffffffffc0200e88:	0a0a8f63          	beqz	s5,ffffffffc0200f46 <buddy_system_check+0x2f2>
        cprintf("测试4: 连续分配测试通过! \n");
ffffffffc0200e8c:	00001517          	auipc	a0,0x1
ffffffffc0200e90:	13c50513          	addi	a0,a0,316 # ffffffffc0201fc8 <commands+0x6e0>
ffffffffc0200e94:	a1eff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    struct Page *page = le2page(le, page_link);
ffffffffc0200e98:	6488                	ld	a0,8(s1)
ffffffffc0200e9a:	1521                	addi	a0,a0,-24
    size_t offset = base - page; // 计算偏移量
ffffffffc0200e9c:	40a98533          	sub	a0,s3,a0
ffffffffc0200ea0:	850d                	srai	a0,a0,0x3
    buddy2_free(offset);
ffffffffc0200ea2:	0325053b          	mulw	a0,a0,s2
ffffffffc0200ea6:	c97ff0ef          	jal	ra,ffffffffc0200b3c <buddy2_free>
    cprintf("max_alloc = %d\n", n44);
ffffffffc0200eaa:	400c                	lw	a1,0(s0)
ffffffffc0200eac:	00001517          	auipc	a0,0x1
ffffffffc0200eb0:	0bc50513          	addi	a0,a0,188 # ffffffffc0201f68 <commands+0x680>
ffffffffc0200eb4:	9feff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    struct Page *page = le2page(le, page_link);
ffffffffc0200eb8:	6488                	ld	a0,8(s1)
ffffffffc0200eba:	1521                	addi	a0,a0,-24
    size_t offset = base - page; // 计算偏移量
ffffffffc0200ebc:	40aa0533          	sub	a0,s4,a0
ffffffffc0200ec0:	850d                	srai	a0,a0,0x3
    buddy2_free(offset);
ffffffffc0200ec2:	0325053b          	mulw	a0,a0,s2
ffffffffc0200ec6:	c77ff0ef          	jal	ra,ffffffffc0200b3c <buddy2_free>
    cprintf("max_alloc = %d\n", n55);
ffffffffc0200eca:	400c                	lw	a1,0(s0)
ffffffffc0200ecc:	00001517          	auipc	a0,0x1
ffffffffc0200ed0:	09c50513          	addi	a0,a0,156 # ffffffffc0201f68 <commands+0x680>
ffffffffc0200ed4:	9deff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    struct Page *page = le2page(le, page_link);
ffffffffc0200ed8:	6488                	ld	a0,8(s1)
ffffffffc0200eda:	1521                	addi	a0,a0,-24
    size_t offset = base - page; // 计算偏移量
ffffffffc0200edc:	40aa8533          	sub	a0,s5,a0
ffffffffc0200ee0:	850d                	srai	a0,a0,0x3
    buddy2_free(offset);
ffffffffc0200ee2:	0325053b          	mulw	a0,a0,s2
ffffffffc0200ee6:	c57ff0ef          	jal	ra,ffffffffc0200b3c <buddy2_free>
    cprintf("max_alloc = %d\n", n66);
ffffffffc0200eea:	400c                	lw	a1,0(s0)
ffffffffc0200eec:	00001517          	auipc	a0,0x1
ffffffffc0200ef0:	07c50513          	addi	a0,a0,124 # ffffffffc0201f68 <commands+0x680>
ffffffffc0200ef4:	9beff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    size_t offset = buddy2_alloc(n);
ffffffffc0200ef8:	6521                	lui	a0,0x8
ffffffffc0200efa:	b0dff0ef          	jal	ra,ffffffffc0200a06 <buddy2_alloc>
    if (offset == -1) return NULL; // 分配失败
ffffffffc0200efe:	57fd                	li	a5,-1
ffffffffc0200f00:	08f50063          	beq	a0,a5,ffffffffc0200f80 <buddy_system_check+0x32c>
    page = page + offset;
ffffffffc0200f04:	00251793          	slli	a5,a0,0x2
ffffffffc0200f08:	6480                	ld	s0,8(s1)
ffffffffc0200f0a:	953e                	add	a0,a0,a5
ffffffffc0200f0c:	050e                	slli	a0,a0,0x3
ffffffffc0200f0e:	1521                	addi	a0,a0,-24
ffffffffc0200f10:	942a                	add	s0,s0,a0
    if (p_again == NULL) {
ffffffffc0200f12:	c43d                	beqz	s0,ffffffffc0200f80 <buddy_system_check+0x32c>
        cprintf("测试5: 释放合并测试通过!\n");
ffffffffc0200f14:	00001517          	auipc	a0,0x1
ffffffffc0200f18:	10450513          	addi	a0,a0,260 # ffffffffc0202018 <commands+0x730>
ffffffffc0200f1c:	996ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    struct Page *page = le2page(le, page_link);
ffffffffc0200f20:	6488                	ld	a0,8(s1)
ffffffffc0200f22:	1521                	addi	a0,a0,-24
    size_t offset = base - page; // 计算偏移量
ffffffffc0200f24:	40a40533          	sub	a0,s0,a0
ffffffffc0200f28:	850d                	srai	a0,a0,0x3
    buddy2_free(offset);
ffffffffc0200f2a:	0325053b          	mulw	a0,a0,s2
ffffffffc0200f2e:	c0fff0ef          	jal	ra,ffffffffc0200b3c <buddy2_free>
    cprintf("buddy system 测试完成.\n");
ffffffffc0200f32:	00001517          	auipc	a0,0x1
ffffffffc0200f36:	10e50513          	addi	a0,a0,270 # ffffffffc0202040 <commands+0x758>
ffffffffc0200f3a:	b35d                	j	ffffffffc0200ce0 <buddy_system_check+0x8c>
        cprintf("测试3: 连续分配测试失败! \n");
ffffffffc0200f3c:	00001517          	auipc	a0,0x1
ffffffffc0200f40:	03c50513          	addi	a0,a0,60 # ffffffffc0201f78 <commands+0x690>
ffffffffc0200f44:	bb71                	j	ffffffffc0200ce0 <buddy_system_check+0x8c>
        cprintf("测试4: 连续分配测试失败！\n");
ffffffffc0200f46:	00001517          	auipc	a0,0x1
ffffffffc0200f4a:	05a50513          	addi	a0,a0,90 # ffffffffc0201fa0 <commands+0x6b8>
ffffffffc0200f4e:	bb49                	j	ffffffffc0200ce0 <buddy_system_check+0x8c>
        cprintf("测试1: 全内存分配测试失败！\n");
ffffffffc0200f50:	00001517          	auipc	a0,0x1
ffffffffc0200f54:	f9850513          	addi	a0,a0,-104 # ffffffffc0201ee8 <commands+0x600>
ffffffffc0200f58:	b361                	j	ffffffffc0200ce0 <buddy_system_check+0x8c>
        cprintf("测试3: 连续分配测试通过！\n");
ffffffffc0200f5a:	00001517          	auipc	a0,0x1
ffffffffc0200f5e:	12e50513          	addi	a0,a0,302 # ffffffffc0202088 <commands+0x7a0>
ffffffffc0200f62:	950ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (base == NULL) {
ffffffffc0200f66:	bd99                	j	ffffffffc0200dbc <buddy_system_check+0x168>
    if (offset == -1) return NULL; // 分配失败
ffffffffc0200f68:	4a81                	li	s5,0
ffffffffc0200f6a:	bd29                	j	ffffffffc0200d84 <buddy_system_check+0x130>
ffffffffc0200f6c:	4981                	li	s3,0
ffffffffc0200f6e:	bb4d                	j	ffffffffc0200d20 <buddy_system_check+0xcc>
ffffffffc0200f70:	4a01                	li	s4,0
ffffffffc0200f72:	b3d5                	j	ffffffffc0200d56 <buddy_system_check+0x102>
ffffffffc0200f74:	4981                	li	s3,0
ffffffffc0200f76:	b545                	j	ffffffffc0200e16 <buddy_system_check+0x1c2>
ffffffffc0200f78:	4a01                	li	s4,0
ffffffffc0200f7a:	b5e9                	j	ffffffffc0200e44 <buddy_system_check+0x1f0>
ffffffffc0200f7c:	4a81                	li	s5,0
ffffffffc0200f7e:	bdd5                	j	ffffffffc0200e72 <buddy_system_check+0x21e>
        cprintf("测试5: 释放合并测试失败！\n");
ffffffffc0200f80:	00001517          	auipc	a0,0x1
ffffffffc0200f84:	07050513          	addi	a0,a0,112 # ffffffffc0201ff0 <commands+0x708>
ffffffffc0200f88:	bba1                	j	ffffffffc0200ce0 <buddy_system_check+0x8c>

ffffffffc0200f8a <pmm_init>:

static void check_alloc_page(void);

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200f8a:	00001797          	auipc	a5,0x1
ffffffffc0200f8e:	14678793          	addi	a5,a5,326 # ffffffffc02020d0 <buddy_system_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200f92:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200f94:	1101                	addi	sp,sp,-32
ffffffffc0200f96:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200f98:	00001517          	auipc	a0,0x1
ffffffffc0200f9c:	17050513          	addi	a0,a0,368 # ffffffffc0202108 <buddy_system_pmm_manager+0x38>
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200fa0:	00045497          	auipc	s1,0x45
ffffffffc0200fa4:	4c048493          	addi	s1,s1,1216 # ffffffffc0246460 <pmm_manager>
void pmm_init(void) {
ffffffffc0200fa8:	ec06                	sd	ra,24(sp)
ffffffffc0200faa:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200fac:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fae:	904ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc0200fb2:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200fb4:	00045417          	auipc	s0,0x45
ffffffffc0200fb8:	4c440413          	addi	s0,s0,1220 # ffffffffc0246478 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200fbc:	679c                	ld	a5,8(a5)
ffffffffc0200fbe:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200fc0:	57f5                	li	a5,-3
ffffffffc0200fc2:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200fc4:	00001517          	auipc	a0,0x1
ffffffffc0200fc8:	15c50513          	addi	a0,a0,348 # ffffffffc0202120 <buddy_system_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200fcc:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0200fce:	8e4ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200fd2:	46c5                	li	a3,17
ffffffffc0200fd4:	06ee                	slli	a3,a3,0x1b
ffffffffc0200fd6:	40100613          	li	a2,1025
ffffffffc0200fda:	16fd                	addi	a3,a3,-1
ffffffffc0200fdc:	07e005b7          	lui	a1,0x7e00
ffffffffc0200fe0:	0656                	slli	a2,a2,0x15
ffffffffc0200fe2:	00001517          	auipc	a0,0x1
ffffffffc0200fe6:	15650513          	addi	a0,a0,342 # ffffffffc0202138 <buddy_system_pmm_manager+0x68>
ffffffffc0200fea:	8c8ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200fee:	777d                	lui	a4,0xfffff
ffffffffc0200ff0:	00046797          	auipc	a5,0x46
ffffffffc0200ff4:	49778793          	addi	a5,a5,1175 # ffffffffc0247487 <end+0xfff>
ffffffffc0200ff8:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200ffa:	00045517          	auipc	a0,0x45
ffffffffc0200ffe:	45650513          	addi	a0,a0,1110 # ffffffffc0246450 <npage>
ffffffffc0201002:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201006:	00045597          	auipc	a1,0x45
ffffffffc020100a:	45258593          	addi	a1,a1,1106 # ffffffffc0246458 <pages>
    npage = maxpa / PGSIZE;
ffffffffc020100e:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201010:	e19c                	sd	a5,0(a1)
ffffffffc0201012:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201014:	4701                	li	a4,0
ffffffffc0201016:	4885                	li	a7,1
ffffffffc0201018:	fff80837          	lui	a6,0xfff80
ffffffffc020101c:	a011                	j	ffffffffc0201020 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc020101e:	619c                	ld	a5,0(a1)
ffffffffc0201020:	97b6                	add	a5,a5,a3
ffffffffc0201022:	07a1                	addi	a5,a5,8
ffffffffc0201024:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201028:	611c                	ld	a5,0(a0)
ffffffffc020102a:	0705                	addi	a4,a4,1
ffffffffc020102c:	02868693          	addi	a3,a3,40
ffffffffc0201030:	01078633          	add	a2,a5,a6
ffffffffc0201034:	fec765e3          	bltu	a4,a2,ffffffffc020101e <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201038:	6190                	ld	a2,0(a1)
ffffffffc020103a:	00279713          	slli	a4,a5,0x2
ffffffffc020103e:	973e                	add	a4,a4,a5
ffffffffc0201040:	fec006b7          	lui	a3,0xfec00
ffffffffc0201044:	070e                	slli	a4,a4,0x3
ffffffffc0201046:	96b2                	add	a3,a3,a2
ffffffffc0201048:	96ba                	add	a3,a3,a4
ffffffffc020104a:	c0200737          	lui	a4,0xc0200
ffffffffc020104e:	08e6ef63          	bltu	a3,a4,ffffffffc02010ec <pmm_init+0x162>
ffffffffc0201052:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0201054:	45c5                	li	a1,17
ffffffffc0201056:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201058:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc020105a:	04b6e863          	bltu	a3,a1,ffffffffc02010aa <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020105e:	609c                	ld	a5,0(s1)
ffffffffc0201060:	7b9c                	ld	a5,48(a5)
ffffffffc0201062:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201064:	00001517          	auipc	a0,0x1
ffffffffc0201068:	16c50513          	addi	a0,a0,364 # ffffffffc02021d0 <buddy_system_pmm_manager+0x100>
ffffffffc020106c:	846ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201070:	00004597          	auipc	a1,0x4
ffffffffc0201074:	f9058593          	addi	a1,a1,-112 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0201078:	00045797          	auipc	a5,0x45
ffffffffc020107c:	3eb7bc23          	sd	a1,1016(a5) # ffffffffc0246470 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201080:	c02007b7          	lui	a5,0xc0200
ffffffffc0201084:	08f5e063          	bltu	a1,a5,ffffffffc0201104 <pmm_init+0x17a>
ffffffffc0201088:	6010                	ld	a2,0(s0)
}
ffffffffc020108a:	6442                	ld	s0,16(sp)
ffffffffc020108c:	60e2                	ld	ra,24(sp)
ffffffffc020108e:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0201090:	40c58633          	sub	a2,a1,a2
ffffffffc0201094:	00045797          	auipc	a5,0x45
ffffffffc0201098:	3cc7ba23          	sd	a2,980(a5) # ffffffffc0246468 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020109c:	00001517          	auipc	a0,0x1
ffffffffc02010a0:	15450513          	addi	a0,a0,340 # ffffffffc02021f0 <buddy_system_pmm_manager+0x120>
}
ffffffffc02010a4:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02010a6:	80cff06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02010aa:	6705                	lui	a4,0x1
ffffffffc02010ac:	177d                	addi	a4,a4,-1
ffffffffc02010ae:	96ba                	add	a3,a3,a4
ffffffffc02010b0:	777d                	lui	a4,0xfffff
ffffffffc02010b2:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02010b4:	00c6d513          	srli	a0,a3,0xc
ffffffffc02010b8:	00f57e63          	bgeu	a0,a5,ffffffffc02010d4 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc02010bc:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02010be:	982a                	add	a6,a6,a0
ffffffffc02010c0:	00281513          	slli	a0,a6,0x2
ffffffffc02010c4:	9542                	add	a0,a0,a6
ffffffffc02010c6:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02010c8:	8d95                	sub	a1,a1,a3
ffffffffc02010ca:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02010cc:	81b1                	srli	a1,a1,0xc
ffffffffc02010ce:	9532                	add	a0,a0,a2
ffffffffc02010d0:	9782                	jalr	a5
}
ffffffffc02010d2:	b771                	j	ffffffffc020105e <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc02010d4:	00001617          	auipc	a2,0x1
ffffffffc02010d8:	0cc60613          	addi	a2,a2,204 # ffffffffc02021a0 <buddy_system_pmm_manager+0xd0>
ffffffffc02010dc:	06b00593          	li	a1,107
ffffffffc02010e0:	00001517          	auipc	a0,0x1
ffffffffc02010e4:	0e050513          	addi	a0,a0,224 # ffffffffc02021c0 <buddy_system_pmm_manager+0xf0>
ffffffffc02010e8:	ac4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02010ec:	00001617          	auipc	a2,0x1
ffffffffc02010f0:	07c60613          	addi	a2,a2,124 # ffffffffc0202168 <buddy_system_pmm_manager+0x98>
ffffffffc02010f4:	06f00593          	li	a1,111
ffffffffc02010f8:	00001517          	auipc	a0,0x1
ffffffffc02010fc:	09850513          	addi	a0,a0,152 # ffffffffc0202190 <buddy_system_pmm_manager+0xc0>
ffffffffc0201100:	aacff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201104:	86ae                	mv	a3,a1
ffffffffc0201106:	00001617          	auipc	a2,0x1
ffffffffc020110a:	06260613          	addi	a2,a2,98 # ffffffffc0202168 <buddy_system_pmm_manager+0x98>
ffffffffc020110e:	08a00593          	li	a1,138
ffffffffc0201112:	00001517          	auipc	a0,0x1
ffffffffc0201116:	07e50513          	addi	a0,a0,126 # ffffffffc0202190 <buddy_system_pmm_manager+0xc0>
ffffffffc020111a:	a92ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020111e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020111e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201122:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201124:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201128:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020112a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020112e:	f022                	sd	s0,32(sp)
ffffffffc0201130:	ec26                	sd	s1,24(sp)
ffffffffc0201132:	e84a                	sd	s2,16(sp)
ffffffffc0201134:	f406                	sd	ra,40(sp)
ffffffffc0201136:	e44e                	sd	s3,8(sp)
ffffffffc0201138:	84aa                	mv	s1,a0
ffffffffc020113a:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020113c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201140:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201142:	03067e63          	bgeu	a2,a6,ffffffffc020117e <printnum+0x60>
ffffffffc0201146:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201148:	00805763          	blez	s0,ffffffffc0201156 <printnum+0x38>
ffffffffc020114c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020114e:	85ca                	mv	a1,s2
ffffffffc0201150:	854e                	mv	a0,s3
ffffffffc0201152:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201154:	fc65                	bnez	s0,ffffffffc020114c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201156:	1a02                	slli	s4,s4,0x20
ffffffffc0201158:	00001797          	auipc	a5,0x1
ffffffffc020115c:	0d878793          	addi	a5,a5,216 # ffffffffc0202230 <buddy_system_pmm_manager+0x160>
ffffffffc0201160:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201164:	9a3e                	add	s4,s4,a5
}
ffffffffc0201166:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201168:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020116c:	70a2                	ld	ra,40(sp)
ffffffffc020116e:	69a2                	ld	s3,8(sp)
ffffffffc0201170:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201172:	85ca                	mv	a1,s2
ffffffffc0201174:	87a6                	mv	a5,s1
}
ffffffffc0201176:	6942                	ld	s2,16(sp)
ffffffffc0201178:	64e2                	ld	s1,24(sp)
ffffffffc020117a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020117c:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020117e:	03065633          	divu	a2,a2,a6
ffffffffc0201182:	8722                	mv	a4,s0
ffffffffc0201184:	f9bff0ef          	jal	ra,ffffffffc020111e <printnum>
ffffffffc0201188:	b7f9                	j	ffffffffc0201156 <printnum+0x38>

ffffffffc020118a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020118a:	7119                	addi	sp,sp,-128
ffffffffc020118c:	f4a6                	sd	s1,104(sp)
ffffffffc020118e:	f0ca                	sd	s2,96(sp)
ffffffffc0201190:	ecce                	sd	s3,88(sp)
ffffffffc0201192:	e8d2                	sd	s4,80(sp)
ffffffffc0201194:	e4d6                	sd	s5,72(sp)
ffffffffc0201196:	e0da                	sd	s6,64(sp)
ffffffffc0201198:	fc5e                	sd	s7,56(sp)
ffffffffc020119a:	f06a                	sd	s10,32(sp)
ffffffffc020119c:	fc86                	sd	ra,120(sp)
ffffffffc020119e:	f8a2                	sd	s0,112(sp)
ffffffffc02011a0:	f862                	sd	s8,48(sp)
ffffffffc02011a2:	f466                	sd	s9,40(sp)
ffffffffc02011a4:	ec6e                	sd	s11,24(sp)
ffffffffc02011a6:	892a                	mv	s2,a0
ffffffffc02011a8:	84ae                	mv	s1,a1
ffffffffc02011aa:	8d32                	mv	s10,a2
ffffffffc02011ac:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011ae:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02011b2:	5b7d                	li	s6,-1
ffffffffc02011b4:	00001a97          	auipc	s5,0x1
ffffffffc02011b8:	0b0a8a93          	addi	s5,s5,176 # ffffffffc0202264 <buddy_system_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02011bc:	00001b97          	auipc	s7,0x1
ffffffffc02011c0:	284b8b93          	addi	s7,s7,644 # ffffffffc0202440 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011c4:	000d4503          	lbu	a0,0(s10)
ffffffffc02011c8:	001d0413          	addi	s0,s10,1
ffffffffc02011cc:	01350a63          	beq	a0,s3,ffffffffc02011e0 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02011d0:	c121                	beqz	a0,ffffffffc0201210 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02011d2:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011d4:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02011d6:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011d8:	fff44503          	lbu	a0,-1(s0)
ffffffffc02011dc:	ff351ae3          	bne	a0,s3,ffffffffc02011d0 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011e0:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02011e4:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02011e8:	4c81                	li	s9,0
ffffffffc02011ea:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02011ec:	5c7d                	li	s8,-1
ffffffffc02011ee:	5dfd                	li	s11,-1
ffffffffc02011f0:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02011f4:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011f6:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02011fa:	0ff5f593          	zext.b	a1,a1
ffffffffc02011fe:	00140d13          	addi	s10,s0,1
ffffffffc0201202:	04b56263          	bltu	a0,a1,ffffffffc0201246 <vprintfmt+0xbc>
ffffffffc0201206:	058a                	slli	a1,a1,0x2
ffffffffc0201208:	95d6                	add	a1,a1,s5
ffffffffc020120a:	4194                	lw	a3,0(a1)
ffffffffc020120c:	96d6                	add	a3,a3,s5
ffffffffc020120e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201210:	70e6                	ld	ra,120(sp)
ffffffffc0201212:	7446                	ld	s0,112(sp)
ffffffffc0201214:	74a6                	ld	s1,104(sp)
ffffffffc0201216:	7906                	ld	s2,96(sp)
ffffffffc0201218:	69e6                	ld	s3,88(sp)
ffffffffc020121a:	6a46                	ld	s4,80(sp)
ffffffffc020121c:	6aa6                	ld	s5,72(sp)
ffffffffc020121e:	6b06                	ld	s6,64(sp)
ffffffffc0201220:	7be2                	ld	s7,56(sp)
ffffffffc0201222:	7c42                	ld	s8,48(sp)
ffffffffc0201224:	7ca2                	ld	s9,40(sp)
ffffffffc0201226:	7d02                	ld	s10,32(sp)
ffffffffc0201228:	6de2                	ld	s11,24(sp)
ffffffffc020122a:	6109                	addi	sp,sp,128
ffffffffc020122c:	8082                	ret
            padc = '0';
ffffffffc020122e:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201230:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201234:	846a                	mv	s0,s10
ffffffffc0201236:	00140d13          	addi	s10,s0,1
ffffffffc020123a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020123e:	0ff5f593          	zext.b	a1,a1
ffffffffc0201242:	fcb572e3          	bgeu	a0,a1,ffffffffc0201206 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201246:	85a6                	mv	a1,s1
ffffffffc0201248:	02500513          	li	a0,37
ffffffffc020124c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020124e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201252:	8d22                	mv	s10,s0
ffffffffc0201254:	f73788e3          	beq	a5,s3,ffffffffc02011c4 <vprintfmt+0x3a>
ffffffffc0201258:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020125c:	1d7d                	addi	s10,s10,-1
ffffffffc020125e:	ff379de3          	bne	a5,s3,ffffffffc0201258 <vprintfmt+0xce>
ffffffffc0201262:	b78d                	j	ffffffffc02011c4 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201264:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201268:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020126c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020126e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201272:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201276:	02d86463          	bltu	a6,a3,ffffffffc020129e <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020127a:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020127e:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201282:	0186873b          	addw	a4,a3,s8
ffffffffc0201286:	0017171b          	slliw	a4,a4,0x1
ffffffffc020128a:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc020128c:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201290:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201292:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201296:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020129a:	fed870e3          	bgeu	a6,a3,ffffffffc020127a <vprintfmt+0xf0>
            if (width < 0)
ffffffffc020129e:	f40ddce3          	bgez	s11,ffffffffc02011f6 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02012a2:	8de2                	mv	s11,s8
ffffffffc02012a4:	5c7d                	li	s8,-1
ffffffffc02012a6:	bf81                	j	ffffffffc02011f6 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02012a8:	fffdc693          	not	a3,s11
ffffffffc02012ac:	96fd                	srai	a3,a3,0x3f
ffffffffc02012ae:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012b2:	00144603          	lbu	a2,1(s0)
ffffffffc02012b6:	2d81                	sext.w	s11,s11
ffffffffc02012b8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02012ba:	bf35                	j	ffffffffc02011f6 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02012bc:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012c0:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02012c4:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012c6:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02012c8:	bfd9                	j	ffffffffc020129e <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02012ca:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02012cc:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02012d0:	01174463          	blt	a4,a7,ffffffffc02012d8 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02012d4:	1a088e63          	beqz	a7,ffffffffc0201490 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02012d8:	000a3603          	ld	a2,0(s4)
ffffffffc02012dc:	46c1                	li	a3,16
ffffffffc02012de:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02012e0:	2781                	sext.w	a5,a5
ffffffffc02012e2:	876e                	mv	a4,s11
ffffffffc02012e4:	85a6                	mv	a1,s1
ffffffffc02012e6:	854a                	mv	a0,s2
ffffffffc02012e8:	e37ff0ef          	jal	ra,ffffffffc020111e <printnum>
            break;
ffffffffc02012ec:	bde1                	j	ffffffffc02011c4 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02012ee:	000a2503          	lw	a0,0(s4)
ffffffffc02012f2:	85a6                	mv	a1,s1
ffffffffc02012f4:	0a21                	addi	s4,s4,8
ffffffffc02012f6:	9902                	jalr	s2
            break;
ffffffffc02012f8:	b5f1                	j	ffffffffc02011c4 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02012fa:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02012fc:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201300:	01174463          	blt	a4,a7,ffffffffc0201308 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201304:	18088163          	beqz	a7,ffffffffc0201486 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201308:	000a3603          	ld	a2,0(s4)
ffffffffc020130c:	46a9                	li	a3,10
ffffffffc020130e:	8a2e                	mv	s4,a1
ffffffffc0201310:	bfc1                	j	ffffffffc02012e0 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201312:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201316:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201318:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020131a:	bdf1                	j	ffffffffc02011f6 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020131c:	85a6                	mv	a1,s1
ffffffffc020131e:	02500513          	li	a0,37
ffffffffc0201322:	9902                	jalr	s2
            break;
ffffffffc0201324:	b545                	j	ffffffffc02011c4 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201326:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020132a:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020132c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020132e:	b5e1                	j	ffffffffc02011f6 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201330:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201332:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201336:	01174463          	blt	a4,a7,ffffffffc020133e <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020133a:	14088163          	beqz	a7,ffffffffc020147c <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc020133e:	000a3603          	ld	a2,0(s4)
ffffffffc0201342:	46a1                	li	a3,8
ffffffffc0201344:	8a2e                	mv	s4,a1
ffffffffc0201346:	bf69                	j	ffffffffc02012e0 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201348:	03000513          	li	a0,48
ffffffffc020134c:	85a6                	mv	a1,s1
ffffffffc020134e:	e03e                	sd	a5,0(sp)
ffffffffc0201350:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201352:	85a6                	mv	a1,s1
ffffffffc0201354:	07800513          	li	a0,120
ffffffffc0201358:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020135a:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020135c:	6782                	ld	a5,0(sp)
ffffffffc020135e:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201360:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201364:	bfb5                	j	ffffffffc02012e0 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201366:	000a3403          	ld	s0,0(s4)
ffffffffc020136a:	008a0713          	addi	a4,s4,8
ffffffffc020136e:	e03a                	sd	a4,0(sp)
ffffffffc0201370:	14040263          	beqz	s0,ffffffffc02014b4 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201374:	0fb05763          	blez	s11,ffffffffc0201462 <vprintfmt+0x2d8>
ffffffffc0201378:	02d00693          	li	a3,45
ffffffffc020137c:	0cd79163          	bne	a5,a3,ffffffffc020143e <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201380:	00044783          	lbu	a5,0(s0)
ffffffffc0201384:	0007851b          	sext.w	a0,a5
ffffffffc0201388:	cf85                	beqz	a5,ffffffffc02013c0 <vprintfmt+0x236>
ffffffffc020138a:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020138e:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201392:	000c4563          	bltz	s8,ffffffffc020139c <vprintfmt+0x212>
ffffffffc0201396:	3c7d                	addiw	s8,s8,-1
ffffffffc0201398:	036c0263          	beq	s8,s6,ffffffffc02013bc <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc020139c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020139e:	0e0c8e63          	beqz	s9,ffffffffc020149a <vprintfmt+0x310>
ffffffffc02013a2:	3781                	addiw	a5,a5,-32
ffffffffc02013a4:	0ef47b63          	bgeu	s0,a5,ffffffffc020149a <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02013a8:	03f00513          	li	a0,63
ffffffffc02013ac:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02013ae:	000a4783          	lbu	a5,0(s4)
ffffffffc02013b2:	3dfd                	addiw	s11,s11,-1
ffffffffc02013b4:	0a05                	addi	s4,s4,1
ffffffffc02013b6:	0007851b          	sext.w	a0,a5
ffffffffc02013ba:	ffe1                	bnez	a5,ffffffffc0201392 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02013bc:	01b05963          	blez	s11,ffffffffc02013ce <vprintfmt+0x244>
ffffffffc02013c0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02013c2:	85a6                	mv	a1,s1
ffffffffc02013c4:	02000513          	li	a0,32
ffffffffc02013c8:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02013ca:	fe0d9be3          	bnez	s11,ffffffffc02013c0 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02013ce:	6a02                	ld	s4,0(sp)
ffffffffc02013d0:	bbd5                	j	ffffffffc02011c4 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02013d2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02013d4:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02013d8:	01174463          	blt	a4,a7,ffffffffc02013e0 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02013dc:	08088d63          	beqz	a7,ffffffffc0201476 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02013e0:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02013e4:	0a044d63          	bltz	s0,ffffffffc020149e <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02013e8:	8622                	mv	a2,s0
ffffffffc02013ea:	8a66                	mv	s4,s9
ffffffffc02013ec:	46a9                	li	a3,10
ffffffffc02013ee:	bdcd                	j	ffffffffc02012e0 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02013f0:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02013f4:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02013f6:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02013f8:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02013fc:	8fb5                	xor	a5,a5,a3
ffffffffc02013fe:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201402:	02d74163          	blt	a4,a3,ffffffffc0201424 <vprintfmt+0x29a>
ffffffffc0201406:	00369793          	slli	a5,a3,0x3
ffffffffc020140a:	97de                	add	a5,a5,s7
ffffffffc020140c:	639c                	ld	a5,0(a5)
ffffffffc020140e:	cb99                	beqz	a5,ffffffffc0201424 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201410:	86be                	mv	a3,a5
ffffffffc0201412:	00001617          	auipc	a2,0x1
ffffffffc0201416:	e4e60613          	addi	a2,a2,-434 # ffffffffc0202260 <buddy_system_pmm_manager+0x190>
ffffffffc020141a:	85a6                	mv	a1,s1
ffffffffc020141c:	854a                	mv	a0,s2
ffffffffc020141e:	0ce000ef          	jal	ra,ffffffffc02014ec <printfmt>
ffffffffc0201422:	b34d                	j	ffffffffc02011c4 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201424:	00001617          	auipc	a2,0x1
ffffffffc0201428:	e2c60613          	addi	a2,a2,-468 # ffffffffc0202250 <buddy_system_pmm_manager+0x180>
ffffffffc020142c:	85a6                	mv	a1,s1
ffffffffc020142e:	854a                	mv	a0,s2
ffffffffc0201430:	0bc000ef          	jal	ra,ffffffffc02014ec <printfmt>
ffffffffc0201434:	bb41                	j	ffffffffc02011c4 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201436:	00001417          	auipc	s0,0x1
ffffffffc020143a:	e1240413          	addi	s0,s0,-494 # ffffffffc0202248 <buddy_system_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020143e:	85e2                	mv	a1,s8
ffffffffc0201440:	8522                	mv	a0,s0
ffffffffc0201442:	e43e                	sd	a5,8(sp)
ffffffffc0201444:	1e6000ef          	jal	ra,ffffffffc020162a <strnlen>
ffffffffc0201448:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020144c:	01b05b63          	blez	s11,ffffffffc0201462 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201450:	67a2                	ld	a5,8(sp)
ffffffffc0201452:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201456:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201458:	85a6                	mv	a1,s1
ffffffffc020145a:	8552                	mv	a0,s4
ffffffffc020145c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020145e:	fe0d9ce3          	bnez	s11,ffffffffc0201456 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201462:	00044783          	lbu	a5,0(s0)
ffffffffc0201466:	00140a13          	addi	s4,s0,1
ffffffffc020146a:	0007851b          	sext.w	a0,a5
ffffffffc020146e:	d3a5                	beqz	a5,ffffffffc02013ce <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201470:	05e00413          	li	s0,94
ffffffffc0201474:	bf39                	j	ffffffffc0201392 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201476:	000a2403          	lw	s0,0(s4)
ffffffffc020147a:	b7ad                	j	ffffffffc02013e4 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc020147c:	000a6603          	lwu	a2,0(s4)
ffffffffc0201480:	46a1                	li	a3,8
ffffffffc0201482:	8a2e                	mv	s4,a1
ffffffffc0201484:	bdb1                	j	ffffffffc02012e0 <vprintfmt+0x156>
ffffffffc0201486:	000a6603          	lwu	a2,0(s4)
ffffffffc020148a:	46a9                	li	a3,10
ffffffffc020148c:	8a2e                	mv	s4,a1
ffffffffc020148e:	bd89                	j	ffffffffc02012e0 <vprintfmt+0x156>
ffffffffc0201490:	000a6603          	lwu	a2,0(s4)
ffffffffc0201494:	46c1                	li	a3,16
ffffffffc0201496:	8a2e                	mv	s4,a1
ffffffffc0201498:	b5a1                	j	ffffffffc02012e0 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020149a:	9902                	jalr	s2
ffffffffc020149c:	bf09                	j	ffffffffc02013ae <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc020149e:	85a6                	mv	a1,s1
ffffffffc02014a0:	02d00513          	li	a0,45
ffffffffc02014a4:	e03e                	sd	a5,0(sp)
ffffffffc02014a6:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02014a8:	6782                	ld	a5,0(sp)
ffffffffc02014aa:	8a66                	mv	s4,s9
ffffffffc02014ac:	40800633          	neg	a2,s0
ffffffffc02014b0:	46a9                	li	a3,10
ffffffffc02014b2:	b53d                	j	ffffffffc02012e0 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02014b4:	03b05163          	blez	s11,ffffffffc02014d6 <vprintfmt+0x34c>
ffffffffc02014b8:	02d00693          	li	a3,45
ffffffffc02014bc:	f6d79de3          	bne	a5,a3,ffffffffc0201436 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02014c0:	00001417          	auipc	s0,0x1
ffffffffc02014c4:	d8840413          	addi	s0,s0,-632 # ffffffffc0202248 <buddy_system_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02014c8:	02800793          	li	a5,40
ffffffffc02014cc:	02800513          	li	a0,40
ffffffffc02014d0:	00140a13          	addi	s4,s0,1
ffffffffc02014d4:	bd6d                	j	ffffffffc020138e <vprintfmt+0x204>
ffffffffc02014d6:	00001a17          	auipc	s4,0x1
ffffffffc02014da:	d73a0a13          	addi	s4,s4,-653 # ffffffffc0202249 <buddy_system_pmm_manager+0x179>
ffffffffc02014de:	02800513          	li	a0,40
ffffffffc02014e2:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02014e6:	05e00413          	li	s0,94
ffffffffc02014ea:	b565                	j	ffffffffc0201392 <vprintfmt+0x208>

ffffffffc02014ec <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02014ec:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02014ee:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02014f2:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02014f4:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02014f6:	ec06                	sd	ra,24(sp)
ffffffffc02014f8:	f83a                	sd	a4,48(sp)
ffffffffc02014fa:	fc3e                	sd	a5,56(sp)
ffffffffc02014fc:	e0c2                	sd	a6,64(sp)
ffffffffc02014fe:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201500:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201502:	c89ff0ef          	jal	ra,ffffffffc020118a <vprintfmt>
}
ffffffffc0201506:	60e2                	ld	ra,24(sp)
ffffffffc0201508:	6161                	addi	sp,sp,80
ffffffffc020150a:	8082                	ret

ffffffffc020150c <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020150c:	715d                	addi	sp,sp,-80
ffffffffc020150e:	e486                	sd	ra,72(sp)
ffffffffc0201510:	e0a6                	sd	s1,64(sp)
ffffffffc0201512:	fc4a                	sd	s2,56(sp)
ffffffffc0201514:	f84e                	sd	s3,48(sp)
ffffffffc0201516:	f452                	sd	s4,40(sp)
ffffffffc0201518:	f056                	sd	s5,32(sp)
ffffffffc020151a:	ec5a                	sd	s6,24(sp)
ffffffffc020151c:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc020151e:	c901                	beqz	a0,ffffffffc020152e <readline+0x22>
ffffffffc0201520:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201522:	00001517          	auipc	a0,0x1
ffffffffc0201526:	d3e50513          	addi	a0,a0,-706 # ffffffffc0202260 <buddy_system_pmm_manager+0x190>
ffffffffc020152a:	b89fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc020152e:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201530:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201532:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201534:	4aa9                	li	s5,10
ffffffffc0201536:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201538:	00045b97          	auipc	s7,0x45
ffffffffc020153c:	af8b8b93          	addi	s7,s7,-1288 # ffffffffc0246030 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201540:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201544:	be7fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201548:	00054a63          	bltz	a0,ffffffffc020155c <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020154c:	00a95a63          	bge	s2,a0,ffffffffc0201560 <readline+0x54>
ffffffffc0201550:	029a5263          	bge	s4,s1,ffffffffc0201574 <readline+0x68>
        c = getchar();
ffffffffc0201554:	bd7fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201558:	fe055ae3          	bgez	a0,ffffffffc020154c <readline+0x40>
            return NULL;
ffffffffc020155c:	4501                	li	a0,0
ffffffffc020155e:	a091                	j	ffffffffc02015a2 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201560:	03351463          	bne	a0,s3,ffffffffc0201588 <readline+0x7c>
ffffffffc0201564:	e8a9                	bnez	s1,ffffffffc02015b6 <readline+0xaa>
        c = getchar();
ffffffffc0201566:	bc5fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc020156a:	fe0549e3          	bltz	a0,ffffffffc020155c <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020156e:	fea959e3          	bge	s2,a0,ffffffffc0201560 <readline+0x54>
ffffffffc0201572:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201574:	e42a                	sd	a0,8(sp)
ffffffffc0201576:	b73fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc020157a:	6522                	ld	a0,8(sp)
ffffffffc020157c:	009b87b3          	add	a5,s7,s1
ffffffffc0201580:	2485                	addiw	s1,s1,1
ffffffffc0201582:	00a78023          	sb	a0,0(a5)
ffffffffc0201586:	bf7d                	j	ffffffffc0201544 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201588:	01550463          	beq	a0,s5,ffffffffc0201590 <readline+0x84>
ffffffffc020158c:	fb651ce3          	bne	a0,s6,ffffffffc0201544 <readline+0x38>
            cputchar(c);
ffffffffc0201590:	b59fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc0201594:	00045517          	auipc	a0,0x45
ffffffffc0201598:	a9c50513          	addi	a0,a0,-1380 # ffffffffc0246030 <buf>
ffffffffc020159c:	94aa                	add	s1,s1,a0
ffffffffc020159e:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02015a2:	60a6                	ld	ra,72(sp)
ffffffffc02015a4:	6486                	ld	s1,64(sp)
ffffffffc02015a6:	7962                	ld	s2,56(sp)
ffffffffc02015a8:	79c2                	ld	s3,48(sp)
ffffffffc02015aa:	7a22                	ld	s4,40(sp)
ffffffffc02015ac:	7a82                	ld	s5,32(sp)
ffffffffc02015ae:	6b62                	ld	s6,24(sp)
ffffffffc02015b0:	6bc2                	ld	s7,16(sp)
ffffffffc02015b2:	6161                	addi	sp,sp,80
ffffffffc02015b4:	8082                	ret
            cputchar(c);
ffffffffc02015b6:	4521                	li	a0,8
ffffffffc02015b8:	b31fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc02015bc:	34fd                	addiw	s1,s1,-1
ffffffffc02015be:	b759                	j	ffffffffc0201544 <readline+0x38>

ffffffffc02015c0 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02015c0:	4781                	li	a5,0
ffffffffc02015c2:	00005717          	auipc	a4,0x5
ffffffffc02015c6:	a4673703          	ld	a4,-1466(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc02015ca:	88ba                	mv	a7,a4
ffffffffc02015cc:	852a                	mv	a0,a0
ffffffffc02015ce:	85be                	mv	a1,a5
ffffffffc02015d0:	863e                	mv	a2,a5
ffffffffc02015d2:	00000073          	ecall
ffffffffc02015d6:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02015d8:	8082                	ret

ffffffffc02015da <sbi_set_timer>:
    __asm__ volatile (
ffffffffc02015da:	4781                	li	a5,0
ffffffffc02015dc:	00045717          	auipc	a4,0x45
ffffffffc02015e0:	ea473703          	ld	a4,-348(a4) # ffffffffc0246480 <SBI_SET_TIMER>
ffffffffc02015e4:	88ba                	mv	a7,a4
ffffffffc02015e6:	852a                	mv	a0,a0
ffffffffc02015e8:	85be                	mv	a1,a5
ffffffffc02015ea:	863e                	mv	a2,a5
ffffffffc02015ec:	00000073          	ecall
ffffffffc02015f0:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc02015f2:	8082                	ret

ffffffffc02015f4 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc02015f4:	4501                	li	a0,0
ffffffffc02015f6:	00005797          	auipc	a5,0x5
ffffffffc02015fa:	a0a7b783          	ld	a5,-1526(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc02015fe:	88be                	mv	a7,a5
ffffffffc0201600:	852a                	mv	a0,a0
ffffffffc0201602:	85aa                	mv	a1,a0
ffffffffc0201604:	862a                	mv	a2,a0
ffffffffc0201606:	00000073          	ecall
ffffffffc020160a:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
ffffffffc020160c:	2501                	sext.w	a0,a0
ffffffffc020160e:	8082                	ret

ffffffffc0201610 <sbi_shutdown>:
    __asm__ volatile (
ffffffffc0201610:	4781                	li	a5,0
ffffffffc0201612:	00005717          	auipc	a4,0x5
ffffffffc0201616:	9fe73703          	ld	a4,-1538(a4) # ffffffffc0206010 <SBI_SHUTDOWN>
ffffffffc020161a:	88ba                	mv	a7,a4
ffffffffc020161c:	853e                	mv	a0,a5
ffffffffc020161e:	85be                	mv	a1,a5
ffffffffc0201620:	863e                	mv	a2,a5
ffffffffc0201622:	00000073          	ecall
ffffffffc0201626:	87aa                	mv	a5,a0

void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
ffffffffc0201628:	8082                	ret

ffffffffc020162a <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020162a:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020162c:	e589                	bnez	a1,ffffffffc0201636 <strnlen+0xc>
ffffffffc020162e:	a811                	j	ffffffffc0201642 <strnlen+0x18>
        cnt ++;
ffffffffc0201630:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201632:	00f58863          	beq	a1,a5,ffffffffc0201642 <strnlen+0x18>
ffffffffc0201636:	00f50733          	add	a4,a0,a5
ffffffffc020163a:	00074703          	lbu	a4,0(a4)
ffffffffc020163e:	fb6d                	bnez	a4,ffffffffc0201630 <strnlen+0x6>
ffffffffc0201640:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201642:	852e                	mv	a0,a1
ffffffffc0201644:	8082                	ret

ffffffffc0201646 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201646:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020164a:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020164e:	cb89                	beqz	a5,ffffffffc0201660 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201650:	0505                	addi	a0,a0,1
ffffffffc0201652:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201654:	fee789e3          	beq	a5,a4,ffffffffc0201646 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201658:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020165c:	9d19                	subw	a0,a0,a4
ffffffffc020165e:	8082                	ret
ffffffffc0201660:	4501                	li	a0,0
ffffffffc0201662:	bfed                	j	ffffffffc020165c <strcmp+0x16>

ffffffffc0201664 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201664:	00054783          	lbu	a5,0(a0)
ffffffffc0201668:	c799                	beqz	a5,ffffffffc0201676 <strchr+0x12>
        if (*s == c) {
ffffffffc020166a:	00f58763          	beq	a1,a5,ffffffffc0201678 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020166e:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201672:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201674:	fbfd                	bnez	a5,ffffffffc020166a <strchr+0x6>
    }
    return NULL;
ffffffffc0201676:	4501                	li	a0,0
}
ffffffffc0201678:	8082                	ret

ffffffffc020167a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020167a:	ca01                	beqz	a2,ffffffffc020168a <memset+0x10>
ffffffffc020167c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020167e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201680:	0785                	addi	a5,a5,1
ffffffffc0201682:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201686:	fec79de3          	bne	a5,a2,ffffffffc0201680 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020168a:	8082                	ret
