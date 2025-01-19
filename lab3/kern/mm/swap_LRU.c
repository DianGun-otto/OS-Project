//实现不考虑实现开销和效率的LRU页替换算法
//*LAB3 CHALLENGE EXERCISE : 2211289 张铭*/ 
#include <defs.h>
#include <riscv.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <swap_LRU.h>
#include <list.h>
extern list_entry_t pra_list_head;

static int
_LRU_init_mm(struct mm_struct *mm)
{     
    // 初始化LRU链表的头节点
    list_init(&pra_list_head);
    // 将mm结构体中的sm_priv字段指向LRU链表的头节点
    mm->sm_priv = &pra_list_head;
    // 初始化成功，返回0
    return 0;
}

static int
_LRU_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    // 获取LRU链表的头节点
    list_entry_t *head = (list_entry_t*) mm->sm_priv;
    // 获取该页面的链表节点
    list_entry_t *entry = &(page->pra_page_link);
    // 确保entry和head不为空
    assert(entry != NULL && head != NULL);
    // 将该页面的链表节点添加到LRU链表的头部
    list_add((list_entry_t*) mm->sm_priv, entry);
    // 成功执行，返回0
    return 0;
}

static int
_LRU_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page, int in_tick)
{
    // 获取LRU链表的头节点
    list_entry_t *head = (list_entry_t*) mm->sm_priv;
    // 确保head不为空
    assert(head != NULL);
    // 确保in_tick为0（意味着当前不是在时钟中断中执行）
    assert(in_tick == 0);
    // 获取LRU链表的前一个元素（即最久未使用的页面）
    list_entry_t* entry = list_prev(head);
    // 如果链表中有元素（entry != head），则执行页面交换
    if (entry != head) {
        // 从链表中删除该元素
        list_del(entry);
        // 将ptr_page指向该页面结构体
        *ptr_page = le2page(entry, pra_page_link);
    } else {
        // 如果链表为空，则将ptr_page置为NULL
        *ptr_page = NULL;
    }
    // 成功执行，返回0
    return 0;
}

static int
_LRU_check_swap(void) 
{
    cprintf("write Virt Page c in LRU_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==4);
    cprintf("write Virt Page a in LRU_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==4);
    cprintf("write Virt Page d in LRU_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==4);
    cprintf("write Virt Page b in LRU_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==4);
    cprintf("write Virt Page e in LRU_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==5);
    cprintf("write Virt Page b in LRU_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==5);
    cprintf("write Virt Page a in LRU_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==6);
    cprintf("write Virt Page b in LRU_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==7);
    cprintf("write Virt Page c in LRU_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==8);
    cprintf("write Virt Page d in LRU_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==9);
    cprintf("write Virt Page e in LRU_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==10);
    cprintf("write Virt Page a in LRU_check_swap\n");
    assert(*(unsigned char *)0x1000 == 0x0a);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==11);
    return 0;
}

static int
_LRU_init(void)
{
    return 0;
}

static int
_LRU_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}

static int
_LRU_tick_event(struct mm_struct *mm)
{ return 0; }

struct swap_manager swap_manager_LRU =
{
     .name            = "LRU swap manager",
     .init            = &_LRU_init,
     .init_mm         = &_LRU_init_mm,
     .tick_event      = &_LRU_tick_event,
     .map_swappable   = &_LRU_map_swappable,
     .set_unswappable = &_LRU_set_unswappable,
     .swap_out_victim = &_LRU_swap_out_victim,
     .check_swap      = &_LRU_check_swap,
};