

use "lib/debug.yap"
use "lib/chunk.yap"

use "src/lex.yap"
use "src/ctx.yap"
use "src/ast/prog.yap"



fn main()
{
    put ctx = Ctx::MakeGlobal();
    put path = "src/main.yap";

    put root = Ast::Prog::File(path, ctx);
    
    put it = HT::MakeIter(ctx.Ctx::Global::CONSTS);
    lab loop;
        jump done ~ 1 ^ HT::Next(it);

        print("%s : %d\n", [it.HT::Iter::KEY, it.HT::Iter::VALUE]);
        jump loop;
    lab done;



}



