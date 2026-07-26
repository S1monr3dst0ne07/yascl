


seq Config
{
    WORD_SIZE = 8, // 8 bytes => 64-bit compiler
}


fn Config::ABI()
    // ABI is shared is the linux x86_64 syscalls,
    // to reduce syscall overhead. (and because im lazy :3)
{
    return [
        "rax",
        "rdi",
        "rsi",
        "rdx",
        "r10",
        "r8",
        "r9",
    ];
}


