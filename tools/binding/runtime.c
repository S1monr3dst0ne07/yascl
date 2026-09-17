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
    long long offset = 64;

    outchar('0');
    outchar('x');
    while (offset)
    {
        offset -= 4;
        outchar(digits[number & (0b1111 << offset)]);
    }
    outchar('\n');
}

