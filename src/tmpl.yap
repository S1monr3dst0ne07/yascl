
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

    // emit strings
    put it = HT::MakeIter(ctx.Ctx::Global::STRINGS);
    lab string_loop;
        jump string_done ~ Bool::TRUE ^ HT::Next(it);
        put label = it.HT::Iter::KEY;
        put string = it.HT::Iter::VALUE;

        Ctx::Emit(ctx, "%s:", [label]);
        
        put i = 0;
        lab string_emit_loop;
            put char = string.i;
            put i = i + 1;

            jump string_emit_done ~ char == '\0';
            Ctx::Emit(ctx, "\tdq %d", [char]);
            jump string_emit_loop;
        lab string_emit_done;

        Ctx::Emit(ctx, "\tdq 0");

        jump string_loop;
    lab string_done;

    // emit static buffers
    put it = HT::MakeIter(ctx.Ctx::Global::STATICS);
    lab static_loop;
        jump static_done ~ Bool::TRUE ^ HT::Next(it);
        put label = it.HT::Iter::KEY;
        put words = it.HT::Iter::VALUE;

        Ctx::Emit(ctx, "%s: rq %d", [label, words]);
        jump static_loop;
    lab static_done;

    // heap base
    Ctx::Emit(ctx, "__heap_base: dq 10000000 dup(0)");

}
