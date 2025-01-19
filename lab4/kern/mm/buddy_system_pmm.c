#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_system_pmm.h>
#include <stdio.h>

#define MAX_ORDER 15 // 设定最大块的阶数，总页数为32256约为2^15
#define MAX_SIZE (1 << MAX_ORDER) // 实际情况可能不需要这么大，这里防止出错

// 静态内存区域，用于 buddy 系统管理
static unsigned buddy_longest[2 * MAX_SIZE - 1];
static unsigned buddy_size;

extern free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

#define LEFT_LEAF(index) ((index) * 2 + 1)
#define RIGHT_LEAF(index) ((index) * 2 + 2)
#define PARENT(index) (((index) - 1) / 2)

#define IS_POWER_OF_2(x) (((x) & ((x) - 1)) == 0)
#define MAX(a,b) ((a) > (b) ? (a) : (b))

// 向上补齐到2的幂次
unsigned int next_power_of_2(unsigned int v) {
    if (v == 0) return 1;
    v--;
    v |= v >> 1;
    v |= v >> 2;
    v |= v >> 4;
    v |= v >> 8;
    v |= v >> 16;
    return v + 1;
}

void buddy2_init(unsigned size) {
    unsigned node_size;
    int i;

    if (!IS_POWER_OF_2(size)) size = next_power_of_2(size);

    cprintf("length = %d\n", size);

    buddy_size = size;
    node_size = size * 2;

    for (i = 0; i < 2 * size - 1; ++i) {
        if (IS_POWER_OF_2(i + 1))
            node_size /= 2;
        buddy_longest[i] = node_size;
    }
}

int buddy2_alloc(unsigned size) {
    unsigned index = 0;
    unsigned node_size;
    unsigned offset = 0;

    if (size <= 0)
        size = 1;
    else if (!IS_POWER_OF_2(size)) {
        size = next_power_of_2(size);
    }

    if (buddy_longest[index] < size)
        return -1;

    for (node_size = buddy_size; node_size != size; node_size /= 2) {
        if (buddy_longest[LEFT_LEAF(index)] >= size)
            index = LEFT_LEAF(index);
        else
            index = RIGHT_LEAF(index);
    }

    buddy_longest[index] = 0;
    offset = (index + 1) * node_size - buddy_size;

    while (index) {
        index = PARENT(index);
        buddy_longest[index] = MAX(buddy_longest[LEFT_LEAF(index)], buddy_longest[RIGHT_LEAF(index)]);
    }

    return offset;
}

void buddy2_free(unsigned offset) {
    unsigned node_size, index = 0;
    unsigned left_longest, right_longest;

    assert(offset < buddy_size);

    node_size = 1;
    index = offset + buddy_size - 1;

    for (; buddy_longest[index]; index = PARENT(index)) {
        node_size *= 2;
        if (index == 0)
            return;
    }

    buddy_longest[index] = node_size;

    while (index) {
        index = PARENT(index);
        node_size *= 2;

        left_longest = buddy_longest[LEFT_LEAF(index)];
        right_longest = buddy_longest[RIGHT_LEAF(index)];

        if (left_longest + right_longest == node_size)
            buddy_longest[index] = node_size;
        else
            buddy_longest[index] = MAX(left_longest, right_longest);
    }
}

static void
buddy_system_init(void) {
    list_init(&free_list);
    nr_free = 0;
}

static void
buddy_system_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    buddy2_init(n);
    cprintf("length = %d\n", n);
    
    struct Page* p = base;
    for (; p != base + n; p++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }

    base->property = n;
    SetPageProperty(base);

    nr_free += n;
    if (list_empty(&free_list))
        list_add(&free_list, &(base->page_link));
}

static struct Page *
buddy_system_alloc_pages(size_t n) {
    assert(n > 0);
    size_t offset = buddy2_alloc(n);
    if (offset == -1) return NULL; // 分配失败

    list_entry_t *le = &free_list;
    le = list_next(le);
    struct Page *page = le2page(le, page_link);
    page = page + offset;
    return page;
}

