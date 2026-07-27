

use "lib/debug.yap"
use "lib/chunk.yap"

use "src/lex.yap"
use "src/ctx.yap"
use "src/tmpl.yap"
use "src/ast/prog.yap"






fn main()
{
    put ctx = Ctx::MakeGlobal();
    put path = "src/main.yap";

    Dyn::Recap(ctx.Ctx::Global::OUTPUT, 2048);

    put root = Ast::Prog::File(path, ctx);
    Ast::Prog::Resolve(root, ctx);
    
    Tmpl::Header(ctx);
    Ast::Prog::Compile(root, ctx);
    Tmpl::Finalize(ctx);

    print("Compilation successful\n");
    Ctx::Write(ctx, "subbuild.asm");

}



