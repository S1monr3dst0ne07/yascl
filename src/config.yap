


seq Config
{
    WORD_SIZE   = 8,   // 8 bytes => 64-bit compiler
    PARAM_LIMIT = 7, // rax, rdi, rsi, rdx, r10, r8, r9, nice
}


fn Config::ABI()
    // system V ABI, function parameters passing registers.
    // calling convention is shared with the linux x86_64 syscalls,
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