static void
buddy_system_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    // 检查 base 是否为 NULL
    if (base == NULL) {
        return; // 如果为 NULL，直接返回
    }
    list_entry_t *le = &free_list;
    le = list_next(le);
    struct Page *page = le2page(le, page_link);
    size_t offset = base - page; // 计算偏移量
    buddy2_free(offset);
}

static size_t
buddy_system_max_alloc() {
    return buddy_longest[0];  // 根节点的值代表最大可用块
}

static void
basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    assert(alloc_page() == NULL);

    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(nr_free == 3);

    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(alloc_page() == NULL);

    free_page(p0);
    assert(!list_empty(&free_list));

    struct Page *p;
    assert((p = alloc_page()) == p0);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    free_list = free_list_store;
    nr_free = nr_free_store;

    free_page(p);
    free_page(p1);
    free_page(p2);
}

// 检查函数
static void buddy_system_check() {
    cprintf("开始 buddy system 测试...\n");

    // 测试1: 全内存分配和释放
    struct Page* p_all = buddy_system_alloc_pages(32768);
    if (p_all == NULL) {
        cprintf("测试1: 全内存分配测试失败！\n");
        return;
    } else {
        cprintf("测试1: 全内存分配测试通过!\n");
    }
    buddy_system_free_pages(p_all, 32768);

    // 测试2: 边界条件测试，超过总内存大小分配应失败
    struct Page* p_alll = buddy_system_alloc_pages(32769);
    if (p_alll == NULL) {
        cprintf("测试2: 边界条件测试通过！\n");
    } else {
        cprintf("测试2: 边界条件测试失败！\n");
        return;
    }
    buddy_system_free_pages(p_alll, 32769);

    // 测试3：连续分配测试，分配p3时会失败
    struct Page* p1 = buddy_system_alloc_pages(16000);
    unsigned n1 = buddy_system_max_alloc();
    cprintf("max_alloc = %d\n", n1);
    struct Page* p2 = buddy_system_alloc_pages(6000);
    unsigned n2 = buddy_system_max_alloc();
    cprintf("max_alloc = %d\n", n2);
    struct Page* p3 = buddy_system_alloc_pages(9000);
    unsigned n3 = buddy_system_max_alloc();
    cprintf("max_alloc = %d\n", n3);
    if (p1 == NULL || p2 == NULL || p3 == NULL) {
        cprintf("测试3: 连续分配测试通过！\n");
    } else {
        cprintf("测试3: 连续分配测试失败! \n");
        return;
    }
    buddy_system_free_pages(p1, 16000);
    buddy_system_free_pages(p2, 6000);
    buddy_system_free_pages(p3, 9000);
    unsigned n = buddy_system_max_alloc();
    cprintf("max_alloc = %d\n", n);
    
    // 测试4：连续分配测试，分配成功
    struct Page* p4 = buddy_system_alloc_pages(16000);
    unsigned n4 = buddy_system_max_alloc();
    cprintf("max_alloc = %d\n", n4);
    struct Page* p5 = buddy_system_alloc_pages(6000);
    unsigned n5 = buddy_system_max_alloc();
    cprintf("max_alloc = %d\n", n5);
    struct Page* p6 = buddy_system_alloc_pages(8000);
    unsigned n6 = buddy_system_max_alloc();
    cprintf("max_alloc = %d\n", n6);
    if (p4 == NULL || p5 == NULL || p6 == NULL) {
        cprintf("测试4: 连续分配测试失败！\n");
        return;
    } else {
        cprintf("测试4: 连续分配测试通过! \n");
    } 
    buddy_system_free_pages(p4, 16000);
    unsigned n44 = buddy_system_max_alloc();
    cprintf("max_alloc = %d\n", n44);
    buddy_system_free_pages(p5, 6000);
    unsigned n55 = buddy_system_max_alloc();
    cprintf("max_alloc = %d\n", n55);
    buddy_system_free_pages(p6, 8000);
    unsigned n66 = buddy_system_max_alloc();
    cprintf("max_alloc = %d\n", n66);

    // 测试5: 分配之后释放合并
    struct Page* p_again = buddy_system_alloc_pages(32768);
    if (p_again == NULL) {
        cprintf("测试5: 释放合并测试失败！\n");
        return;
    } else {
        cprintf("测试5: 释放合并测试通过!\n");
    }
    buddy_system_free_pages(p_again, 32768);

    // // 测试5：合并
    // struct Page* p16_1 = buddy_system_alloc_pages(16000);
    // struct Page* p16_2 = buddy_system_alloc_pages(16000);
    // if (p16_1 == NULL || p16_2 == NULL) {
    //     cprintf("合并测试失败！\n");
    //     return;
    // }

    // buddy_system_free_pages(p16_1, 16);
    // buddy_system_free_pages(p16_2, 16);

    // // 现在，如果合并正确，应该可以分配一个 32 页的块
    // struct Page* p32_again = buddy_system_alloc_pages(32);
    // if (p32_again == NULL) {
    //     cprintf("块合并测试失败！\n");
    //     return;
    // }
    // cprintf("块合并测试通过...\n");

    cprintf("buddy system 测试完成.\n");
}

