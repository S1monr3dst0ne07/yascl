

use "lib/chunk.yap"
use "lib/bool.yap"

use "src/lex.yap"
use "src/ast/fndef.yap"


seq Ast::Prog
{
    FNS,
}




fn Ast::Prog::Parse(stream, ctx)
{
    put fns = Chunk::New(Ast::Prog);

    lab loop;
        jump done ~ (Lex::Has(stream) ^ Bool::TRUE);
        put content = Lex::Peek(stream);

        jump fn  ~ Str::Diff(content, "fn")  == 0;
        jump seq ~ Str::Diff(content, "seq") == 0;
        jump use ~ Str::Diff(content, "use") == 0;

    
    lab fn;
        put node = Ast::FnDef::Parse(stream, ctx);
        Dyn::Push(fns, node);
        jump loop;

    lab seq;
        Ast::Prog::ParseSeq(stream, ctx);
        jump loop;

    lab use;
        Lex::Expect(stream, "use");
        put path = Lex::PopCheck(stream, Lex::Kind::DOUBLE_QUOTE);

        
        put path_pool = ctx.GlobalCtx::PATHS;
        put present = HT::Get(path_pool, path);
        jump loop ~ present;

        print("using: %s\n", [path]);

        HT::Set(path_pool, path, Bool::TRUE);
        //put subprog = Ast::Prog::File(path, ctx);
        //Dyn::Merge(fns, subprog.Ast::Prog::FNS);

        // functions are taken by self.
        //Chunk::Void(subprog);
        jump loop;
        
    lab done;  

}


fn Ast::Prog::File(path, ctx)
{
    put stream = Lex::Tokenize(path);
    return Ast::Prog::Parse(stream, ctx);
}


fn Ast::Prog::ParseSeq(stream, ctx)
{
    print("!!! TODO !!! implement Ast::Prog::ParseSeq\n");
}


