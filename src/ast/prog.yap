

use "lib/chunk.yap"
use "lib/bool.yap"
use "lib/ht.yap"

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

        put token = Lex::PeekTok(stream);
        Error::LexError(
            token.Lex::Token::INFO,
            "Invalid toplevel prefix: %s\n", [content],
        );

    
    lab fn;
        put node = Ast::FnDef::Parse(stream);
        Dyn::Push(fns, node);
        jump loop;

    lab seq;
        Ast::Prog::ParseSeq(stream, ctx);
        jump loop;

    lab use;
        Lex::Expect(stream, "use");
        put path_token = Lex::PopCheck(stream, Lex::Kind::DOUBLE_QUOTE);
        put path = Str::Copy(path_token);
        
        put path_pool = ctx.Ctx::Global::PATHS;
        jump loop ~ HT::Has(path_pool, path);

        print("using: %s\n", [path]);

        HT::Set(path_pool, path, Bool::TRUE);
        put subprog = Ast::Prog::File(path, ctx);
        Dyn::Merge(fns, subprog.Ast::Prog::FNS);

        // functions are taken by self.
        Dyn::Void(subprog.Ast::Prog::FNS);
        Chunk::Void(subprog);
        jump loop;
        
    lab done;  

    put meta = Chunk::New(Ast::Prog);
    put meta.Ast::Prog::FNS = fns;
    return meta;
}

fn Ast::Prog::CheckFile(path)
{
    static FS::Struct::Stat ~ stat;
    put status = syscall(
        SYSCALL::STAT, 
        FS::ConvertPath(path), 
        stat,
    );

    jump good ~ Bool::Not(Sys::Error(status));
    put error = 0 - status;

    jump no_such_path ~ error == Sys::Errno::ENOENT;
    jump generic_error;

lab no_such_path;
    Error::PrintError("No such path or filename: `%s`", [path]);
lab generic_error;
    Error::PrintError(
        "Unable to stat path `%s`: %s", [
        path,
        Sys::ErrorMsg(status),
    ]);
lab not_readable;
    Error::PrintError("No file `%s` is not readable", [path]);

lab good;
    put mode = (stat + FS::Struct::Stat::MODE).0;
    jump not_readable ~ (mode & (1 << 8)) == 0;
}

fn Ast::Prog::File(path, ctx)
{
    Ast::Prog::CheckFile(path);

    put stream = Lex::Tokenize(path);
    put root = Ast::Prog::Parse(stream, ctx);

    Lex::VoidStream(stream);
    return root;
}


fn Ast::Prog::ParseSeq(stream, ctx)
{
    Lex::Expect(stream, "seq");
    put name = Lex::PopCheck(stream, Lex::Kind::IDEN);
    Lex::Expect(stream, "{");

    static 4096 ~ iden;

    put i = 0;
    lab loop;
        jump done ~ (Lex::Peek(stream).0) == '}';
        put field = Lex::PopCheck(stream, Lex::Kind::IDEN);

        jump skip_assign ~ (Lex::Peek(stream).0) != '=';
            Lex::Expect(stream, "=");
            put i = Str::ToInt(Lex::Pop(stream));
        lab skip_assign;

        Str::Format(iden, "%s::%s", [name, field]);
        HT::Set(ctx.Ctx::Global::CONSTS, iden, i);
        put i = i + 1;
        
        jump loop ~ (Lex::Peek(stream).0) != ',';
        Lex::Expect(stream, ",");
        jump loop;
    lab done;

    // length of sequence
    HT::Set(ctx.Ctx::Global::CONSTS, name, i);

    Lex::Expect(stream, "}");
}


fn Ast::Prog::Resolve(node, ctx)
{
    put fns = node.Ast::Prog::FNS;

    put i = 0;
    lab loop;
        put func = Dyn::Ptr(fns).i;
        Ast::FnDef::Resolve(func, ctx);
        put i = i + 1;
    jump loop ~ i < Dyn::Size(fns);
}


fn Ast::Prog::Compile(node, ctx)
{
    put fns = node.Ast::Prog::FNS;

    put i = 0;
    lab loop;
        put func = Dyn::Ptr(fns).i;
        Ast::FnDef::Compile(func, ctx);
        put i = i + 1;
    jump loop ~ i < Dyn::Size(fns);
}

fn Ast::Prog::Void(node)
{
    put fns = node.Ast::Prog::FNS;

    put i = 0;
    lab loop;
        jump done ~ i == Dyn::Size(fns);
        put func = Dyn::Ptr(fns).i;
        put i = i + 1;

        Ast::FnDef::Void(func);

        jump loop;
    lab done;

    Dyn::Void(fns);
    Chunk::Void(node);
}