//这个结构体在
const struct pmm_manager buddy_system_pmm_manager = {
    .name = "buddy_system_pmm_manager",
    .init = buddy_system_init,
    .init_memmap = buddy_system_init_memmap,
    .alloc_pages = buddy_system_alloc_pages,
    .free_pages =buddy_system_free_pages,
    .nr_free_pages = buddy_system_max_alloc,
    .check = buddy_system_check,
};

// #include <pmm.h>
// #include <list.h>
// #include <string.h>
// #include <buddy_system_pmm.h>
// #include <stdio.h>

// #define MAX_ORDER 15 // 设定最大块的阶数，总页数为32256约为2^15
// #define MAX_SIZE (1 << MAX_ORDER)

// // 静态内存区域，用于 buddy 系统管理
// static unsigned buddy_longest[2 * MAX_SIZE - 1];
// static unsigned buddy_size;

// extern free_area_t free_area;

// #define free_list (free_area.free_list)
// #define nr_free (free_area.nr_free)

// #define LEFT_LEAF(index) ((index) * 2 + 1)
// #define RIGHT_LEAF(index) ((index) * 2 + 2)
// #define PARENT(index) (((index) - 1) / 2)

// #define IS_POWER_OF_2(x) (((x) & ((x) - 1)) == 0)
// #define MAX(a,b) ((a) > (b) ? (a) : (b))

// // 向上补齐到2的幂次
// unsigned int next_power_of_2(unsigned int v) {
//     if (v == 0) return 1;
//     v--;
//     v |= v >> 1;
//     v |= v >> 2;
//     v |= v >> 4;
//     v |= v >> 8;
//     v |= v >> 16;
//     return v + 1;
// }

// // struct buddy2 {
// //   unsigned size;
// //   unsigned longest[1];
// // };

// // #define ALLOC(size) malloc(size)

// // struct buddy2* buddy2_new(int size) {
// //   struct buddy2* self;
// //   unsigned node_size;
// //   int i;

// //     // 调整 size 为最近的 2 的幂次方
// //   if (size < 1) return NULL;
// //   if (!IS_POWER_OF_2(size)) size = next_power_of_2(size);

// //   self = (struct buddy2*)ALLOC(sizeof(struct buddy2) + (2 * size - 2) * sizeof(unsigned));
// //   self->size = size;
// //   node_size = size * 2;
// //   for (i = 0; i < 2 * size - 1; ++i) {
// //     if (IS_POWER_OF_2(i + 1))
// //       node_size /= 2;
// //     self->longest[i] = node_size;
// //   }
// //   return self;
// // }

// void buddy2_init(unsigned size) {
//     unsigned node_size;
//     int i;

//     if (!IS_POWER_OF_2(size)) size = next_power_of_2(size);

//     cprintf("length = %d\n", size);

//     buddy_size = size;
//     node_size = size * 2;

//     for (i = 0; i < 2 * size - 1; ++i) {
//         if (IS_POWER_OF_2(i + 1))
//             node_size /= 2;
//         buddy_longest[i] = node_size;
//     }
// }

// // int buddy2_alloc(struct buddy2* self, int size) {
// //   unsigned index = 0;
// //   unsigned node_size;
// //   unsigned offset = 0;

// //   if (self == NULL)
// //     return -1;

// //   if (size <= 0)
// //     size = 1;
// //   else if (!IS_POWER_OF_2(size))
// //     size = next_power_of_2(size);

