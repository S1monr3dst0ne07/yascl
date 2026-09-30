

use "lib/debug.yap"
use "lib/chunk.yap"
use "lib/args.yap"

use "src/lex.yap"
use "src/ctx.yap"
use "src/error.yap"
use "src/ast/prog.yap"



fn main(argc, argv)
{
    jump path_good ~ argc > 1;
        Error::PrintError("No source path provided\n   Usage: ./compiler <source-path>");
    lab path_good;

    put ctx = Ctx::MakeGlobal();
    put path = Args::Read(argv.1);

    put root = Ast::Prog::File(path, ctx);
    Ast::Prog::Resolve(root, ctx);
    
    Ast::Prog::Compile(root, ctx);
    Ctx::LinkGlobal(ctx);
    IR::Asm(ctx);

    print("Compilation successful\n");

    put output = ctx.Ctx::Global::OUTPUT;
    put fd = FS::Sys::Open("raw.out", 
        FS::Mode::WRONLY |
        FS::Mode::CREATE |
        FS::Mode::TRUNC
    );
    put file = Chunk::New(Dyn::Size(output));
    Mem::ToBytes(file, Dyn::Ptr(output), Dyn::Size(output));
    Sys::TryCall(
        "output",
        SYSCALL::WRITE,
        fd,
        file,
        Dyn::Size(output),
    );


    //dump_ht("consts.txt", "%s: %d\n", ctx.Ctx::Global::CONSTS);
    //dump_heap("core");
}



