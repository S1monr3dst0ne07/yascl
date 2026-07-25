

use "lib/debug.yap"
use "lib/chunk.yap"

use "src/lex.yap"
use "src/ctx.yap"
use "src/ast/prog.yap"



fn main()
{
    put ctx = Ctx::MakeGlobal();
    put path = "src/main.yap";

    print("--- parsing ---\n");
    put root = Ast::Prog::File(path, ctx);
    print("--- resolving ---\n");
    Ast::Prog::Resolve(root, ctx);
    


}



