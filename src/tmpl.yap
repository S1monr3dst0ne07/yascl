
// elf64 header tables
use "src/ctx.yap"
use "src/ir.yap"


seq Tmpl::Config
{
    HEADER_SIZE = 120,   // 0x78 = header + program
    LOAD_ADDR   = 4194304, // 0x400000
}

fn Tmpl::Header(ctx)
{
    // --- ELF header table ---
    IR::Push8(ctx, 127); // MAGIC
    IR::Push8(ctx, 'E');
    IR::Push8(ctx, 'L');
    IR::Push8(ctx, 'F');

    IR::Push8(ctx, 2); // 64-bit format
    IR::Push8(ctx, 1); // little endian

    IR::Push8(ctx, 1); // elf version 1 (still waiting for elf 2)
    IR::Push8(ctx, 0); // ABI System V
    IR::Push8(ctx, 0); // ABI Version 0

    // PADDING!!!!!
    // a hole 7 bytes >;3
    IR::Push8(ctx, 0);
    IR::Push8(ctx, 0);
    IR::Push8(ctx, 0);
    IR::Push8(ctx, 0);
    IR::Push8(ctx, 0);
    IR::Push8(ctx, 0);
    IR::Push8(ctx, 0);

    IR::Push16(ctx, 2); // ET_EXEC
    IR::Push16(ctx, 62); // x86
    IR::Push32(ctx, 1); // just 1

    put entry = Tmpl::Config::HEADER_SIZE + Tmpl::Config::LOAD_ADDR;
    IR::Push64(ctx, entry); // entry address = 0x400078
    IR::Push64(ctx, 64); // phoff bytes
    IR::Push64(ctx, 0);  // shoff bytes
    IR::Push32(ctx, 0);  // flags = 0x0
    IR::Push16(ctx, 64); // size of this header

    IR::Push16(ctx, 56); // size of program header
    IR::Push16(ctx, 1);  // number of program headers
    IR::Push16(ctx, 0);  // size of section header
    IR::Push16(ctx, 0);  // number of section headers

    IR::Push16(ctx, 0);  // section header string table index (i have no idea what this means)

    
    // --- ELF program table ---
    IR::Push32(ctx, 1); // PT_LOAD
    IR::Push32(ctx, 7); // PF_X | PF_W | PF_R
    IR::Push64(ctx, 0); // segment offset
    IR::Push64(ctx, Tmpl::Config::LOAD_ADDR); // vaddr
    IR::Push64(ctx, Tmpl::Config::LOAD_ADDR); // paddr (doesn't matter)

    // need to be patched
    put ctx.Ctx::Global::PATCH_FILE_SIZE = IR::Addr(ctx);
    IR::Push64(ctx, 0);  // file size
    put ctx.Ctx::Global::PATCH_MEM_SIZE  = IR::Addr(ctx);
    IR::Push64(ctx, 0);  // mem  size

    IR::Push64(ctx, 4096); // align to page size
    
    // --- call stub ---

    // make sure processes parameters are accessible to main.
    // System V ABI, section 3.4 process init
    // (https://web.archive.org/web/20160706074221/http://www.x86-64.org/documentation/abi.pdf)

    // mov rax, [rsp]
    // mov rdi, [rsp+8]
    IR::Push8(ctx, 72); IR::Push8(ctx, 139); IR::Push8(ctx,   4); IR::Push8(ctx, 36);
    IR::Push8(ctx, 72); IR::Push8(ctx, 141); IR::Push8(ctx, 124); IR::Push8(ctx, 36); IR::Push8(ctx, 8);

    // mov rbx, main (needs to be patched)
    IR::PushREXW(ctx);
    IR::Push8(ctx, 187); // B8 + 3 (3 -> rbx)
    put ctx.Ctx::Global::PATCH_MAIN = IR::Addr(ctx);
    IR::Push64(ctx, 0);
    // call *rbx
    IR::Push8(ctx, 255);
    IR::Push8(ctx, 211);

    // mov rdi, rax
    // mov rax, 60
    // syscall
    IR::PushREXW(ctx); IR::Push8(ctx, 137); IR::Push8(ctx, 199);
    IR::PushREXW(ctx); IR::Push8(ctx, 199); IR::Push8(ctx, 192); IR::Push32(ctx, 60);
    IR::Push8(ctx, 15); IR::Push8(ctx, 5);

}


fn Tmpl::Finalize(ctx)
{
    put segment_size = IR::Addr(ctx);
    IR::Patch64(ctx, ctx.Ctx::Global::PATCH_MEM_SIZE,  segment_size);
    IR::Patch64(ctx, ctx.Ctx::Global::PATCH_FILE_SIZE, segment_size);

    put main_node = HT::Get(ctx.Ctx::Global::DEF_TABLE, "main");
    put main_addr = main_node.IR::Node::ADDR; // must be REF node.
    IR::Patch64(ctx, ctx.Ctx::Global::PATCH_MAIN, main_addr);
}