// //   if (self->longest[index] < size)
// //     return -1;

// //   for (node_size = self->size; node_size != size; node_size /= 2) {
// //     if (self->longest[LEFT_LEAF(index)] >= size)
// //       index = LEFT_LEAF(index);
// //     else
// //       index = RIGHT_LEAF(index);
// //   }

// //   self->longest[index] = 0;
// //   offset = (index + 1) * node_size - self->size;

// //   while (index) {
// //     index = PARENT(index);
// //     self->longest[index] = MAX(self->longest[LEFT_LEAF(index)], self->longest[RIGHT_LEAF(index)]);
// //   }

// //   return offset;
// // }

// // void buddy2_free(struct buddy2* self, int offset) {
// //   unsigned node_size, index = 0;
// //   unsigned left_longest, right_longest;

// //   assert(self && offset >= 0 && offset < self->size);

// //   node_size = 1;
// //   index = offset + self->size - 1;

// //   for (; self->longest[index]; index = PARENT(index)) {
// //     node_size *= 2;
// //     if (index == 0)
// //       return;
// //   }

// //   self->longest[index] = node_size;

// //   while (index) {
// //     index = PARENT(index);
// //     node_size *= 2;

// //     left_longest = self->longest[LEFT_LEAF(index)];
// //     right_longest = self->longest[RIGHT_LEAF(index)];

// //     if (left_longest + right_longest == node_size)
// //       self->longest[index] = node_size;
// //     else
// //       self->longest[index] = MAX(left_longest, right_longest);
// //   }
// // }

// int buddy2_alloc(unsigned size) {
//     unsigned index = 0;
//     unsigned node_size;
//     unsigned offset = 0;

//     if (size <= 0)
//         size = 1;
//     else if (!IS_POWER_OF_2(size)) {
//         size = next_power_of_2(size);
//     }

//     if (buddy_longest[index] < size)
//         return -1;

//     for (node_size = buddy_size; node_size != size; node_size /= 2) {
//         if (buddy_longest[LEFT_LEAF(index)] >= size)
//             index = LEFT_LEAF(index);
//         else
//             index = RIGHT_LEAF(index);
//     }

//     buddy_longest[index] = 0;
//     offset = (index + 1) * node_size - buddy_size;

//     while (index) {
//         index = PARENT(index);
//         buddy_longest[index] = MAX(buddy_longest[LEFT_LEAF(index)], buddy_longest[RIGHT_LEAF(index)]);
//     }

//     return offset;
// }

// void buddy2_free(unsigned offset) {
//     unsigned node_size, index = 0;
//     unsigned left_longest, right_longest;

//     assert(offset < buddy_size);

//     node_size = 1;
//     index = offset + buddy_size - 1;

//     for (; buddy_longest[index]; index = PARENT(index)) {
//         node_size *= 2;
//         if (index == 0)
//             return;
//     }

//     buddy_longest[index] = node_size;

//     while (index) {
//         index = PARENT(index);
//         node_size *= 2;

//         left_longest = buddy_longest[LEFT_LEAF(index)];
//         right_longest = buddy_longest[RIGHT_LEAF(index)];

//         if (left_longest + right_longest == node_size)
//             buddy_longest[index] = node_size;
//         else
//             buddy_longest[index] = MAX(left_longest, right_longest);
//     }
// }


// // struct buddy2* buddy_system;

// static void
// buddy_system_init(void) {
//     list_init(&free_list);
//     nr_free = 0;
// }

// static void
// buddy_system_init_memmap(struct Page *base, size_t n) {
//     assert(n > 0);
//     // buddy_system = buddy2_new(n); // 初始化 Buddy System
//     buddy2_init(n);
//     cprintf("length = %d\n", n);
    
//     struct Page* p = base;
//     for (; p != base + n; p++) {
//         assert(PageReserved(p));
//         p->flags = p->property = 0;
//         set_page_ref(p, 0);
//     }

//     base->property = n;
//     SetPageProperty(base);

//     nr_free += n;
//     if (list_empty(&free_list))
//         list_add(&free_list, &(base->page_link));
    
