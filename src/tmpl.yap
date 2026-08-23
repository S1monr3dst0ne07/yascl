
// FASM backend templating
use "src/ctx.yap"

fn Tmpl::Header(ctx)
{
    // fasm headers
    Ctx::Emit(ctx, "format ELF64 executable");
    Ctx::Emit(ctx, "entry start");
    Ctx::Emit(ctx, "segment readable executable");

    // program entry point
    Ctx::Emit(ctx, "start:");

    // make sure processes parameters are accessible to main.
    // System V ABI, section 3.4 process init
    // (https://web.archive.org/web/20160706074221/http://www.x86-64.org/documentation/abi.pdf)
    Ctx::Emit(ctx, "mov rax, [rsp]"  ); // argc
    Ctx::Emit(ctx, "lea rdi, [rsp+8]"); // argv

    // call into main function
    Ctx::Emit(ctx, "call main");

    // on return, exit with status code 0
    Ctx::Emit(ctx, "mov rdi, rax");
    Ctx::Emit(ctx, "mov rax, 60");
    Ctx::Emit(ctx, "syscall");
}


fn Tmpl::Finalize(ctx)
{
    Ctx::Emit(ctx, "segment writeable readable");

    // emit strings
    put it = HT::MakeIter(ctx.Ctx::Global::STRINGS);
    lab string_loop;
        jump string_done ~ Bool::Not(HT::Next(it));
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
        jump static_done ~ Bool::Not(HT::Next(it));
        put label = it.HT::Iter::KEY;
        put words = it.HT::Iter::VALUE;

        Ctx::Emit(ctx, "%s: rq %d", [label, words]);
        jump static_loop;
    lab static_done;
}
