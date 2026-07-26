
// FASM backend templating
use "src/ctx.yap"

fn Tmpl::Header(ctx)
{
    Ctx::Emit(ctx, "format ELF64 executable");
    Ctx::Emit(ctx, "entry start");
    Ctx::Emit(ctx, "segment readable executable");
    Ctx::Emit(ctx, "start:");
    Ctx::Emit(ctx, "call main");
    Ctx::Emit(ctx, "mov rdi, rax");
    Ctx::Emit(ctx, "mov rax, 60");
    Ctx::Emit(ctx, "syscall");
}


fn Tmpl::Finalize(ctx)
{
    // concurrent local variables
    put VAR_COUNT = 100;

    Ctx::Emit(ctx, "segment writeable readable");
    Ctx::Emit(ctx, "vars: \n\trq %d", [VAR_COUNT]);


}
