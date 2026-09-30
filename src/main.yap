

use "lib/debug.yap"
use "lib/chunk.yap"
use "lib/args.yap"

use "src/lex.yap"
use "src/ctx.yap"
use "src/error.yap"
use "src/ast/prog.yap"



fn main(argc, argv)
{
    jump path_good ~ argc > 2;
        Error::PrintError("Too few paths provided.\n   Usage: ./compiler <source-path> <exec-path>");
    lab path_good;

    put ctx = Ctx::MakeGlobal();
    put src_path = Args::Read(argv.1);
    put out_path = Args::Read(argv.2);

    put root = Ast::Prog::File(src_path, ctx);
    Ast::Prog::Resolve(root, ctx);
    
    Ast::Prog::Compile(root, ctx);
    Ctx::LinkGlobal(ctx);
    IR::Asm(ctx);

    print("Compilation successful\n");

    Ctx::Output(ctx, out_path);

    //dump_ht("consts.txt", "%s: %d\n", ctx.Ctx::Global::CONSTS);
    //dump_heap("core");
}



