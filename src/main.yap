

use "lib/debug.yap"
use "lib/chunk.yap"
use "lib/args.yap"

use "src/lex.yap"
use "src/ctx.yap"
use "src/tmpl.yap"
use "src/error.yap"
use "src/ast/prog.yap"



fn main(argc, argv)
{
    print("argc: %d\n", [argc]);
    jump path_good ~ argc > 1;
        Error::Error("Not source path provided.\n");
    lab path_good;

    put ctx = Ctx::MakeGlobal();
    put path = Args::Read(argv.1);

    Dyn::Recap(ctx.Ctx::Global::OUTPUT, 2048);

    put root = Ast::Prog::File(path, ctx);
    Ast::Prog::Resolve(root, ctx);
    
    Tmpl::Header(ctx);
    Ast::Prog::Compile(root, ctx);
    Tmpl::Finalize(ctx);

    print("Compilation successful\n");
    Ctx::Write(ctx, "build.asm");

    Chunk::Void(path);
}



