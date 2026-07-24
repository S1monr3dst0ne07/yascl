

use "lib/ht.yap"
use "lib/dyn.yap"


seq Ctx::Global
{
    OUTPUT,
    PATHS,
    CONSTS
}



fn Ctx::MakeGlobal()
{
    
    put ctx = Chunk::New(Ctx::Global);
    put ctx.Ctx::Global::PATHS  = HT::Create();
    put ctx.Ctx::Global::CONSTS = HT::Create();
    put ctx.Ctx::Global::OUTPUT = Dyn::Create();
    return ctx;    
}


fn Ctx::Emit(ctx, pattern, args)
{
    static 4096 ~ buffer;
    Str::Format(buffer, pattern, args);

    Dyn::Push(
        ctx.Ctx::Global::OUTPUT,
        Str::Copy(buffer),
    );
}





