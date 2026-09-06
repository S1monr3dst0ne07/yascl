

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
    jump path_good ~ argc > 1;
        Error::Error("No source path provided.\n");
    lab path_good;

    put ctx = Ctx::MakeGlobal();
    put path = Args::Read(argv.1);

    put root = Ast::Prog::File(path, ctx);
    Ast::Prog::Resolve(root, ctx);
    
    Tmpl::Header(ctx);
    Ast::Prog::Compile(root, ctx);
    Tmpl::Finalize(ctx);

    print("Compilation successful\n");
    Ctx::Write(ctx, "build.asm");

    //dump_ht("consts.txt", "%s: %d\n", ctx.Ctx::Global::CONSTS);

    Chunk::Void(path);
    Ctx::VoidGlobal(ctx);
    Ast::Prog::Void(root);

    //dump_heap("core");
}



