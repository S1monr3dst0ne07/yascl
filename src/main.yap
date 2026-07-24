

use "lib/debug.yap"
use "lib/chunk.yap"
use "lib/ht.yap"

use "src/lex.yap"
use "src/ast/prog.yap"


seq GlobalCtx
{
    PATHS,
}


fn main()
{
    put ctx = Chunk::New(GlobalCtx);
    put ctx.GlobalCtx::PATHS = HT::Create();

    put path = "src/main.yap";

    put root = Ast::Prog::File(path, ctx);



}