//     // buddy2_free(buddy_system, 0); // 将整个内存块标记为空闲
// }

// static struct Page *
// buddy_system_alloc_pages(size_t n) {
//     assert(n > 0);
//     // size_t offset = buddy2_alloc(buddy_system, n);
//     size_t offset = buddy2_alloc(n);
//     if (offset == -1) return NULL; // 分配失败

//     list_entry_t *le = &free_list;
//     le = list_next(le);
//     struct Page *page = le2page(le, page_link);
//     page = page + offset;
//     return page;
// }

// static void
// buddy_system_free_pages(struct Page *base, size_t n) {
//     assert(n > 0);
//     list_entry_t *le = &free_list;
//     le = list_next(le);
//     struct Page *page = le2page(le, page_link);
//     size_t offset = base - page; // 计算偏移量
//     // buddy2_free(buddy_system, offset);
//     buddy2_free(offset);
// }

// static size_t
// buddy_system_nr_free_pages(void) {
//     return nr_free;
// }

// static void
// basic_check(void) {
//     struct Page *p0, *p1, *p2;
//     p0 = p1 = p2 = NULL;
//     assert((p0 = alloc_page()) != NULL);
//     assert((p1 = alloc_page()) != NULL);
//     assert((p2 = alloc_page()) != NULL);

//     assert(p0 != p1 && p0 != p2 && p1 != p2);
//     assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

//     assert(page2pa(p0) < npage * PGSIZE);
//     assert(page2pa(p1) < npage * PGSIZE);
//     assert(page2pa(p2) < npage * PGSIZE);

//     list_entry_t free_list_store = free_list;
//     list_init(&free_list);
//     assert(list_empty(&free_list));

//     unsigned int nr_free_store = nr_free;
//     nr_free = 0;

//     assert(alloc_page() == NULL);

//     free_page(p0);
//     free_page(p1);
//     free_page(p2);
//     assert(nr_free == 3);

//     assert((p0 = alloc_page()) != NULL);
//     assert((p1 = alloc_page()) != NULL);
//     assert((p2 = alloc_page()) != NULL);

//     assert(alloc_page() == NULL);

//     free_page(p0);
//     assert(!list_empty(&free_list));

//     struct Page *p;
//     assert((p = alloc_page()) == p0);
//     assert(alloc_page() == NULL);

//     assert(nr_free == 0);
//     free_list = free_list_store;
//     nr_free = nr_free_store;

//     free_page(p);
//     free_page(p1);
//     free_page(p2);
// }

// // LAB2: below code is used to check the best fit allocation algorithm 
// // NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
// // static void
// // buddy_system_check(void) {
// //     int score = 0 ,sumscore = 6;
// //     int count = 0, total = 0;
// //     list_entry_t *le = &free_list;
// //     while ((le = list_next(le)) != &free_list) {
// //         struct Page *p = le2page(le, page_link);
// //         assert(PageProperty(p));
// //         count ++, total += p->property;
// //     }
// //     assert(total == nr_free_pages());

// //     basic_check();

// //     #ifdef ucore_test
// //     score += 1;
// //     cprintf("grading: %d / %d points\n",score, sumscore);
// //     #endif
// //     struct Page *p0 = alloc_pages(5), *p1, *p2;
// //     assert(p0 != NULL);
// //     assert(!PageProperty(p0));

// //     #ifdef ucore_test
// //     score += 1;
// //     cprintf("grading: %d / %d points\n",score, sumscore);
// //     #endif
// //     list_entry_t free_list_store = free_list;
// //     list_init(&free_list);
// //     assert(list_empty(&free_list));
// //     assert(alloc_page() == NULL);

// //     #ifdef ucore_test
// //     score += 1;
// //     cprintf("grading: %d / %d points\n",score, sumscore);
// //     #endif
// //     unsigned int nr_free_store = nr_free;
// //     nr_free = 0;

// //     // * - - * -
// //     free_pages(p0 + 1, 2);
// //     free_pages(p0 + 4, 1);
// //     assert(alloc_pages(4) == NULL);
// //     assert(PageProperty(p0 + 1) && p0[1].property == 2);
// //     // * - - * *
// //     assert((p1 = alloc_pages(1)) != NULL);
// //     assert(alloc_pages(2) != NULL);      // best fit feature
// //     assert(p0 + 4 == p1);

