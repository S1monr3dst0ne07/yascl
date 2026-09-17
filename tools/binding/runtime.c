#include <asm/unistd.h>

#define offsetof(TYPE, MEMBER) __builtin_offsetof (TYPE, MEMBER)

void outchar(char c)
{
    asm volatile(
        "syscall"
        : : "a"(__NR_write), "D"(1), "S"(&c), "d"(1)
        : "rcx", "r11", "memory"
    );
}

void print(long long number)
    // print as hexadecimal
{
    const char digits[16] = "0123456789abcdef";

    int i = 16;
    while (i--)
        outchar(digits[(number >> (i * 4)) & 0xf]);

    outchar('\n');
}

