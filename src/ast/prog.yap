

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
    put fns = Dyn::Create();

    lab loop;
        jump done ~ Lex::Done(stream);
        put content = Lex::Peek(stream);

        jump fn  ~ Str::Diff(content, "fn")  == 0;
        jump seq ~ Str::Diff(content, "seq") == 0;
        jump use ~ Str::Diff(content, "use") == 0;

        Error::Error("Invalid toplevel prefix: %s\n", [content]);

    
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

    put meta = Chunk::New(Ast::Prog);
    put meta.Ast::Prog::FNS = fns;
    return meta;
}


fn Ast::Prog::File(path, ctx)
{
    put stream = Lex::Tokenize(path);
    return Ast::Prog::Parse(stream, ctx);
}


fn Ast::Prog::ParseSeq(stream, ctx)
{
    Lex::Expect(stream, "seq");
    put name = Lex::PopCheck(stream, Lex::Kind::IDEN);
    Lex::Expect(stream, "{");

    lab loop;
        jump done ~ (Lex::Peek(stream).0) == '}';
        put field = Lex::PopCheck(stream, Lex::Kind::IDEN);

        jump skip_assign ~ (Lex::Peek(stream).0) != '=';
            Lex::Expect(stream, "=");
            put i = Str::ToInt(Lex::Pop(stream));
        lab skip_assign;

        
        jump loop ~ (Lex::Peek(stream).0) != ',';
        Lex::Expect(stream, ",");
        jump loop;
    lab done;


    Lex::Expect(stream, "}");
}