// //     #ifdef ucore_test
// //     score += 1;
// //     cprintf("grading: %d / %d points\n",score, sumscore);
// //     #endif
// //     p2 = p0 + 1;
// //     free_pages(p0, 5);
// //     assert((p0 = alloc_pages(5)) != NULL);
// //     assert(alloc_page() == NULL);

// //     #ifdef ucore_test
// //     score += 1;
// //     cprintf("grading: %d / %d points\n",score, sumscore);
// //     #endif
// //     assert(nr_free == 0);
// //     nr_free = nr_free_store;

// //     free_list = free_list_store;
// //     free_pages(p0, 5);

// //     le = &free_list;
// //     while ((le = list_next(le)) != &free_list) {
// //         struct Page *p = le2page(le, page_link);
// //         count --, total -= p->property;
// //     }
// //     assert(count == 0);
// //     assert(total == 0);
// //     #ifdef ucore_test
// //     score += 1;
// //     cprintf("grading: %d / %d points\n",score, sumscore);
// //     #endif
// // }

// // 检查函数
// static void buddy_system_check() {
//     cprintf("开始 buddy system 测试...\n");

//     // 测试5: 全内存分配和释放
//     struct Page* p_all = buddy_system_alloc_pages(32769);
//     if (p_all == NULL) {
//         cprintf("全内存分配测试失败！\n");
//         return;
//     }
//     cprintf("全内存分配测试通过...\n");

//     buddy_system_free_pages(p_all, 32769);

//     // 测试：分配
//     struct Page* p1 = buddy_system_alloc_pages(1);
//     struct Page* p2 = buddy_system_alloc_pages(2);
//     struct Page* p4 = buddy_system_alloc_pages(4);
    
//     if (p1 == NULL || p2 == NULL || p4 == NULL) {
//         cprintf("分配测试失败！\n");
//         return;
//     }
//     cprintf("分配测试通过...\n");

//     // 测试：释放
//     buddy_system_free_pages(p1, 17000);
//     buddy_system_free_pages(p2, 2);
//     buddy_system_free_pages(p4, 4);

//     // 检查释放后是否能重新分配（应该可以成功）
//     struct Page* p1_again = buddy_system_alloc_pages(1);
//     struct Page* p2_again = buddy_system_alloc_pages(2);
//     struct Page* p4_again = buddy_system_alloc_pages(4);

//     if (p1_again == NULL || p2_again == NULL || p4_again == NULL) {
//         cprintf("重新分配测试失败！\n");
//         return;
//     }
//     cprintf("重新分配测试通过...\n");

//     // 测试大型块分配
//     struct Page* p32 = buddy_system_alloc_pages(32);
//     if (p32 == NULL) {
//         cprintf("大型块分配测试失败！\n");
//         return;
//     }
//     cprintf("大型块分配测试通过...\n");

//     buddy_system_free_pages(p32, 32);

//     // 测试合并
//     struct Page* p16_1 = buddy_system_alloc_pages(16);
//     struct Page* p16_2 = buddy_system_alloc_pages(16);
//     if (p16_1 == NULL || p16_2 == NULL) {
//         cprintf("合并测试失败！\n");
//         return;
//     }

//     buddy_system_free_pages(p16_1, 16);
//     buddy_system_free_pages(p16_2, 16);

//     // 现在，如果合并正确，应该可以分配一个 32 页的块
//     struct Page* p32_again = buddy_system_alloc_pages(32);
//     if (p32_again == NULL) {
//         cprintf("块合并测试失败！\n");
//         return;
//     }
//     cprintf("块合并测试通过...\n");

//     cprintf("buddy system 测试完成.\n");
// }

// //这个结构体在
// const struct pmm_manager buddy_system_pmm_manager = {
//     .name = "buddy_system_pmm_manager",
//     .init = buddy_system_init,
//     .init_memmap = buddy_system_init_memmap,
//     .alloc_pages = buddy_system_alloc_pages,
//     .free_pages =buddy_system_free_pages,
//     .nr_free_pages = buddy_system_nr_free_pages,
//     .check = buddy_system_check,
// };