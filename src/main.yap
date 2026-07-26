

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

    put root = Ast::Prog::File(path, ctx);
    Ast::Prog::Resolve(root, ctx);
    
    Tmpl::Header(ctx);
    Ast::Prog::Compile(root, ctx);
    
    Ctx::Write(ctx, "subbuild.asm");

}



